#!/usr/bin/env bash
# install.sh — set up Claude Code <-> Codex skills: image, review, opinion (macOS / Linux).
#
#   bash install.sh              install (asks before changing anything outside the skill folder)
#   bash install.sh --yes        answer yes to every question
#   bash install.sh --check      change nothing, only report what is ready / missing
#   bash install.sh --plan free|go|paid  set your ChatGPT plan (free/go = Luna model only; default paid)
#   bash install.sh --uninstall  remove the 3 skills (keeps Codex, your login and your images)
#
# Never uses sudo. Never changes Claude/Codex settings files.
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
SKILLS="codex-image codex-review codex-opinion"
SKILLS_DIR="$HOME/.claude/skills"
BACKUP_DIR="$HOME/.claude/skill-backups"
OUT_DIR=${CODEX_IMAGE_DIR:-$HOME/codex-images}
NPM_PREFIX="$HOME/.npm-global"

YES=0 CHECK=0 UNINSTALL=0 PLAN_ARG=""
CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/claude-codex-connector"
while [ $# -gt 0 ]; do
  a=$1; shift
  case $a in
    --plan) [ $# -ge 1 ] || { echo "--plan needs free, go or paid" >&2; exit 2; }; PLAN_ARG=$1; shift; case $PLAN_ARG in free|go|paid) ;; *) echo "--plan must be free, go or paid" >&2; exit 2;; esac;;
    --yes|-y) YES=1;; --check) CHECK=1;; --uninstall) UNINSTALL=1;;
    -h|--help) sed -n '2,10p' "$0"; exit 0;;
    *) echo "unknown option: $a (see --help)" >&2; exit 2;;
  esac
done

ok()   { printf '  [ok]   %s\n' "$*"; }
miss() { printf '  [FAIL] %s\n' "$*"; }
info() { printf '  ...    %s\n' "$*"; }
ask() { # ask "question" -> 0 if yes
  [ "$YES" = 1 ] && return 0
  [ -t 0 ] || return 1
  read -r -p "  ?      $1 [y/N] " r; case $r in y|Y|yes) return 0;; *) return 1;; esac
}

# ---- uninstall -------------------------------------------------------------
if [ "$UNINSTALL" = 1 ]; then
  for s in $SKILLS; do
    if [ -d "$SKILLS_DIR/$s" ]; then rm -rf "${SKILLS_DIR:?}/$s"; ok "removed $SKILLS_DIR/$s"; else info "$s not installed"; fi
  done
  [ -f "$CONF_DIR/config" ] && { rm -f "$CONF_DIR/config"; rmdir "$CONF_DIR" 2>/dev/null || true; ok "removed connector config"; }
  info "kept: Codex CLI, your Codex login, $OUT_DIR"
  info "full removal: see docs/UNINSTALL.md"
  exit 0
fi

PROBLEMS=0
echo "Claude-Codex Connector"

# ---- 1. Node ---------------------------------------------------------------
if command -v node >/dev/null 2>&1 && [ "$(node -p 'process.versions.node.split(".")[0]')" -ge 18 ]; then
  ok "Node.js $(node --version)"
else
  miss "Node.js 18+ not found. Install from https://nodejs.org then run this again."; PROBLEMS=1
fi

# ---- 2. Codex CLI ----------------------------------------------------------
find_codex() { command -v codex 2>/dev/null || { [ -x "$NPM_PREFIX/bin/codex" ] && echo "$NPM_PREFIX/bin/codex"; } || true; }
CODEX=$(find_codex)

if [ -z "$CODEX" ] && [ "$CHECK" = 0 ] && [ "$PROBLEMS" = 0 ]; then
  info "Codex CLI not installed."
  if ask "Install @openai/codex with npm?"; then
    # Global npm dir not writable (the EACCES error)? Use a user-level prefix instead of sudo.
    NPM_ROOT=$(npm root -g 2>/dev/null || echo /usr/local/lib/node_modules)
    if [ ! -w "$NPM_ROOT" ] && [ ! -w "$(dirname "$NPM_ROOT")" ]; then
      info "npm global folder ($NPM_ROOT) is not writable by you."
      if ask "Use $NPM_PREFIX instead (sets npm prefix, adds it to your shell PATH)?"; then
        mkdir -p "$NPM_PREFIX"; npm config set prefix "$NPM_PREFIX"
        RC="$HOME/.zshrc"; case ${SHELL:-} in */bash) RC="$HOME/.bashrc";; esac
        grep -qs '\.npm-global/bin' "$RC" 2>/dev/null || {
          cp "$RC" "$RC.before-claude-codex-image" 2>/dev/null || true
          echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$RC"
          ok "added PATH line to $RC (backup: $RC.before-claude-codex-image)"; }
        export PATH="$NPM_PREFIX/bin:$PATH"
      else
        miss "cannot install without a writable npm folder. See docs/TROUBLESHOOTING.md"; PROBLEMS=1
      fi
    fi
    [ "$PROBLEMS" = 0 ] && { npm install -g @openai/codex && CODEX=$(find_codex); }
  fi
