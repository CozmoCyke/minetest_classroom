# Luanti 5.16.1 runtime write paths audit

Target branch: `patch/luanti-5.15-api-audit`

## Summary

Luanti 5.16.1 disallows writing to mod directories. The Classroom tree was audited for runtime filesystem writes and the real mod-directory write paths were moved to writable runtime storage.

## Real issues found

### mc_worldmanager

Before the patch, classroom schematic exports were written to:

- `mods/mc_worldmanager/maps/`

This affected:

- `mods/mc_worldmanager/realm/realmSchematicSaveLoad.lua`
- schematic registration in `mods/mc_worldmanager/schematicmanager.lua`
- the `classroom schematic register` command in `mods/mc_worldmanager/commands.lua`

### mc_json_importer

Before the patch, generated sample JSON files were written to:

- `mods/mc_json_importer/data/...`

This affected:

- `mods/mc_json_importer/sampleGen.lua`

### skinsdb

Before the patch, downloaded runtime skins and metadata were written to:

- `mods/skinsdb/meta/`
- `mods/skinsdb/textures/`

This affected:

- `mods/skinsdb/skins_updater.lua`
- `mods/skinsdb/skinlist.lua`
- runtime path setup in `mods/skinsdb/init.lua`

## Fix applied

- Added runtime writable data roots with `core.get_mod_data_path()` when available.
- Added a safe fallback to `minetest.get_worldpath() .. "/mod_data/<modname>"` for older engines.
- Redirected `mc_worldmanager` schematic exports to a writable maps directory outside the mod folder.
- Kept reading of legacy schematic files from the old `mods/mc_worldmanager/maps/` directory as a fallback.
- Redirected `mc_json_importer` sample output to writable mod data storage.
- Redirected `skinsdb` downloaded skins and metadata to writable mod data storage.
- Kept `skinsdb` reading from the legacy `textures/` and `meta/` folders so bundled assets still work.

## Files modified

- `mods/mc_worldmanager/schematicmanager.lua`
- `mods/mc_worldmanager/realm/realmSchematicSaveLoad.lua`
- `mods/mc_worldmanager/commands.lua`
- `mods/mc_json_importer/init.lua`
- `mods/mc_json_importer/sampleGen.lua`
- `mods/skinsdb/init.lua`
- `mods/skinsdb/skinlist.lua`
- `mods/skinsdb/skins_updater.lua`
- `PATCH_LUANTI_5_16_RUNTIME_WRITE_PATHS.md`

## Notes on reviewed but unchanged code

- `chatlog` writes to `minetest.get_worldpath()` and is already compatible.
- `openstreetmap` does not target mod directories for runtime filesystem writes.
- `exschem` writes to user-supplied paths and was not changed in this pass.

## Risk assessment

- Low to medium. The path migration is localized, but the first runtime use should be validated once to ensure generated files appear in the new writable location and legacy bundled assets still read correctly.
- Existing schematic/skin files remain readable from old locations.

## Patch status

Applied. A real compatibility bug was confirmed, so a code patch was necessary.
