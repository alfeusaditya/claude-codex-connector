# Berkontribusi

Terima kasih. Repo ini sengaja **kecil dan sempit** (Codex, tiga tugas: gambar, review, opini). Pull request yang memperluas cakupan perlu alasan kuat.

## Aturan

1. **Tidak ada pelonggaran keamanan.** `codex-review` dan `codex-opinion` harus tetap `--sandbox read-only`. Tidak boleh menambah `--dangerously-bypass-approvals-and-sandbox`, `--yolo`, `--full-auto`, `sudo`, hook global, atau perubahan ke settings Claude/Codex.
2. **Bagian "Quality control" di setiap `SKILL.md` harus tetap ada**: Claude yang memegang kendali atas hasil Codex.
3. **Tanpa dependensi baru.** Bash + Node/npm yang sudah ada.
4. Installer harus tetap: bertanya sebelum mengubah sesuatu, bisa diulang (idempotent), punya `--check` dan `--uninstall`, dan membuat backup sebelum mengubah file milik pengguna.
5. Perubahan perilaku wajib punya tes di `tests/test.sh` dan dokumentasi yang diperbarui.
6. Perbarui [CHANGELOG.md](CHANGELOG.md).
7. Jangan menyertakan token, log pribadi, atau gambar pribadi di issue/PR.

## Alur

```bash
git clone https://github.com/alfeusaditya-cyber/claude-codex-connector.git
cd claude-codex-connector
bash tests/test.sh      # harus ALL PASSED
bash -n install.sh shared/codex-ask.sh skills/codex-image/scripts/codex-image.sh
```

Jika punya `shellcheck`, jalankan juga. CI menjalankan semuanya.

Gaya commit: [Conventional Commits](https://www.conventionalcommits.org/) (`fix:`, `feat:`, `docs:`).

Dengan berkontribusi, kamu setuju karyamu berlisensi MIT.
