---Initialize state variables
local function init_globals()
    ---@type table<uint,uint64>
    global.unit_lines = global.unit_lines or {}
end

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
        init_globals()
        clear_line(player)
        local unit = player.selected
        if not unit or unit.type ~= "unit" or not unit.spawner then
            return
        end
        global.unit_lines[player.index] = rendering.draw_line {
            surface = unit.surface,
            from = unit,
            to = unit.spawner,
            players = { player },
            only_in_alt_mode = player.mod_settings["rsbh-only-alt-mode"].value,
            color = { 1, 0, 0 },
            width = 5,
        }
    end)
