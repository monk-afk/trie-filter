  --[[      FilterPlus      ]]--
  --[[   init.lua - 0.010   ]]--
  --[[  monk (c) 2023 MITL  ]]--
local concat = table.concat
local insert = table.insert
local gmatch = string.gmatch
local match  = string.match
local lower  = string.lower
local gsub   = string.gsub
local rep    = string.rep
local sub    = string.sub
local time   = os.time

local max_caps = 12

local filter = {
	blacklist = {},
	players_online = {},
}
local blacklist = filter.blacklist
local players_online = filter.players_online
local blacklist_file = "blacklist.lua"

local blacklist_items = dofile(blacklist_file)

local index_blacklist = function()
	for i, listed_item in pairs(blacklist_items) do
		local index = #blacklist_items[i]
		local head = sub(blacklist_items[i], 1, 1)
		local tail = sub(blacklist_items[i], -1)

		if not blacklist[index] then
			blacklist[index] = {}
		end

		if not blacklist[index][tail] then
			blacklist[index][tail] = {}
		end

		if not blacklist[index][tail][head] then
			blacklist[index][tail][head] = {}
		end

		insert(blacklist[index][tail][head], listed_item)
	end
	return filter
end
index_blacklist()


local function send_message(message, sender, mentions)
	local message = concat(message, " ")

	if #message > max_caps then
		message = lower(message)
	end

	if mentions then
		for recipient,_ in pairs(players_online) do
			print(recipient, message)
		end
		return
	end
	print("all "..message)
	return 
end


local function try_blacklist(try_word)
	local word = gsub(lower(try_word), "[^a-zA-Z]", "")

	local index = #word

	if index <= 1 then
		return try_word
	end

	local head = sub(word, 1, 1)
	local tail = sub(word, -1)

	if not blacklist[index] or
			not blacklist[index][tail] or
			not blacklist[index][tail][head] then
		return try_word
	end

	local blacklist_keys = blacklist[index][tail] and blacklist[index][tail][head]

	if blacklist_keys then
		for n = 1, #blacklist_keys do
			if word == blacklist_keys[n] then
				word = rep("*", #blacklist_keys[n])
				return word
			end
		end
	end
	return try_word
end


local function process_message(word_table, sender)
	local mentions
	local a = 1
	local alpha = {}
	local omega = word_table
	local lambda = {}
	
	for o = 1, #word_table do

		if alpha[a] and #omega[o] > 1 then
			alpha[a] = nil 
			a = a + 1
		end

		if #omega[o] > 1 then
			lambda[a] = try_blacklist(omega[o])
			a = a + 1
		end

		if #omega[o] == 1 then
			alpha[a]  = (alpha[a] or "") .. omega[o]
			lambda[a] =  alpha[a]
		end

		if alpha[a] then
			lambda[a] = try_blacklist(alpha[a])
		end
		
			local name = gsub(word_table[o], "[^a-zA-Z0-9_-]*$", "")
			for players,_ in pairs(players_online) do
				if lower(name) == lower(players) then
					if not mentions then
						mentions = {}
					end
					mentions[players] = true
					print(mentions[players])
				end
			end
	end
	return send_message(lambda, sender, mentions)
end

local function remove_links(string)
	return gsub(string, "h*t*t*p*s*:*/*/*%S+%.+%S+%.*%S%S%S?/*%S*%s?", "")
end

local function make_word_table(string)
	local word_table
	local n = 1

	gsub(string, "%S+", function(word)
		if word then
			if not word_table then
				word_table = {}
			end
			word_table[n] = word
			n = n + 1
		end
	end)

	return word_table
end


local on_chat_message = function(name, message)

	if players_online[name] >= time() then
		return true, print(name, "You are muted.")
	end

	local string = message
	string = remove_links(string)

	local word_table = {}
	word_table = make_word_table(string)

	if word_table then
		process_message(word_table, name)
	end

	return true
end


local name = "moNkk"
players_online[name] = time()-1

local message = "MONK this is a fucking test"

on_chat_message(name, message)

print(os.clock())