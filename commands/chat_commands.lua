local Server = require 'utils.server'
local Muted = require 'utils.muted'
local string_find = string.find

local function chat_with_team(message, team)
    local player = game.player
    if player and player.valid then
        local player_name = player.name

        local tag = player.tag
        if not tag then tag = "" end
        local color = player.chat_color

        local a, b = string_find(message, "gps=", 1, false)
        if a then return end

        local msg = "[To " .. team .. "] " .. player_name .. tag .. " (" ..
                        player.force.name .. "): " .. message

        if not Muted.is_muted(player_name) then
            game.forces.spectator.print(msg, color)
            if (team == "north" or player.force.name == "north") then
                game.forces.north.print(msg, color)
            end
            if (team == "south" or player.force.name == "south") then
                game.forces.south.print(msg, color)
            end
        else
            msg = "[muted] " .. msg
            Muted.print_muted_message(player)
        end
        Server.to_discord_player_chat(msg)
    end
end

commands.add_command('sth', '与南方聊天。你可以使用 /south-chat',
                     function(cmd)
    local message = tostring(cmd.parameter)
    chat_with_team(message, 'south')
end)

commands.add_command('south-chat', '与南方聊天。你可以使用/sth',
                     function(cmd)
    game.player.print("系统:你也可以用/sth")
    local message = tostring(cmd.parameter)
    chat_with_team(message, 'south')
end)

commands.add_command('nth', '与北方聊天。与/north-chat相同',
                     function(cmd)
    local message = tostring(cmd.parameter)
    chat_with_team(message, 'north')
end)

commands.add_command('north-chat', '与北方聊天。你可以使用/nth',
                     function(cmd)
    game.player.print("系统:你也可以用/nth")
    local message = tostring(cmd.parameter)
    chat_with_team(message, 'north')
end)
