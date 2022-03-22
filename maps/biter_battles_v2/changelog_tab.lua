-- changelog tab -- 
local Tabs = require 'comfy_panel.main'

local function add_changelog(player, element)
	local changelog_scrollpanel = element.add { type = "scroll-pane", name = "scroll_pane", direction = "vertical", horizontal_scroll_policy = "never", vertical_scroll_policy = "auto"}
	changelog_scrollpanel.style.maximal_height = 530
	
	local changelog_change = {}
	table.insert(changelog_change,"2022-3-22")
	table.insert(changelog_change,"初步添加汉化")
	table.insert(changelog_change,"Alex")
	table.insert(changelog_change,"2021-12-17")
	table.insert(changelog_change,"Auto tagging outpost")
	table.insert(changelog_change,"Ragnarok77")
	table.insert(changelog_change,"2021-12-15")
	table.insert(changelog_change,"Clear clipboard on game join")
	table.insert(changelog_change,"AwesomePatrol")
	table.insert(changelog_change,"2021-12-15")
	table.insert(changelog_change,"Add more threat to compensate revive")
	table.insert(changelog_change,"AwesomePatrol")
	table.insert(changelog_change,"2021-12-15")
	table.insert(changelog_change,"Set path_finder settings")
	table.insert(changelog_change,"AwesomePatrol")
	table.insert(changelog_change,"2021-12-15")
	table.insert(changelog_change,"Increased copper and stone size by 10%")
	table.insert(changelog_change,"Ragnarok77")
	table.insert(changelog_change,"2021-12-12")
	table.insert(changelog_change,"Fix silo grief (mirroring)")
	table.insert(changelog_change,"Ragnarok77")
	table.insert(changelog_change,"2021-12-15")
	table.insert(changelog_change,"Add changelog tab")
	table.insert(changelog_change,"Ragnarok77")
	table.insert(changelog_change,"2021-12-12")
	table.insert(changelog_change,"Update/prevent landfilling by untrusted user")
	table.insert(changelog_change,"Ragnarok77")
	table.insert(changelog_change,"2021-12-09")
	table.insert(changelog_change,"Do not allow ghosts on enemy side")
	table.insert(changelog_change,"developer-8")
	table.insert(changelog_change,"2021-12-09")
	table.insert(changelog_change,"Limited threshold of biters reviving to 90% chance")
	table.insert(changelog_change,"Ragnarok77")
	table.insert(changelog_change,"2021-12-12")
	table.insert(changelog_change,"Removed trust check on clear-corpses command")
	table.insert(changelog_change,"Ragnarok77")
	table.insert(changelog_change,"2021-12-09")
	table.insert(changelog_change,"Added infinite spy when white science is thrown")
	table.insert(changelog_change,"Ragnarok77")
	table.insert(changelog_change,"2021-12-09")
	table.insert(changelog_change,"Fix difficulty GUI lag spikes")
	table.insert(changelog_change,"AwesomePatrol")
	table.insert(changelog_change,"2021-12-06")
	table.insert(changelog_change,"Improve biter performance")
	table.insert(changelog_change,"AwesomePatrol")
	table.insert(changelog_change,"2021-12-09")
	table.insert(changelog_change,"fix antigrief inconsistency")
	table.insert(changelog_change,"XVhc6A")
	table.insert(changelog_change,"2021-11-19")
	table.insert(changelog_change,"Quick and dirty way to fix desync")
	table.insert(changelog_change,"TheBigZet")
	table.insert(changelog_change,"2021-12-06")
	table.insert(changelog_change,"Added special_games system")
	table.insert(changelog_change,"TheBigZet")
	table.insert(changelog_change,"2021-11-08")
	table.insert(changelog_change,"Change text warning to accurately reflect mechanics")
	table.insert(changelog_change,"Tomab")
	table.insert(changelog_change,"2021-11-10")
	table.insert(changelog_change,"Improved readme")
	table.insert(changelog_change,"Tomab")
	table.insert(changelog_change,"2021-11-21")
	table.insert(changelog_change,"Ban improvements")
	table.insert(changelog_change,"TheBigZet")
	table.insert(changelog_change,"2021-10-30")
	table.insert(changelog_change,"mutes - make mute great again")
	table.insert(changelog_change,"mysticamber")
	table.insert(changelog_change,"2021-10-30")
	table.insert(changelog_change,"shout-fix: fix shout logging so that non admin shouts get logged too")
	table.insert(changelog_change,"mysticamber")

	
	local t = changelog_scrollpanel.add { type = "table", name = "changelog_header_table", column_count = 3 }
	local column_widths = {tonumber(115), tonumber(435), tonumber(230)}
	local headers = {
		[1] = "日期",
		[2] = "变化",
		[3] = "作者",
	}
	for _, w in ipairs(column_widths) do
	local label = t.add { type = "label", caption = headers[_] }
	label.style.minimal_width = w
	label.style.maximal_width = w
	label.style.font = "default-bold"
	label.style.font_color = { r=0.98, g=0.66, b=0.22 }
	end
	changelog_panel_table = changelog_scrollpanel.add { type = "table", column_count = 3 }
	if changelog_change then
		for i = 1, #changelog_change, 3 do
			local label = changelog_panel_table.add { type = "label", name = "changelog_date" .. i, caption = changelog_change[i] }
			label.style.minimal_width = column_widths[1]
			label.style.maximal_width = column_widths[1]
			local label = changelog_panel_table.add { type = "label", name = "changelog_change" .. i, caption = changelog_change[i+1] }
			label.style.minimal_width = column_widths[2]
			label.style.maximal_width = column_widths[2]
			local label = changelog_panel_table.add { type = "label", name = "changelog_author" .. i, caption = changelog_change[i+2] }
			label.style.minimal_width = column_widths[3]
			label.style.maximal_width = column_widths[3]
		end
	end
end

function comfy_panel_get_active_frame(player)
	if not player.gui.left.comfy_panel then return false end
	if not player.gui.left.comfy_panel.tabbed_pane.selected_tab_index then return player.gui.left.comfy_panel.tabbed_pane.tabs[1].content end
	return player.gui.left.comfy_panel.tabbed_pane.tabs[player.gui.left.comfy_panel.tabbed_pane.selected_tab_index].content 
end

local build_config_gui = (function (player, frame)		
	local frame_changelog = comfy_panel_get_active_frame(player)
	if not frame_changelog then
		return
	end
	frame_changelog.clear()
	add_changelog(player, frame_changelog)
end)

comfy_panel_tabs["更新日志"] = {gui = build_config_gui, admin = false}