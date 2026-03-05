# Troubleshooting

Common issues and quick fixes.

## Neovim: missing theme/plugin

- Run `:Lazy sync` and restart Neovim.
- Check `:Mason` and `:CheckHealth` for external dependencies.

## Stow conflicts

- Run `bash ./scripts/bootstrap.sh --dry-run` to see conflicts.
- Check `scripts/doctor.sh` (conflicts + lint) before applying.
- If you need details in JSON: `bash ./scripts/status.sh --json`.

## Missing dependencies

- Run `bash ./scripts/doctor.sh` and then `bash ./scripts/install_deps.sh --core`.
- On desktop, add `--gui`.

## Secrets scan false positives

- Inspect the match line number.
- Adjust patterns or use `_local` files for secrets.

## Stricter verification (Neovim config)

- Run `bash ./scripts/verify.sh --nvim-config` to load `config.options`.
