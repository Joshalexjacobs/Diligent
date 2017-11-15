-- buttons.lua

Button = {
	x = 0,
	y = 0,
	w = 1,
	h = 1,
	color = {100, 100, 100, 255},
	hoverColor = {100, 100, 100, 100},
	clickColor = {25, 25, 25, 255},
	currentColor = {255, 255, 255, 255},
	image = "",
	text = "",
	click = function (self)
		return
	end,
	clickTimer = 1,
	clickTimerMax = 5,
	isClicked = false,
	isActive = true,
	parent = nil
}

Button.__index = Button

local buttons = {}

function Button:create(x, y, w, h, active)
	if active == nil then active = true end

	local button = {}
	setmetatable(button, Button)

	button.x, button.y, button.w, button.h = x, y, w, h
	button.isActive = active

	table.insert(buttons, button)
	return buttons[#buttons]
end

function Button:onClick()
	if self.click ~= nil then
		self.click(self)
		self.isClicked = true
	end
end

function Button:hover()
	if self.isActive == false then
		return false 
	end

	local x, y = love.mouse.getPosition()
	if x >= self.x and x <= self.x + self.w 
		and y >= self.y and y <= self.y + self.h then
		self.currentColor = self.hoverColor
		return true
	else
		self.currentColor = self.color
		return false
	end
end

function Button:draw()
	if self.isActive == false then
		return
	end

	if self.isClicked then
		love.graphics.setColor(self.clickColor)
		self.clickTimer = self.clickTimer + 1
		
		if self.clickTimer >= self.clickTimerMax then
			self.isClicked = false
			self.clickTimer = 1
		end
	else
		love.graphics.setColor(self.currentColor)
	end

	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

--[[ General Functions ]]

function updateButtons(dt)
	for i = 1, #buttons do 
		local button = buttons[i]
		
		button:hover()
	end
end

function checkButtons()
	for i = 1, #buttons do 
		local button = buttons[i]

		if button:hover() then
			return button
		end
	end

	return nil
end

function drawButtons()
	for i = 1, #buttons do 
		local button = buttons[i]

		button:draw()
	end
end