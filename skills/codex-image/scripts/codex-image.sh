#!/usr/bin/env bash
# codex-image.sh — generate ONE image with Codex CLI and print its absolute path.
#
# Usage:  codex-image.sh "prompt" [name]
#   prompt  what to draw (required). Sent to Codex via stdin, not as a process argument.
#   name    output file name without extension (optional; letters, digits, _ and - only)
#
# Env:    CODEX_IMAGE_DIR  output folder (default: ~/codex-images)
#         CODEX_BIN        full path to the codex binary (default: found on PATH)
#         CODEX_PLAN       free|paid (or set in ~/.config/claude-codex-connector/config). free -> gpt-6-luna
#         CODEX_IMAGE_MODEL  optional model for the orchestrating text model (paid plan only)
#
# Exit:   0 ok | 2 bad usage | 3 codex missing | 4 not logged in | 5 no image produced
set -euo pipefail

die() { echo "codex-image: $2" >&2; exit "$1"; }

[ $# -ge 1 ] && [ -n "${1// }" ] || die 2 'usage: codex-image.sh "prompt" [name]'
PROMPT=$1
NAME=${2:-image-$(date +%Y%m%d-%H%M%S)}
case $NAME in *[!A-Za-z0-9_-]*|'') die 2 "name may only contain letters, digits, _ and -";; esac


# ---- plan / model selection -------------------------------------------------
# Plan comes from CODEX_PLAN or the connector config file (never from Codex's own config).
conf_get() { local f="${XDG_CONFIG_HOME:-$HOME/.config}/claude-codex-connector/config"; [ -f "$f" ] && sed -n "s/^$1=//p" "$f" | tail -1 || true; }
PLAN=${CODEX_PLAN:-$(conf_get CODEX_PLAN)}; PLAN=${PLAN:-paid}
case $PLAN in free|paid) ;; *) die 2 "CODEX_PLAN must be free or paid (got '$PLAN')";; esac
MODEL=${CODEX_IMAGE_MODEL:-}
[ "$PLAN" = free ] && MODEL=${CODEX_MODEL_FREE:-gpt-6-luna}
case $MODEL in *[!A-Za-z0-9._-]*) die 2 "invalid model name: $MODEL";; esac

# Find codex: explicit CODEX_BIN, PATH, then the usual user-level npm prefix.
CODEX=${CODEX_BIN:-$(command -v codex || true)}
[ -z "$CODEX" ] && [ -x "$HOME/.npm-global/bin/codex" ] && CODEX="$HOME/.npm-global/bin/codex"
[ -n "$CODEX" ] && [ -x "$CODEX" ] || die 3 "codex not found. Run install.sh from the repo, or: npm i -g @openai/codex"

"$CODEX" login status >/dev/null 2>&1 || die 4 "codex is not logged in. Run: codex login"

OUT_DIR=${CODEX_IMAGE_DIR:-$HOME/codex-images}
mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

# Never overwrite an earlier image.
[ -e "$NAME.png" ] && NAME="$NAME-$(date +%H%M%S)"

# Read-write only inside OUT_DIR (workspace-write); no approval bypass flags, ever.
REQUEST="Generate one image: $PROMPT
Save it as $NAME.png in the current folder. Do nothing else: no other files, no other commands."
run_codex() { # run_codex [model]
  printf '%s\n' "$REQUEST" | "$CODEX" exec ${1:+-m "$1"} --sandbox workspace-write --skip-git-repo-check - >/dev/null 2>"$OUT_DIR/.last-error.log" || true
}
run_codex "$MODEL"
if [ ! -s "$OUT_DIR/$NAME.png" ] && [ -n "$MODEL" ] && [ "$PLAN" != free ]; then
  echo "codex-image: model $MODEL produced no image; retrying once with your default model" >&2
  run_codex ""
fi

if [ -s "$OUT_DIR/$NAME.png" ]; then
  rm -f "$OUT_DIR/.last-error.log"
  echo "$OUT_DIR/$NAME.png"
else
  die 5 "no image produced (quota used up, prompt refused, or plan lacks image generation). Details: $OUT_DIR/.last-error.log"
fi
