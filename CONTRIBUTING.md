# Berkontribusi

Terima kasih. Repo ini sengaja **kecil dan sempit** (Codex, gambar, satu folder). Pull request yang memperluas cakupan perlu alasan kuat.

## Aturan

1. **Tidak ada pelonggaran keamanan.** Tidak boleh menambah `--dangerously-bypass-approvals-and-sandbox`, `--yolo`, `--full-auto`, `sudo`, hook global, atau perubahan ke settings Claude/Codex.
2. **Tanpa dependensi baru.** Bash + Node/npm yang sudah ada.
3. Installer harus tetap: bertanya sebelum mengubah sesuatu, bisa diulang (idempotent), punya `--check` dan `--uninstall`, dan membuat backup sebelum mengubah file milik pengguna.
4. Perubahan perilaku wajib punya tes di `tests/test.sh` dan dokumentasi yang diperbarui.
5. Perbarui [CHANGELOG.md](CHANGELOG.md).
6. Jangan menyertakan token, log pribadi, atau gambar pribadi di issue/PR.

## Alur

```bash
git clone https://github.com/alfeusaditya-cyber/claude-codex-image.git
cd claude-codex-image
bash tests/test.sh      # harus ALL PASSED
bash -n install.sh skills/codex-image/scripts/codex-image.sh
```

Jika punya `shellcheck`, jalankan juga. CI menjalankan semuanya.

Gaya commit: [Conventional Commits](https://www.conventionalcommits.org/) (`fix:`, `feat:`, `docs:`).

Dengan berkontribusi, kamu setuju karyamu berlisensi MIT.
