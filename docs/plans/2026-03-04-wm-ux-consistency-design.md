# WM/UX Consistency Design (Phase 2)

Date: 2026-03-04
Scope: i3 (primary), picom, polybar, rofi, dunst, GTK (3/4)
Goal: visual consistency across desktop UI while preserving existing workflows

## Objectives
- Unify typography (MesloLGLDZ Nerd Font, size 10) across i3, polybar, rofi, dunst, GTK.
- Keep Catppuccin Mocha palette as the base for all UI surfaces.
- Avoid keybinding changes; preserve existing workflow.

## Proposed Approach (Alignment Minimal)
1) Typography
   - Apply MesloLGLDZ Nerd Font 10 to i3, polybar, rofi, dunst, GTK.
2) Palette alignment
   - Ensure colors in polybar/rofi/dunst match Catppuccin Mocha.
3) Safety
   - No changes to keybindings or layout rules.

## Risks and Mitigations
- Risk: text clipping after font change.
  - Mitigation: adjust font size or padding in polybar/rofi/dunst if needed.
- Risk: GTK theme mismatch.
  - Mitigation: keep current GTK theme if already Catppuccin; otherwise set it explicitly.

## Validation
- Polybar, rofi, dunst all render with same font and palette.
- i3 window titles and borders match the palette.
- GTK apps (e.g., file manager, settings) show consistent theme and font.
