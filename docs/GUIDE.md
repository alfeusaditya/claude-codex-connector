# Guide

> Bahasa Indonesia: [id/GUIDE.md](id/GUIDE.md)

Three skills: `codex-image` (images), `codex-review` (diff review), `codex-opinion` (independent opinion).

## Principle: Claude stays in charge

Claude quality-checks every Codex result and makes the final call. For images it revises the prompt and retries automatically (max 2 revisions per image, which uses extra quota). For review and opinion it verifies Codex's claims and re-asks once if the answer is vague. The full rules are in the "Quality control" section of each `SKILL.md`.

## How it works (image)

1. You ask Claude Code for an image.
2. The `codex-image` skill (in `~/.claude/skills/codex-image`) gives Claude instructions and rules.
3. Claude writes an English prompt and runs `scripts/codex-image.sh`.
4. The script checks Codex is installed and logged in, enters `~/codex-images` (or `$CODEX_IMAGE_DIR`), and runs:
   ```
   codex exec --sandbox workspace-write --skip-git-repo-check -
   ```
   The prompt goes through stdin, so it does not show up in the process list.
5. Codex uses its built-in image generator, saves `name.png`, and the script prints the absolute path.
6. Claude opens the image, checks it, and copies it into your project if asked.

No Claude or Codex settings files are changed. A skill is just a folder in `~/.claude/skills`.

## Automatic install

```bash
bash install.sh --check   # report what is ready / missing, change nothing
bash install.sh           # install (asks before changing anything)
bash install.sh --yes     # install without questions
```

## Manual install (step by step)

1. **Node.js 18+**: `node --version`. Install from https://nodejs.org if missing.
2. **Codex CLI**:
   ```bash
   npm i -g @openai/codex
   ```
   On `EACCES`, do not use `sudo`. See [TROUBLESHOOTING](TROUBLESHOOTING.md#npm-eacces).
3. **Log in** (a browser opens; sign in with your ChatGPT account):
   ```bash
   codex login
   codex login status
   ```
4. **Install the skills**:
   ```bash
   mkdir -p ~/.claude/skills ~/codex-images
   cp -R skills/codex-image skills/codex-review skills/codex-opinion ~/.claude/skills/
   mkdir -p ~/.claude/skills/codex-review/scripts ~/.claude/skills/codex-opinion/scripts
   cp shared/codex-ask.sh ~/.claude/skills/codex-review/scripts/
   cp shared/codex-ask.sh ~/.claude/skills/codex-opinion/scripts/
   chmod +x ~/.claude/skills/*/scripts/*.sh
   ```
5. **Test without Claude**:
   ```bash
   bash ~/.claude/skills/codex-image/scripts/codex-image.sh "a red apple on a white background" apple
   ```
   It should print `/Users/<you>/codex-images/apple.png`.
6. Start a new Claude Code session and ask for an image.

## Code review (`codex-review`)

```bash
codex-ask.sh review [-C DIR] [--base REF] [--depth D] [--model M] [--allow-secrets] ["review focus"]
```

- Default: uncommitted changes (staged + unstaged, against `HEAD`). `--base main` compares `main...HEAD`.
- Brand-new files that were never `git add`ed are not included: run `git add -N <file>` first.
- `.env*`, `*.pem`, `*.key`, `*.p12`, `id_rsa*` are excluded from the diff.
- Codex runs `--sandbox read-only --ephemeral` from the project folder: it cannot write, but it can read surrounding files for context.
- Size limit 300 KB (`CODEX_ASK_MAX_BYTES`). For big diffs, review per directory or per commit.
- Claude is expected to review the diff itself too, verify Codex's findings, and compare the two.

## Second / third opinion (`codex-opinion`)

```bash
codex-ask.sh opinion [--file PATH]... [--depth D] [--model M] [--allow-secrets] "question"
printf '%s' "$QUESTION" | codex-ask.sh opinion -     # long question via stdin
```

- The question is written **neutrally**, without Claude's preferred answer (avoids anchoring).
- Runs from an empty temporary folder; only the files you attach are sent.
- For a "third" opinion, include the two earlier views as Option A and B and ask Codex to judge them.

`codex-ask.sh` exit codes: `0` ok, `2` bad usage, `3` codex missing, `4` not logged in, `5` no answer, `6` secrets detected (nothing sent), `7` no diff, `8` too large.

## Models and plans

Codex has several models. The scripts pick one per task so Claude can match effort to the job.

| Option | Meaning |
|---|---|
| `--depth quick` | `gpt-6-luna` (small, cheap) for simple questions and small diffs |
| `--depth normal` (default) | your own Codex default model (`model` in `~/.codex/config.toml`) |
| `--depth deep` | `gpt-6.2-sol` for large/risky diffs and high-stakes decisions |
| `--model NAME` | explicit model; overrides depth |

Defaults can be changed with `CODEX_MODEL_QUICK`, `CODEX_MODEL_DEEP`, `CODEX_MODEL` (used for `normal`). Model names are the slugs from `codex debug models` (for example `gpt-6.1-sol`, `gpt-6.1-terra`, `gpt-6-astra`, `gpt-5.6-luna`). Which ones you may use depends on your plan.

**Free plan.** Free accounts can only use the Luna model. Tell the connector once:

```bash
bash install.sh --plan free        # saved in ~/.config/claude-codex-connector/config
```

or set `CODEX_PLAN=free`. With the free plan every call uses `gpt-6-luna`, whatever depth is requested (a notice is printed). Switch back with `bash install.sh --plan paid`. Image generation may not be available on every free plan; if it is not, `codex-image` reports exit code 5.

**Fallback.** If a chosen model is rejected or returns nothing, the script retries once with your default model (paid plan only) and says so on stderr. Every run prints `codex-ask: model=... plan=... depth=...` so you can see what was used.

For `codex-image`, the model only drives the text model that orchestrates the image tool, so it is **not** a quality knob for the picture; it is unset by default (`CODEX_IMAGE_MODEL` to set it).

## Using the image script directly

```bash
codex-image.sh "prompt" [file-name]
```

| Variable | Purpose | Default |
|---|---|---|
| `CODEX_IMAGE_DIR` | output folder | `~/codex-images` |
| `CODEX_BIN` | path to the codex binary | looked up on `PATH`, then `~/.npm-global/bin` |

Exit codes: `0` ok, `2` bad usage, `3` codex missing, `4` not logged in, `5` no image produced.
Existing files are never overwritten; names are made unique.

## Prompt tips

- Name the subject, style, composition and background, and say "no text" if you do not want text.
- One image per request. Revise by changing the prompt, not by re-running the same one.
- English prompts tend to be the most consistent; Claude translates your request.

## Windows

Not supported: the scripts use bash. An option is WSL (install Node, Codex and the skills inside WSL; Claude Code must also run in WSL). Untested.

## Known limitations

- Image generation depends on your Codex version and subscription plan.
- No built-in time limit (macOS has no `timeout`). Stop with Ctrl+C if it hangs.
- One image per call; no queue or batch.
- Secret detection is a simple regex; it can miss things (and sometimes holds back harmless fake strings, such as test fixtures). Do not rely on it as your only safeguard.
- Review quality depends on Codex and it can miss bugs, which is why Claude is expected to verify and review on its own.
- Tested with Codex CLI 0.169.1 on macOS.
