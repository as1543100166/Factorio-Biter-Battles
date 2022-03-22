local Server = require 'utils.server'
local Color = require 'utils.color_presets'

local function revote()
    local player = game.player

    if player and player ~= nil then
        if not player.admin then
            player.print("[ERROR] 命令是管理员专用的。请询问管理员。", Color.warning)
            return

        else
            local tick = game.ticks_played
            global.difficulty_votes_timeout = tick + 10800
            global.difficulty_player_votes = {}
            msg = player.name .. " 开启了难度投票。投票启用了3分钟"
            game.print(msg)
            Server.to_discord_embed(msg)
        end
    end
end

local function close_difficulty_votes()
    local player = game.player

    if player and player ~= nil then
        if not player.admin then
            player.print("[ERROR] 命令是管理员专用的。请询问管理员。", Color.warning)
            return
        else
            global.difficulty_votes_timeout = game.ticks_played
            msg = player.name .. " 关闭难度投票"
            game.print(msg)
            Server.to_discord_embed(msg)
        end
    end
end

commands.add_command('difficulty-revote', 'open difficulty revote',
                     function(cmd) revote(); end)

commands.add_command('difficulty-close-vote', 'open difficulty revote',
                     function(cmd) close_difficulty_votes(); end)
