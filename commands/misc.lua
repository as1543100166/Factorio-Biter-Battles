local Session = require 'utils.datastore.session_data'
local Modifiers = require 'player_modifiers'
local Server = require 'utils.server'
local Color = require 'utils.color_presets'

commands.add_command(
    'spaghetti',
    'Does spaghett.',
    function(cmd)
        local p_modifer = Modifiers.get_table()
        local player = game.player
        local _a = p_modifer
        local param = tostring(cmd.parameter)
        local force = game.forces['player']
        local p

        if player then
            if player ~= nil then
                p = player.print
                if not player.admin then
                    p("[错误] 你不是管理员!", Color.fail)
                    return
                end
            else
                p = log
            end
        end

        if param == nil then
            player.print('[错误]参数为 true/false', Color.yellow)
            return
        end
        if param == 'true' then
            if not _a.spaghetti_are_you_sure then
                _a.spaghetti_are_you_sure = true
                player.print('Spaghetti未被启用，再次运行此命令以启用spaghett', Color.yellow)
                return
            end
            if _a.spaghetti_enabled == true then
                player.print('Spaghetti 已被启用.', Color.yellow)
                return
            end
            game.print('这个世界已经被修饰了!', Color.success)
            force.technologies['logistic-system'].enabled = false
            force.technologies['construction-robotics'].enabled = false
            force.technologies['logistic-robotics'].enabled = false
            force.technologies['robotics'].enabled = false
            force.technologies['personal-roboport-equipment'].enabled = false
            force.technologies['personal-roboport-mk2-equipment'].enabled = false
            force.technologies['character-logistic-trash-slots-1'].enabled = false
            force.technologies['character-logistic-trash-slots-2'].enabled = false
            force.technologies['auto-character-logistic-trash-slots'].enabled = false
            force.technologies['worker-robots-storage-1'].enabled = false
            force.technologies['worker-robots-storage-2'].enabled = false
            force.technologies['worker-robots-storage-3'].enabled = false
            force.technologies['character-logistic-slots-1'].enabled = false
            force.technologies['character-logistic-slots-2'].enabled = false
            force.technologies['character-logistic-slots-3'].enabled = false
            force.technologies['character-logistic-slots-4'].enabled = false
            force.technologies['character-logistic-slots-5'].enabled = false
            force.technologies['character-logistic-slots-6'].enabled = false
            force.technologies['worker-robots-speed-1'].enabled = false
            force.technologies['worker-robots-speed-2'].enabled = false
            force.technologies['worker-robots-speed-3'].enabled = false
            force.technologies['worker-robots-speed-4'].enabled = false
            force.technologies['worker-robots-speed-5'].enabled = false
            force.technologies['worker-robots-speed-6'].enabled = false
            _a.spaghetti_enabled = true
        elseif param == 'false' then
            if _a.spaghetti_enabled == false or _a.spaghetti_enabled == nil then
                player.print('Spaghetti 已被禁用.', Color.yellow)
                return
            end
            game.print('世界不再是spaghett!', Color.yellow)
            force.technologies['logistic-system'].enabled = true
            force.technologies['construction-robotics'].enabled = true
            force.technologies['logistic-robotics'].enabled = true
            force.technologies['robotics'].enabled = true
            force.technologies['personal-roboport-equipment'].enabled = true
            force.technologies['personal-roboport-mk2-equipment'].enabled = true
            force.technologies['character-logistic-trash-slots-1'].enabled = true
            force.technologies['character-logistic-trash-slots-2'].enabled = true
            force.technologies['auto-character-logistic-trash-slots'].enabled = true
            force.technologies['worker-robots-storage-1'].enabled = true
            force.technologies['worker-robots-storage-2'].enabled = true
            force.technologies['worker-robots-storage-3'].enabled = true
            force.technologies['character-logistic-slots-1'].enabled = true
            force.technologies['character-logistic-slots-2'].enabled = true
            force.technologies['character-logistic-slots-3'].enabled = true
            force.technologies['character-logistic-slots-4'].enabled = true
            force.technologies['character-logistic-slots-5'].enabled = true
            force.technologies['character-logistic-slots-6'].enabled = true
            force.technologies['worker-robots-speed-1'].enabled = true
            force.technologies['worker-robots-speed-2'].enabled = true
            force.technologies['worker-robots-speed-3'].enabled = true
            force.technologies['worker-robots-speed-4'].enabled = true
            force.technologies['worker-robots-speed-5'].enabled = true
            force.technologies['worker-robots-speed-6'].enabled = true
            _a.spaghetti_enabled = false
        end
    end
)

