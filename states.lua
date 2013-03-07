-- fonts
smallFont = love.graphics.newFont(12)
largeFont = love.graphics.newFont(32)
middleFont = love.graphics.newFont(24)

--Music/Sound
menuMusic = love.audio.newSource("music/AlaFlair.ogg")
clickSound = love.audio.newSource("sounds/click1.wav")
rolloverSound = love.audio.newSource("sounds/rollover1.wav")

-- Menu State
-- Main menu...
Menu = {}
Menu.__index = Menu

function Menu.create()
	local temp = {}
	setmetatable(temp, Menu)
	love.audio.play(menuMusic)
	logoImage = love.graphics.newImage("textures/logo.png")
    backgroundImage = love.graphics.newImage("textures/background.png")
	temp.button = {	new = Button.create("New Game", 512, 300),
					instructions = Button.create("Instructions", 512, 350),
					options = Button.create("Options", 512, 400),
					quit = Button.create("Quit", 512, 450) }
	return temp
end

function Menu:draw()
    love.graphics.draw(backgroundImage, 0, 0)
	for n,b in pairs(self.button) do
		b:draw()
	end
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(logoImage, 200, 50)

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
    local openX = 0
    local openY = 0
	setmetatable(temp, Game)
	love.audio.stop(menuMusic)
    map = createCave(mapWidth, mapHeight)
    -- when assigning a value to value that is a table, lua does not set the original value to the table, but rather as a pointer to the table
    --so if I change collisionMap.x = 5 the map.x = 5 as well
    collisionMap = TSerial.unpack(TSerial.pack(map))
    for num=1, 2 do
        ent.enimines[num] = monster:new(100, "textures/dc-mon/acid_blob.png")
    end
    terrain = makeTerrain()
    Astar(collisionMap)
    Astar:setObstValue(2)
    Astar:disableDiagonalMove()
	return temp
end

function Game:draw()
    if gameState == "world" then
        if showPerlin == 1 then plot2D(terrain.perlin)
        else
            love.graphics.setColor(161, 235, 255, 255)
            love.graphics.rectangle("fill", -1, -1, love.graphics.getWidth()+2, love.graphics.getHeight()+2)
            drawTerrain(terrain)
        end
    elseif gameState == "cave" then
        love.graphics.push()
        	love.graphics.translate(player.translate_x, player.translate_y) --have the player always centered
            drawMap(map, mapWidth, mapHeight)
            love.graphics.setColor(255, 255, 255) --because the button script sets the color to a slight blue
            love.graphics.draw(player.body, player.x, player.y)
            for x=1,#ent.enimines do
                ent.enimines[x]:draw()
            end
        love.graphics.pop()

        --gui
        love.graphics.draw(guiBar, 0, 476)
        love.graphics.setFont(mediumFont)
        love.graphics.print(player.health, 47, 520)
        love.graphics.print(player.magic, 203, 520)
        love.graphics.print("1", 400, 520)
    end
    --debug info
    love.graphics.setColor(255, 255, 255)
end

function Game:update(dt)

end

function Game:mousepressed(x, y, button)
	
end

function Game:keypressed(key)
    if gameState == "cave" then
        if key == 'up' and testMapEdge(0, -32, mapWidth, mapHeight) == false then -- if the player pushes up and is not at the end of the world
            if testCollisionTile(0, -1) == false then --then check for collision, this is done this way so testCollisionTile won't try to index a value that doesn't exist
                player.y = player.y - 32
                player.translate_y = player.translate_y + 32
            end
            for x=1,#ent.enimines do
                ent.enimines[x]:turn()
            end
        end

        if key == 'down' and testMapEdge(0, 32, mapWidth, mapHeight) == false then
            if testCollisionTile(0, 1) == false then
                player.y = player.y + 32
                player.translate_y = player.translate_y - 32
            end
            for x=1,#ent.enimines do
                ent.enimines[x]:turn()
            end
        end
       
        if key == 'left' and testMapEdge(-32, 0, mapWidth, mapHeight) == false then
            if testCollisionTile(-1, 0) == false then
                player.x = player.x - 32
                player.translate_x = player.translate_x + 32
            end
            for x=1,#ent.enimines do
                ent.enimines[x]:turn()
            end
        end

        if key == 'right' and testMapEdge(32, 0, mapWidth, mapHeight) == false then
            if testCollisionTile(1, 0) == false then
                player.x = player.x + 32
                player.translate_x = player.translate_x - 32
            end
            for x=1,#ent.enimines do
                ent.enimines[x]:turn()
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
        love.event.push("quit")
        profiler.stop()
    end
end
