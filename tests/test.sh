#!/usr/bin/env bash
# Offline tests: a fake `codex` stands in for the real one (no network, no quota).
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SCRIPT="$ROOT/skills/codex-image/scripts/codex-image.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir "$T/bin"; export HOME="$T/home"; mkdir -p "$HOME"
unset CODEX_BIN CODEX_PLAN CODEX_IMAGE_DIR   # never let the caller's env reach the real Codex
NODE_DIR=$(dirname "$(command -v node)")
export PATH="$T/bin:$NODE_DIR:/usr/bin:/bin:/usr/sbin:/sbin"
export CODEX_IMAGE_DIR="$T/out" FAKE_LOG="$T/fake"

# fake codex: `login status` succeeds; `exec ... -` reads the prompt and writes the PNG it names.
cat > "$T/bin/codex" <<'EOF'
#!/usr/bin/env bash
case $1 in
  login) [ -z "${FAKE_LOGGED_OUT:-}" ] && { echo "Logged in using ChatGPT"; exit 0; } || exit 1;;
  exec) [ -n "${FAKE_REJECT_MODEL:-}" ] && case " $* " in *" -m "*) exit 1;; esac
        p=$(cat); printf '%s\n' "$*" > "$FAKE_LOG.args"; printf '%s' "$p" > "$FAKE_LOG.stdin"
        out=""; prev=""; for a in "$@"; do [ "$prev" = "-o" ] && out=$a; prev=$a; done
        if [ -n "$out" ]; then [ -n "${FAKE_NO_IMAGE:-}" ] || echo "FAKE ANSWER" > "$out"; exit 0; fi
        n=$(printf '%s' "$p" | sed -n 's/.*as \([A-Za-z0-9_-]*\)\.png.*/\1/p' | head -1)
        [ -n "${FAKE_NO_IMAGE:-}" ] || printf 'PNG' > "$PWD/$n.png"; exit 0;;
esac
EOF
chmod +x "$T/bin/codex"

fail=0
t() { # t "name" expected_rc cmd...
  local name=$1 want=$2; shift 2; local rc=0; "$@" >"$T/o" 2>"$T/e" || rc=$?
  if [ "$rc" = "$want" ]; then echo "PASS $name"; else echo "FAIL $name (rc=$rc want=$want)"; cat "$T/e"; fail=1; fi
}

t "generates image"          0 bash "$SCRIPT" "a red apple" apple
[ -s "$T/out/apple.png" ] || { echo "FAIL file missing"; fail=1; }
t "does not overwrite"       0 bash "$SCRIPT" "a red apple" apple
[ "$(ls "$T/out"/apple*.png | wc -l | tr -d ' ')" = 2 ] || { echo "FAIL overwrite protection"; fail=1; }
t "rejects empty prompt"     2 bash "$SCRIPT" ""
t "rejects bad name"         2 bash "$SCRIPT" "x" "../evil"
FAKE_LOGGED_OUT=1 t "not logged in" 4 bash "$SCRIPT" "x" a
FAKE_NO_IMAGE=1   t "no image"      5 bash "$SCRIPT" "x" b
PATH=/usr/bin:/bin t "codex missing" 3 bash "$SCRIPT" "x" c
ASK="$ROOT/shared/codex-ask.sh"
R="$T/repo"; mkdir "$R"; git -C "$R" init -q; git -C "$R" config user.email a@b.c; git -C "$R" config user.name t
echo "one" > "$R/a.txt"; git -C "$R" add a.txt; git -C "$R" commit -q -m init
t "review: nothing to review" 7 bash "$ASK" review -C "$R"
echo "two" >> "$R/a.txt"
t "review: ok"               0 bash "$ASK" review -C "$R" "focus on x"
grep -q "FAKE ANSWER" "$T/o" || { echo "FAIL review output"; fail=1; }
grep -q -- "--sandbox read-only" "$T/fake.args" || { echo "FAIL review not read-only"; fail=1; }
grep -q "+two" "$T/fake.stdin" || { echo "FAIL diff not sent"; fail=1; }
echo "key = 'AKIAABCDEFGHIJKLMNOP'" >> "$R/a.txt"
t "review: blocks secrets"   6 bash "$ASK" review -C "$R"
t "review: allow-secrets"    0 bash "$ASK" review -C "$R" --allow-secrets
t "review: not a repo"       2 bash "$ASK" review -C "$T"
t "review: too large"        8 env CODEX_ASK_MAX_BYTES=10 bash "$ASK" review -C "$R" --allow-secrets
printf 'hello\n' > "$T/note.txt"
t "opinion: ok"              0 bash "$ASK" opinion --file "$T/note.txt" "A or B?"
grep -q "hello" "$T/fake.stdin" || { echo "FAIL file not sent"; fail=1; }
t "opinion: empty question"  2 bash "$ASK" opinion ""
echo "SECRET=1" > "$T/.env"
t "opinion: blocks .env file" 6 bash "$ASK" opinion --file "$T/.env" "x"
t "opinion: secret in text"  6 bash "$ASK" opinion "password = 'hunter2hunter2'"
FAKE_LOGGED_OUT=1 t "ask: not logged in" 4 bash "$ASK" opinion "x"
FAKE_NO_IMAGE=1   t "ask: no answer"     5 bash "$ASK" opinion "x"
# --- models / plans ---
export XDG_CONFIG_HOME="$T/cfg"
m() { grep -q -- "$1" "$T/fake.args" || { echo "FAIL expected '$1' in args: $(cat "$T/fake.args")"; fail=1; }; }
t "model: default has no -m"  0 bash "$ASK" opinion "q"
grep -q -- " -m " "$T/fake.args" && { echo "FAIL default passed -m"; fail=1; }
t "model: explicit default"   0 bash "$ASK" opinion --model Default "q"
grep -q -- " -m " "$T/fake.args" && { echo "FAIL 'Default' passed -m"; fail=1; }
t "model: luna"   0 bash "$ASK" opinion --model luna "q";   m "-m gpt-6-luna"
t "model: Terra (case-insens.)" 0 bash "$ASK" opinion --model Terra "q"; m "-m gpt-6.1-terra"
t "model: sol"    0 bash "$ASK" opinion --model sol "q";    m "-m gpt-6.2-sol"
t "model: astra"  0 bash "$ASK" opinion --model astra "q";  m "-m gpt-6.2-astra"
t "model: raw slug" 0 bash "$ASK" opinion --model gpt-6.1-sol "q"; m "-m gpt-6.1-sol"
CODEX_MODEL_SOL=gpt-9-sol t "model: env override" 0 bash "$ASK" opinion --model sol "q"; m "-m gpt-9-sol"
t "model: bad name"           2 bash "$ASK" opinion --model 'x;rm' "q"
for plan in free go; do
  CODEX_PLAN=$plan t "plan $plan forces luna" 0 bash "$ASK" opinion --model sol "q"; m "-m gpt-6-luna"
  grep -q "gpt-6.2" "$T/fake.args" && { echo "FAIL $plan used paid model"; fail=1; }
  CODEX_PLAN=$plan t "plan $plan default->luna" 0 bash "$ASK" opinion "q"; m "-m gpt-6-luna"
