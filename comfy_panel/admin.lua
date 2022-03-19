--antigrief things made by mewmew

local Event = require 'utils.event'
local Jailed = require 'utils.datastore.jail_data'
local Tabs = require 'comfy_panel.main'
local AntiGrief = require 'antigrief'
local Server = require 'utils.server'
local Color = require 'utils.color_presets'
local lower = string.lower

local function admin_only_message(str)
    for _, player in pairs(game.connected_players) do
        if player.admin == true then
            player.print('管理员专用消息: ' .. str, {r = 0.88, g = 0.88, b = 0.88})
        end
    end
end

local function jail(player, source_player)
    if player.name == source_player.name then
        return player.print("你不能选择自己!", {r = 1, g = 0.5, b = 0.1})
    end
    Jailed.try_ul_data(player.name, true, source_player.name)
end

local function free(player, source_player)
    if player.name == source_player.name then
        return player.print("你不能选择自己!", {r = 1, g = 0.5, b = 0.1})
    end
    Jailed.try_ul_data(player.name, false, source_player.name)
end

local bring_player_messages = {
    '过来我的朋友!',
    '请出示证件.',
    '你在做什么?'
}

local function bring_player(player, source_player)
    if player.name == source_player.name then
        return player.print("你不能选择自己!", {r = 1, g = 0.5, b = 0.1})
    end
    if player.driving == true then
        source_player.print('目标玩家在车辆中，无法进行传送.', {r = 0.88, g = 0.88, b = 0.88})
        return
    end
    local pos = source_player.surface.find_non_colliding_position('character', source_player.position, 50, 1)
    if pos then
        player.teleport(pos, source_player.surface)
        game.print(
            player.name ..
                ' 已被传送到 ' ..
                    source_player.name .. '. ' .. bring_player_messages[math.random(1, #bring_player_messages)],
            {r = 0.98, g = 0.66, b = 0.22}
        )
    end
end

local go_to_player_messages = {
    '请出示证件.',
    '你在做什么?'
}
local function go_to_player(player, source_player)
    if player.name == source_player.name then
        return player.print("你不能选择自己!", {r = 1, g = 0.5, b = 0.1})
    end
    local pos = player.surface.find_non_colliding_position('character', player.position, 50, 1)
    if pos then
        source_player.teleport(pos, player.surface)
        game.print(
            source_player.name ..
                ' is visiting ' .. player.name .. '. ' .. go_to_player_messages[math.random(1, #go_to_player_messages)],
            {r = 0.98, g = 0.66, b = 0.22}
        )
    end
end

local function spank(player, source_player)
    if player.name == source_player.name then
        return player.print("你不能选择自己!", {r = 1, g = 0.5, b = 0.1})
    end
    if player.character then
        if player.character.health > 1 then
            player.character.damage(1, 'player')
        end
        player.character.health = player.character.health - 5
        player.surface.create_entity({name = 'water-splash', position = player.position})
        game.print(source_player.name .. ' spanked ' .. player.name, {r = 0.98, g = 0.66, b = 0.22})
    end
end

local damage_messages = {
    ' 收到了一封来自 ',
    ' 收到了一个奇怪的包裹，来自 '
}
local function damage(player, source_player)
    if player.name == source_player.name then
        return player.print("你不能选择自己!", {r = 1, g = 0.5, b = 0.1})
    end
    if player.character then
        if player.character.health > 1 then
            player.character.damage(1, 'player')
        end
        player.character.health = player.character.health - 125
        player.surface.create_entity({name = 'big-explosion', position = player.position})
        game.print(
            player.name .. damage_messages[math.random(1, #damage_messages)] .. source_player.name,
            {r = 0.98, g = 0.66, b = 0.22}
        )
    end
end

local kill_messages = {
    ' 不遵守法律.',
    ' 不应该触发管理员.',
    ' 不尊重其他人.',
    ' 发生了一个奇怪的事故.',
    ' 被雷击中了.'
}
local function kill(player, source_player)
    if player.name == source_player.name then
        return player.print("你不能选择自己!", {r = 1, g = 0.5, b = 0.1})
    end
    if player.character then
        player.character.die('player')
        game.print(player.name .. kill_messages[math.random(1, #kill_messages)], {r = 0.98, g = 0.66, b = 0.22})
        admin_only_message(source_player.name .. ' killed ' .. player.name)
    end
end

local enemy_messages = {
    '见人就射!',
    '被通缉的死人或活人!'
}
local function enemy(player, source_player)
    if player.name == source_player.name then
        return player.print("你不能选择自己!", {r = 1, g = 0.5, b = 0.1})
    end
    if not game.forces.enemy_players then
        game.create_force('enemy_players')
    end
    player.force = game.forces.enemy_players
    game.print(
        player.name .. ' 现在是敌人了! ' .. enemy_messages[math.random(1, #enemy_messages)],
        {r = 0.95, g = 0.15, b = 0.15}
    )
    admin_only_message(source_player.name .. ' 已转为 ' .. player.name .. ' 变成敌人')
end

local function ally(player, source_player)
    if player.name == source_player.name then
        return player.print("你不能选择自己!", {r = 1, g = 0.5, b = 0.1})
    end
    player.force = game.forces.player
    game.print(player.name .. ' 又是我们的盟友!', {r = 0.98, g = 0.66, b = 0.22})
    admin_only_message(source_player.name .. ' made ' .. player.name .. ' 我们的盟友')
end

local function turn_off_global_speakers(player)
    local counter = 0
    for _, surface in pairs(game.surfaces) do
        local speakers = surface.find_entities_filtered({name = 'programmable-speaker'})
        for i, speaker in pairs(speakers) do
            if speaker.parameters.playback_globally == true then
                speaker.surface.create_entity({name = 'massive-explosion', position = speaker.position})
                speaker.die('player')
                counter = counter + 1
            end
        end
    end
    if counter == 0 then
        return
    end
    if counter == 1 then
        game.print(player.name .. ' 已经核爆了 ' .. counter .. ' 所有发言者', {r = 0.98, g = 0.66, b = 0.22})
    else
        game.print(player.name .. ' 已经核爆了 ' .. counter .. ' 所有发言者.', {r = 0.98, g = 0.66, b = 0.22})
    end
end

local function delete_all_blueprints(player)
    local counter = 0
    for _, surface in pairs(game.surfaces) do
        for _, ghost in pairs(surface.find_entities_filtered({type = {'entity-ghost', 'tile-ghost'}})) do
            ghost.destroy()
            counter = counter + 1
        end
    end
    if counter == 0 then
        return
    end
    if counter == 1 then
        game.print(counter .. ' 蓝图已被清除!', {r = 0.98, g = 0.66, b = 0.22})
    else
        game.print(counter .. ' 蓝图已被清除!', {r = 0.98, g = 0.66, b = 0.22})
    end
    admin_only_message(player.name .. ' 已经清除了所有的蓝图.')
end

local function create_mini_camera_gui(player, caption, position, surface)
    if player.gui.center['mini_camera'] then
        player.gui.center['mini_camera'].destroy()
    end
    local frame = player.gui.center.add({type = 'frame', name = 'mini_camera', caption = caption})
    surface = tonumber(surface)
    local camera =
        frame.add(
        {
            type = 'camera',
            name = 'mini_cam_element',
            position = position,
            zoom = 0.6,
            surface_index = game.surfaces[surface].index
        }
    )
    camera.style.minimal_width = 640
    camera.style.minimal_height = 480
end

local function filter_brackets(str)
    return (string.find(str, '%[') ~= nil)
end

local function match_test(value, pattern)
    return lower(value:gsub('-', ' ')):find(pattern)
end

local function contains_text(key, value, search_text)
    if filter_brackets(search_text) then
        return false
    end
    if value then
        if not match_test(key[value], search_text) then
            return false
        end
    else
        if not match_test(key, search_text) then
            return false
        end
    end
    return true
end

local function draw_events(data)
    local frame = data.frame
    local antigrief = data.antigrief
    local search_text = data.search_text or nil
    local history = frame['admin_history_select'].items[frame['admin_history_select'].selected_index]

    local history_index = {
        ['Capsule History'] = antigrief.capsule_history,
        ['Friendly Fire History'] = antigrief.friendly_fire_history,
        ['Mining History'] = antigrief.mining_history,
        ['Landfill History'] = antigrief.landfill_history,
        ['Corpse Looting History'] = antigrief.corpse_history,
        ['Cancel Crafting History'] = antigrief.cancel_crafting_history
    }

    local scroll_pane
    if frame.datalog then
        frame.datalog.clear()
    else
        scroll_pane =
            frame.add(
            {
                type = 'scroll-pane',
                name = 'datalog',
                direction = 'vertical',
                horizontal_scroll_policy = 'never',
                vertical_scroll_policy = 'auto'
            }
        )
        scroll_pane.style.maximal_height = 200
        scroll_pane.style.minimal_width = 790
    end

    local target_player_name = frame['admin_player_select'].items[frame['admin_player_select'].selected_index]
    if game.players[target_player_name] then
        if not history_index or not history_index[history] or #history_index[history] <= 0 then
            return
        end

        for i = #history_index[history], 1, -1 do
            if history_index[history][i]:find(target_player_name) then
                if search_text then
                    local success = contains_text(history_index[history][i], nil, search_text)
                    if not success then
                        goto continue
                    end
                end

                frame.datalog.add(
                    {
                        type = 'label',
                        caption = history_index[history][i],
                        tooltip = '点击打开迷你摄像头.'
                    }
                )
                ::continue::
            end
        end
    else
        for i = #history_index[history], 1, -1 do
            if search_text then
                local success = contains_text(history_index[history][i], nil, search_text)
                if not success then
                    goto continue
                end
            end

            frame.datalog.add(
                {
                    type = 'label',
                    caption = history_index[history][i],
                    tooltip = '点击打开迷你摄像头.'
                }
            )
            ::continue::
        end
    end
end

local function text_changed(event)
    local element = event.element
    if not element then
        return
    end
    if not element.valid then
        return
    end

    local antigrief = AntiGrief.get()
    local player = game.players[event.player_index]

    local frame = Tabs.comfy_panel_get_active_frame(player)
    if not frame then
        return
    end
    if frame.name ~= 'Admin' then
        return
    end

    local data = {
        frame = frame,
        antigrief = antigrief,
        search_text = element.text
    }

    draw_events(data)
end

local create_admin_panel = (function(player, frame)
    local antigrief = AntiGrief.get()
    frame.clear()

    local player_names = {}
    for _, p in pairs(game.connected_players) do
        table.insert(player_names, tostring(p.name))
    end
    table.insert(player_names, 'Select Player')

    local selected_index = #player_names
    if global.admin_panel_selected_player_index then
        if global.admin_panel_selected_player_index[player.name] then
            if player_names[global.admin_panel_selected_player_index[player.name]] then
                selected_index = global.admin_panel_selected_player_index[player.name]
            end
        end
    end

    local drop_down =
        frame.add(
        {type = 'drop-down', name = 'admin_player_select', items = player_names, selected_index = selected_index}
    )
    drop_down.style.minimal_width = 326
    drop_down.style.right_padding = 12
    drop_down.style.left_padding = 12

    local t = frame.add({type = 'table', column_count = 3})
    local buttons = {
        t.add(
            {
                type = 'button',
                caption = 'Jail',
                name = 'jail',
                tooltip = '囚禁玩家，他们将不再能够执行任何行动，除了聊天。.'
            }
        ),
        t.add({type = 'button', caption = 'Free', name = 'free', tooltip = '将玩家从监狱中释放出来.'}),
        t.add(
            {
                type = 'button',
                caption = 'Bring Player',
                name = 'bring_player',
                tooltip = '将被选中的玩家传送到你的位置.'
            }
        ),
        t.add(
            {
                type = 'button',
                caption = 'Make Enemy',
                name = 'enemy',
                tooltip = '将所选玩家的力量设置为敌方玩家。         不要在Pvp地图中使用！!'
            }
        ),
        t.add(
            {
                type = 'button',
                caption = 'Make Ally',
                name = 'ally',
                tooltip = '将所选玩家的武力值设置为默认玩家武力值。          不要在Pvp地图中使用！!'
            }
        ),
        t.add(
            {
                type = 'button',
                caption = 'Go to Player',
                name = 'go_to_player',
                tooltip = '将自己传送到选定的玩家处.'
            }
        ),
        t.add(
            {
                type = 'button',
                caption = 'Spank',
                name = 'spank',
                tooltip = '对被选中的玩家造成轻微伤害。不能杀死该玩家。'
            }
        ),
        t.add(
            {
                type = 'button',
                caption = 'Damage',
                name = 'damage',
                tooltip = '对被选中的玩家造成更大的伤害。不能杀死该玩家。'
            }
        ),
        t.add({type = 'button', caption = 'Kill', name = 'kill', tooltip = '瞬间杀死被选中的玩家.'})
    }
    for _, button in pairs(buttons) do
        button.style.font = 'default-bold'
        --button.style.font_color = { r=0.99, g=0.11, b=0.11}
        button.style.font_color = {r = 0.99, g = 0.99, b = 0.99}
        button.style.minimal_width = 106
    end

    local line = frame.add {type = 'line'}
    line.style.top_margin = 8
    line.style.bottom_margin = 8

    local l = frame.add({type = 'label', caption = 'Global Actions:'})
    local t = frame.add({type = 'table', column_count = 2})
    local buttons = {
        t.add(
            {
                type = 'button',
                caption = 'Destroy global speakers',
                name = 'turn_off_global_speakers',
                tooltip = '摧毁所有设置为全局播放声音的扬声器.'
            }
        ),
        t.add(
            {
                type = 'button',
                caption = 'Delete blueprints',
                name = 'delete_all_blueprints',
                tooltip = '删除地图上所有放置的蓝图.'
            }
        )
        ---	t.add({type = "button", caption = "Cancel all deconstruction orders", name = "remove_all_deconstruction_orders"})
    }
    for _, button in pairs(buttons) do
        button.style.font = 'default-bold'
        button.style.font_color = {r = 0.98, g = 0.66, b = 0.22}
        button.style.minimal_width = 80
    end

    local line = frame.add {type = 'line'}
    line.style.top_margin = 8
    line.style.bottom_margin = 8

    local histories = {}
    if antigrief.capsule_history then
        table.insert(histories, 'Capsule History')
    end
    if antigrief.friendly_fire_history then
        table.insert(histories, 'Friendly Fire History')
    end
    if antigrief.mining_history then
        table.insert(histories, 'Mining History')
    end
    if antigrief.landfill_history then
        table.insert(histories, 'Landfill History')
    end
    if antigrief.corpse_history then
        table.insert(histories, 'Corpse Looting History')
    end
    if antigrief.cancel_crafting_history then
        table.insert(histories, 'Cancel Crafting History')
    end

    if #histories == 0 then
        return
    end

    local search_table = frame.add({type = 'table', column_count = 2})
    search_table.add({type = 'label', caption = 'Search: '})
    local search_text = search_table.add({type = 'textfield'})
    search_text.style.width = 140

    local l = frame.add({type = 'label', caption = '----------------------------------------------'})
    l.style.font = 'default-listbox'
    l.style.font_color = {r = 0.98, g = 0.66, b = 0.22}

    local selected_index_2 = 1
    if global.admin_panel_selected_history_index then
        if global.admin_panel_selected_history_index[player.name] then
            selected_index_2 = global.admin_panel_selected_history_index[player.name]
        end
    end

    local drop_down_2 =
        frame.add(
        {type = 'drop-down', name = 'admin_history_select', items = histories, selected_index = selected_index_2}
    )
    drop_down_2.style.right_padding = 12
    drop_down_2.style.left_padding = 12

    local data = {
        frame = frame,
        antigrief = antigrief
    }

    draw_events(data)
end)

local admin_functions = {
    ['jail'] = jail,
    ['free'] = free,
    ['bring_player'] = bring_player,
    ['spank'] = spank,
    ['damage'] = damage,
    ['kill'] = kill,
    ['enemy'] = enemy,
    ['ally'] = ally,
    ['go_to_player'] = go_to_player
}

local admin_global_functions = {
    ['turn_off_global_speakers'] = turn_off_global_speakers,
    ['delete_all_blueprints'] = delete_all_blueprints
}

local function get_surface_from_string(str)
    if not str then
        return
    end
    if str == '' then
        return
    end
    str = string.lower(str)
    local start = string.find(str, 'surface:')
    local sname = string.len(str)
    local surface = string.sub(str, start + 8, sname)
    if not surface then
        return false
    end

    return surface
end

local function get_position_from_string(str)
    if not str then
        return
    end
    if str == '' then
        return
    end
    str = string.lower(str)
    local x_pos = string.find(str, 'x:')
    local y_pos = string.find(str, 'y:')
    if not x_pos then
        return false
    end
    if not y_pos then
        return false
    end
    x_pos = x_pos + 2
    y_pos = y_pos + 2

    local a = 1
    for i = 1, string.len(str), 1 do
        local s = string.sub(str, x_pos + i, x_pos + i)
        if not s then
            break
        end
        if string.byte(s) == 32 then
            break
        end
        a = a + 1
    end
    local x = string.sub(str, x_pos, x_pos + a)

    local a = 1
    for i = 1, string.len(str), 1 do
        local s = string.sub(str, y_pos + i, y_pos + i)
        if not s then
            break
        end
        if string.byte(s) == 32 then
            break
        end
        a = a + 1
    end

    local y = string.sub(str, y_pos, y_pos + a)
    x = tonumber(x)
    y = tonumber(y)
    local position = {x = x, y = y}
    return position
end

local function on_gui_click(event)
    local player = game.players[event.player_index]
    local frame = Tabs.comfy_panel_get_active_frame(player)
    if not frame then
        return
    end

    if not event.element.valid then
        return
    end

    local name = event.element.name

    if name == 'mini_camera' or name == 'mini_cam_element' then
        player.gui.center['mini_camera'].destroy()
        return
    end

    if frame.name ~= 'Admin' then
        return
    end

    if admin_functions[name] then
        local target_player_name = frame['admin_player_select'].items[frame['admin_player_select'].selected_index]
        if not target_player_name then
            return
        end
        if target_player_name == 'Select Player' then
            player.print('没有选择目标玩家.', {r = 0.88, g = 0.88, b = 0.88})
            return
        end
        local target_player = game.players[target_player_name]
        if target_player.connected == true then
            admin_functions[name](target_player, player)
        end
        return
    end

    if admin_global_functions[name] then
        admin_global_functions[name](player)
        return
    end

    if not frame then
        return
    end
    if not event.element.caption then
        return
    end
    local position = get_position_from_string(event.element.caption)
    if not position then
        return
    end

    local surface = get_surface_from_string(event.element.caption)
    if not surface then
        return
    end

    if player.gui.center['mini_camera'] then
        if player.gui.center['mini_camera'].caption == event.element.caption then
            player.gui.center['mini_camera'].destroy()
            return
        end
    end

    create_mini_camera_gui(player, event.element.caption, position, surface)
end

local function on_gui_selection_state_changed(event)
    local player = game.players[event.player_index]
    local name = event.element.name

    if name == 'admin_history_select' then
        if not global.admin_panel_selected_history_index then
            global.admin_panel_selected_history_index = {}
        end
        global.admin_panel_selected_history_index[player.name] = event.element.selected_index

        local frame = Tabs.comfy_panel_get_active_frame(player)
        if not frame then
            return
        end
        if frame.name ~= 'Admin' then
            return
        end

        create_admin_panel(player, frame)
    end
    if name == 'admin_player_select' then
        if not global.admin_panel_selected_player_index then
            global.admin_panel_selected_player_index = {}
        end
        global.admin_panel_selected_player_index[player.name] = event.element.selected_index

        local frame = Tabs.comfy_panel_get_active_frame(player)
        if not frame then
            return
        end
        if frame.name ~= 'Admin' then
            return
        end

        create_admin_panel(player, frame)
    end
end

comfy_panel_tabs['Admin'] = {gui = create_admin_panel, admin = true}

commands.add_command("kill", "杀死一个玩家。使用方法: /kill <name>", function(cmd)
	if not cmd.player_index then return end
	local killer = game.get_player(cmd.player_index)
	if not killer then return end
	if cmd.parameter then
		local victim = game.get_player(cmd.parameter)
		if killer.admin and victim and victim.valid then
			kill(victim, killer)
		elseif not victim or not victim.valid then
			killer.print("无效名称", Color.warning)
		else
			killer.print("只有管理员才有杀人的许可!", Color.warning)
		end
	else
		killer.print("使用方法: /kill <name>", Color.warning)
	end
end)

commands.add_command("punish", "杀死并禁止一名玩家。使用方法。 /punish <name> <原因>", function(cmd)
	if not cmd.player_index then return end
	local punisher = game.get_player(cmd.player_index)
	if not punisher then return end
	local t = {}
	local message
	if punisher.admin and cmd.parameter then
		for i in string.gmatch(cmd.parameter, '%S+') do t[#t + 1] = i end
		local offender = game.get_player(t[1])
		table.remove(t, 1)
		message = table.concat(t, ' ')
		if offender.valid and string.len(message) > 5 then
			Server.to_discord_embed(offender.name .. " 被禁止 " .. punisher.name .. ". " .. "原因: " .. message)
			message = message .. " Appeal on discord. Link on biterbattles.org", Color.warning
			if offender.force.name == "spectator" then join_team(offender, global.chosen_team[offender.name], true) end -- switches offender to their team if he's spectating
			kill(offender, punisher)
			game.ban_player(offender, message)
		elseif not offender.valid then
			punisher.print("无效名称", Color.warning)
		else
			punisher.print("没有给出有效的理由，或者理由太短", Color.warning)
		end
	elseif not punisher.admin then
		punisher.print("这只是管理员的命令", Color.warning)
	else
		punisher.print("使用方法: /punish <name> <reason>", Color.warning)
	end
end)
        

Event.add(defines.events.on_gui_text_changed, text_changed)
Event.add(defines.events.on_gui_click, on_gui_click)
Event.add(defines.events.on_gui_selection_state_changed, on_gui_selection_state_changed)
