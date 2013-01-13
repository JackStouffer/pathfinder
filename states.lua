
smallFont = love.graphics.newFont(12)
mediumFont = love.graphics.newFont(32)

-- Menu State
-- Main menu...
Menu = {}
Menu.__index = Menu

function Menu.create()
	local temp = {}
	setmetatable(temp, Menu)
	temp.button = {	new = Button.create("New Game", 400, 250),
					instructions = Button.create("Instructions", 400, 300),
					options = Button.create("Options", 400, 350),
					quit = Button.create("Quit", 400, 550) }
	return temp
end

function Menu:draw()
	
	for n,b in pairs(self.button) do
		b:draw()
	end

end

function Menu:update(dt)
	
	for n,b in pairs(self.button) do
		b:update(dt)
	end
	
end

function Menu:mousepressed(x,y,button)
	
	for n,b in pairs(self.button) do
		if b:mousepressed(x,y,button) then
			if n == "new" then
				state = Game.create()
			elseif n == "instructions" then
				state = Instructions.create()
			elseif n == "options" then
				state = Options.create()
			elseif n == "quit" then
				love.event.push("quit")
			end
		end
	end
	
end

function Menu:keypressed(key)
	if key == "escape" then
		love.event.push("q")
	end
end


-- Instructions State
-- Shows the instructions
Instructions = {}
Instructions.__index = Instructions

function Instructions.create()
	local temp = {}
	setmetatable(temp, Instructions)
	temp.button = {	back = Button.create("Back", 400, 550) }
	return temp
end

function Instructions:draw()

	-- love.graphics.draw(graphics["logo"], 400, 125, 0, 1, 1, 100, 75)
	
	-- love.graphics.setColor(unpack(color["text"]))
	-- love.graphics.setFont(font["small"])
	love.graphics.printf("The point of this game is to fill out a standard, randomly generated, nonogram by using the mouse. The left mouse button fills in (or \"un-fills\") an area whilst the right mouse button is used to set hints where you think an area shouldn't be filled.\nUse the escape key to pause the game.\n\nGood luck.", 100, 250, 600, "center")
	
	for n,b in pairs(self.button) do
		b:draw()
	end

end

function Instructions:update(dt)
	
	for n,b in pairs(self.button) do
		b:update(dt)
	end
	
end

function Instructions:mousepressed(x,y,button)
	
	for n,b in pairs(self.button) do
		if b:mousepressed(x,y,button) then
			if n == "back" then
				state = Menu.create()
			end
		end
	end
	
end

function Instructions:keypressed(key)
	
	if key == "escape" then
		state = Menu.create()
	end
	
end


-- Options State
-- Shows the options
Options = {}
Options.__index = Options

function Options.create()
	local temp = {}
	setmetatable(temp, Options)
	temp.button = {	on = Button.create("On", 425, 300),
					off = Button.create("Off", 550, 300),
					five = Button.create(" 5 ", 375, 375),
					six = Button.create(" 6 ", 425, 375),
					seven = Button.create(" 7 ", 475, 375),
					eight = Button.create(" 8 ", 525, 375),
					--nine = Button.create(" 9 ", 575, 375),
					back = Button.create("Back", 400, 550) }
	return temp
end

function Options:draw()

	love.graphics.print("Audio:", 250, 270)
	love.graphics.print("Level:", 250, 345)
	
	-- love.graphics.setColor(unpack(color["main"]))
	love.graphics.setLine(4, "rough")
	
	if audio then
		love.graphics.line(400,305,450,305)
	else
		love.graphics.line(525,305,575,305)
	end
	
	love.graphics.line(360+((size-5)*50),380,390+((size-5)*50),380)
	
	for n,b in pairs(self.button) do
		b:draw()
	end

end

function Options:update(dt)
	
	for n,b in pairs(self.button) do
		b:update(dt)
	end
	
end

function Options:mousepressed(x,y,button)
	
	for n,b in pairs(self.button) do
		if b:mousepressed(x,y,button) then
			if n == "on" then
				audio = true
				love.audio.resume()
			elseif n == "off" then
				audio = false
				love.audio.pause()
			elseif n == "five" then
				size = 5
			elseif n == "six" then
				size = 6
			elseif n == "seven" then
				size = 7
			elseif n == "eight" then
				size = 8
			elseif n == "nine" then
				size = 9
			elseif n == "back" then
				state = Menu.create()
			end
		end
	end
	
end

function Options:keypressed(key)
	
	if key == "escape" then
		state = Menu.create()
	end
	
end


-- Game State
-- Where the actual playing takes place
Game = {}
Game.__index = Game

function Game.create()
	local temp = {}
	setmetatable(temp, Game)

	return temp
end

function Game:draw()
	
	draw_map()
	love.graphics.setFont(smallFont)
    love.graphics.print("@", player.x, player.y)
    
    --debug info
    love.graphics.print("map_h:" .. table.getn(map), 16, 2)
    love.graphics.print("map_w:" .. table.getn(map[1]), 100, 2)
    love.graphics.print("map_x:" ..map_x, 180, 2)
    love.graphics.print("test_coord:" .. (player.grid_y / 16) + 1 .. " " .. (player.grid_x / 16) + 1, 250, 2)
    love.graphics.print("test_map:" .. tostring(testMap(0, 1)), 390, 2)
	
end

function Game:update(dt)

end

function Game:mousepressed(x, y, button)
	
end

function Game:keypressed(key)
    if key == 'up' then
        if testMap(0, -1) then
            map_y = map_y - 1
            player.grid_y = player.grid_y - 16
            if map_y < 0 then 
                map_y = 0;
                player.y = player.y - 16
            end
        end
    end

    if key == 'down' then
        if testMap(0, 1) then
            map_y = map_y + 1
            player.grid_y = player.grid_y + 16
            if map_y > 14 then 
                map_y = 14;
                player.y = player.y + 16
            end
        end
    end
   
    if key == 'left' then
        if testMap(-1, 0) then
            player.grid_x = player.grid_x - 16
            if math.max(map_x - 1, 0) == map_x - 1 then
                map_x = map_x - 1
            elseif math.max(map_x - 1, 0) == 0 then
                map_x = 0
                player.x = player.x - 16
            end
        end
    end

    if key == 'right' then
        if testMap(1, 0) then
            player.grid_x = player.grid_x + 16
            if math.min(map_x + 1, 19) == map_x + 1 then --for some reason, map_w - map_display_w does not work for the second param
                map_x = map_x + 1
            elseif math.min(map_x + 1, 19) == 19 then
                map_x = 19
                player.x = player.x + 16
            end 
        end
    end
end
