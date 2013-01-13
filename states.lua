-- fonts
smallFont = love.graphics.newFont(12)
mediumFont = love.graphics.newFont(18)
largeFont = love.graphics.newFont(32)

--Music/Sound
menuMusic = love.audio.newSource("music/AlaFlair.ogg")
clickSound = love.audio.newSource("sounds/click1.wav")

-- Menu State
-- Main menu...
Menu = {}
Menu.__index = Menu

function Menu.create()
	local temp = {}
	setmetatable(temp, Menu)
	love.audio.play(menuMusic)
	logoImage = love.graphics.newImage("textures/logo.png")
	temp.button = {	new = Button.create("New Game", 360, 270),
					instructions = Button.create("Instructions", 360, 320),
					options = Button.create("Options", 360, 370),
					quit = Button.create("Quit", 360, 420) }
	return temp
end

function Menu:draw()

	for n,b in pairs(self.button) do
		b:draw()
	end
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(logoImage, 60, 50)

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
	temp.button = {	back = Button.create("Back", 350, 200) }
	return temp
end

function Instructions:draw()
	love.graphics.setFont(smallFont)
	love.graphics.printf("This is filler text yo", 50, 50, 600, "center")
	
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
	temp.button = {back = Button.create("Back", 350, 200)}
	return temp
end

function Options:draw()
	
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
			if n == "back" then
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
	love.audio.stop(menuMusic)
	love.graphics.setColor(255, 255, 255) --because the button script sets the color to a slight blue
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
