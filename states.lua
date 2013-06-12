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

    loveframes.SetState("menu")

	return temp
end

function Menu:draw()
    love.graphics.draw(backgroundImage, 0, 0)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(logoImage, 200, 50)

    loveframes.draw()
end

function Menu:update(dt)
    loveframes.update(dt)
end

function Menu:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end

function Menu:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

function Menu:keypressed(key)
	if key == "escape" then
		love.event.push("q")
	elseif key == " " or key == "enter" then
        state = Game.create()
    end

    loveframes.keypressed(key, unicode)
end

function Menu:keyreleased(key)
    loveframes.keyreleased(key)
end

-- Instructions State
-- Shows the instructions
Instructions = {}
Instructions.__index = Instructions

function Instructions.create(pause)
	local temp = {}
	setmetatable(temp, Instructions)

    if pause == true then
        loveframes.SetState("instructions_pause")
    else
        loveframes.SetState("instructions")
    end

	return temp
end

function Instructions:draw()
    loveframes.draw()
end

function Instructions:update(dt)
    loveframes.update(dt)
end

function Instructions:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end

function Instructions:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

function Instructions:keypressed(key)
	if key == "escape" then
		state = Menu.create()
	end
    loveframes.keypressed(key, unicode)
end

function Instructions:keyreleased(key)
    loveframes.keyreleased(key)
end

-- Options State
-- Shows the options
Options = {}
Options.__index = Options

function Options.create(pause)
    local temp = {}
    setmetatable(temp, Options)

    if pause == true then
        loveframes.SetState("options_pause")
    else
        loveframes.SetState("options")
    end

    return temp
end

function Options:draw()
    loveframes.draw()
end

function Options:update(dt)
    loveframes.update(dt)
end

function Options:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end

function Options:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

function Options:keypressed(key)
    if key == "escape" then
        state = Menu.create()
    end
    loveframes.keypressed(key, unicode)
end

function Options:keyreleased(key)
    loveframes.keyreleased(key)
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

    cursor_nodes = {}

    menuMusic.source:stop()
    caveMusic.source:play()
    loveframes.SetState("game")
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
            
            drawMap(cave, mapWidth, mapHeight, 19, 9)
            
            love.graphics.setColor(255, 255, 255) --because the button script sets the color to a slight blue

            for x = 1, #cave.items[current_level] do
                cave.items[current_level][x]:draw()
            end

            for x = 1, #cave.stair[current_level] do
                cave.stair[current_level][x]:draw()
            end

            for x = 1, #cave.enemies[current_level] do
                cave.enemies[current_level][x]:draw()
            end

            player:draw(cave)

            for nodes = 1, #cursor_nodes do
                love.graphics.draw(cursor_img, cursor_nodes[nodes].x, cursor_nodes[nodes].y)
            end
        love.graphics.pop()
        
        drawGUI(cave)
        loveframes.draw()
    elseif gameState == "dungeon" then
        love.graphics.push()
            --have the player always centered
            love.graphics.translate(dungeon.map[current_level].translate_x, dungeon.map[current_level].translate_y)
            
            drawMap(dungeon, mapWidth, mapHeight, 19, 9)
            
            love.graphics.setColor(255, 255, 255) --because the button script sets the color to a slight blue

            for x = 1, #dungeon.items[current_level] do
                dungeon.items[current_level][x]:draw()
            end

            for x = 1, #dungeon.stair[current_level] do
                dungeon.stair[current_level][x]:draw()
            end

            for x = 1, #dungeon.enemies[current_level] do
                dungeon.enemies[current_level][x]:draw()
            end

            player:draw(dungeon)
            
            for nodes = 1, #cursor_nodes do
                love.graphics.draw(cursor_img, cursor_nodes[nodes].x, cursor_nodes[nodes].y)
            end
        love.graphics.pop()
        
        drawGUI(dungeon)
        loveframes.draw()
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

        loveframes.update(dt)

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

        loveframes.update(dt)

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

        loveframes.mousepressed(x, y, button)
    end
end

function Game:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
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
    loveframes.keypressed(key, unicode)
end

function Game:keyreleased(key)
    loveframes.keyreleased(key)
end

-- Pause menu...
Pause = {}
Pause.__index = Pause

function Pause.create()
    local temp = {}
    setmetatable(temp, Pause)

    loveframes.SetState("pause")
    return temp
end

function Pause:draw()
    love.graphics.setColor(255, 255, 255)
    loveframes.draw()
end

function Pause:update(dt)
    loveframes.update(dt)
end

function Pause:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end

function Pause:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

function Pause:keypressed(key)
    if key == " " then
        state = Game.create()
    end
    loveframes.keypressed(key, unicode)
end

function Pause:keyreleased(key)
    loveframes.keyreleased(key)
end

-- Death screen
Death = {}
Death.__index = Pause

function Death.create()
    local temp = {}
    setmetatable(temp, Pause)
    loveframes.SetState("death")
    return temp
end

function Death:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(mediumFont)
    love.graphics.print("You Died", 100, 100)

    loveframes.draw()
end

function Death:update(dt)
    loveframes.update(dt)
end

function Death:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end

function Death:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

function Death:keypressed(key)
    if key == " " then
        state = Menu.create()
    end
    loveframes.keypressed(key, unicode)
end

function Death:keyreleased(key)
    loveframes.keyreleased(key)
end
