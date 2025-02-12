-- config tab --

local Antigrief = require 'antigrief'
local Color = require 'utils.color_presets'
local SessionData = require 'utils.datastore.session_data'
local Utils = require 'utils.core'

local spaghett_entity_blacklist = {
    ['logistic-chest-requester'] = true,
    ['logistic-chest-buffer'] = true,
    ['logistic-chest-active-provider'] = true
}

local function get_actor(event, prefix, msg, admins_only)
    local player = game.get_player(event.player_index)
    if not player or not player.valid then
        return
    end
    if admins_only then
        Utils.print_admins(msg, player.name)
    else
        Utils.action_warning(prefix, player.name .. ' ' .. msg)
    end
end

local function spaghett_deny_building(event)
    local spaghett = global.comfy_panel_config.spaghett
    if not spaghett.enabled then
        return
    end
    local entity = event.created_entity
    if not entity.valid then
        return
    end
    if not spaghett_entity_blacklist[event.created_entity.name] then
        return
    end

    if event.player_index then
        game.players[event.player_index].insert({name = entity.name, count = 1})
    else
        local inventory = event.robot.get_inventory(defines.inventory.robot_cargo)
        inventory.insert({name = entity.name, count = 1})
    end

    event.created_entity.surface.create_entity(
        {
            name = 'flying-text',
            position = entity.position,
            text = 'Spaghett Mode Active!',
            color = {r = 0.98, g = 0.66, b = 0.22}
        }
    )

    entity.destroy()
end

local function spaghett()
    local spaghett = global.comfy_panel_config.spaghett
    if spaghett.enabled then
        for _, f in pairs(game.forces) do
            if f.technologies['logistic-system'].researched then
                spaghett.undo[f.index] = true
            end
            f.technologies['logistic-system'].enabled = false
            f.technologies['logistic-system'].researched = false
        end
    else
        for _, f in pairs(game.forces) do
            f.technologies['logistic-system'].enabled = true
            if spaghett.undo[f.index] then
                f.technologies['logistic-system'].researched = true
                spaghett.undo[f.index] = nil
            end
        end
    end
end

local function trust_connected_players()
    local trust = SessionData.get_trusted_table()
    local AG = Antigrief.get()
    local players = game.connected_players
    if not AG.enabled then
        for _, p in pairs(players) do
            trust[p.name] = true
        end
    else
        for _, p in pairs(players) do
            trust[p.name] = false
        end
    end
end

local functions = {
    ['comfy_panel_spectator_switch'] = function(event)
        if event.element.switch_state == 'left' then
            game.players[event.player_index].spectator = true
        else
            game.players[event.player_index].spectator = false
        end
    end,
    ['comfy_panel_auto_hotbar_switch'] = function(event)
        if event.element.switch_state == 'left' then
            global.auto_hotbar_enabled[event.player_index] = true
        else
            global.auto_hotbar_enabled[event.player_index] = false
        end
    end,
    ['comfy_panel_blueprint_toggle'] = function(event)
        if event.element.switch_state == 'left' then
            game.permissions.get_group('Default').set_allows_action(
                defines.input_action.open_blueprint_library_gui,
                true
            )
            game.permissions.get_group('Default').set_allows_action(defines.input_action.import_blueprint_string, true)
            get_actor(event, '{Blueprints}', '已启用蓝图!')
        else
            game.permissions.get_group('Default').set_allows_action(
                defines.input_action.open_blueprint_library_gui,
                false
            )
            game.permissions.get_group('Default').set_allows_action(defines.input_action.import_blueprint_string, false)
            get_actor(event, '{Blueprints}', '已禁用蓝图!')
        end
    end,
    ['comfy_panel_spaghett_toggle'] = function(event)
        if event.element.switch_state == 'left' then
            global.comfy_panel_config.spaghett.enabled = true
            get_actor(event, '{Spaghett}', '已启用spaghett模式!')
        else
            global.comfy_panel_config.spaghett.enabled = nil
            get_actor(event, '{Spaghett}', '已禁用spaghett模式!')
        end
        spaghett()
    end,
	["bb_team_balancing_toggle"] = function(event) 
		if event.element.switch_state == "left" then
			global.bb_settings.team_balancing = true
			game.print("团队平衡已启用!")
		else
			global.bb_settings.team_balancing = false
			game.print("团队平衡已被禁用!")
		end
	end,
	
	["bb_only_admins_vote"] = function(event) 
		if event.element.switch_state == "left" then
			global.bb_settings.only_admins_vote = true
			global.difficulty_player_votes = {}
			game.print("仅限管理员的难度投票已被启用!")
		else
			global.bb_settings.only_admins_vote = false
			game.print("仅限管理员的难度投票已被禁用!!")
		end
	end,
}

