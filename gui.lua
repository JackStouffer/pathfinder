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

function drawGUI(system)
	love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 832, 0, 260, 576)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle("fill", 845, 20, 165 * (player.health / player.max_health), 15)
    love.graphics.setColor(0, 0, 255)
    love.graphics.rectangle("fill", 844, 45, 165 * (player.mana / player.max_mana), 15)
    love.graphics.setColor(255, 255, 255)
    
    love.graphics.setFont(smallFont)
    if current_player == 0 then
        if turn_state == 0 then
            love.graphics.print("movement", 860, 100)
        elseif turn_state == 1 then
            love.graphics.print("attack", 860, 100)
        elseif turn_state == 3 then
            love.graphics.print("end", 860, 100)
        end
    else
        love.graphics.print("Enemy Turn", 860, 100)
    end

    if system.map[current_level].clear == true then
        love.graphics.print("Level Clear", 860, 200)
    end

    love.graphics.setFont(mediumFont)
end