-- Menu State
-- Main menu...
Menu = {}
Menu.__index = Menu

function Menu.create()
	local temp = {}
	setmetatable(temp, Menu)

    menuMusic.source:play()

    SoundManager.set_listener(512, 288) --the middle of the screen
	logoImage = love.graphics.newImage("textures/gui/logo.png")
    backgroundImage = love.graphics.newImage("textures/gui/background.png")
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
				createWorld()
                state = Game.create()
			elseif n == "instructions" then
				state = Instructions.create(false)
			elseif n == "options" then
				state = Options.create(false)
			elseif n == "quit" then
				love.event.push("quit")
			end
		end
	end
	
end

function Menu:keypressed(key)
	if key == "escape" then
		love.event.push("q")
	elseif key == " " or key == "enter" then
        state = Game.create()
    end
end


-- Instructions State
-- Shows the instructions
Instructions = {}
Instructions.__index = Instructions

function Instructions.create(pause)
	local temp = {}
	setmetatable(temp, Instructions)
	temp.button = {	back = Button:new("Back", 550, 500) }
    temp.pause = pause
	return temp
end

function Instructions:draw()
	love.graphics.setFont(mediumFont)
	love.graphics.printf("Pathfinder is a mix between a rougelike and chess. The game is split into turns with one action per turn, e.g. attacking or drinking a potion, while your range of movement is dictated by your MP, or movement points. Click the mouse to select where to move and 'G' picks items up or activates things under you.", 150, 50, 700, "left")
	
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
				if self.pause then
                    state = Pause.create()
                else
                    state = Menu.create()
                end
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

function Options.create(pause)
    local temp = {}
    setmetatable(temp, Options)
    temp.button = { on = Button:new("On", 425, 155),
                    off = Button:new("Off", 550, 155),
                    back = Button:new("Back", 550, 500)}
    temp.pause = pause
    return temp
end

function Options:draw()
    love.graphics.setColor(214, 169, 187)
    love.graphics.print("Audio:", 250, 100)
    love.graphics.print("Controls:", 179, 170)
    
    love.graphics.setLine(4, "rough")

    if not Settings.is_mute() then
        love.graphics.line(380,135,430,135)
    else
        love.graphics.line(493,135,543,135)
    end
    
    --love.graphics.line(360+((size-5)*50),380,390+((size-5)*50),380)
    
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
                Settings.set("volume", 1)
                SoundManager.resume()
            elseif n == "off" then
                Settings.set("volume", 0)
                SoundManager.pause_current()
            elseif n == "back" then
                if self.pause then
                    state = Pause.create()
                else
                    state = Menu.create()
                end
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

    temp.button = { turn = Button:new("Turn", 950, 500) }

    cursor_nodes = {}

    menuMusic.source:stop()
    caveMusic.source:play()

	return temp
end

