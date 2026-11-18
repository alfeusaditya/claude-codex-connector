#!/usr/bin/env bash
# Offline tests: a fake `codex` stands in for the real one (no network, no quota).
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SCRIPT="$ROOT/skills/codex-image/scripts/codex-image.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir "$T/bin"; export HOME="$T/home"; mkdir -p "$HOME"
NODE_DIR=$(dirname "$(command -v node)")
export PATH="$T/bin:$NODE_DIR:/usr/bin:/bin:/usr/sbin:/sbin"
export CODEX_IMAGE_DIR="$T/out" FAKE_LOG="$T/fake"

# fake codex: `login status` succeeds; `exec ... -` reads the prompt and writes the PNG it names.
cat > "$T/bin/codex" <<'EOF'
#!/usr/bin/env bash
case $1 in
  login) [ -z "${FAKE_LOGGED_OUT:-}" ] && { echo "Logged in using ChatGPT"; exit 0; } || exit 1;;
  exec) p=$(cat); printf '%s\n' "$*" > "$FAKE_LOG.args"; printf '%s' "$p" > "$FAKE_LOG.stdin"
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
t "install --check runs"     1 bash "$ROOT/install.sh" --check   # skill not installed in fake HOME -> not ready
t "install + check + uninstall" 0 bash -c "bash '$ROOT/install.sh' --yes && bash '$ROOT/install.sh' --check && bash '$ROOT/install.sh' --uninstall"
for k in codex-image codex-review codex-opinion; do [ ! -e "$HOME/.claude/skills/$k" ] || { echo "FAIL uninstall left $k"; fail=1; }; done
bash "$ROOT/install.sh" --yes >/dev/null
[ -x "$HOME/.claude/skills/codex-review/scripts/codex-ask.sh" ] && [ -x "$HOME/.claude/skills/codex-opinion/scripts/codex-ask.sh" ] && [ -x "$HOME/.claude/skills/codex-image/scripts/codex-image.sh" ] && echo "PASS skills self-contained" || { echo "FAIL skill scripts missing"; fail=1; }

[ "$fail" = 0 ] && echo "ALL PASSED" || { echo "SOME FAILED"; exit 1; }
