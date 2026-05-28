# Patch Luanti 5.12 Controls and Look API Compatibility

Branch base: `compat/luanti-5.12.0`
Patch branch: `patch/luanti-5.12-controls-look-api`

## Summary

This patch applies the minimal Luanti 5.12 compatibility fix needed for the remaining legacy look API usage in the classroom UI, while keeping gameplay and control bindings unchanged.

## Files modified

- `mods/mc_teacher/gui.lua`

## `get_look_yaw()` usage found and corrected

- The remaining legacy usage was in the teacher UI map preview path.
- It now goes through a small compatibility helper:
  - prefers `player:get_look_horizontal()` when available
  - falls back to `player:get_look_yaw()` on older engines

This keeps the code compatible with Luanti 5.12+ while not breaking older Minetest-era behavior.

## Controls and help text review

- The classroom help text in `mc_core/gui.lua` already reads keybinds from engine settings (`keymap_*`) and therefore stays configurable.
- No gameplay keybindings were changed.
- No rigid key prompts were introduced.
- No `get_player_control()` hardening was required in this patch after review.

## Compatibility expectation

- Expected to work on Luanti 5.12 and later.
- Expected to remain safe on nearby older engines because of the fallback helper.

## Risks remaining

- This patch only covers the remaining legacy look API usage found in the teacher GUI.
- Broader input / scancode / help-display work remains handled by the separate Classroom compatibility work already tracked elsewhere.
- Runtime verification is still recommended after cherry-picking onto later Luanti branches.

## Cherry-pick recommendation

This patch should cherry-pick cleanly to:

- `compat/luanti-5.13.0`
- `compat/luanti-5.14.0`
- `compat/luanti-5.15.0`
- `compat/luanti-5.16.1`

## Notes

- No gameplay changes.
- No mod renames.
- No itemstring changes.
- No upstream PR created.