commands.add_command(
    'generate_map',
    'Pregenerates map.',
    function(cmd)
        local p_modifer = Modifiers.get_table()
        local _a = p_modifer
        local player = game.player
        local param = tonumber(cmd.parameter)
        local p

        if player then
            if player ~= nil then
                p = player.print
                if not player.admin then
                    p("[错误] 你不是管理员!", Color.fail)
                    return
                end
            else
                p = log
            end
        end
        if param == nil then
            player.print('[ERROR] 必须指定半径!', Color.fail)
            return
        end
        if param > 50 then
            player.print('[ERROR] 数值太大。', Color.fail)
            return
        end

        if not _a.generate_map then
            _a.generate_map = true
            player.print(
                '[警告]这个命令将使服务器变成LAG，如果你真的想这样做，请再运行这个命令',
                Color.yellow
            )
            return
        end
        local radius = param
        local surface = game.players[1].surface
        if surface.is_chunk_generated({radius, radius}) then
            game.print('地图生成完成!', Color.success)
            _a.generate_map = nil
            return
        end
        surface.request_to_generate_chunks({0, 0}, radius)
        surface.force_generate_chunk_requests()
        for _, pl in pairs(game.connected_players) do
            pl.play_sound {path = 'utility/new_objective', volume_modifier = 1}
        end
        game.print('地图生成完成!', Color.success)
        _a.generate_map = nil
    end
)

commands.add_command(
    'dump_layout',
    'Dump the current map-layout.',
    function()
        local p_modifer = Modifiers.get_table()
        local _a = p_modifer
        local player = game.player
        local p

        if player then
            if player ~= nil then
                p = player.print
                if not player.admin then
                    p("[错误] 你不是管理员!", Color.warning)
                    return
                end
            else
                p = log
            end
        end
        if not _a.dump_layout then
            _a.dump_layout = true
            player.print(
                '[警告]这个命令将使服务器变成LAG，如果你真的想这样做，请再运行这个命令',
                Color.yellow
            )
            return
        end
        local surface = game.players[1].surface
        game.write_file('layout.lua', '', false)

        local area = {
            left_top = {x = 0, y = 0},
            right_bottom = {x = 32, y = 32}
        }

        local entities = surface.find_entities_filtered {area = area}
        local tiles = surface.find_tiles_filtered {area = area}

        for _, e in pairs(entities) do
            local str = '{position = {x = ' .. e.position.x
            str = str .. ', y = '
            str = str .. e.position.y
            str = str .. '}, name = "'
            str = str .. e.name
            str = str .. '", direction = '
            str = str .. tostring(e.direction)
            str = str .. ', force = "'
            str = str .. e.force.name
            str = str .. '"},'
            if e.name ~= 'character' then
                game.write_file('layout.lua', str .. '\n', true)
            end
        end

        game.write_file('layout.lua', '\n', true)
        game.write_file('layout.lua', '\n', true)
        game.write_file('layout.lua', 'Tiles: \n', true)

        for _, t in pairs(tiles) do
            local str = '{position = {x = ' .. t.position.x
            str = str .. ', y = '
            str = str .. t.position.y
            str = str .. '}, name = "'
            str = str .. t.name
            str = str .. '"},'
            game.write_file('layout.lua', str .. '\n', true)
            player.print('将布局转储为文件： layout.lua', Color.success)
        end
        _a.dump_layout = false
    end
)

