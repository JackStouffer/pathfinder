
Button = {}
Button.__index = Button

function Button.create(text,x,y)
	
	local temp = {}
	setmetatable(temp, Button)
	temp.hover = false -- whether the mouse is hovering over the button
	temp.click = false -- whether the mouse has been clicked on the button
	temp.text = text -- the text in the button
	temp.width = largeFont:getWidth(text)
	temp.height = largeFont:getHeight()
	temp.x = x - (temp.width / 2)
	temp.y = y
	return temp
	
end

function Button:draw()
	
	love.graphics.setFont(largeFont)
	if self.hover then love.graphics.setColor(255, 255, 255)
	else love.graphics.setColor(214, 169, 187) end
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
		love.audio.play(clickSound)
		return true
	end
	
	return false
	
end
