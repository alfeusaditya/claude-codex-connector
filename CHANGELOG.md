# Changelog

Format follows [Keep a Changelog](https://keepachangelog.com/); versions follow [SemVer](https://semver.org/).

## [1.5.1] - 2026-11-18

Fixes from a Codex (Sol) review of this repo, each verified by Claude before fixing.

### Fixed
- `codex-ask.sh opinion -` (read the question from stdin) was documented but rejected as an unknown option.
- Sensitive-file exclusions (`.env*`, `id_rsa*`, `*.pem`, ...) only matched the repo root; they now apply at any depth.
- `--base` starting with `-` was passed to git as an option (could write a file); it is now rejected and resolved with `rev-parse` first.
- A failing secret scan (grep error) was treated as clean; it now blocks sending. Unquoted `*_TOKEN=...` style secrets are also detected.
- Reviewing a repo with no commits yet reported "nothing to review"; staged changes are now included.
- Installer: `--uninstall` moves skills to `~/.claude/skill-backups/` instead of deleting; identical reinstalls change nothing; unique backup names; clear failure message when `npm install` fails; the plan file is written atomically and only on change.
- `codex-image.sh` now prints `model=... plan=...` as its skill documents.
- Tests could reach the real Codex through an inherited `CODEX_BIN`; the harness now unsets it. CI and CONTRIBUTING ran `bash -n` on only the first file; they now check each script.

## [1.5.0] - 2026-11-18

### Changed
- Models are now chosen by name: **Default, Luna, Terra, Sol, Astra** (`--model`). Every skill invocation makes Claude ask which one (recommending by task), unless the plan is Free/Go or a model was already named. `--depth` was removed.
- Plans: `free`, `go` and `paid`. Free and Go are limited to Luna.
- `codex-ask.sh plan` and `codex-image.sh --show-plan` print the configured plan.

## [1.4.0] - 2026-11-18

### Added
- Per-task model selection: `--depth quick|normal|deep` and `--model NAME` on `codex-ask.sh`; skills tell Claude when to use each and to report the model used.
- Free-plan mode (`bash install.sh --plan free` or `CODEX_PLAN=free`): always uses `gpt-6-luna`.
- One automatic fallback to the user's default model when a chosen model is rejected (paid plan).
- Optional `CODEX_IMAGE_MODEL` for `codex-image`.

## [1.3.0] - 2026-11-18

### Changed
- Documentation is now English first. Indonesian versions are kept in `README.id.md` and `docs/id/`.
- Repository URLs updated to the new GitHub username.

### Added
- 1280x640 social preview image (`docs/assets/social-preview.png`).

## [1.2.0] - 2026-11-18

### Added
- "Quality control: Claude in charge" rules in all three skills: automatic image revision (max 2), labelling of review findings, one re-ask when Codex's answer is vague.
- Repo banner (`docs/assets/banner.png`), made with `codex-image`.

### Fixed
- Installer backups now go to `~/.claude/skill-backups/` so they are not loaded as duplicate skills.

## [1.1.0] - 2026-11-18

### Added
- Skill `codex-review`: Codex reviews the `git diff` (read-only, ephemeral).
- Skill `codex-opinion`: independent Codex opinion (read-only, temp folder).
- `shared/codex-ask.sh` with secret scanning, size cap and sensitive-file exclusion.
- Installer handles three skills; tests and docs updated.

### Changed
- Project renamed to **Claude-Codex Connector** (`claude-codex-connector`).

## [1.0.0] - 2026-11-18

### Added
- Skill `codex-image` for Claude Code, with usage rules.
- `codex-image.sh`: prompt via stdin, locked folder `~/codex-images`, never overwrites files, documented exit codes.
- `install.sh` with `--check`, `--yes`, `--uninstall`; no sudo; asks before changing anything.
- Offline tests (`tests/test.sh`) with a fake `codex`, and GitHub Actions CI.
- Docs: guide, security, troubleshooting, uninstall.

Tested with Codex CLI 0.169.1 on macOS.