local poll_function = {
    ['comfy_panel_poll_trusted_toggle'] = function(event)
        if event.element.switch_state == 'left' then
            global.comfy_panel_config.poll_trusted = true
            get_actor(event, '{Poll Mode}', '使未被信任的人不能进行民意调查.')
        else
            global.comfy_panel_config.poll_trusted = false
            get_actor(event, '{Poll Mode}', '允许未受信任的人做民意调查.')
        end
    end,
    ['comfy_panel_poll_no_notify_toggle'] = function(event)
        local poll = package.loaded['comfy_panel.poll']
        local poll_table = poll.get_no_notify_players()
        if event.element.switch_state == 'left' then
            poll_table[event.player_index] = false
        else
            poll_table[event.player_index] = true
        end
    end
}

local antigrief_functions = {
    ['comfy_panel_disable_antigrief'] = function(event)
        local AG = Antigrief.get()
        if event.element.switch_state == 'left' then
            AG.enabled = true
            get_actor(event, '{Antigrief}', '保护插件已开启.', true)
        else
            AG.enabled = false
            get_actor(event, '{Antigrief}', '保护插件已关闭.', true)
        end
        trust_connected_players()
    end
}

local fortress_functions = {
    ['comfy_panel_disable_fullness'] = function(event)
        local Fullness = package.loaded['modules.check_fullness']
        local this = Fullness.get()
        if event.element.switch_state == 'left' then
            this.fullness_enabled = true
            get_actor(event, '{Fullness}', '启用了存货充盈功能.')
        else
            this.fullness_enabled = false
            get_actor(event, '{Fullness}', '已经禁用了存货充盈功能。')
        end
    end,
    ['comfy_panel_offline_players'] = function(event)
        local WPT = package.loaded['maps.mountain_fortress_v3.table']
        local this = WPT.get()
        if event.element.switch_state == 'left' then
            this.offline_players_enabled = true
            get_actor(event, '{Offline Players}', 'has enabled the offline player function.')
        else
            this.offline_players_enabled = false
            get_actor(event, '{Offline Players}', 'has disabled the offline player function.')
        end
    end,
    ['comfy_panel_collapse_grace'] = function(event)
        local WPT = package.loaded['maps.mountain_fortress_v3.table']
        local this = WPT.get()
        if event.element.switch_state == 'left' then
            this.collapse_grace = true
            get_actor(event, '{Collapse}', 'has enabled the collapse function. Collapse will occur after wave 100!')
        else
            this.collapse_grace = false
            get_actor(
                event,
                '{Collapse}',
                '已经禁用了塌陷功能。你必须到达2区才能发生塌陷!'
            )
        end
    end,
    ['comfy_panel_spill_items_to_surface'] = function(event)
        local WPT = package.loaded['maps.mountain_fortress_v3.table']
        local this = WPT.get()
        if event.element.switch_state == 'left' then
            this.spill_items_to_surface = true
            get_actor(
                event,
                '{Item Spill}',
                '启用了矿石溢出功能。采矿时，矿石现在会掉到地面上.'
            )
        else
            this.spill_items_to_surface = false
            get_actor(
                event,
                '{Item Spill}',
                '已禁用物品溢出功能。采矿时矿石不再掉落到地面.'
            )
        end
    end,
    ['comfy_panel_void_or_tile'] = function(event)
        local WPT = package.loaded['maps.mountain_fortress_v3.table']
        local this = WPT.get()
        if event.element.switch_state == 'left' then
            this.void_or_tile = 'out-of-map'
            get_actor(event, '{Void}', '已将各区的地砖改为：out-of-map (void)')
        else
            this.void_or_tile = 'lab-dark-2'
            get_actor(event, '{Void}', '已将各区的瓷砖改为：dark-tiles（易燃瓷砖）')
        end
    end,
    ['comfy_panel_trusted_only_car_tanks'] = function(event)
        local WPT = package.loaded['maps.mountain_fortress_v3.table']
        local this = WPT.get()
        if event.element.switch_state == 'left' then
            this.trusted_only_car_tanks = true
            get_actor(event, '{Market}', '已经改变了，只有受信任的人才能购买汽车/坦克.', true)
        else
            this.trusted_only_car_tanks = false
            get_actor(event, '{Market}', '已经改变，所以每个人都可以购买汽车/坦克.', true)
        end
    end
}

