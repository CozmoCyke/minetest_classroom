local function get_texture_roots()
	local roots = {}
	if skins.textures_path and skins.textures_path ~= "" then
		table.insert(roots, skins.textures_path)
	end
	table.insert(roots, skins.modpath .. "/textures")
	return roots
end

local function get_meta_roots()
	local roots = {}
	if skins.meta_path and skins.meta_path ~= "" then
		table.insert(roots, skins.meta_path)
	end
	table.insert(roots, skins.modpath .. "/meta")
	return roots
end

local function open_from_roots(roots, filename, mode)
	for _, root in ipairs(roots) do
		local file = io.open(root .. "/" .. filename, mode or "r")
		if file then
			return file
		end
	end
	return nil
end

local skins_dir_list = {}
local seen_files = {}
for _, root in ipairs(get_texture_roots()) do
	for _, fn in ipairs(minetest.get_dir_list(root, false)) do
		if not seen_files[fn] then
			seen_files[fn] = true
			table.insert(skins_dir_list, fn)
		end
	end
end

for _, fn in pairs(skins_dir_list) do
	local name, sort_id, assignment, is_preview, playername
	local nameparts = string.gsub(fn, "[.]", "_"):split("_")

	-- check allowed prefix and file extension
	if (nameparts[1] == 'player' or nameparts[1] == 'character') and
			nameparts[#nameparts]:lower() == 'png' then

		-- cut filename extension
		table.remove(nameparts, #nameparts)

		-- check preview suffix
		if nameparts[#nameparts] == 'preview' then
			is_preview = true
			table.remove(nameparts, #nameparts)
		end

		-- Build technically skin name
		name = table.concat(nameparts, '_')

		-- Handle metadata from file name
		if not is_preview then
			-- Get player name
			if nameparts[1] == "player" then
				playername = nameparts[2]
				table.remove(nameparts, 1)
				sort_id = 0
			else
				sort_id = 5000
			end

			-- Get sort index
			if tonumber(nameparts[#nameparts]) then
				sort_id = sort_id + nameparts[#nameparts]
			end
		end

		local skin_obj = skins.get(name) or skins.new(name)
		if is_preview then
			skin_obj:set_preview(fn)
		else
			skin_obj:set_texture(fn)
			skin_obj:set_meta("_sort_id", sort_id)
			if playername then
				skin_obj:set_meta("assignment", "player:"..playername)
				skin_obj:set_meta("playername", playername)
			end
			local file = open_from_roots(get_texture_roots(), fn, "r")
			if file then
				skin_obj:set_meta("format", skins.get_skin_format(file))
				file:close()
			end
			file = open_from_roots(get_meta_roots(), name..".txt", "r")
			if file then
				local data = string.split(file:read("*all"), "\n", 3)
				file:close()
				skin_obj:set_meta("name", data[1])
				skin_obj:set_meta("author", data[2])
				skin_obj:set_meta("license", data[3])
			else
				-- remove player / character prefix if further naming given
				if nameparts[2] and not tonumber(nameparts[2]) then
					table.remove(nameparts, 1)
				end
				skin_obj:set_meta("name", table.concat(nameparts, ' '))
			end
		end
	end
end

local function skins_sort(skinslist)
	table.sort(skinslist, function(a,b)
		local a_id = a:get_meta("_sort_id") or 10000
		local b_id = b:get_meta("_sort_id") or 10000
		if a_id ~= b_id then
			return a:get_meta("_sort_id") < b:get_meta("_sort_id")
		else
			return a:get_meta("name") < b:get_meta("name")
		end
	end)
end

-- (obsolete) get skinlist. If assignment given ("mod:wardrobe" or "player:bell07") select skins matches the assignment. select_unassigned selects the skins without any assignment too
function skins.get_skinlist(assignment, select_unassigned)
	minetest.log("deprecated", "skins.get_skinlist() is deprecated. Use skins.get_skinlist_for_player() instead")
	local skinslist = {}
	for _, skin in pairs(skins.meta) do
		if not assignment or
				assignment == skin:get_meta("assignment") or
				(select_unassigned and skin:get_meta("assignment") == nil) then
			table.insert(skinslist, skin)
		end
	end
	skins_sort(skinslist)
	return skinslist
end

-- Get skinlist for player. If no player given, public skins only selected
function skins.get_skinlist_for_player(playername)
	local skinslist = {}
	for _, skin in pairs(skins.meta) do
		if skin:is_applicable_for_player(playername) and skin:get_meta("in_inventory_list") ~= false then
			table.insert(skinslist, skin)
		end
	end
	skins_sort(skinslist)
	return skinslist
end

-- Get skinlist selected by metadata
function skins.get_skinlist_with_meta(key, value)
	assert(key, "key parameter for skins.get_skinlist_with_meta() missed")
	local skinslist = {}
	for _, skin in pairs(skins.meta) do
		if skin:get_meta(key) == value then
			table.insert(skinslist, skin)
		end
	end
	skins_sort(skinslist)
	return skinslist
end
