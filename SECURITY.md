# Kebijakan keamanan

## Melaporkan celah

Jangan buka issue publik untuk celah keamanan. Gunakan **GitHub → tab Security → "Report a vulnerability"** (private vulnerability reporting) di repo ini. Sertakan langkah reproduksi dan versi (lihat [CHANGELOG.md](CHANGELOG.md)).

Ini proyek hobi tanpa SLA; laporan ditanggapi sebisanya.

## Cakupan

Dalam cakupan: `install.sh`, `skills/*` dan `shared/codex-ask.sh` (skrip dan instruksi skill), termasuk celah pada pemindai rahasia, alur yang memungkinkan penulisan di luar `~/codex-images` atau eksekusi tak terduga.

Di luar cakupan: celah di Codex CLI, Claude Code, atau layanan OpenAI/Anthropic (laporkan ke mereka).

Batasan yang sudah diketahui dan didokumentasikan ada di [docs/SECURITY.md](docs/SECURITY.md).
