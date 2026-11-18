# Keamanan, peringatan, dan batasan

Baca sebelum memakai. Ini bukan formalitas.

## 1. Apa yang dikirim ke mana

- **Prompt gambar** dikirim ke OpenAI lewat akun ChatGPT-mu. Anggap sebagai teks yang bisa disimpan di sisi OpenAI sesuai kebijakan mereka.
- Tidak ada data yang dikirim ke pihak lain oleh repo ini. Tidak ada analytics, tidak ada server milik repo ini.
- **Jangan** memasukkan: API key, password, token, kode privat, data klien, data pribadi orang lain.

## 2. Apa yang dibatasi

Skrip menjalankan Codex dengan `--sandbox workspace-write` di dalam `~/codex-images`:

- Tulis file dibatasi ke folder itu (dan folder sementara).
- Tidak memakai `--dangerously-bypass-approvals-and-sandbox`, `--yolo`, atau `--full-auto`. Skill melarang Claude menambahkannya.

## 3. Apa yang TIDAK dibatasi

- Sandbox `workspace-write` membatasi **penulisan**, bukan **pembacaan**. Codex bisa membaca file di luar folder itu. Pada uji kami, Codex membaca gambar dari `~/.codex/generated_images/` di luar folder kerja.
- Karena itu, prompt yang berisi instruksi jahat (prompt injection) bisa mencoba membuat Codex membaca file lain. Jangan menempelkan teks tak tepercaya ke prompt.
- Sandbox adalah lapisan pengaman, bukan jaminan. Jalankan di akun/mesin yang wajar, bukan di mesin dengan rahasia yang tidak boleh bocor.
- Folder `~/codex-images` tidak dienkripsi. Siapa pun yang punya akses ke akun OS-mu bisa membacanya. Jangan commit folder ini ke git publik.

## 4. Kuota dan biaya

- Satu gambar sekitar 28 ribu token pada uji kami. Ini mengurangi kuota Codex/ChatGPT-mu.
- Skill menginstruksikan Claude membuat satu gambar per permintaan dan bertanya sebelum lebih dari tiga.

## 5. Ketentuan layanan

Memakai langganan lewat CLI secara otomatis mungkin diatur oleh ketentuan OpenAI. Repo ini memakai CLI resmi dan login resmi (tidak menyimpan atau memindahkan token), tetapi **kamu yang bertanggung jawab** memeriksa syaratnya. Isi gambar tunduk pada kebijakan konten OpenAI; penolakan dilaporkan apa adanya.

## 6. Yang dilakukan dan tidak dilakukan installer

Dilakukan (setelah bertanya, kecuali `--yes`):
- `npm i -g @openai/codex`
- jika folder global npm tidak bisa ditulis: `npm config set prefix ~/.npm-global` dan menambah satu baris `PATH` ke `~/.zshrc`/`~/.bashrc` (backup `*.before-claude-codex-image`)
- menyalin skill ke `~/.claude/skills/codex-image`, membuat `~/codex-images`

Tidak dilakukan: `sudo`, mengubah `~/.claude/settings.json`, `~/.codex/*`, menambah hook atau MCP server, mengirim data ke mana pun.

Periksa sebelum menjalankan: `install.sh` pendek dan terbuka untuk dibaca.

## Kenapa sempit

Ada tool yang menghubungkan banyak AI sekaligus (mis. Claude, Codex, Gemini, Kimi) dengan hak penuh dan hook global. Risikonya: AI lain berjalan tanpa izin, sandbox hanya kooperatif, injection bisa menyebar antar model, dan konfigurasi global diubah. Repo ini menghindarinya dengan satu tujuan: Codex, gambar, satu folder, tanpa hak lain.

## Melaporkan celah

Lihat [../SECURITY.md](../SECURITY.md).
