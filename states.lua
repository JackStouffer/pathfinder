-- fonts
smallFont = love.graphics.newFont(12)
largeFont = love.graphics.newFont(32)
middleFont = love.graphics.newFont(24)

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
    map = createDungeon()
	return temp
end

function Game:draw()
    if gameState == "world" then
        if showPerlin == 1 then plot2D(terrain.perlin)
        else
            love.graphics.setColor(0, 255, 0, 255)
            love.graphics.rectangle("fill", -1, -1, love.graphics.getWidth()+2, love.graphics.getHeight()+2)
            love.graphics.setBlendMode("additive")
            drawTerrain(terrain)
            love.graphics.setBlendMode("alpha")
        end
    elseif gameState == "cave" then
        love.graphics.push()
        	love.graphics.translate(player.translate_x, player.translate_y)
            drawMap()
            love.graphics.setColor(255, 255, 255) --because the button script sets the color to a slight blue
            love.graphics.draw(player.body, player.x, player.y)
        love.graphics.pop()
    end
    --debug info
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(smallFont)
    love.graphics.print("tile above:" .. tostring(testCollisionTile(0, -1)), 8, 2)
    love.graphics.print("player x:" .. player.x, 120, 2)
    love.graphics.print("player y:" .. player.y, 210, 2)
    love.graphics.print("translate_y:" .. player.translate_y, 300, 2)
    love.graphics.print("test:" .. player.y/16 + 1 - 1, 400, 2)
end

function Game:update(dt)

end

function Game:mousepressed(x, y, button)
	
end

function Game:keypressed(key)
    if gameState == "cave" then
        if key == 'up' and testMapEdge(0, -32) == false then -- if the player pushes up and is not at the end of the world
            if testCollisionTile(0, -1) == false then --then check for collision, this is done this way so testCollisionTile won't try to index a value that doesn't exist
                player.y = player.y - 32
                player.translate_y = player.translate_y + 32
            end
        end

        if key == 'down' and testMapEdge(0, 32) == false then
            if testCollisionTile(0, 1) == false then
                player.y = player.y + 32
                player.translate_y = player.translate_y - 32
            end
        end
       
        if key == 'left' and testMapEdge(-32, 0) == false then
            if testCollisionTile(-1, 0) == false then
                player.x = player.x - 32
                player.translate_x = player.translate_x + 32
            end
        end

        if key == 'right' and testMapEdge(32, 0) == false then
            if testCollisionTile(1, 0) == false then
                player.x = player.x + 32
                player.translate_x = player.translate_x - 32
            end
        end
    end

    if key == "r" then
        terrain = makeTerrain()
    elseif key == "p" then
        showPerlin = 1 - showPerlin
    elseif key == "c" then
        gameState = "cave"
    elseif key == "escape" then
        love.event.push("q")
    end
end
