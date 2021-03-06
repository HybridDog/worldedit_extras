local load_time_start = os.clock()

worldedit.node_is_valid = worldedit.node_is_valid or function(nodename)
	return minetest.registered_nodes[nodename]
	or minetest.registered_nodes["default:" .. nodename]
end

local random = math.random
worldedit.rr = function(pos1, pos2, searchnode, replacenode, zahl)
	local pos1, pos2 = worldedit.sort_pos(pos1, pos2)

	if not minetest.registered_nodes[searchnode] then
		searchnode = "default:" .. searchnode
	end

	local node = {name=replacenode}

	local count = 0
	for z = pos1.z, pos2.z do
		for y = pos1.y, pos2.y do
			for x = pos1.x, pos2.x do
				if random(1, zahl) == 1 then
					local pos = {x=x,y=y,z=z}
					if minetest.get_node(pos).name == searchnode then
						minetest.set_node(pos, node)
						count = count+1
					end
				end
			end
		end
	end
	return count
end

--[[function worldedit.create_bomb_list()
	local tab = {}
	local num = 1
	for _,i in ipairs(nuke.bombs_list) do
		tab[num] = minetest.get_content_id("nuke:"..i[1].."_tnt")
		tab[num] = "nuke:"..i[1].."_tnt"
		num = num+1
	end
	return tab
end]]

function worldedit.lit_bombs(pos1, pos2, name)
	local pos1, pos2 = worldedit.sort_pos(pos1, pos2)
	local count = 0

	for i = pos1.x, pos2.x do
		for j = pos1.y, pos2.y do
			for k = pos1.z, pos2.z do
				local pos = {x=i, y=j, z=k}
				local node = minetest.get_node(pos)
				for _,l in pairs(nuke.bombs_list) do
					if node.name == "nuke:"..l[1].."_tnt" then
						nuke.lit_tnt(pos, node.name, name)
						count = count+1
						break
					end
				end
			end
		end
	end
	return count
end

minetest.register_chatcommand("/rr", {
	params = "<search node> <replace node> <zahl>",
	description = "Replace all instances of <search node> with <replace node> in the current WorldEdit region",
	privs = {worldedit=true},
	func = function(name, param)
		local pos1, pos2 = worldedit.pos1[name], worldedit.pos2[name]
		if pos1 == nil or pos2 == nil then
			minetest.chat_send_player(name, "No WorldEdit region selected")
			return
		end

		local found, _, searchnode, replacenode, zahl = param:find("^([^%s]+)%s+([^%s]+)%s+([^%s]+)$")
		if found == nil then
			minetest.chat_send_player(name, "Invalid usage: " .. param)
			return
		end
		if not worldedit.node_is_valid(searchnode) then
			minetest.chat_send_player(name, "Invalid search node name: " .. searchnode)
			return
		end
		if not worldedit.node_is_valid(replacenode) then
			minetest.chat_send_player(name, "Invalid replace node name: " .. replacenode)
			return
		end

		local count = worldedit.rr(pos1, pos2, searchnode, replacenode, zahl)
		minetest.chat_send_player(name, count .. " nodes random replaced")
	end,
})

minetest.register_chatcommand("/lit", {
	params = "",
	description = "Lit bombs",
	privs = {worldedit=true},
	func = function(name)
		local pos1, pos2 = worldedit.pos1[name], worldedit.pos2[name]
		if not pos1
		or not pos2 then
			minetest.chat_send_player(name, "No WorldEdit region selected")
			return
		end

		minetest.chat_send_player(name, worldedit.lit_bombs(pos1, pos2, name) .. " bombs lit")
	end,
})


local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "[worldedit_extras] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end
