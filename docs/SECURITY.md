# Security, warnings and limits

> Bahasa Indonesia: [id/SECURITY.md](id/SECURITY.md)

Read this before using the tool. It is not a formality.

## 1. What is sent where

- **Image prompts, code diffs (review), questions and attached files (opinion)** are sent to OpenAI through your ChatGPT account. Assume they may be retained on OpenAI's side under their policies.
- This repo sends nothing to anyone else. No analytics, no server of its own.
- **Never** include: API keys, passwords, tokens, private code, client data, other people's personal data.

## 2. What is restricted

- **codex-image**: `--sandbox workspace-write` inside `~/codex-images`. Writing is limited to that folder (plus temp folders).
- **codex-review / codex-opinion**: `--sandbox read-only --ephemeral`. Codex cannot write files and does not keep a session. Review runs from the project folder; opinion from an empty temp folder.
- **Secret scanner**: before sending, the payload is scanned (AWS keys, private keys, GitHub/Slack/Google tokens, `sk-...`, `password=` / `token=` patterns). On a match **nothing is sent** (exit code 6). This is a heuristic and can miss other secret formats. `.env*`, `*.pem`, `*.key`, `id_rsa*` are excluded automatically.
- No `--dangerously-bypass-approvals-and-sandbox`, `--yolo` or `--full-auto`. The skills forbid Claude from adding them.

## 3. What is NOT restricted

- The sandbox (`workspace-write` and `read-only` alike) limits **writing**, not **reading**. Codex can read files outside the working folder. In our test, Codex read the image from `~/.codex/generated_images/`, outside its working folder.
- During review, Codex runs in your project folder and may read surrounding files (including ones not in the diff, such as an untracked `.env`). The diff we send is scanned; files Codex reads on its own are not.
- A prompt containing hostile instructions (prompt injection) could try to make Codex read other files. Do not paste untrusted text into prompts.
- The sandbox is a safety layer, not a guarantee. Use a reasonable account/machine, not one holding secrets that must never leak.
- `~/codex-images` is not encrypted; anyone with access to your OS account can read it. Do not commit it to a public git repo.

## 4. Quota and cost

- One image was about 28k tokens in our tests. This counts against your Codex/ChatGPT quota.
- The skills tell Claude to make one image per request, not to repeat reviews without reason, and to ask before sending confidential material.
- **Codex output is untrusted advice.** The skills forbid Claude from running commands or editing files just because Codex says so, and require verifying findings.

## 5. Terms of service

Using a subscription automatically through a CLI may be governed by OpenAI's terms. This repo uses the official CLI and official login (it does not store or move tokens), but **you are responsible** for checking the terms. Image content is subject to OpenAI's content policy; refusals are reported as they are.

## 6. What the installer does and does not do

Does (after asking, unless `--yes`):
- `npm i -g @openai/codex`
- if the global npm folder is not writable: `npm config set prefix ~/.npm-global` and adds one `PATH` line to `~/.zshrc` / `~/.bashrc` (backup `*.before-claude-codex-image`)
- copies the three skills to `~/.claude/skills/` (old versions are backed up in `~/.claude/skill-backups/`) and creates `~/codex-images`
- saves your plan (`free`/`paid`) in its own file `~/.config/claude-codex-connector/config`; this is not a Codex or Claude settings file

Does not: use `sudo`, edit `~/.claude/settings.json` or `~/.codex/*`, add hooks or MCP servers, or send data anywhere.

Check before running: `install.sh` is short and open to read.

## Why so narrow

Some tools wire many AIs together (for example Claude, Codex, Gemini, Kimi) with full permissions and global hooks. The risks: other AIs running without approval, sandboxes that are only cooperative, injection spreading between models, and global configuration being changed. This repo avoids that: Codex only, three tasks, tight sandbox (write in one folder, or read-only), no other rights.

## Reporting a vulnerability

See [../SECURITY.md](../SECURITY.md).
