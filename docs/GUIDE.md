# Panduan

## Cara kerja

1. Kamu meminta gambar di Claude Code.
2. Skill `codex-image` (di `~/.claude/skills/codex-image`) memberi Claude instruksi dan aturan.
3. Claude menyusun prompt bahasa Inggris dan menjalankan `scripts/codex-image.sh`.
4. Skrip memeriksa Codex terpasang dan sudah login, masuk ke `~/codex-images`, lalu menjalankan:
   ```
   codex exec --sandbox workspace-write --skip-git-repo-check -
   ```
   Prompt dikirim lewat stdin (tidak tampil di daftar proses).
5. Codex memakai image generator bawaannya, menyimpan `nama.png`, dan skrip mencetak path absolutnya.
6. Claude membuka gambar dan menyalinnya ke proyekmu bila diminta.

Tidak ada file settings Claude/Codex yang diubah. Skill hanyalah satu folder.

## Instalasi otomatis

```bash
bash install.sh --check   # lihat apa yang siap / kurang, tanpa mengubah apa pun
bash install.sh           # pasang (bertanya sebelum mengubah sesuatu)
bash install.sh --yes     # pasang tanpa pertanyaan
```

## Instalasi manual (langkah demi langkah)

1. **Node.js 18+**: `node --version`. Jika belum ada, pasang dari https://nodejs.org.
2. **Codex CLI**:
   ```bash
   npm i -g @openai/codex
   ```
   Jika muncul `EACCES`, jangan pakai `sudo`. Lihat [TROUBLESHOOTING](TROUBLESHOOTING.md#npm-eacces).
3. **Login** (browser terbuka, kamu sign-in dengan akun ChatGPT):
   ```bash
   codex login
   codex login status
   ```
4. **Pasang skill**:
   ```bash
   mkdir -p ~/.claude/skills ~/codex-images
   cp -R skills/codex-image ~/.claude/skills/codex-image
   chmod +x ~/.claude/skills/codex-image/scripts/codex-image.sh
   ```
5. **Uji tanpa Claude**:
   ```bash
   bash ~/.claude/skills/codex-image/scripts/codex-image.sh "a red apple on a white background" apple
   ```
   Harus mencetak `/Users/<kamu>/codex-images/apple.png`.
6. Mulai sesi Claude Code baru dan minta sebuah gambar.

## Memakai skrip langsung

```bash
codex-image.sh "prompt" [nama-file]
```

| Variabel | Fungsi | Default |
|---|---|---|
| `CODEX_IMAGE_DIR` | folder hasil | `~/codex-images` |
| `CODEX_BIN` | path biner codex | dicari di `PATH`, lalu `~/.npm-global/bin` |

Kode keluar: `0` ok, `2` salah pakai, `3` codex tidak ada, `4` belum login, `5` gambar tidak terbentuk.
File lama tidak pernah ditimpa; nama dibuat unik.

## Tips prompt

- Sebutkan subjek, gaya, komposisi, latar, dan "no text" bila tidak butuh teks.
- Satu gambar per permintaan. Revisi dengan mengubah prompt, bukan mengulang yang sama.
- Prompt bahasa Inggris biasanya paling konsisten; Claude menerjemahkan permintaanmu.

## Windows

Belum didukung: skrip memakai bash. Opsi: jalankan di WSL (pasang Node, Codex, dan skill di dalam WSL; Claude Code harus berjalan di WSL juga). Belum diuji.

## Batasan yang diketahui

- Tersedianya pembuatan gambar bergantung pada versi Codex dan paket langgananmu.
- Tidak ada batas waktu bawaan (macOS tidak punya `timeout`). Hentikan dengan Ctrl+C jika macet.
- Satu gambar per panggilan; tidak ada antrean atau batch.
- Ditest dengan Codex CLI 0.169.1 di macOS.
