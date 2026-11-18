# Uninstall

> Bahasa Indonesia: [id/UNINSTALL.md](id/UNINSTALL.md)

## Skills only

```bash
bash install.sh --uninstall
```

Removes the three skills in `~/.claude/skills/` (`codex-image`, `codex-review`, `codex-opinion`). Codex, your login and your images stay.

## Remove everything (manual, pick what you need)

```bash
codex logout                        # run BEFORE uninstalling: revokes the login
npm uninstall -g @openai/codex      # remove the Codex CLI
rm -rf ~/codex-images               # DELETES ALL generated images (cannot be undone)
```

If the installer added to PATH: remove the line `export PATH="$HOME/.npm-global/bin:$PATH"` from `~/.zshrc` (or `~/.bashrc`). Pre-change backup: `~/.zshrc.before-claude-codex-image`.

Restore the npm prefix if needed:

```bash
npm config delete prefix
```

Old skill backups live in `~/.claude/skill-backups/`. Codex's login cache and raw generated images are in `~/.codex/` (for example `~/.codex/generated_images/`); delete them yourself if you do not want to keep them.
