# Claude-Codex Connector

Hubungkan **Claude Code** ke **Codex (OpenAI)** lewat langganan ChatGPT kamu: **buat gambar**, **review kode**, dan **minta opini kedua/ketiga**. Tanpa API key, tanpa server tambahan, tanpa mengubah file settings Claude atau Codex.

> English summary: [README.en.md](README.en.md)

## Tiga skill

| Skill | Fungsi | Contoh permintaan | Akses Codex |
|---|---|---|---|
| `codex-image` | Codex membuat gambar, Claude mengambil file PNG-nya | "Buatkan logo kucing astronot" | tulis hanya di `~/codex-images` |
| `codex-review` | Codex me-review `git diff` sebagai reviewer independen | "Minta Codex review perubahan saya" | **read-only** |
| `codex-opinion` | Codex memberi opini independen atas pertanyaan/desain/rencana | "Minta opini kedua dari Codex: Postgres atau SQLite?" | **read-only** |

```
Kamu ──> Claude Code ──(skill)──> codex exec (sandbox) ──> jawaban / file
```

Claude tidak menelan mentah jawaban Codex: skill menyuruhnya memverifikasi temuan, membandingkan dengan pendapatnya sendiri, dan memperlakukan output Codex sebagai saran yang tidak tepercaya.

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
git clone https://github.com/alfeusaditya-cyber/claude-codex-connector.git
cd claude-codex-connector
bash install.sh
```

Installer akan:
1. memeriksa Node.js,
2. memasang `@openai/codex` (jika belum ada) dan **bertanya dulu** sebelum mengubah apa pun di luar folder skill,
3. membantu `codex login` (sign-in lewat browser, kamu yang melakukannya),
4. menyalin tiga skill ke `~/.claude/skills/` dan membuat `~/codex-images`.

Lalu **mulai sesi Claude Code baru** dan minta:

> "Buatkan gambar apel merah di latar putih"
> "Minta Codex review perubahan yang belum di-commit"
> "Minta opini kedua dari Codex soal pendekatan ini: ..."

Opsi installer: `--yes` (jawab ya semua), `--check` (hanya periksa, tidak mengubah apa pun), `--uninstall`.

## Panduan lengkap

- [docs/GUIDE.md](docs/GUIDE.md): cara pakai, tips prompt, cara kerja, instalasi manual langkah demi langkah
- [docs/SECURITY.md](docs/SECURITY.md): **baca ini**: peringatan, data yang dikirim, batasan sandbox
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md): error umum (termasuk `EACCES` npm)
- [docs/UNINSTALL.md](docs/UNINSTALL.md): cara menghapus bersih
- [CONTRIBUTING.md](CONTRIBUTING.md) · [CHANGELOG.md](CHANGELOG.md) · [SECURITY.md](SECURITY.md)

## Peringatan singkat

- Prompt, **diff kode**, dan file yang dilampirkan dikirim ke OpenAI. **Jangan** menyertakan rahasia, kunci API, atau kode/data klien yang rahasia. Review dan opini memindai pola rahasia dan menolak mengirim, tetapi itu hanya heuristik.
- Setiap panggilan memakai kuota Codex-mu (satu gambar sekitar 28 ribu token pada uji kami).
- Sandbox Codex (`workspace-write` untuk gambar, `read-only` untuk review/opini) membatasi penulisan, tetapi **bukan** pengganti isolasi penuh. Lihat [docs/SECURITY.md](docs/SECURITY.md).
- Penggunaan otomatis langganan lewat CLI mengikuti ketentuan layanan OpenAI. Periksa sendiri syaratnya.

## Kenapa bukan Frenemy atau tool sejenis?

Repo ini sengaja kecil: **hanya Codex, hanya tiga tugas, sandbox ketat** (gambar: tulis di satu folder; review/opini: read-only). Tidak ada hook global, tidak ada AI lain yang berjalan tanpa izin, dan tidak ada perubahan pada konfigurasi Claude/Codex. Alasannya ada di [docs/SECURITY.md](docs/SECURITY.md#kenapa-sempit).

## Uji

```bash
bash tests/test.sh
```

Tes berjalan offline dengan `codex` palsu; tidak memakai jaringan atau kuota.

## Lisensi

[MIT](LICENSE)
