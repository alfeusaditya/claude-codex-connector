# Changelog

Format mengikuti [Keep a Changelog](https://keepachangelog.com/); versi mengikuti [SemVer](https://semver.org/).

## [1.2.0] - 2026-11-18

### Added
- Aturan "Quality control: Claude in charge" di ketiga skill: revisi otomatis gambar (maks 2x), pelabelan temuan review, tanya ulang sekali bila jawaban Codex kabur.
- Banner repo (`docs/assets/banner.png`), dibuat dengan `codex-image`.

## [1.1.0] - 2026-11-18

### Added
- Skill `codex-review`: review `git diff` oleh Codex (read-only, ephemeral).
- Skill `codex-opinion`: opini independen Codex (read-only, folder sementara).
- `shared/codex-ask.sh` dengan pemindai rahasia, batas ukuran, dan pengecualian file sensitif.
- Installer memasang tiga skill; tes dan docs diperbarui.

### Changed
- Proyek berganti nama menjadi **Claude-Codex Connector** (repo `claude-codex-connector`).

## [1.0.0] - 2026-11-18

### Added
- Skill `codex-image` untuk Claude Code, dengan aturan penggunaan.
- `codex-image.sh`: prompt via stdin, folder terkunci `~/codex-images`, tidak menimpa file, kode keluar terdokumentasi.
- `install.sh` dengan `--check`, `--yes`, `--uninstall`; tidak memakai sudo; bertanya sebelum perubahan.
- Tes offline (`tests/test.sh`) dengan `codex` palsu, dan CI GitHub Actions.
- Dokumentasi: panduan, keamanan, troubleshooting, uninstall.

Diuji dengan Codex CLI 0.169.1 di macOS.
