---@type table<uint,uint64>
global.unit_lines = global.unit_lines or {}
---@type table<uint,LuaEntity>
global.unit_spawners = global.unit_spawners or {}

script.on_configuration_changed(function()
	-- See issue #1
	for unit_number, unit in pairs(global.unit_spawners) do
		if unit.valid then
			script.register_on_entity_destroyed(unit)
		else
			global.unit_spawners[unit_number] = nil
		end
	end
end)

---@param player LuaPlayer
local function clear_line(player)
	local line = global.unit_lines[player.index]
	if line then
		rendering.destroy(line)
	end
	global.unit_lines[player.index] = nil
end

script.on_event(defines.events.on_selected_entity_changed,
	---@param event on_selected_entity_changed
	function(event)
		local player = game.get_player(event.player_index)
		clear_line(player)
		local unit = player.selected
		if not unit or unit.type ~= "unit" or not (unit.spawner or
			global.unit_spawners[unit.unit_number] and global.unit_spawners[unit.unit_number].valid) then
			return
		end
		global.unit_lines[player.index] = rendering.draw_line {
			surface = unit.surface,
			from = unit,
			to = unit.spawner or global.unit_spawners[unit.unit_number],
			players = { player },
			only_in_alt_mode = player.mod_settings["rsbh-only-alt-mode"].value,
			color = { 1, 0, 0 },
			width = 5,
		}
	end)

script.on_event(defines.events.on_entity_spawned,
	---@param event on_entity_spawned
	function(event)
		local unit = event.entity
		if unit.type ~= "unit" or not event.spawner then
			return
		end
		global.unit_spawners[unit.unit_number] = event.spawner
		script.register_on_entity_destroyed(unit)
	end)

script.on_event(defines.events.on_entity_destroyed,
	---@param event on_entity_destroyed
	function(event)
		if event.unit_number then
			global.unit_spawners[event.unit_number] = nil
		end
	end)