function Game:draw()
    if gameState == "world" then
        if showPerlin == 1 then plot2D(terrain.perlin)
        else
            drawTerrain(terrain)
        end
    elseif gameState == "cave" then
        love.graphics.push()
        	--have the player always centered
            love.graphics.translate(cave.map[current_level].translate_x, cave.map[current_level].translate_y)
            love.graphics.scale(player.scale, player.scale)
            
            drawMap(cave, mapWidth, mapHeight, 15, 6)
            
            love.graphics.setColor(255, 255, 255) --because the button script sets the color to a slight blue
            
            for x = 1, #cave.enemies[current_level] do
                cave.enemies[current_level][x]:draw()
            end

            for x = 1, #cave.items[current_level] do
                cave.items[current_level][x]:draw()
            end

            for x = 1, #cave.stair[current_level] do
                cave.stair[current_level][x]:draw()
            end

            player:draw(cave)

            for nodes = 1, #cursor_nodes do
                love.graphics.draw(cursor_img, cursor_nodes[nodes].x, cursor_nodes[nodes].y)
            end
        love.graphics.pop()
        
        drawGUI(cave)

        for n,b in pairs(self.button) do
            b:draw()
        end
    elseif gameState == "dungeon" then
        love.graphics.push()
            --have the player always centered
            love.graphics.translate(dungeon.map[current_level].translate_x, dungeon.map[current_level].translate_y)
            
            drawMap(dungeon, mapWidth, mapHeight, 15, 6)
            
            love.graphics.setColor(255, 255, 255) --because the button script sets the color to a slight blue
            
            for x = 1, #dungeon.enemies[current_level] do
                dungeon.enemies[current_level][x]:draw()
            end

            for x = 1, #dungeon.items[current_level] do
                dungeon.items[current_level][x]:draw()
            end

            for x = 1, #dungeon.stair[current_level] do
                dungeon.stair[current_level][x]:draw()
            end

            player:draw(dungeon)
            
            for nodes = 1, #cursor_nodes do
                love.graphics.draw(cursor_img, cursor_nodes[nodes].x, cursor_nodes[nodes].y)
            end
        love.graphics.pop()
        
        drawGUI(dungeon)

        for n,b in pairs(self.button) do
            b:draw()
        end
    end
    love.graphics.setColor(255, 255, 255)
end

function Game:update(dt)
    local num_dead
    local num_clear

    SoundManager.update()
    if gameState == "cave" then
        turnManager(cave)

        player:update(dt, cave)

        num_dead = 0
        for x = 1, #cave.enemies[current_level] do
            cave.enemies[current_level][x]:update(dt, cave)

            if cave.enemies[current_level][x].dead == true then
                num_dead = num_dead + 1
            end

            if num_dead == #cave.enemies[current_level] then
                cave.map[current_level].clear = true
            end
        end

        num_clear = 0
        for level = 1, #cave.map do
            if cave.map[level].clear == true then
                num_clear = num_clear + 1
            end

            if num_clear == #cave.map then
                cave.clear = true
            end
        end

        for n,b in pairs(self.button) do
            b:update(dt)
        end

        if cave.clear == true then
            gameState = 'world'
        end
    elseif gameState == "dungeon" then
        turnManager(dungeon)

        player:update(dt, dungeon)

        num_dead = 0
        for x = 1, #dungeon.enemies[current_level] do
            dungeon.enemies[current_level][x]:update(dt, cave)

            if dungeon.enemies[current_level][x].dead == true then
                num_dead = num_dead + 1
            end

            if num_dead == #dungeon.enemies[current_level] then
                dungeon.map[current_level].clear = true
            end
        end

        num_clear = 0
        for level = 1, #dungeon.map do
            if dungeon.map[level].clear == true then
                num_clear = num_clear + 1
            end

            if num_clear == #dungeon.map then
                dungeon.clear = true
            end
        end

        for n,b in pairs(self.button) do
            b:update(dt)
        end

        if dungeon.clear == true then
            gameState = 'world'
        end
    end
end

function Game:mousepressed(x, y, button)
	if gameState == "world" then
        if x >= terrain.locations.cave.x and 
            x <= terrain.locations.cave.x + 32 and 
            y <= terrain.locations.cave.y + 32 and 
            y >= terrain.locations.cave.y then
            gameState = "cave"
        elseif x >= terrain.locations.dungeon.x and 
            x <= terrain.locations.dungeon.x + 32 and 
            y <= terrain.locations.dungeon.y + 32 and 
            y >= terrain.locations.dungeon.y then
            gameState = "dungeon"
        end
    else
        player:mousepressed(x, y, button)

        for n,b in pairs(self.button) do
            if b:mousepressed(x,y,button) then
                if n == "turn" and current_player == 0 then
                    turn_state = 3
                end
            end
        end
    end
end

