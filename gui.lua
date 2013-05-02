Button = class{text, x, y}

function Button:__init(text,x,y)
	self.hover = false -- whether the mouse is hovering over the button
	self.click = false -- whether the mouse has been clicked on the button
	self.once = false
	self.text = text -- the text in the button
	self.width = largeFont:getWidth(text)
	self.height = largeFont:getHeight()
	self.x = x - (self.width / 2)
	self.y = y
end

function Button:draw()
	love.graphics.setFont(mediumFont)
	
	if self.hover then 
		love.graphics.setColor(255, 255, 255)
	else 
		love.graphics.setColor(214, 169, 187) 
	end
	
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

	if not self.once and self.hover then -- if the mouse is inside the button
    	love.audio.play(rolloverSound)
    	self.once = true
  	elseif self.once and not self.hover then
    	self.once = false
  	end
end

function Button:mousepressed(x, y, button)
	if self.hover then
		love.audio.play(clickSound)
		return true
	end
	
	return false
end
