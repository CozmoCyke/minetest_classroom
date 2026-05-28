# Engine Compatibility Matrix

This audit covers the current `minetest_classroom` fork on `main` and summarizes the main compatibility risks across the Minetest / Luanti engine line.

## Summary

The game is largely self-contained and ships its own `default` mod plus the classroom stack, so it does not depend on an external Minetest Game install for runtime content. The main compatibility pressure is concentrated in a few areas:

- Entity definition style changes around 5.8.
- HUD field renames and texture alpha handling around 5.9.
- HTTP API security and engine rename changes around 5.10.
- Input / control display behavior around 5.12.
- Stricter vector validation around 5.13.
- Script-init restrictions in display mods around 5.14.
- Mod-directory write restrictions in 5.16.1.

No BMP textures were found in the repository scan, so 5.11 does not appear to have an asset-format blocker from the current codebase.

## Matrix

| Engine version | Priority | Likely status | Main risks | Sensitive modules | Recommendation |
|---|---:|---|---|---|---|
| Minetest 5.7.0 | Low | Test manual only | Baseline compatibility is generally old-engine friendly, but metadata is still legacy in places (`game.conf` uses `name`, and some mod metadata is uneven). | `game.conf`, `colorbrewer`, `mc_core`, `default` | Keep as baseline branch; no immediate gameplay refactor expected. |
| Minetest 5.8.0 | Medium | Patch necessary | Minetest Game is no longer bundled by the engine, and entity registration style should be checked for `initial_properties`. Current scan shows entity tables still using root fields in `openstreetmap` and `display_modpack`. | `openstreetmap/entities.lua`, `display_modpack/display_api/display.lua`, `mc_core/freeze.lua`, `game.conf` | Audit entity defs and packaging assumptions first. This is the earliest branch where compatibility cleanup is worthwhile. |
| Minetest 5.9.0 | High | Patch necessary | `hud_elem_type` becomes `type`, transparency handling is stricter, and legacy HUD tables remain in several classroom modules. | `mhud`, `mc_worldmanager/hud.lua`, `mc_teacher/functions.lua`, `mc_core/coordinates.lua`, `display_modpack`, `default`, `flowers` | Patch HUD definitions and verify transparent nodes with `use_texture_alpha`. |
| Luanti 5.10.0 | High | Patch necessary | Engine rename is mostly cosmetic, but HTTP API access must be gated with `secure.http_mods`. `openstreetmap` and `skinsdb` both call `request_http_api()`. | `openstreetmap`, `skinsdb`, `game.conf`, `minetest.conf` | Add / verify `secure.http_mods`, keep `minetest.*` compatibility as needed, and modernize metadata where useful. |
| Luanti 5.11.0 | Low | Test manual only | No BMP files were found in the repo scan, so there is no obvious texture-format blocker. | Asset tree scan only | Run manual startup and content checks; no code change is likely from this scan. |
| Luanti 5.12.0 | High | Patch necessary | Input behavior changed (scancodes / keybindings), and node/item registration checks are stricter. The teacher UI still uses deprecated look APIs in one place. | `mc_teacher/gui.lua`, `mc_core` help display, `mc_json_importer`, `mc_student/gui.lua`, `mc_teacher/functions.lua` | Audit control display, keep gameplay keys readable, and validate dynamic registrations carefully. |
| Luanti 5.13.0 | High | Patch necessary | Vectors with nil components are rejected more strictly. Classroom code builds many `{x,y,z}` tables from metadata/settings and should guard them. | `mc_worldmanager/realm/*`, `mc_tutorial`, `openstreetmap`, `portals`, `mc_mapper`, `mc_teacher` | Add nil-safe vector guards before any geometry / coordinate math. |
| Luanti 5.14.0 | High | Patch necessary | Display mods can trigger script-init restrictions. `display_api.is_rotation_restricted()` is called from `signs_api` during init, which can provoke the warning seen in later engine logs. | `display_modpack/display_api`, `display_modpack/signs_api`, `display_modpack/signs`, `display_modpack/signs_road`, `display_modpack/boards` | Defer the relevant check out of init and keep display registration behavior intact. |
| Luanti 5.15.0 | Low | Test manual only | No fresh engine-specific blocker surfaced in the current scan beyond the older compatibility debt already tracked in other versions. | General runtime smoke test | Keep this as a verification branch unless new warnings appear in runtime logs. |
| Luanti 5.16.1 | High | Patch necessary | Writing to mod directories is disallowed. The code still writes runtime data under mod paths in several places, and some client-facing locale files should not flow through media loading. | `mc_worldmanager`, `mc_json_importer`, `skinsdb`, `display_modpack` locale files | Move runtime writes to `minetest.get_worldpath()` or `core.get_mod_data_path()`, and exclude non-media `.po` files from client media flow. |

## Compatibility notes by topic

### 1. Metadata and package layout

- `game.conf` still uses `name = Minetest Classroom`; `title` should be used where engine UX expects a display title.
- `colorbrewer` does not have a `mod.conf` in the current tree.
- Several classroom support mods already have `mod.conf` files and are not blocked by packaging alone.

### 2. Entity definitions

- `openstreetmap:highlight` still uses legacy root entity fields.
- `display_api:dummy_entity` also uses legacy root entity fields.
- `mc_core:frozen_player` already uses `initial_properties`, so that part is fine.

### 3. HUD compatibility

- `hud_elem_type` is still used in:
  - `mhud`
  - `mc_worldmanager/hud.lua`
  - `mc_teacher/functions.lua`
  - `mc_core/coordinates.lua`
- These are the main 5.9-era HUD audit points.

### 4. HTTP / security

- `openstreetmap` and `skinsdb` both call `minetest.request_http_api()`.
- The codebase should be run with `secure.http_mods` configured for those mods on newer engines.

### 5. Filesystem writes

- `mc_worldmanager` saves schematics into `mods/mc_worldmanager/maps/`.
- `mc_json_importer` sample generation writes into `mods/mc_json_importer/data/`.
- `skinsdb` downloads cache files into `mods/skinsdb/meta/` and `mods/skinsdb/textures/`.
- These are the main 5.16.1 compatibility hot spots.

### 6. Input / controls

- `mc_teacher` still has a deprecated `get_look_yaw()` call in the current tree.
- The help / controls UI is the most sensitive area for Luanti 5.12 scancode changes.

### 7. Asset formats

- No `.bmp` textures were found in the scan.
- That reduces the likelihood of a 5.11 asset-format migration task.

## Recommended next correction branch

If we start turning this audit into patch branches, the best first target is:

- `compat/minetest-5.9.0`

Reason: 5.9 is the first version where the HUD and transparency deprecations become broadly visible and affect later versions as well. Fixing that branch first will carry forward cleanly into all later compatibility lines.

## Status

This branch is audit-only. No gameplay changes were made.
