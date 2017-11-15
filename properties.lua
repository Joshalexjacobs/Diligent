-- properties.lua

Properties = {
	APP_NAME = "Vitrify", -- Diligent?

	VIGILANT_DIR = "Vigilant-Waffle",
	VIGILANT_IMG = "/img",
	VIGILANT_ENEMIES = "/enemies",
	VIGILANT_TIMELINE = "/timelineManager.lua",
	VIGILANT_GIT = "https://github.com/Joshalexjacobs/Vigilant-Waffle.git",
	VIGILANT_COMMIT_PATH = "Vigilant-Waffle/.git/refs/heads/master",

	PROPERTIES_NAME = "properties.txt",
	PROPERTIES_DIR = "save",

	CURRENT_COMMIT = "",
	REMOTE_COMMIT = "",

	VIGILANT_X = 308,
	VIGILANT_Y = 80,

	VARS_TO_COMB = {
		'require "',
		'newFont%(%"',
		'timelineName = "',
		'sprite = "',
		'spriteSheet = "',
		'newImage%(%"',
	},

	-- context: `string.gsub(content, 'maid64.newImage("', 'maid64.newImage("' .. "game/")`

	EXCLUDED_FILES = {
		".git",
		"img",
		"lib",
		"timelines",
	},

	MAIN_UPDATE = "function love.update%(dt%)\n\nend",

	MAIN_REPLACER = [[
local isLoaded = false

function love.update(dt)
	if isLoaded == false then
		love.load()
		isLoaded = true
	end
end ]],

	ENEMY_VARS = {
		'spriteSheet = "',
		'spriteGrid = anim8',
		'anim8.newAnimation',
	},

	COMBED = false,
	DEBUG = true,
}

Properties.__index = Properties

function Properties:create()
	local properties = {}
	setmetatable(properties, Properties)
	
	properties:load()
	return properties
end

function Properties:load()
	print("Loading properties.txt...")

	local file = io.open(self.PROPERTIES_DIR.."/"..self.PROPERTIES_NAME, "r")
	local content = file:read("*all")
	file:close()

	if content == "false" then 
		self.COMBED = false
	elseif content == "true" then
		self.COMBED = true
	end
end

function Properties:save()
	-- save current properties
	print("Saving to properties.txt...")

	local file = io.open(self.PROPERTIES_DIR.."/"..self.PROPERTIES_NAME, "w")
	file:write(tostring(self.COMBED))
	file:close()
end