#!/usr/bin/env bash
# Offline tests: a fake `codex` stands in for the real one (no network, no quota).
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SCRIPT="$ROOT/skills/codex-image/scripts/codex-image.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir "$T/bin"; export HOME="$T/home"; mkdir -p "$HOME"
NODE_DIR=$(dirname "$(command -v node)")
export PATH="$T/bin:$NODE_DIR:/usr/bin:/bin:/usr/sbin:/sbin"
export CODEX_IMAGE_DIR="$T/out"

# fake codex: `login status` succeeds; `exec ... -` reads the prompt and writes the PNG it names.
cat > "$T/bin/codex" <<'EOF'
#!/usr/bin/env bash
case $1 in
  login) [ -z "${FAKE_LOGGED_OUT:-}" ] && { echo "Logged in using ChatGPT"; exit 0; } || exit 1;;
  exec) p=$(cat); n=$(printf '%s' "$p" | sed -n 's/.*as \([A-Za-z0-9_-]*\)\.png.*/\1/p' | head -1)
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
t "install --check runs"     1 bash "$ROOT/install.sh" --check   # skill not installed in fake HOME -> not ready
t "install + check + uninstall" 0 bash -c "bash '$ROOT/install.sh' --yes && bash '$ROOT/install.sh' --check && bash '$ROOT/install.sh' --uninstall"
[ ! -e "$HOME/.claude/skills/codex-image" ] || { echo "FAIL uninstall left skill"; fail=1; }

[ "$fail" = 0 ] && echo "ALL PASSED" || { echo "SOME FAILED"; exit 1; }
