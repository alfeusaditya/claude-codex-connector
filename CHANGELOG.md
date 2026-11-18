# Changelog

Format mengikuti [Keep a Changelog](https://keepachangelog.com/); versi mengikuti [SemVer](https://semver.org/).

## [1.0.0] - 2026-11-18

### Added
- Skill `codex-image` untuk Claude Code, dengan aturan penggunaan.
- `codex-image.sh`: prompt via stdin, folder terkunci `~/codex-images`, tidak menimpa file, kode keluar terdokumentasi.
- `install.sh` dengan `--check`, `--yes`, `--uninstall`; tidak memakai sudo; bertanya sebelum perubahan.
- Tes offline (`tests/test.sh`) dengan `codex` palsu, dan CI GitHub Actions.
- Dokumentasi: panduan, keamanan, troubleshooting, uninstall.

Diuji dengan Codex CLI 0.169.1 di macOS.