local function add_switch(element, switch_state, name, description_main, description)
    local t = element.add({type = 'table', column_count = 5})
    local label = t.add({type = 'label', caption = 'ON'})
    label.style.padding = 0
    label.style.left_padding = 10
    label.style.font_color = {0.77, 0.77, 0.77}
    local switch = t.add({type = 'switch', name = name})
    switch.switch_state = switch_state
    switch.style.padding = 0
    switch.style.margin = 0
    local label = t.add({type = 'label', caption = 'OFF'})
    label.style.padding = 0
    label.style.font_color = {0.70, 0.70, 0.70}

    local label = t.add({type = 'label', caption = description_main})
    label.style.padding = 2
    label.style.left_padding = 10
    label.style.minimal_width = 120
    label.style.font = 'heading-2'
    label.style.font_color = {0.88, 0.88, 0.99}

    local label = t.add({type = 'label', caption = description})
    label.style.padding = 2
    label.style.left_padding = 10
    label.style.single_line = false
    label.style.font = 'heading-3'
    label.style.font_color = {0.85, 0.85, 0.85}

    return switch
end

local build_config_gui = (function(player, frame)
    local AG = Antigrief.get()
    local switch_state
    local label

    local admin = player.admin
    frame.clear()

    local scroll_pane =
        frame.add {
        type = 'scroll-pane',
        horizontal_scroll_policy = 'never'
    }
    local scroll_style = scroll_pane.style
    scroll_style.vertically_squashable = true
    scroll_style.bottom_padding = 2
    scroll_style.left_padding = 2
    scroll_style.right_padding = 2
    scroll_style.top_padding = 2

    label = scroll_pane.add({type = 'label', caption = 'Player Settings'})
    label.style.font = 'default-bold'
    label.style.padding = 0
    label.style.left_padding = 10
    label.style.horizontal_align = 'left'
    label.style.vertical_align = 'bottom'
    label.style.font_color = {0.55, 0.55, 0.99}

    scroll_pane.add({type = 'line'})

    switch_state = 'right'
    if player.spectator then
        switch_state = 'left'
    end
    add_switch(
        scroll_pane,
        switch_state,
        'comfy_panel_spectator_switch',
        '观察者模式',
        '切换缩放世界观的噪音效果\n环境声音将基于地图视图'
    )

    scroll_pane.add({type = 'line'})

    if global.auto_hotbar_enabled then
        switch_state = 'right'
        if global.auto_hotbar_enabled[player.index] then
            switch_state = 'left'
        end
        add_switch(
            scroll_pane,
            switch_state,
            'comfy_panel_auto_hotbar_switch',
            '自动热键',
            '自动用可放置的项目填满你的热键栏'
        )
        scroll_pane.add({type = 'line'})
    end

    if package.loaded['comfy_panel.poll'] then
        local poll = package.loaded['comfy_panel.poll']
        local poll_table = poll.get_no_notify_players()
        switch_state = 'right'
        if not poll_table[player.index] then
            switch_state = 'left'
        end
        add_switch(
            scroll_pane,
            switch_state,
            'comfy_panel_poll_no_notify_toggle',
            '通知投票情况',
            '当新的投票被创建时，会收到一条消息，并弹出投票。'
        )
        scroll_pane.add({type = 'line'})
    end

    if admin then
        label = scroll_pane.add({type = 'label', caption = 'Admin Settings'})
        label.style.font = 'default-bold'
        label.style.padding = 0
        label.style.left_padding = 10
        label.style.top_padding = 10
        label.style.horizontal_align = 'left'
        label.style.vertical_align = 'bottom'
        label.style.font_color = {0.77, 0.11, 0.11}

        scroll_pane.add({type = 'line'})

        switch_state = 'right'
        if game.permissions.get_group('Default').allows_action(defines.input_action.open_blueprint_library_gui) then
            switch_state = 'left'
        end
        add_switch(
            scroll_pane,
            switch_state,
            'comfy_panel_blueprint_toggle',
            '蓝图库',
            '切换蓝图字符串和库的用法'
        )

        scroll_pane.add({type = 'line'})

        switch_state = 'right'
        if global.comfy_panel_config.spaghett.enabled then
            switch_state = 'left'
        end
        add_switch(
            scroll_pane,
            switch_state,
            'comfy_panel_spaghett_toggle',
            '物流系统',
            '禁用物流系统研究\n不能建立机器人物流的三个箱子.'
        )

        if package.loaded['comfy_panel.poll'] then
            scroll_pane.add({type = 'line'})
            switch_state = 'right'
            if global.comfy_panel_config.poll_trusted then
                switch_state = 'left'
            end
            add_switch(
                scroll_pane,
                switch_state,
                'comfy_panel_poll_trusted_toggle',
                '投票模式',
                '禁止未受信任的人创建投票.'
            )
        end

        scroll_pane.add({type = 'line'})

        label = scroll_pane.add({type = 'label', caption = 'Antigrief Settings'})
        label.style.font = 'default-bold'
        label.style.padding = 0
        label.style.left_padding = 10
        label.style.top_padding = 10
        label.style.horizontal_align = 'left'
        label.style.vertical_align = 'bottom'
        label.style.font_color = Color.yellow

        switch_state = 'right'
        if AG.enabled then
            switch_state = 'left'
        end
        add_switch(
            scroll_pane,
            switch_state,
            'comfy_panel_disable_antigrief',
            '地形保护插件',
            'Left = 开启 地形保护插件 / Right = 关闭 地形保护插件'
        )
        scroll_pane.add({type = 'line'})
		
		
        if package.loaded['maps.biter_battles_v2.main'] then
            label = scroll_pane.add({type = 'label', caption = 'Biter Battles Settings'})
            label.style.font = 'default-bold'
            label.style.padding = 0
            label.style.left_padding = 10
            label.style.top_padding = 10
            label.style.horizontal_align = 'left'
            label.style.vertical_align = 'bottom'
            label.style.font_color = Color.green

            scroll_pane.add({type = 'line'})
			
			local switch_state = "right"
			if global.bb_settings.team_balancing then switch_state = "left" end
			local switch = add_switch(scroll_pane, switch_state, "bb_team_balancing_toggle", "Team Balancing", "Players can only join a team that has less or equal players than the opposing.")
			if not admin then switch.ignored_by_interaction = true end
			
			scroll_pane.add({type = 'line'})
				
			local switch_state = "right"
			if global.bb_settings.only_admins_vote then switch_state = "left" end
			local switch = add_switch(scroll_pane, switch_state, "bb_only_admins_vote", "Admin Vote", "Only admins can vote for map difficulty. Clears all currently existing votes.")
			if not admin then switch.ignored_by_interaction = true end
			
			scroll_pane.add({type = 'line'})
		end
		
        if package.loaded['maps.mountain_fortress_v3.main'] then
            label = scroll_pane.add({type = 'label', caption = 'Mountain Fortress Settings'})
            label.style.font = 'default-bold'
            label.style.padding = 0
            label.style.left_padding = 10
            label.style.top_padding = 10
            label.style.horizontal_align = 'left'
            label.style.vertical_align = 'bottom'
            label.style.font_color = Color.green

            local Fullness = package.loaded['modules.check_fullness']
            local full = Fullness.get()
            switch_state = 'right'
            if full.fullness_enabled then
                switch_state = 'left'
            end
            add_switch(
                scroll_pane,
                switch_state,
                'comfy_panel_disable_fullness',
                '存货充实',
                'Left = 启用库存充实度。Right = 禁用库存充实度。'
            )

            scroll_pane.add({type = 'line'})

            local WPT = package.loaded['maps.mountain_fortress_v3.table']
            local this = WPT.get()
            switch_state = 'right'
            if this.offline_players_enabled then
                switch_state = 'left'
            end
            add_switch(
                scroll_pane,
                switch_state,
                'comfy_panel_offline_players',
                '离线玩家',
                '左 = 启用离线玩家库存下降。右 = 禁用离线玩家库存下降。.'
            )

            scroll_pane.add({type = 'line'})

            switch_state = 'right'
            if this.collapse_grace then
                switch_state = 'left'
            end
            add_switch(
                scroll_pane,
                switch_state,
                'comfy_panel_collapse_grace',
                '塌陷',
                '左=在第100波后启用崩溃。右=禁用崩溃--你必须到达第2区才能发生崩溃。'
            )

            scroll_pane.add({type = 'line'})

            switch_state = 'right'
            if this.spill_items_to_surface then
                switch_state = 'left'
            end
            add_switch(
                scroll_pane,
                switch_state,
                'comfy_panel_spill_items_to_surface',
                '溢出的矿石',
                '左 = 采矿时启用矿石溢出到地面。右 = 采矿时禁用矿石溢出到地面。.'
            )
            scroll_pane.add({type = 'line'})

            switch_state = 'right'
            if this.void_or_tile then
                switch_state = 'left'
            end
            add_switch(
                scroll_pane,
                switch_state,
                'comfy_panel_void_or_tile',
                '虚空砖',
                '左 = 将瓷砖改为地图外。右 = 将瓷砖改为实验室黑暗-2。'
            )
            scroll_pane.add({type = 'line'})

            switch_state = 'right'
            if this.trusted_only_car_tanks then
                switch_state = 'left'
            end
            add_switch(
                scroll_pane,
                switch_state,
                'comfy_panel_trusted_only_car_tanks',
                '市场购买',
                '左 = 只允许受信任的人购买汽车/坦克。右 = 允许所有人购买汽车/坦克。'
            )
            scroll_pane.add({type = 'line'})
        end
    end
    for _, e in pairs(scroll_pane.children) do
        if e.type == 'line' then
            e.style.padding = 0
            e.style.margin = 0
        end
    end
end)

