-- enemies.lua

Enemy = {
	name = "",
	spriteSheet = "",
	spriteGrid = nil,
	animation = {},
	button = {}
}

Enemy.__index = Enemy

local enemies = {}
selection = nil
local enemyPage = 1

function Enemy:create(name, spriteSheet, spriteGrid)
	local enemy = {}
	setmetatable(enemy, Enemy)

	-- enemy.spriteSheet = spriteSheet
	enemy.name = name
	enemy.spriteSheet = love.graphics.newImage(spriteSheet)
	enemy.spriteGrid = spriteGrid
	enemy.animation = {
		anim8.newAnimation(enemy.spriteGrid(1, 1), 0.05)
	}

	return enemy
end

local function splitByComma(string)
	local returnTable = {}
	local i = 1

	for x in string.gmatch(string, '%d+,') do
		table.insert(returnTable, tonumber(string.sub(x, 1, #x-1)))

		i = i + 1
		if i > 4 then 
			return returnTable 
		end
	end
end

local function getSpriteSheet(fileName)
	for line in io.lines(fileName) do
		if string.find(line, prop.ENEMY_VARS[1]) then
			local indexOne = string.find(line, '"') + 1
			local indexTwo = string.find(line, '"', indexOne) - 1
			return string.sub(line, indexOne, indexTwo)
		end
	end

	return ""
end

local function getSpriteGrid(fileName)
	for line in io.lines(fileName) do
		if string.find(line, prop.ENEMY_VARS[2]) then
			local indexOne = string.find(line, "%(") + 1
			local indexTwo = string.find(line, "%)", indexOne) - 1
			local grid = string.sub(line, indexOne, indexTwo)

			local t = splitByComma(grid)
			return anim8.newGrid(t[1], t[2], t[3], t[4], 0, 0, 0)
		end
	end

	return ""
end

local function activateEnemyListButtons(page)
	-- deactivate 5 buttons depending on the current page
	for i = page * 5 - 4, page * 5 do
		enemies[i].button.isActive = not enemies[i].button.isActive
	end	
end

local function loadEnemyButtons()
	-- [[ Create Up and Down buttons ]]

	local upButton = Button:create(10, 640, 25, 62.5)
	local downButton = Button:create(10, 702.5, 25, 62.5)

	upButton.color = {100, 100, 100, 255}
	downButton.color = {100, 100, 100, 255}

	upButton.click = function()
		if enemyPage > 1 then 
			activateEnemyListButtons(enemyPage)
			enemyPage = enemyPage - 1
			activateEnemyListButtons(enemyPage)
		end
	end

	downButton.click = function()
		if enemyPage * 5 < #enemies then 
			activateEnemyListButtons(enemyPage)
			enemyPage = enemyPage + 1
			activateEnemyListButtons(enemyPage)
		end
	end

	-- [[ Create enemy list buttons ]]

	for i = 1, #enemies do
		local enemy = enemies[i]

		local offI = i % 5
		if offI == 0 then offI = 5 end
		
		enemy.button = Button:create(40, 615 + offI * 25, 120, 25, false)
		enemy.button.parent = enemy
		enemy.button.color = {100, 100, 100, 15}
		enemy.button.hoverColor = {25, 25, 25, 50}
		enemy.button.clickColor = {0, 0, 0, 100}
		enemy.button.click = function(self)
			selection = self.parent
		end
	end

	activateEnemyListButtons(enemyPage)
end

function getCurrentEnemy()
	if selection == nil then
		return
	end

	return selection
end

function loadEnemies()
	local files = love.filesystem.getDirectoryItems(prop.VIGILANT_DIR .. prop.VIGILANT_ENEMIES)

	for i = 1, #files do 
		if files[i] == "templateEnemy.lua" then break end

		local fileName = prop.VIGILANT_DIR .. prop.VIGILANT_ENEMIES .. "/" .. files[i]

		local spriteSheet = getSpriteSheet(fileName)
		local spriteGrid = getSpriteGrid(fileName)

		table.insert(enemies, Enemy:create(files[i], spriteSheet, spriteGrid))
	end

	-- [[ Set up Enemy UI Assets ]]

	loadEnemyButtons() -- buttons
end

function drawEnemiesList()
	-- variables for easy adjustment
	local x = 40
	local y = 620

	love.graphics.setColor({100, 100, 100, 255})
	love.graphics.rectangle("fill", x, y + 20, 120, 125)

	love.graphics.setColor({255, 255, 255, 255})
	love.graphics.printf("enemies", x, y, 120, "center")

	-- [[ Draw enemy list ]]
	local offI = 1
	for i = ((enemyPage - 1) * 5) + 1 , #enemies do
		local enemy = enemies[i]

		if selection == enemy then
			love.graphics.setColor({255, 150, 25, 255})
		else
			love.graphics.setColor({255, 255, 255, 255})
		end

		love.graphics.printf(enemy.name, x + 5, y + offI * 25, 110, "left") -- move me out later

		offI = offI + 1

		if offI > 5 then 
			break
		end
	end
end