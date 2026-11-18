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

## Review/opini: kode keluar 6 (rahasia terdeteksi)

Tidak ada yang dikirim. Hapus rahasia dari diff/file, atau (hanya jika yakin itu palsu/uji) jalankan dengan `--allow-secrets`. Repo ini sendiri memuat string uji palsu di `tests/test.sh`, jadi me-review repo ini memerlukan `--allow-secrets`.

## Review: kode keluar 7 (tidak ada diff)

Tidak ada perubahan terhadap `HEAD`. Cek branch, pakai `--base main`, atau jalankan `git add -N <file>` untuk file baru.

## Review/opini: kode keluar 8 (terlalu besar)

Batas 300 KB. Review per direktori/commit, lampirkan file lebih sedikit, atau naikkan `CODEX_ASK_MAX_BYTES` (ingat: makin besar, makin banyak kuota dan data terkirim).

## Claude tidak memakai skill

- Mulai **sesi baru** setelah instalasi.
- Pastikan ada `~/.claude/skills/codex-image/SKILL.md` (dan `codex-review`, `codex-opinion`).
- Sebut jelas: "buat gambar ... pakai codex".

## `timeout: command not found` (macOS)

Tidak dipakai oleh repo ini. Jika kamu membungkus skrip sendiri, pakai `gtimeout` dari `brew install coreutils`.

## Prosesnya macet

Tekan Ctrl+C. Tidak ada batas waktu bawaan.

## Masih gagal

Buka issue dengan keluaran `bash install.sh --check`, `codex --version`, dan OS-mu. **Hapus semua data pribadi dan token** dari log sebelum menempel.