fi
if [ -n "$CODEX" ]; then ok "Codex CLI $("$CODEX" --version 2>/dev/null | head -1) ($CODEX)"
else miss "Codex CLI missing (npm i -g @openai/codex)"; PROBLEMS=1; fi

# ---- 3. Codex login --------------------------------------------------------
if [ -n "$CODEX" ]; then
  if "$CODEX" login status >/dev/null 2>&1; then
    ok "Codex login: $("$CODEX" login status 2>&1 | head -1)"
  else
    miss "Codex not logged in (needs a browser sign-in with your ChatGPT account)"
    if [ "$CHECK" = 0 ] && [ -t 0 ] && ask "Run 'codex login' now?"; then
      "$CODEX" login && ok "logged in" || { miss "login failed"; PROBLEMS=1; }
    else PROBLEMS=1; info "run it yourself: codex login"; fi
  fi
fi

# ---- 4. Skills + output folder --------------------------------------------
if [ "$CHECK" = 1 ]; then
  for s in $SKILLS; do
    [ -f "$SKILLS_DIR/$s/SKILL.md" ] && ok "skill $s installed" || { miss "skill $s not installed"; PROBLEMS=1; }
  done
  [ -d "$OUT_DIR" ] && ok "image folder $OUT_DIR" || info "image folder will be created on first use"
else
  mkdir -p "$SKILLS_DIR" "$OUT_DIR"
  for s in $SKILLS; do
    src="$HERE/skills/$s"; dst="$SKILLS_DIR/$s"
    # review/opinion share one script; copy it in so each skill folder is self-contained
    stage=$(mktemp -d); cp -R "$src/." "$stage/"
    case $s in codex-review|codex-opinion) mkdir -p "$stage/scripts"; cp "$HERE/shared/codex-ask.sh" "$stage/scripts/";; esac
    if [ -e "$dst" ] && ! diff -rq "$stage" "$dst" >/dev/null 2>&1; then
      # backups live OUTSIDE the skills folder, or Claude would load them as duplicate skills
      mkdir -p "$BACKUP_DIR"; mv "$dst" "$BACKUP_DIR/$s.$(date +%Y%m%d%H%M%S)"; info "existing $s backed up to $BACKUP_DIR"
    fi
    rm -rf "$dst"; cp -R "$stage" "$dst"; rm -rf "$stage"
    [ -d "$dst/scripts" ] && chmod +x "$dst"/scripts/*.sh
    ok "skill $s installed"
  done
  ok "image folder $OUT_DIR"
fi


# ---- 5. Plan (free = Luna model only) ----------------------------------------
get_plan() { [ -f "$CONF_DIR/config" ] && sed -n 's/^CODEX_PLAN=//p' "$CONF_DIR/config" | tail -1 || true; }
if [ "$CHECK" = 1 ]; then
  info "plan: $(P=${CODEX_PLAN:-$(get_plan)}; echo "${P:-paid (default)}")"
else
  PLAN_NOW=${PLAN_ARG:-$(get_plan)}
  if [ -z "$PLAN_NOW" ]; then
    if [ "$YES" = 0 ] && [ -t 0 ] && ask "Are you on the ChatGPT Free or Go plan (Luna model only)?"; then PLAN_NOW=free; else PLAN_NOW=paid; fi
  fi
  mkdir -p "$CONF_DIR"; printf 'CODEX_PLAN=%s\n' "$PLAN_NOW" > "$CONF_DIR/config"
  ok "plan: $PLAN_NOW (saved in $CONF_DIR/config; change with: bash install.sh --plan free|go|paid)"
fi

echo
if [ "$PROBLEMS" = 0 ]; then
  echo "Ready. Restart Claude Code (or start a new session), then try:"
  echo "  - generate an image of a red apple        (codex-image)"
  echo "  - ask codex to review my uncommitted diff (codex-review)"
  echo "  - get a second opinion from codex on X    (codex-opinion)"
  echo "Read docs/SECURITY.md before sharing prompts or files."
else
  echo "Not ready yet: fix the [FAIL] lines above, then run this again."; exit 1
fi
