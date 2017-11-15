-- scene.lua

Scene = {
	path = nil,
	vPath = nil
}

Scene.__index = Scene

local selectedEnemy = nil

function Scene:create(name)
	local scene = {}
	setmetatable(scene, Scene)

	scene.name = name
	scene.enemies = {}
	return scene
end

function Scene:addEnemy(newEnemy, time, x, y, dir)
	if newEnemy == nil then return end

	local enemyName = string.gsub(newEnemy.name, '%.lua', "")
	local w, h = newEnemy.animation[1]:getDimensions()

	local enemy = {
		name = enemyName,
		spriteSheet = newEnemy.spriteSheet,
		animation = newEnemy.animation,
		time = time,
		x = x - w / 2,
		y = y - h / 2,
		w = w,
		h = h,
		trueX = x - prop.VIGILANT_X,
		trueY = y - prop.VIGILANT_Y,
		dir = dir,
		suit = suit.new(),
		xInput = {},
		yInput = {}
	}

	enemy.xInput = {text = tostring(enemy.trueX)}
	-- xInput.text = tostring(enemy.trueX)
	enemy.yInput = {text = tostring(enemy.trueY)}

	if #self.enemies > 0 then
		local index = 1

		for _, selfEnemy in ipairs(self.enemies) do
			if selfEnemy.time > enemy.time then
				break
			end
			
			index = index + 1
		end

		table.insert(self.enemies, index, enemy)
		selectedEnemy = self.enemies[index]
	else
		table.insert(self.enemies, enemy)
		selectedEnemy = self.enemies[#self.enemies]
	end
end

function Scene:updateSelectedEnemyProperties()
	if selectedEnemy ~= nil then
		selectedEnemy.suit:Input(selectedEnemy.xInput, 180, 645, 120, 30)
		selectedEnemy.suit:Input(selectedEnemy.yInput, 180, 680, 120, 30)
	end
end

function Scene:enemyHover()
	local x, y = love.mouse.getPosition()

	for i = 1, #self.enemies do
		local enemy = self.enemies[i]
		if x >= enemy.x and x <= enemy.x + enemy.w 
		and y >= enemy.y and y <= enemy.y + enemy.h then
			return enemy
		end
	end
end

function Scene:setSelectedEnemy(enemy)
	selectedEnemy = enemy
end

function Scene:getSelectedEnemy()
	return selectedEnemy
end

function Scene:drawEnemies()
	-- should only draw enemies for the current time you're on...
	-- or within the past 10 seconds or so

	for i = 1, #self.enemies do
		local enemy = self.enemies[i]

		enemy.animation[1]:draw(enemy.spriteSheet, enemy.x, enemy.y)

		if prop.DEBUG then
			-- local w, h = enemy.animation[1]:getDimensions()
			if selectedEnemy ~= nil and selectedEnemy == enemy then
				love.graphics.setColor({255, 0, 0, 255})
			else
				love.graphics.setColor({0, 255, 0, 255})
			end

			love.graphics.rectangle("line", enemy.x, enemy.y, enemy.w, enemy.h)
			love.graphics.setColor({255, 255, 255, 255})
		end
	end
end

function Scene:drawSelectedEnemyProperties()
	local x = 180
	local y = 620

	love.graphics.setColor({100, 100, 100, 255})
	love.graphics.rectangle("fill", x, y + 20, 120, 125)

	if selectedEnemy == nil then
		return
	end

	love.graphics.setColor({255, 255, 255, 255})
	love.graphics.printf(selectedEnemy.name, x, y, 120, "center")
 
	-- love.graphics.printf("X: " .. selectedEnemy.trueX, x + 5, y + 25, 120, "left")
	-- love.graphics.printf("Y: " .. selectedEnemy.trueY, x + 5, y + 50, 120, "left")

	-- love.graphics.printf("Dir: " .. selectedEnemy.dir, x + 5, y + 75, 120, "left")

	selectedEnemy.suit:draw()
end

local function writeTo(path, content)
	local file = io.open(path, "w")
	file:write(content)
	file:close()
end

function Scene:writeToFile()
	local content = ""

	for i = 1, #self.enemies do
		local enemy = self.enemies[i]
		content = content .. enemy.name .. " " .. enemy.time .. " " .. enemy.trueX .. " " .. enemy.trueY .. " " .. enemy.dir .. "\n"
	end

	content = content .. "end 0.0 1 1 1"
	
	self.vPath = prop.VIGILANT_DIR .. "/timelines/" .. self.name .. "-" .. os.time() .. ".txt"
	self.path = "save/scenes/" .. self.name .. "-" .. os.time() .. ".txt"

	writeTo(self.vPath, content)
	writeTo(self.path, content)
end

function Scene:printEnemies()
	for _, selfEnemy in ipairs(self.enemies) do
		print(selfEnemy.name .. " " ..selfEnemy.time)
	end
end