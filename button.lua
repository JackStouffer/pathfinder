--[[
Code originally created by Michael Enger and was under the zlib license
This code is copyrighted Jack Stouffer. Any use of this code without the
express permission of Jack Stouffer will suffer the consequences of the
law.
--]]

Button = {}
Button.__index = Button

function Button.create(text,x,y)
	
	local temp = {}
	setmetatable(temp, Button)
	temp.hover = false -- whether the mouse is hovering over the button
	temp.click = false -- whether the mouse has been clicked on the button
	temp.text = text -- the text in the button
	temp.width = love.graphics.newFont(32):getWidth(text)
	temp.height = love.graphics.newFont(32):getHeight()
	temp.x = x - (temp.width / 2)
	temp.y = y
	return temp
	
end

function Button:draw()
	
	love.graphics.setFont(love.graphics.newFont(32))
	-- if self.hover then love.graphics.setColor(unpack(color["main"]))
	-- else love.graphics.setColor(unpack(color["text"])) end
	love.graphics.print(self.text, self.x, self.y-self.height)
	
end

function Button:update(dt)
	
	self.hover = false
	
	local x = love.mouse.getX()
	local y = love.mouse.getY()
	
	if x > self.x
		and x < self.x + self.width
		and y > self.y - self.height
		and y < self.y then
		self.hover = true
	end
	
end

function Button:mousepressed(x, y, button)
	
	if self.hover then
		if audio then
			love.audio.play(sound["click"])
		end
		return true
	end
	
	return false
	
end
