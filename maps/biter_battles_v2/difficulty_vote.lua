local bb_config = require "maps.biter_battles_v2.config"
local ai = require "maps.biter_battles_v2.ai"
local event = require 'utils.event'
local Server = require 'utils.server'
local Tables = require "maps.biter_battles_v2.tables"
require 'utils/gui_styles'

local difficulties = Tables.difficulties

local function difficulty_gui(player)
	local value = math.floor(global.difficulty_vote_value*100)
	if player.gui.top["difficulty_gui"] then player.gui.top["difficulty_gui"].destroy() end
	local str = table.concat({"全球地图难度为 ", difficulties[global.difficulty_vote_index].name, ". 变异有 ", value, "% 效果."})
	local b = player.gui.top.add { type = "sprite-button", caption = difficulties[global.difficulty_vote_index].name, tooltip = str, name = "difficulty_gui" }
	b.style.font = "heading-2"
	b.style.font_color = difficulties[global.difficulty_vote_index].print_color
	element_style({element = b, x = 114, y = 38, pad = -2})
end

local function difficulty_gui_all()
	for _, player in pairs(game.connected_players) do
		difficulty_gui(player)
	end
end

local function poll_difficulty(player)
	if player.gui.center["difficulty_poll"] then player.gui.center["difficulty_poll"].destroy() return end
	
	if global.bb_settings.only_admins_vote or global.tournament_mode then
		if not player.admin then return end
	end
	
	local tick = game.ticks_played
	if tick > global.difficulty_votes_timeout then
		if player.online_time ~= 0 then
			local t = math.abs(math.floor((global.difficulty_votes_timeout - tick) / 3600))
			local str = "投票已经结束 " .. t
			str = str .. " 分钟"
			if t > 1 then str = str .. "s" end
			str = str .. " 之前."
			player.print(str)
		end
		return 
	end
	
	local frame = player.gui.center.add { type = "frame", caption = "投票决定全球难度:", name = "difficulty_poll", direction = "vertical" }
	for key, _ in pairs(difficulties) do
		local b = frame.add({type = "button", name = tostring(key), caption = difficulties[key].name .. " (" .. difficulties[key].str .. ")"})
		b.style.font_color = difficulties[key].color
		b.style.font = "heading-2"
		b.style.minimal_width = 180
	end
	local b = frame.add({type = "label", caption = "- - - - - - - - - - - - - - - - - - - -"})
	local b = frame.add({type = "button", name = "close", caption = "关闭 (" .. math.floor((global.difficulty_votes_timeout - tick) / 3600) .. " 分钟之前)"})
	b.style.font_color = {r=0.66, g=0.0, b=0.66}
	b.style.font = "heading-3"
	b.style.minimal_width = 96
end

local function set_difficulty()
	local a = {}
	local vote_count = 0
	local c = 0
	local v = 0
	for _, d in pairs(global.difficulty_player_votes) do
		c = c + 1
		a[c] = d
		vote_count = vote_count + 1
	end
	if vote_count == 0 then return end
	v= math.floor(vote_count/2)+1
	table.sort(a)
	local new_index = a[v]
	if global.difficulty_vote_index ~= new_index then
		local message = table.concat({">> 地图难度已改为 ", difficulties[new_index].name, " 难度!"})
		game.print(message, difficulties[new_index].print_color)
		Server.to_discord_embed(message)
	end
	 global.difficulty_vote_index = new_index
	 global.difficulty_vote_value = difficulties[new_index].value
	 ai.reset_evo()
end

local function on_player_joined_game(event)
	if not global.difficulty_vote_value then global.difficulty_vote_value = 1 end
	if not global.difficulty_vote_index then global.difficulty_vote_index = 4 end
	if not global.difficulty_player_votes then global.difficulty_player_votes = {} end
	
	local player = game.players[event.player_index]
	if game.ticks_played < global.difficulty_votes_timeout then
		if not global.difficulty_player_votes[player.name] then
			if global.bb_settings.only_admins_vote or global.tournament_mode then
				if player.admin then poll_difficulty(player) end
			end
		end
	else
		if player.gui.center["difficulty_poll"] then player.gui.center["difficulty_poll"].destroy() end
	end
	
	difficulty_gui_all()
end

local function on_player_left_game(event)
	if game.ticks_played > global.difficulty_votes_timeout then return end
	local player = game.players[event.player_index]
	if not global.difficulty_player_votes[player.name] then return end
	global.difficulty_player_votes[player.name] = nil
	set_difficulty()
end

local function on_gui_click(event)
	if not event then return end
	if not event.element then return end
	if not event.element.valid then return end
	local player = game.players[event.element.player_index]
	if event.element.name == "difficulty_gui" then
		poll_difficulty(player)
		return
	end
	if event.element.type ~= "button" then return end
	if event.element.parent.name ~= "difficulty_poll" then return end
	if event.element.name == "close" then event.element.parent.destroy() return end
	if game.ticks_played > global.difficulty_votes_timeout then event.element.parent.destroy() return end
	local i = tonumber(event.element.name)
	
	if global.bb_settings.only_admins_vote or global.tournament_mode then
		if player.admin then
			game.print(player.name .. " 已投票给 " .. difficulties[i].name .. " 难度!", difficulties[i].print_color)
			global.difficulty_player_votes[player.name] = i
			set_difficulty()
			difficulty_gui(player)
		end
		event.element.parent.destroy()
		return
	end

    if player.spectator then
        player.print("旁观者不能投票选择难度")
		event.element.parent.destroy()
        return
    end

	if game.tick - global.spectator_rejoin_delay[player.name] < 3600 then
        player.print(
            "未准备好投票。请等待 " .. 60-(math.floor((game.tick - global.spectator_rejoin_delay[player.name])/60)) .. " seconds.",
            {r = 0.98, g = 0.66, b = 0.22}
        )
		event.element.parent.destroy()
        return
    end
	
	game.print(player.name .. " 已投票给 " .. difficulties[i].name .. " 难度!", difficulties[i].print_color)
	global.difficulty_player_votes[player.name] = i
	set_difficulty()
	difficulty_gui_all()
	event.element.parent.destroy()
end
	
event.add(defines.events.on_gui_click, on_gui_click)
event.add(defines.events.on_player_left_game, on_player_left_game)
event.add(defines.events.on_player_joined_game, on_player_joined_game)

local Public = {}
Public.difficulties = difficulties
Public.difficulty_gui = difficulty_gui
Public.difficulty_gui_all = difficulty_gui_all

return Public
