-- comb.lua

local luaFiles = {}

local function excludedFiles(file)
	for i = 1, #prop.EXCLUDED_FILES do
		if file == prop.EXCLUDED_FILES[i] then
			return false
		end
	end

	return true
end

local function combLuaFiles()
	print("Modifying Repo Paths...")

	for _, luaFile in ipairs(luaFiles) do
		-- print(luaFile)
		local file = io.open(luaFile, "r")
		local content = file:read("*all")
		file:close()

		for i = 1, #prop.VARS_TO_COMB do
			content = string.gsub(content, prop.VARS_TO_COMB[i], prop.VARS_TO_COMB[i] .. "Vigilant-Waffle/")
		end

		local file = io.open(luaFile, "w")
		file:write(content)
		file:close()
	end
end

local function changeVigilantMain()
	print("Injecting love.load() into " .. prop.VIGILANT_DIR .. "/main.lua...")

	local file = io.open(prop.VIGILANT_DIR .. "/main.lua", "r")
	local content = file:read("*all")
	file:close()

	content = string.gsub(content, prop.MAIN_UPDATE, prop.MAIN_REPLACER)
	-- print(content)

	local file = io.open(prop.VIGILANT_DIR .. "/main.lua", "w")
	file:write(content)
	file:close()

	prop.COMBED = true
	prop:save()
end

function combVigilantRepo(directory)
	if directory == nil then
		return
	end

	local files = love.filesystem.getDirectoryItems(directory)

	if files == nil then
		return
	end

	print("Combing Directory: "..tostring(directory))

	for i = 1, #files do
		local isDir = love.filesystem.isDirectory(directory .. "/" .. files[i])

		if isDir == false and string.find(tostring(files[i]), ".lua") ~= nil then
			table.insert(luaFiles, directory .. "/" .. files[i])
		elseif excludedFiles(files[i]) then
			combVigilantRepo(directory .. "/" .. files[i])
		end
	end

	if directory == prop.VIGILANT_DIR then
		combLuaFiles()
		changeVigilantMain()
	end
end

function setVigilantScene(scene)
	if #scene.enemies < 1 then
		return 
	end
	
	local file = io.open(prop.VIGILANT_DIR .. prop.VIGILANT_TIMELINE, "r")
	local content = file:read("*all")
	file:close()

	content = string.gsub(content, 'local timelineName = %b""', 'local timelineName = "' .. scene.vPath .. '"')
	file = io.open(prop.VIGILANT_DIR .. prop.VIGILANT_TIMELINE, "w")
	file:write(content)
	file:close()
end

function getLuaFiles()
	for i = 1, #luaFiles do
		print(luaFiles[i])
	end
end