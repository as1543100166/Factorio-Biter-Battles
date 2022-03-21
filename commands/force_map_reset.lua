local Server = require 'utils.server'
local Color = require 'utils.color_presets'

local function force_map_reset(reason)
    local player = game.player

    if player and player ~= nil then
        if not player.admin then
            player.print("[ERROR] 命令是管理员专用的。请询问管理员。",
                         Color.warning)
            return
        elseif not reason or string.len(reason) <= 5 then
            player.print("[错误]请输入原因，最小长度为5。")
        else
	    if not global.rocket_silo["north"].valid then
		game.print("[错误]地图已经在重置过程中了")
		return
	    end

            msg ="Admin " .. player.name .. " 启动地图重置。原因是。 " .. reason
            game.print(msg, Color.warning)
            Server.to_discord_embed(msg)
            local p = global.rocket_silo["north"].position
            global.rocket_silo["north"].die("south_biters")
        end
    end
end

commands.add_command('force-map-reset',
                     '通过杀死北面的发射井来强制重置地图: /force-map-reset <原因> ',
                     function(cmd) force_map_reset(cmd.parameter); end)
