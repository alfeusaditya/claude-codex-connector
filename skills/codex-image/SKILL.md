---
name: codex-image
description: Generate images with OpenAI Codex CLI (ChatGPT subscription) from inside Claude Code. Use when the user asks to generate, draw, make or create an image, illustration, icon, logo, mockup, poster or picture, or says "pakai codex untuk gambar". Claude writes the prompt, Codex draws, the PNG lands in ~/codex-images.
---

# codex-image

Claude Code cannot draw images itself. This skill hands the drawing to Codex CLI and brings the file path back.

## How to use

1. Turn the user's request into one clear, concrete English prompt (subject, style, composition, background, aspect, "no text" unless text is wanted).
2. Ask which model (section below), then run (one image per call):

```bash
bash "$HOME/.claude/skills/codex-image/scripts/codex-image.sh" --model <name> "<prompt>" [optional-file-name]
```

3. The script prints the absolute PNG path on success. View it with the Read tool and run the quality control below.
4. Deliver it where the user asked (copy it into the project; do not leave it only in `~/codex-images`).

## Ask which model (every time this skill is invoked)

1. Check the plan first: `bash "$HOME/.claude/skills/codex-image/scripts/codex-image.sh" --show-plan` prints `free`, `go` or `paid`.
   - `free` or `go`: only **Luna** exists for this user. **Do not ask.** Use it (the script forces it) and say "using Luna (free/Go plan)" in your report.
   - `paid`: continue.
2. If the user already named a model in this request or earlier in the same task, use that and do not ask.
3. Otherwise ask with **AskUserQuestion** (single choice). Options, in this order, with your recommendation first and "(Recommended)" plus a one-line reason:
   - **Default**: the user's own Codex default model (nothing is overridden)
   - **Luna**: the lightest tier (the only one on Free/Go); least quota
   - **Terra**: middle tier
   - **Sol**: heavier tier, for hard or high-stakes work
   - **Astra**: if the question tool only allows 4 options, show Default, Luna, Terra and Sol and say in the question text that the user can type **Astra** under "Other".
   For images the model only drives the text model that orchestrates the image tool; it is probably not a picture-quality knob (not verified), so recommend **Default** unless the user prefers otherwise.
   Do not claim exact capabilities or rankings beyond that; heavier tiers use more Codex quota.
4. Pass the answer as `--model luna|terra|sol|astra|default`. Reuse the same answer for any retry or re-ask in this task; ask again only for a new request.
5. The script prints `codex-ask`/`codex-image: model=... plan=...` on stderr: **state the model used in your report**. If it says it retried with the default model, say so.

## Quality control: you are in charge (do this without being asked)

Codex is a tool; **you** own the result and the final judgment. After every image, look at it (Read tool) and check it against what the user asked:

- requested text present and **spelled exactly** (no garbled or extra letters)
- subject, style, palette and composition match the request (safe areas, margins, aspect ratio, "simple" means simple)
- no artifacts: warped shapes, duplicated parts, stray text, watermark, cut-off edges
- usable for its purpose (e.g. still readable at small size for an avatar)

If anything fails, **revise the prompt yourself and re-run automatically**, up to **2 automatic revisions** per requested image. Change the prompt to fix the specific defect (do not just re-run). Do not ask permission for these retries, and they do not count toward the "ask before more than 3 images" rule (that rule is for *new* images). Keep the best attempt. Then tell the user briefly what you fixed and what, if anything, is still off after 2 retries. Never present a flawed image as good; never hide that a retry happened.

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
- Generate **one image per request** unless the user asks for more (quality-control revisions are allowed, see above). Each image uses a noticeable chunk of their Codex quota (~28k tokens in testing). Ask before generating more than 3.
- Do not install, log in, edit Codex config, or run Codex for anything other than this script.
- If the user asks for images of real people, logos of real brands, or similar, expect refusals from Codex and report them; do not try to work around a refusal.
