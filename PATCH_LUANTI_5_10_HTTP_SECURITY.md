# Patch Luanti 5.10 HTTP Security

Branch base: `compat/luanti-5.10.0`
Patch branch: `patch/luanti-5.10-http-security`

## Summary

This patch makes the HTTP-using mods fail gracefully when `request_http_api()` is unavailable, while preserving existing gameplay and offline load behavior.

## Mods using HTTP API

- `openstreetmap`
- `skinsdb`

## Recommended configuration

```text
secure.http_mods = openstreetmap,skinsdb
```

## Behavior with HTTP allowed

### openstreetmap

- HTTP-backed Overpass search and import features work normally.
- Existing online search and import chatcommands remain available.
- No gameplay changes are introduced.

### skinsdb

- Online skin download/update behavior works as before.
- The downloader still requires the insecure environment for writing downloaded files.

## Behavior with HTTP refused

### openstreetmap

- The mod loads without a startup error.
- Online import/search commands return a clear warning instead of crashing.
- Offline / non-HTTP content registration remains available.

### skinsdb

- The base mod still loads.
- The skin downloader reports a clear error and does not run.
- Normal skin selection/runtime behavior is preserved.

## Files modified

- `mods/openstreetmap/init.lua`
- `mods/openstreetmap/functions.lua`
- `mods/openstreetmap/commands.lua`
- `mods/skinsdb/skins_updater.lua`
- `PATCH_LUANTI_5_10_HTTP_SECURITY.md`

## Risks remaining

- `skinsdb` still depends on the insecure environment for downloaded skin writes, which is an existing behavior and separate from the HTTP API change.
- This patch does not address later Luanti branches or unrelated compatibility work.

## Notes

- No gameplay changes.
- No mod renames.
- No itemstring changes.
- No upstream PR created.
