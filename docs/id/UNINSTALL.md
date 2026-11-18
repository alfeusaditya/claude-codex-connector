# Menghapus

## Hanya skill

```bash
bash install.sh --uninstall
```

Menghapus tiga skill di `~/.claude/skills/` (`codex-image`, `codex-review`, `codex-opinion`). Codex, login, dan gambarmu tetap ada.

## Hapus semuanya (manual, pilih yang perlu)

```bash
npm uninstall -g @openai/codex      # hapus Codex CLI
codex logout                        # jalankan SEBELUM uninstall: cabut login
rm -rf ~/codex-images               # HAPUS SEMUA gambar hasil (tidak bisa dikembalikan)
```

Jika installer menambah PATH: hapus baris `export PATH="$HOME/.npm-global/bin:$PATH"` dari `~/.zshrc` (atau `~/.bashrc`). Backup sebelum perubahan: `~/.zshrc.before-claude-codex-image`.

Kembalikan prefix npm bila perlu:

```bash
npm config delete prefix
```

Cache login Codex dan gambar mentah ada di `~/.codex/` (mis. `~/.codex/generated_images/`). Hapus sendiri bila tidak ingin menyimpannya.
