# Patch Minetest 5.9 HUD and alpha compatibility

Branch base: `compat/minetest-5.9.0`
Patch branch: `patch/minetest-5.9-hud-alpha`

## Summary

This patch applies the minimal compatibility fixes needed for Minetest 5.9-era HUD handling and node transparency handling, without changing gameplay or itemstrings.

### HUD compatibility

- `mhud` now accepts both `hud_elem_type` and `type` in incoming HUD definitions.
- `mhud` emits `type` when calling the engine HUD API, which avoids the 5.9 deprecation path.
- Existing callers were updated to use `type` where they construct HUD definitions:
  - `mc_core/coordinates.lua`
  - `mc_worldmanager/hud.lua`
  - `mc_teacher/functions.lua`

### Transparency / alpha

- Added `use_texture_alpha = "clip"` to the sign-family node definitions that use transparent textures:
  - `mods/display_modpack/signs/nodes.lua`
  - `mods/display_modpack/signs_road/nodes.lua`
  - `mods/display_modpack/boards/init.lua`

- No changes were needed in `mods/default` or `mods/flowers`; the scan showed their relevant nodes already declare `use_texture_alpha`.

## Files modified

- `mods/mhud/mhud.lua`
- `mods/mc_core/coordinates.lua`
- `mods/mc_worldmanager/hud.lua`
- `mods/mc_teacher/functions.lua`
- `mods/display_modpack/signs/nodes.lua`
- `mods/display_modpack/signs_road/nodes.lua`
- `mods/display_modpack/boards/init.lua`

## Risks remaining

- `mhud` still contains the legacy `hud_elem_type` keyword in its compatibility path and in the README, which is intentional for back-compat input handling.
- This patch does not address the broader Luanti 5.10+ branches or later engine changes such as input scancode handling, stricter vector validation, or mod-directory write restrictions.
- Runtime verification is still recommended on the 5.9 target branch and on later Luanti branches after cherry-picking.

## Cherry-pick recommendation

This patch should cherry-pick cleanly to:

- `compat/luanti-5.10.0`
- `compat/luanti-5.11.0`
- `compat/luanti-5.12.0`
- `compat/luanti-5.13.0`
- `compat/luanti-5.14.0`
- `compat/luanti-5.15.0`
- `compat/luanti-5.16.1`

The patch is aimed at the 5.9+ compatibility line and should not be backported to 5.7/5.8 without reviewing the HUD API expectations on those branches.

## Notes

- No gameplay changes were introduced.
- No mods were renamed.
- No itemstrings were changed.
- No upstream PR was created.