commands.add_command(
    'creative',
    'Enables creative_mode.',
    function()
        local p_modifer = Modifiers.get_table()
        local _a = p_modifer
        local player = game.player
        local p

        if player then
            if player ~= nil then
                p = player.print
                if not player.admin then
                    p("[错误] 你不是管理员!", Color.fail)
                    return
                end
            else
                p = log
            end
        end
        if not _a.creative_are_you_sure then
            _a.creative_are_you_sure = true
            player.print(
                '[警告]此命令将为所有连接的玩家启用创造/作弊模式，如果你真的想这样做，请再次运行此命令',
                Color.yellow
            )
            return
        end
        if _a.creative_enabled == true then
            player.print('[ERROR] 创造/作弊模式已经激活!', Color.fail)
            return
        end

        game.print(player.name .. ' 激活了创造模式!', Color.warning)
        Server.to_discord_bold(table.concat {'[Creative] ' .. player.name .. ' 激活了创造模式!'})

        for k, v in pairs(game.connected_players) do
            v.cheat_mode = true
            if v.character ~= nil then
                if v.get_inventory(defines.inventory.character_armor) then
                    v.get_inventory(defines.inventory.character_armor).clear()
                end
                v.insert {name = 'power-armor-mk2', count = 1}
                local p_armor = v.get_inventory(5)[1].grid
                if p_armor and p_armor.valid then
                    p_armor.put({name = 'fusion-reactor-equipment'})
                    p_armor.put({name = 'fusion-reactor-equipment'})
                    p_armor.put({name = 'fusion-reactor-equipment'})
                    p_armor.put({name = 'exoskeleton-equipment'})
                    p_armor.put({name = 'exoskeleton-equipment'})
                    p_armor.put({name = 'exoskeleton-equipment'})
                    p_armor.put({name = 'energy-shield-mk2-equipment'})
                    p_armor.put({name = 'energy-shield-mk2-equipment'})
                    p_armor.put({name = 'energy-shield-mk2-equipment'})
                    p_armor.put({name = 'energy-shield-mk2-equipment'})
                    p_armor.put({name = 'personal-roboport-mk2-equipment'})
                    p_armor.put({name = 'night-vision-equipment'})
                    p_armor.put({name = 'battery-mk2-equipment'})
                    p_armor.put({name = 'battery-mk2-equipment'})
                end
                local item = game.item_prototypes
                local i = 0
                for _k, _v in pairs(item) do
                    i = i + 1
                    if _k and _v.type ~= 'mining-tool' then
                        _a[k].character_inventory_slots_bonus['creative'] = tonumber(i)
                        v.character_inventory_slots_bonus = _a[k].character_inventory_slots_bonus['creative']
                        v.insert {name = _k, count = _v.stack_size}
                        v.print('插入了所有基础项目.', Color.success)
                        _a.creative_enabled = true
                    end
                end
            end
        end
    end
)

commands.add_command(
    'delete-uncharted-chunks',
    '删除所有不在图表中的区块。可以减少保存游戏的文件大小。在某些自定义地图中使用可能不安全。',
    function()
        local player = game.player
        local p
        if player then
            if player ~= nil then
                p = player.print
                if not player.admin then
                    p("[错误] 你不是管理员!", Color.fail)
                    return
                end
            else
                p = log
            end
        end

        local forces = {}
        for _, force in pairs(game.forces) do
            if force.index == 1 or force.index > 3 then
                table.insert(forces, force)
            end
        end

        local is_charted
        local count = 0
        for _, surface in pairs(game.surfaces) do
            for chunk in surface.get_chunks() do
                is_charted = false
                for _, force in pairs(forces) do
                    if force.is_chunk_charted(surface, {chunk.x, chunk.y}) then
                        is_charted = true
                        break
                    end
                end
                if not is_charted then
                    surface.delete_chunk({chunk.x, chunk.y})
                    count = count + 1
                end
            end
        end

        local message = player.name .. ' 删除了 ' .. count .. ' 未知的区块!'
        game.print(message, Color.warning)
        Server.to_discord_bold(table.concat {message})
    end
)
