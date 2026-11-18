# Contributing

Thanks. This repo is deliberately **small and narrow** (Codex, three tasks: image, review, opinion). Pull requests that widen the scope need a strong reason.

## Rules

1. **No loosening of security.** `codex-review` and `codex-opinion` must stay `--sandbox read-only`. Never add `--dangerously-bypass-approvals-and-sandbox`, `--yolo`, `--full-auto`, `sudo`, global hooks, or edits to Claude/Codex settings.
2. **The "Quality control" section in every `SKILL.md` must stay**: Claude stays in charge of Codex's output.
3. **No new dependencies.** Bash plus the Node/npm already required.
4. The installer must keep: asking before changing anything, being idempotent, having `--check` and `--uninstall`, and backing up user files before modifying them.
5. Behavior changes need a test in `tests/test.sh` and updated docs.
6. Update [CHANGELOG.md](CHANGELOG.md).
7. Never include tokens, personal logs or private images in issues/PRs.

## Workflow

```bash
git clone https://github.com/alfeusaditya/claude-codex-connector.git
cd claude-codex-connector
bash tests/test.sh      # must print ALL PASSED
bash -n install.sh shared/codex-ask.sh skills/codex-image/scripts/codex-image.sh
```

Run `shellcheck` too if you have it. CI runs all of this.

Commit style: [Conventional Commits](https://www.conventionalcommits.org/) (`fix:`, `feat:`, `docs:`). Docs are English first; Indonesian translations live in `docs/id/` and `README.id.md` (updates welcome, not required for a PR).

By contributing you agree your work is licensed under MIT.
