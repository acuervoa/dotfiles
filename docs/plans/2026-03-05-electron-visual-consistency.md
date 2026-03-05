# Electron Visual Consistency (Phase 4) Notes

Date: 2026-03-05

## Summary
Goal: apply Catppuccin Mocha and unified fonts where supported, avoid fragile theme injection for Electron apps without native support.

## Applied
- VS Code: Catppuccin Mocha + MesloLGLDZ Nerd Font (settings.json).
- Obsidian: Catppuccin snippet + MesloLGLDZ fonts in vault appearance.
- Joplin Desktop: userchrome.css/userstyle.css with Catppuccin palette + MesloLGLDZ.

## Not Modified (no native support / avoided mods)
- Discord
- Whatsdesk
- Postman
- FreeTube
- Brave/Chromium

## Rationale
- No CSS/patch injection to avoid breakage on updates.
- Keep native dark themes for consistency without increasing maintenance burden.
