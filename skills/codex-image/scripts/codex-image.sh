#!/usr/bin/env bash
# codex-image.sh — generate ONE image with Codex CLI and print its absolute path.
#
# Usage:  codex-image.sh [--model luna|terra|sol|astra|default] "prompt" [name]
#         codex-image.sh --show-plan      (prints free|go|paid)
#   prompt  what to draw (required). Sent to Codex via stdin, not as a process argument.
#   name    output file name without extension (optional; letters, digits, _ and - only)
#
# Env:    CODEX_IMAGE_DIR  output folder (default: ~/codex-images)
#         CODEX_BIN        full path to the codex binary (default: found on PATH)
#         CODEX_PLAN       free|go|paid (or ~/.config/claude-codex-connector/config). free/go -> Luna only
#         CODEX_MODEL_<LUNA|TERRA|SOL|ASTRA>  override a model slug
#
# Exit:   0 ok | 2 bad usage | 3 codex missing | 4 not logged in | 5 no image produced
set -euo pipefail

die() { echo "codex-image: $2" >&2; exit "$1"; }

MODEL_NAME=default SHOW_PLAN=0
while [ $# -gt 0 ]; do case $1 in
  --model) [ $# -ge 2 ] || die 2 "--model needs a name"; MODEL_NAME=$2; shift 2;;
  --show-plan) SHOW_PLAN=1; shift;;
  *) break;; esac; done
if [ "$SHOW_PLAN" = 0 ] && [ -z "${1:-}" ]; then die 2 'usage: codex-image.sh [--model NAME] "prompt" [name]'; fi
PROMPT=${1:-}
NAME=${2:-image-$(date +%Y%m%d-%H%M%S)}
case $NAME in *[!A-Za-z0-9_-]*|'') die 2 "name may only contain letters, digits, _ and -";; esac


# ---- plan / model selection -------------------------------------------------
# Plan comes from CODEX_PLAN or the connector config file (never from Codex's own config).
conf_get() { local f="${XDG_CONFIG_HOME:-$HOME/.config}/claude-codex-connector/config"; [ -f "$f" ] && sed -n "s/^$1=//p" "$f" | tail -1 || true; }
PLAN=${CODEX_PLAN:-$(conf_get CODEX_PLAN)}; PLAN=${PLAN:-paid}
case $PLAN in free|go|paid) ;; *) die 2 "CODEX_PLAN must be free, go or paid (got '$PLAN')";; esac
resolve_model() { # friendly name -> Codex slug ("" = your own Codex default)
  case $(printf '%s' "$1" | tr '[:upper:]' '[:lower:]') in
    default|"") echo "";;
    luna)  echo "${CODEX_MODEL_LUNA:-gpt-6-luna}";;
    terra) echo "${CODEX_MODEL_TERRA:-gpt-6.1-terra}";;
    sol)   echo "${CODEX_MODEL_SOL:-gpt-6.2-sol}";;
    astra) echo "${CODEX_MODEL_ASTRA:-gpt-6.2-astra}";;
    *) echo "$1";;   # a raw slug such as gpt-6.1-sol
  esac
}
[ "$SHOW_PLAN" = 1 ] && { echo "$PLAN"; exit 0; }
MODEL=$(resolve_model "$MODEL_NAME")
if [ "$PLAN" != paid ]; then
  [ "$MODEL_NAME" != default ] && [ "$MODEL" != "$(resolve_model luna)" ] && echo "codex-image: $PLAN plan can only use Luna; using it instead of $MODEL_NAME" >&2
  MODEL=$(resolve_model luna)
fi
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
if [ ! -s "$OUT_DIR/$NAME.png" ] && [ -n "$MODEL" ] && [ "$PLAN" = paid ]; then
  echo "codex-image: model $MODEL produced no image; retrying once with your default model" >&2
  run_codex ""
fi

if [ -s "$OUT_DIR/$NAME.png" ]; then
  rm -f "$OUT_DIR/.last-error.log"
  echo "$OUT_DIR/$NAME.png"
else
  die 5 "no image produced (quota used up, prompt refused, or plan lacks image generation). Details: $OUT_DIR/.last-error.log"
fi
