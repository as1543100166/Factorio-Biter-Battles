local Server = require 'utils.server'
local mapkeeper = '[color=blue]Mapkeeper:[/color]'

commands.add_command(
    'scenario',
    'Usable only for admins - controls the scenario!',
    function(cmd)
        local p
        local player = game.player

        if not player or not player.valid then
            p = log
        else
            p = player.print
            if not player.admin then
                return
            end
        end

        local param = cmd.parameter

        if param == 'restart' or param == 'shutdown' or param == 'restartnow' then
            goto continue
        else
            p('[ERROR] 参数是:\nrestart\nshutdown\nrestartnow')
            return
        end

        ::continue::

        if not global.reset_are_you_sure then
            global.reset_are_you_sure = true
            p('[WARNING] 这条命令将禁用软复位功能，如果你真的想这样做，请再次运行这条命令。')
            return
        end

        if param == 'restart' then
            if global.restart then
                global.reset_are_you_sure = nil
                global.restart = false
                global.soft_reset = true
                p('[SUCCESS] Soft-reset is enabled.')
                return
            else
                global.reset_are_you_sure = nil
                global.restart = true
                global.soft_reset = false
                if global.shutdown then
                    global.shutdown = false
                end
                p('[WARNING] 软复位功能被禁用! 服务器将从场景中重新启动.')
                return
            end
        elseif param == 'restartnow' then
            global.reset_are_you_sure = nil
            p(player.name .. ' has restarted the game.')
            Server.start_scenario('Biter_Battles')
            return
        elseif param == 'shutdown' then
            if global.shutdown then
                global.reset_are_you_sure = nil
                global.shutdown = false
                global.soft_reset = true
                p('[SUCCESS] Soft-reset is enabled.')
                return
            else
                global.reset_are_you_sure = nil
                global.shutdown = true
                global.soft_reset = false
                if global.restart then
                    global.restart = false
                end
                p('[WARNING] 软复位功能被禁用! 服务器将被关闭.')
                return
            end
        end
    end
)
