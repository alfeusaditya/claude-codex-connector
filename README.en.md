# claude-codex-image

Let **Claude Code** generate images through **Codex (OpenAI)** using your existing ChatGPT subscription. No API keys, no extra servers, and it does not edit your Claude or Codex settings files.

Claude Code cannot draw. This skill lets it write a prompt, call `codex exec` inside a locked folder (`~/codex-images`) and return the PNG path.

Not affiliated with Anthropic or OpenAI. MIT licensed.

## Requirements

macOS or Linux, Node.js 18+, Claude Code, a ChatGPT account whose plan includes Codex image generation (not verified for every plan; test with one image).

## Install

```bash
git clone https://github.com/alfeusaditya-cyber/claude-codex-image.git
cd claude-codex-image
bash install.sh          # options: --yes, --check, --uninstall
```

Start a new Claude Code session and ask: "generate an image of a red apple on a white background".

## Docs

[Guide](docs/GUIDE.md) · [Security notes](docs/SECURITY.md) · [Troubleshooting](docs/TROUBLESHOOTING.md) · [Uninstall](docs/UNINSTALL.md) (docs are in Indonesian)

## Warnings

- Prompts go to OpenAI. Never include secrets or confidential material.
- Each image costs noticeable Codex quota (~28k tokens in testing).
- The Codex `workspace-write` sandbox is not full isolation. See [docs/SECURITY.md](docs/SECURITY.md).
- Check OpenAI's terms for automated use of subscriptions.

## Test

```bash
bash tests/test.sh   # offline, uses a fake codex
```
