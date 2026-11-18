# Changelog

Format follows [Keep a Changelog](https://keepachangelog.com/); versions follow [SemVer](https://semver.org/).

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
