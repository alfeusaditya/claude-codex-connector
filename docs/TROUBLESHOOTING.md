# Pemecahan masalah

Mulai dengan `bash install.sh --check`. Ia melaporkan apa yang kurang tanpa mengubah apa pun.

## npm EACCES

```
npm error code EACCES ... mkdir '/usr/local/lib/node_modules/@openai'
```

npm mencoba menulis ke folder sistem. **Jangan pakai `sudo`.** Pakai folder di home:

```bash
mkdir -p ~/.npm-global && npm config set prefix ~/.npm-global
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
npm i -g @openai/codex
```

(`install.sh` menawarkan ini otomatis.) Catatan: ketik `@` biasa, bukan `＠` (huruf lebar) hasil copy-paste.

## `codex: command not found`

PATH belum memuat folder npm global. Buka terminal baru, atau `source ~/.zshrc`. Cek `ls ~/.npm-global/bin`. Skrip juga mencari di `~/.npm-global/bin`; untuk lokasi lain set `CODEX_BIN=/path/ke/codex`.

## Kode keluar 4: belum login

```bash
codex login
codex login status
```

Browser terbuka untuk sign-in ChatGPT. Di mesin tanpa browser: `codex login --device-auth`. Claude tidak bisa melakukan ini untukmu.

## Kode keluar 5: gambar tidak terbentuk

Baca `~/codex-images/.last-error.log`. Penyebab umum:
- kuota habis atau limit tercapai: tunggu reset
- paket langgananmu tidak mendukung pembuatan gambar di Codex
- prompt ditolak kebijakan konten: ubah prompt, jangan cari jalan memutar
- Codex versi lama: `npm i -g @openai/codex@latest`

## Claude tidak memakai skill

- Mulai **sesi baru** setelah instalasi.
- Pastikan ada `~/.claude/skills/codex-image/SKILL.md`.
- Sebut jelas: "buat gambar ... pakai codex".

## `timeout: command not found` (macOS)

Tidak dipakai oleh repo ini. Jika kamu membungkus skrip sendiri, pakai `gtimeout` dari `brew install coreutils`.

## Prosesnya macet

Tekan Ctrl+C. Tidak ada batas waktu bawaan.

## Masih gagal

Buka issue dengan keluaran `bash install.sh --check`, `codex --version`, dan OS-mu. **Hapus semua data pribadi dan token** dari log sebelum menempel.