local function on_gui_switch_state_changed(event)
    if not event.element then
        return
    end
    if not event.element.valid then
        return
    end
    if functions[event.element.name] then
        functions[event.element.name](event)
        return
    elseif antigrief_functions[event.element.name] then
        antigrief_functions[event.element.name](event)
        return
    elseif fortress_functions[event.element.name] then
        fortress_functions[event.element.name](event)
        return
    elseif package.loaded['comfy_panel.poll'] then
        if poll_function[event.element.name] then
            poll_function[event.element.name](event)
            return
        end
    end
end

local function on_force_created()
    spaghett()
end

local function on_built_entity(event)
    spaghett_deny_building(event)
end

local function on_robot_built_entity(event)
    spaghett_deny_building(event)
end

local function on_init()
    global.comfy_panel_config = {}
    global.comfy_panel_config.spaghett = {}
    global.comfy_panel_config.spaghett.undo = {}
    global.comfy_panel_config.poll_trusted = false
    global.comfy_panel_disable_antigrief = false
end

comfy_panel_tabs['配置'] = {gui = build_config_gui, admin = false}

local Event = require 'utils.event'
Event.on_init(on_init)
Event.add(defines.events.on_gui_switch_state_changed, on_gui_switch_state_changed)
Event.add(defines.events.on_force_created, on_force_created)
Event.add(defines.events.on_built_entity, on_built_entity)
Event.add(defines.events.on_robot_built_entity, on_robot_built_entity)
