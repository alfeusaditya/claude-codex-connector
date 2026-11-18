# claude-codex-image

Hubungkan **Claude Code** ke **Codex (OpenAI)** supaya Claude bisa membuat gambar lewat langganan ChatGPT kamu. Tanpa API key, tanpa server tambahan, tanpa mengubah file settings Claude atau Codex.

> English summary: [README.en.md](README.en.md)

Claude Code tidak bisa menggambar. Skill ini memberinya satu kemampuan: menyusun prompt, memanggil `codex exec` di dalam folder yang dikunci (`~/codex-images`), lalu mengambil path PNG hasilnya.

```
Kamu ──> Claude Code ──(skill codex-image)──> codex exec (sandbox) ──> ~/codex-images/gambar.png
```

Tidak berafiliasi dengan Anthropic atau OpenAI. Lisensi MIT.

## Prasyarat

| Kebutuhan | Keterangan |
|---|---|
| macOS atau Linux | Windows belum didukung (lihat [docs/GUIDE.md](docs/GUIDE.md#windows)) |
| Node.js 18+ | https://nodejs.org |
| Claude Code | sudah terpasang |
| Akun ChatGPT | paket yang mendukung Codex dan pembuatan gambar. **Belum diverifikasi untuk semua paket**; uji dengan satu gambar |

## Instalasi (satu perintah)

```bash
git clone https://github.com/alfeusaditya-cyber/claude-codex-image.git
cd claude-codex-image
bash install.sh
```

Installer akan:
1. memeriksa Node.js,
2. memasang `@openai/codex` (jika belum ada) dan **bertanya dulu** sebelum mengubah apa pun di luar folder skill,
3. membantu `codex login` (sign-in lewat browser, kamu yang melakukannya),
4. menyalin skill ke `~/.claude/skills/codex-image` dan membuat `~/codex-images`.

Lalu **mulai sesi Claude Code baru** dan minta:

> "Buatkan gambar apel merah di latar putih"

Opsi installer: `--yes` (jawab ya semua), `--check` (hanya periksa, tidak mengubah apa pun), `--uninstall`.

## Panduan lengkap

- [docs/GUIDE.md](docs/GUIDE.md): cara pakai, tips prompt, cara kerja, instalasi manual langkah demi langkah
- [docs/SECURITY.md](docs/SECURITY.md): **baca ini**: peringatan, data yang dikirim, batasan sandbox
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md): error umum (termasuk `EACCES` npm)
- [docs/UNINSTALL.md](docs/UNINSTALL.md): cara menghapus bersih
- [CONTRIBUTING.md](CONTRIBUTING.md) · [CHANGELOG.md](CHANGELOG.md) · [SECURITY.md](SECURITY.md)

## Peringatan singkat

- Prompt dikirim ke OpenAI. **Jangan** menyertakan rahasia, kunci API, kode privat, atau data klien.
- Satu gambar memakai kuota Codex-mu (sekitar 28 ribu token pada uji kami). Skill meminta konfirmasi sebelum membuat banyak gambar.
- Sandbox Codex (`workspace-write`) membatasi tulis ke `~/codex-images`, tetapi **bukan** pengganti isolasi penuh. Lihat [docs/SECURITY.md](docs/SECURITY.md).
- Penggunaan otomatis langganan lewat CLI mengikuti ketentuan layanan OpenAI. Periksa sendiri syaratnya.

## Kenapa bukan Frenemy atau tool sejenis?

Repo ini sengaja kecil: **hanya Codex, hanya gambar, hanya satu folder**. Tidak ada hook global, tidak ada AI lain yang berjalan tanpa izin, dan tidak ada perubahan pada konfigurasi Claude/Codex. Alasannya ada di [docs/SECURITY.md](docs/SECURITY.md#kenapa-sempit).

## Uji

```bash
bash tests/test.sh
```

Tes berjalan offline dengan `codex` palsu; tidak memakai jaringan atau kuota.

## Lisensi

[MIT](LICENSE)
