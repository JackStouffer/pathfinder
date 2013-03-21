-- fonts
smallFont = love.graphics.newFont(12)
largeFont = love.graphics.newFont(32)
middleFont = love.graphics.newFont(24)

--Music/Sound
menuMusic = love.audio.newSource("music/AlaFlair.ogg")
caveMusic = love.audio.newSource("music/radakan-cave ambience.ogg")
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
	temp.button = {	new = Button:new("New Game", 512, 300),
					instructions = Button:new("Instructions", 512, 350),
					options = Button:new("Options", 512, 400),
					quit = Button:new("Quit", 512, 450) }
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
	temp.button = {	back = Button:new("Back", 350, 200) }
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
	temp.button = {back = Button:new("Back", 350, 200)}
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
    
    bg = love.graphics.newImage("textures/gui/bg.png")
    
    cave = caveSystem(level_num, "normal")
    print("cave")
    
    player = playerClass:new(416, 288, "textures/player/base/human_m.png", 100, 100)
    
    for level = 1, level_num do 
        for num=1, 5 do
            cave.enemies[level][num] = monster:new(100, "textures/dc-mon/acid_blob.png", level)
        end
    end

    for level = 1, level_num do 
        for num=1, 20 do
            cave.items[level][num] = item:new("textures/item/potion/ruby.png", level)
        end
    end

    terrain = makeTerrain()
    
    Astar(cave.collisionMap[current_level])
    Astar:setObstValue(2)
    Astar:disableDiagonalMove()

    love.audio.play(caveMusic)

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
            drawMap(cave.map[current_level], mapWidth, mapHeight, 15)
            love.graphics.setColor(255, 255, 255) --because the button script sets the color to a slight blue
            player:draw()
            
            for x=1,#cave.enemies[current_level] do
                cave.enemies[current_level][x]:draw()
            end

            for x=1,#cave.items[current_level] do
                cave.items[current_level][x]:draw()
            end
        love.graphics.pop()
        
        --gui
        love.graphics.draw(bg, 832, 0)
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("fill", 845, 20, 165 * (player.health/player.max_health), 15)
        love.graphics.setColor(0, 0, 255)
        love.graphics.rectangle("fill", 844, 45, 165 * (player.mana/player.max_mana), 15)
        love.graphics.setColor(255, 255, 255)
    end
    love.graphics.setColor(255, 255, 255)
end

function Game:update(dt)

end

function Game:mousepressed(x, y, button)
	
end

function Game:keypressed(key)
    if gameState == "cave" then
        player:keypressed(key)
    end

    if key == "r" then
        terrain = makeTerrain()
    elseif key == "p" then
        showPerlin = 1 - showPerlin
    elseif key == "c" then
        gameState = "cave"
    elseif key == "escape" then
        love.event.push("quit")
    elseif key == "1" then
        current_level = 1
        Astar(cave.collisionMap[current_level])
        Astar:setObstValue(2)
        Astar:disableDiagonalMove()
    elseif key == "2" then
        current_level = 2
        Astar(cave.collisionMap[current_level])
        Astar:setObstValue(2)
        Astar:disableDiagonalMove()
    elseif key == "3" then
        current_level = 3
        Astar(cave.collisionMap[current_level])
        Astar:setObstValue(2)
        Astar:disableDiagonalMove()
    end
end
