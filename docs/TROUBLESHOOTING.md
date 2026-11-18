# Troubleshooting

> Bahasa Indonesia: [id/TROUBLESHOOTING.md](id/TROUBLESHOOTING.md)

Start with `bash install.sh --check`. It reports what is missing without changing anything.

## npm EACCES

```
npm error code EACCES ... mkdir '/usr/local/lib/node_modules/@openai'
```

npm tried to write to a system folder. **Do not use `sudo`.** Use a folder in your home directory:

```bash
mkdir -p ~/.npm-global && npm config set prefix ~/.npm-global
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
npm i -g @openai/codex
```

(`install.sh` offers this automatically.) Note: type a normal `@`, not a full-width `＠` that can come from copy-paste.

## `codex: command not found`

The npm global folder is not on your PATH. Open a new terminal or run `source ~/.zshrc`. Check `ls ~/.npm-global/bin`. The scripts also look in `~/.npm-global/bin`; for another location set `CODEX_BIN=/path/to/codex`.

## Exit code 4: not logged in

```bash
codex login
codex login status
```

A browser opens for ChatGPT sign-in. On a machine without a browser: `codex login --device-auth`. Claude cannot do this for you.

## Exit code 5: no image produced

Read `~/codex-images/.last-error.log`. Common causes:
- quota exhausted or limit reached: wait for the reset
- your plan does not support image generation in Codex
- prompt refused by content policy: change the prompt; do not look for a workaround
- old Codex version: `npm i -g @openai/codex@latest`

## Review/opinion: exit code 6 (secrets detected)

Nothing was sent. Remove the secrets from the diff/file, or (only if you are sure they are fake/test values) run with `--allow-secrets`. This repo itself contains fake secret strings in `tests/test.sh`, so reviewing this repo requires `--allow-secrets`.

## Review: exit code 7 (no diff)

No changes against `HEAD`. Check the branch, use `--base main`, or run `git add -N <file>` for new files.

## Review/opinion: exit code 8 (too large)

The limit is 300 KB. Review per directory/commit, attach fewer files, or raise `CODEX_ASK_MAX_BYTES` (remember: more quota used and more data sent).

## Claude does not use the skill

- Start a **new session** after installing.
- Make sure `~/.claude/skills/codex-image/SKILL.md` exists (and `codex-review`, `codex-opinion`).
- Be explicit: "generate an image ... using codex".

## `timeout: command not found` (macOS)

Not used by this repo. If you wrap the scripts yourself, use `gtimeout` from `brew install coreutils`.

## The process hangs

Press Ctrl+C. There is no built-in time limit.

## Still failing

Open an issue with the output of `bash install.sh --check`, `codex --version` and your OS. **Remove all personal data and tokens** from logs before pasting.