function Game:keypressed(key)
    if gameState == "cave" then
        player:keypressed(key, cave)
    elseif gameState == "dungeon" then 
        player:keypressed(key, dungeon)
    end

    if key == "w" then
        player.scale = player.scale - .1
    elseif key == "s" then
        player.scale = player.scale + .1
    elseif key == "r" then
        terrain = makeTerrain()
    elseif key == "p" then
        showPerlin = 1 - showPerlin
    elseif key == "c" then
        gameState = "cave"
        Astar(cave.collisionMap[current_level])
        Astar:setObstValue(2)
        Astar:enableDiagonalMove()
    elseif key == "d" then
        gameState = "dungeon"
        Astar(dungeon.collisionMap[current_level])
        Astar:setObstValue(2)
        Astar:enableDiagonalMove()
    elseif key == "escape" then
        love.event.push("quit")
    elseif key == "q" or key == " " then
        state = Pause.create()
    elseif key == "1" then
        current_level = 1
        if gameState == "cave" then
            Astar(cave.collisionMap[current_level])
            Astar:setObstValue(2)
            Astar:enableDiagonalMove()
        elseif gameState == "dungeon" then
            Astar(dungeon.collisionMap[current_level])
            Astar:setObstValue(2)
            Astar:enableDiagonalMove()
        end
    elseif key == "2" then
        current_level = 2
        if gameState == "cave" then
            Astar(cave.collisionMap[current_level])
            Astar:setObstValue(2)
            Astar:enableDiagonalMove()
        elseif gameState == "dungeon" then
            Astar(dungeon.collisionMap[current_level])
            Astar:setObstValue(2)
            Astar:enableDiagonalMove()
        end
    elseif key == "3" then
        current_level = 3
        if gameState == "cave" then
            Astar(cave.collisionMap[current_level])
            Astar:setObstValue(2)
            Astar:enableDiagonalMove()
        elseif gameState == "dungeon" then
            Astar(dungeon.collisionMap[current_level])
            Astar:setObstValue(2)
            Astar:enableDiagonalMove()
        end
    end
end

-- Pause menu...
Pause = {}
Pause.__index = Pause

function Pause.create()
    local temp = {}
    setmetatable(temp, Pause)

    temp.button = { resume = Button:new("Resume Game", 512, 300),
                    instructions = Button:new("Instructions", 512, 350),
                    options = Button:new("Options", 512, 400),
                    menu = Button:new("Main Menu", 512, 450) }
    return temp
end

function Pause:draw()
    for n,b in pairs(self.button) do
        b:draw()
    end
    love.graphics.setColor(255, 255, 255)
end

function Pause:update(dt)
    
    for n,b in pairs(self.button) do
        b:update(dt)
    end
    
end

function Pause:mousepressed(x,y,button)
    
    for n,b in pairs(self.button) do
        if b:mousepressed(x,y,button) then
            if n == "resume" then
                state = Game.create()
            elseif n == "instructions" then
                state = Instructions.create(true)
            elseif n == "options" then
                state = Options.create(true)
            elseif n == "menu" then
                state = Menu.create()
            end
        end
    end
    
end

function Pause:keypressed(key)
    if key == " " then
        state = Game.create()
    end
end

-- Death screen
Death = {}
Death.__index = Pause

function Death.create()
    local temp = {}
    setmetatable(temp, Pause)

    temp.button = { menu = Button:new("Main Menu", 512, 300),
                    quit = Button:new("Quit", 512, 350) }
    return temp
end

function Death:draw()
    for n,b in pairs(self.button) do
        b:draw()
    end

    love.graphics.setFont(largeFont)
    love.graphics.print("You Died", 512, 150)

    love.graphics.setColor(255, 255, 255)
end

function Death:update(dt)
    
    for n,b in pairs(self.button) do
        b:update(dt)
    end
    
end

function Death:mousepressed(x,y,button)
    
    for n,b in pairs(self.button) do
        if b:mousepressed(x,y,button) then
            if n == "menu" then
                state = Menu.create()
            elseif n == "quit" then
                state = love.event.push("quit")
            end
        end
    end
end

function Death:keypressed(key)
    if key == " " then
        state = Menu.create()
    end
end