done
t "plan: invalid"             2 env CODEX_PLAN=gold bash "$ASK" opinion "q"
t "plan: show (ask)"          0 env CODEX_PLAN=go bash "$ASK" plan
[ "$(CODEX_PLAN=go bash "$ASK" plan)" = go ] || { echo "FAIL plan output"; fail=1; }
[ "$(bash "$SCRIPT" --show-plan)" = paid ] || { echo "FAIL show-plan default"; fail=1; }
FAKE_REJECT_MODEL=1 t "model rejected -> falls back" 0 bash "$ASK" opinion --model sol "q"
grep -q "FAKE ANSWER" "$T/o" || { echo "FAIL fallback answer"; fail=1; }
FAKE_REJECT_MODEL=1 CODEX_PLAN=free t "free: no fallback" 5 bash "$ASK" opinion "q"
t "image: --model astra"      0 bash "$SCRIPT" --model astra "x" m1; m "-m gpt-6.2-astra"
t "image: default no -m"      0 bash "$SCRIPT" "x" m1b
grep -q -- " -m " "$T/fake.args" && { echo "FAIL image default passed -m"; fail=1; }
CODEX_PLAN=free t "image: free plan luna" 0 bash "$SCRIPT" --model sol "x" m2; m "-m gpt-6-luna"
mkdir -p "$XDG_CONFIG_HOME/claude-codex-connector"; echo "CODEX_PLAN=go" > "$XDG_CONFIG_HOME/claude-codex-connector/config"
t "config file: go"           0 bash "$ASK" opinion --model sol "q"; m "-m gpt-6-luna"
rm -rf "$XDG_CONFIG_HOME"
t "installer --plan free"     0 bash "$ROOT/install.sh" --yes --plan free
grep -q "CODEX_PLAN=free" "$XDG_CONFIG_HOME/claude-codex-connector/config" || { echo "FAIL plan not saved"; fail=1; }
t "installer --plan go"       0 bash "$ROOT/install.sh" --yes --plan go
grep -q "CODEX_PLAN=go" "$XDG_CONFIG_HOME/claude-codex-connector/config" || { echo "FAIL go not saved"; fail=1; }
t "installer bad plan"        2 bash "$ROOT/install.sh" --plan gold
bash "$ROOT/install.sh" --uninstall >/dev/null; [ ! -e "$XDG_CONFIG_HOME/claude-codex-connector/config" ] || { echo "FAIL config left"; fail=1; }
unset XDG_CONFIG_HOME
# --- review-driven fixes ---
printf 'q via stdin' | bash "$ASK" opinion - > "$T/o" 2>"$T/e" && grep -q "q via stdin" "$T/fake.stdin" && echo "PASS opinion stdin (-)" || { echo "FAIL opinion stdin"; cat "$T/e"; fail=1; }
t "base: leading hyphen rejected" 2 bash "$ASK" review -C "$R" --base "--output=$T/pwned" --allow-secrets
[ ! -e "$T/pwned...HEAD" ] && [ -z "$(ls "$T" | grep pwned)" ] || { echo "FAIL --base option injection wrote a file"; fail=1; }
t "base: bad ref"             2 bash "$ASK" review -C "$R" --base no-such-ref --allow-secrets
# nested sensitive files must be excluded at any depth
N="$T/nested"; mkdir "$N"; git -C "$N" init -q; git -C "$N" config user.email a@b.c; git -C "$N" config user.name t
mkdir -p "$N/sub/deep"; echo base > "$N/a.txt"; echo one > "$N/sub/deep/.env"; echo one > "$N/id_rsa"; git -C "$N" add -A; git -C "$N" commit -q -m i
echo two >> "$N/a.txt"; echo two >> "$N/sub/deep/.env"; echo two >> "$N/id_rsa"
t "nested .env excluded"      0 bash "$ASK" review -C "$N"
grep -q "sub/deep/.env\|id_rsa" "$T/fake.stdin" && { echo "FAIL nested sensitive file was sent"; fail=1; }
grep -q "a.txt" "$T/fake.stdin" || { echo "FAIL normal file missing"; fail=1; }
# unborn branch: staged initial change is reviewable
U="$T/unborn"; mkdir "$U"; git -C "$U" init -q; echo hi > "$U/f.txt"; git -C "$U" add f.txt
t "unborn branch review"      0 bash "$ASK" review -C "$U"
grep -q "+hi" "$T/fake.stdin" || { echo "FAIL unborn staged diff"; fail=1; }
# unquoted env-style secrets are caught
t "unquoted secret blocked"   6 bash "$ASK" opinion "export API_TOKEN=abcd1234efgh5678"
# image script now reports model/plan
bash "$SCRIPT" --model terra "x" rep 2>&1 >/dev/null | grep -q "model=gpt-6.1-terra plan=paid" && echo "PASS image reports model" || { echo "FAIL image model line"; fail=1; }
# uninstall keeps a copy (never deletes local edits)
bash "$ROOT/install.sh" --yes >/dev/null; echo "# my edit" >> "$HOME/.claude/skills/codex-opinion/SKILL.md"; bash "$ROOT/install.sh" --uninstall >/dev/null
grep -rq "my edit" "$HOME/.claude/skill-backups" && echo "PASS uninstall keeps copy" || { echo "FAIL uninstall lost local edit"; fail=1; }
bash "$ROOT/install.sh" --yes >/dev/null; OUT2=$(bash "$ROOT/install.sh" --yes); case $OUT2 in *"already up to date"*) echo "PASS reinstall idempotent";; *) echo "FAIL reinstall not idempotent"; fail=1;; esac
bash "$ROOT/install.sh" --uninstall >/dev/null   # leave a clean HOME for the checks below
t "install --check runs"     1 bash "$ROOT/install.sh" --check   # skill not installed in fake HOME -> not ready
t "install + check + uninstall" 0 bash -c "bash '$ROOT/install.sh' --yes && bash '$ROOT/install.sh' --check && bash '$ROOT/install.sh' --uninstall"
for k in codex-image codex-review codex-opinion; do [ ! -e "$HOME/.claude/skills/$k" ] || { echo "FAIL uninstall left $k"; fail=1; }; done
bash "$ROOT/install.sh" --yes >/dev/null
[ -x "$HOME/.claude/skills/codex-review/scripts/codex-ask.sh" ] && [ -x "$HOME/.claude/skills/codex-opinion/scripts/codex-ask.sh" ] && [ -x "$HOME/.claude/skills/codex-image/scripts/codex-image.sh" ] && echo "PASS skills self-contained" || { echo "FAIL skill scripts missing"; fail=1; }

# changed skill content -> old copy is backed up OUTSIDE the skills dir
echo "# local edit" >> "$HOME/.claude/skills/codex-image/SKILL.md"; bash "$ROOT/install.sh" --yes >/dev/null
[ -z "$(ls "$HOME/.claude/skills" | grep before)" ] && [ -n "$(ls "$HOME/.claude/skill-backups" 2>/dev/null)" ] && echo "PASS backup outside skills dir" || { echo "FAIL backup location"; fail=1; }
for k in codex-image codex-review codex-opinion; do grep -q "Quality control" "$ROOT/skills/$k/SKILL.md" && grep -q "Ask which model" "$ROOT/skills/$k/SKILL.md" && echo "PASS QC rule in $k" || { echo "FAIL QC rule missing in $k"; fail=1; }; done
[ "$fail" = 0 ] && echo "ALL PASSED" || { echo "SOME FAILED"; exit 1; }
