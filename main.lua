-- main.lua

--[[
	TODO: 
	- Output timeline.txt and inject timeline.txt into timelineManager.lua
	- Save current scene
	- Timeline (in seconds)
	- Select and move enemies
	- Display enemy info (x, y, time, etc...) on screen 
]]

require "properties"
require "scene"
require "enemies"
require "comb"
require "button"
require "lib/timer"
anim8 = require "lib/anim8"
suit = require "lib/suit"

prop = Properties:create()

currentScene = Scene:create("scene1")
local scenes = {}
local sceneIndex = 1
local playTestButton = Button:create(884, 640, 120, 120)
local debugModeButton = Button:create(10, 770, 25, 20)

function love.textinput(t)
	if tonumber(t) ~= nil or t == '-' then
		-- suit.textinput(t)
		-- local selectedEnemy = currentScene:getSelectedEnemy()
		-- if selectedEnemy ~= nil then
		-- 	selectedEnemy.suit:textinput(t)
		-- end
	end
end

function love:keypressed(key, code)
  if key == 'escape' then -- quit on escape
    love.event.quit()
  elseif key == 'b' then
    prop.DEBUG = not prop.DEBUG
  end
  
 --  local selectedEnemy = currentScene:getSelectedEnemy()
	-- if selectedEnemy ~= nil then
	-- 	selectedEnemy.suit:keypressed(key)
	-- end
end

function love.mousepressed(x, y, button)
	if button == 1 then
		local button = checkButtons()
		local enemy = currentScene:enemyHover() 
		if button ~= nil then
			button:onClick(button)
		elseif enemy ~= nil then
			currentScene:setSelectedEnemy(enemy)
		end
	elseif button == 2 then
		if y < 600 then
			currentScene:addEnemy(getCurrentEnemy(), 0.00, x, y, 1)
		end
	end 
end

local function getRemoteCommit()
	local handle = io.popen("cd Vigilant-Waffle\ngit rev-parse origin/master", "r")

	for lines in handle:lines() do
		prop.REMOTE_COMMIT = lines
		print("REMOTE_COMMIT  "..prop.REMOTE_COMMIT)
	end
end

function love.load(arg)
	playTestButton.color = {100, 150, 100, 255}
	playTestButton.hoverColor = {100, 200, 100, 255}
	playTestButton.click = function()
		love.graphics.setColor({255, 255, 255, 255})
		currentScene:writeToFile()
		setVigilantScene(currentScene)
		love.filesystem.load("Vigilant-Waffle/main.lua")() -- lol it just feels wrong that this works
	end

	debugModeButton.click = function()
		prop.DEBUG = not prop.DEBUG
	end

	love.window.setMode(1024, 800, {resizable=false, vsync=true})

	-- [[ Handle Vigilant Repo ]]

	-- if Vigilant directory isn't found then...
	if love.filesystem.exists(prop.VIGILANT_DIR) == false then
		
		prop.COMBED = false
		prop:save()

		-- git clone Vigilant
		if (os.execute("git clone " .. prop.VIGILANT_GIT) > 0) then
			love.errhand("ERROR CLONING VIGILANT REPOSITORY:\n" .. prop.VIGILANT_GIT .. "\nMake sure git is installed before runnning " .. prop.APP_NAME)
			love.event.quit()
		end
	else -- else..
		for line in io.lines(prop.VIGILANT_COMMIT_PATH) do
			prop.CURRENT_COMMIT = line
			print("CURRENT_COMMIT "..prop.CURRENT_COMMIT)

			getRemoteCommit()
			break
		end

		-- ..check if we need to pull the latest commit
		if prop.CURRENT_COMMIT ~= prop.REMOTE_COMMIT then
			print("Cleaning up Vigilant-Waffle repo...")
			os.execute("git reset head --hard") -- may need this
			os.execute("git pull origin master") -- grab latest commit
		end
	end

	-- [[ Comb Vigilant Repo ]]
	if prop.COMBED == false then
		combVigilantRepo(prop.VIGILANT_DIR)
	end
	
	--[[ Load Enemies ]]
	loadEnemies()
end

function love.update(dt)
	updateButtons(dt)
	currentScene:updateSelectedEnemyProperties()
end

function love.draw()
	love.graphics.setColor({75, 75, 75, 255})
	love.graphics.rectangle("fill", prop.VIGILANT_X, prop.VIGILANT_Y, 408, 260)

	love.graphics.setColor({15, 15, 15, 255})
	love.graphics.rectangle("fill", 0, 600, 1024, 427)

	love.graphics.setColor({255, 255, 255, 255})

	drawEnemiesList()
	currentScene:drawEnemies()
	
	currentScene:drawSelectedEnemyProperties()

	drawButtons()
end
