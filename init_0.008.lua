  --[[      TrieFilter      ]]--
  --[[   init.lua - 0.008   ]]--
  --[[  monk (c) 2023 MITL  ]]--
local match = string.match
local gmatch = string.gmatch
local lower = string.lower
local gsub = string.gsub
local rep = string.rep
local sub = string.sub

local max_caps = 32


local filter = {
	blacklist = {},
}
local blacklist = filter.blacklist

local blacklist_file = "blacklist.lua"

local index_lists = function()
	local blacklist_items = dofile(blacklist_file)

	return blacklist_items
end

local blacklist_items = index_lists()
local index_filter = function()
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

		table.insert(blacklist[index][tail][head], listed_item)
	end
	return filter
end
index_filter()

local function try_blacklist(try_word)
	word = gsub(lower(try_word), "[^a-zA-Z]", "")

	local index = #word

	if index <= 1 then
		return word
	end

	local head = sub(word, 1, 1)
	local tail = sub(word, -1)
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

local function remove_links(string)
	return gsub(string, "h*t*t*p*s*:*/*/*%S+%.+%S+%.*%S%S%S?/*%S*%s?", "")
end

local function make_word_table(string)
	local word_table, n = {}, 1

	gsub(string, "%S+", function(word)
		if not word_table[n] then
			word_table[n] = ""
		end
		
		word_table[n] = word
		n = n + 1
	end)
	return word_table
end


local fakechat = "fakechat.txt"  -- Replace with input stream from here
local function simulate_chat()

	local function file_exists(file)
		local f = io.open(file,"rb")
		if f then f:close() end
		return f~=nil
	end

	if not file_exists(fakechat) then
		return
	end

	for message in io.lines(fakechat) do  -- replace fakechat with real chat
		print(os.date("%b-%d %H:%M:%S"))
		local string = message

		if #string > max_caps then
			string:lower()
		end

		string = remove_links(string)

		local word_table = {}
		word_table = make_word_table(string)

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
				alpha[a] = (alpha[a] or "") .. omega[o]
				lambda[a] = alpha[a]
			end

			if alpha[a] then
				lambda[a] = try_blacklist(alpha[a])
			end
		end

		local mentions = {}
		for word = 1,#lambda do
			gsub(lambda[word], "^@([a-zA-Z0-9_-]+)", function(name)
				table.insert(mentions, name)
			end)
		end
		print(table.concat(mentions, ", "))
		return table.concat(lambda, " ")
	end
end


local send_message = simulate_chat()

print("X: "..send_message)
