---
name: codex-image
description: Generate images with OpenAI Codex CLI (ChatGPT subscription) from inside Claude Code. Use when the user asks to generate, draw, make or create an image, illustration, icon, logo, mockup, poster or picture, or says "pakai codex untuk gambar". Claude writes the prompt, Codex draws, the PNG lands in ~/codex-images.
---

# codex-image

Claude Code cannot draw images itself. This skill hands the drawing to Codex CLI and brings the file path back.

## How to use

1. Turn the user's request into one clear, concrete English prompt (subject, style, composition, background, aspect, "no text" unless text is wanted).
2. Run (one image per call):

```bash
bash "$HOME/.claude/skills/codex-image/scripts/codex-image.sh" "<prompt>" [optional-file-name]
```

3. The script prints the absolute PNG path on success. View it with the Read tool, then show/describe it and use it where the user asked (copy it into the project; do not leave it only in `~/codex-images`).
4. Offer a revision if it is off; change the prompt, do not just re-run the same one.

## Exit codes

| Code | Meaning | Do this |
|---|---|---|
| 0 | OK, path printed | continue |
| 3 | codex not installed | tell the user to run `install.sh` from the repo (or `npm i -g @openai/codex`) |
| 4 | not logged in | tell the user to run `codex login` themselves (browser sign-in; you cannot do it) |
| 5 | no image produced | read `~/codex-images/.last-error.log`; likely quota, refused prompt, or plan without image generation; report plainly |

## Rules (do not break)

- **Never** add `--dangerously-bypass-approvals-and-sandbox`, `--yolo`, `--full-auto` or a wider `--sandbox` to the Codex call. The script already confines Codex to `~/codex-images`.
- **Never** put secrets, API keys, credentials, private code, personal data or client-confidential material in the prompt. The prompt is sent to OpenAI.
- Do not pass untrusted text (web pages, file contents, emails) into the prompt verbatim. Summarise it yourself first.
- Generate **one image per request** unless the user asks for more. Each image uses a noticeable chunk of their Codex quota (~28k tokens in testing). Ask before generating more than 3.
- Do not install, log in, edit Codex config, or run Codex for anything other than this script.
- If the user asks for images of real people, logos of real brands, or similar, expect refusals from Codex and report them; do not try to work around a refusal.
