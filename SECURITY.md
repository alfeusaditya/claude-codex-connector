# Security policy

## Reporting a vulnerability

Do not open a public issue for a security problem. Use **GitHub, Security tab, "Report a vulnerability"** (private vulnerability reporting) on this repo. Include reproduction steps and the version (see [CHANGELOG.md](CHANGELOG.md)).

This is a hobby project with no SLA; reports are handled on a best-effort basis.

## Scope

In scope: `install.sh`, `skills/*` and `shared/codex-ask.sh` (scripts and skill instructions), including weaknesses in the secret scanner and any path that allows writing outside `~/codex-images` or unexpected execution.

Out of scope: vulnerabilities in the Codex CLI, Claude Code, or OpenAI/Anthropic services (report those to them).

Known, documented limits are in [docs/SECURITY.md](docs/SECURITY.md).
