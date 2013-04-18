-- Menu State
-- Main menu...
Menu = {}
Menu.__index = Menu

function Menu.create()
	local temp = {}
	setmetatable(temp, Menu)

    menuMusic.source:play()

    SoundManager.set_listener(512, 288)
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
    temp.button = { on = Button:new("On", 425, 155),
                    off = Button:new("Off", 550, 155),
                    back = Button:new("Back", 550, 500)}
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

    print("start")
    cave = levelSystem(level_num, "normal", "cave")
    print("cave")

    dungeon = levelSystem(level_num, "normal", "dungeon")
    print("dungeon")
    
    player = playerClass:new(416, 288, "textures/player/base/human_m.png", 100, 100)

    fireball = love.graphics.newParticleSystem(love.graphics.newImage("textures/part1.png"), 500)
    fireball:setEmissionRate(100)
    fireball:setSpeed(200, 300)
    fireball:setGravity(0)
    fireball:setSizes(2, 1)
    fireball:setColors(255, 0, 0, 255, 254, 166, 61, 170, 255, 255, 0, 0)
    fireball:setPosition((player.x * 32) - 32, (player.y * 32) - 32)
    fireball:setLifetime(-1)
    fireball:setParticleLife(.3)
    fireball:setDirection(0)
    fireball:setSpread(360)
    fireball:setRadialAcceleration(-2000)
    fireball:setTangentialAcceleration(0)
    fireball:stop()

    terrain = makeTerrain()

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
        	love.graphics.translate(player.translate_x, player.translate_y) --have the player always centered
            love.graphics.scale(player.scale, player.scale)
            
            drawMap(cave, mapWidth, mapHeight, 15, 6)
            
            love.graphics.setColor(255, 255, 255) --because the button script sets the color to a slight blue
            
            for x = 1, #cave.enemies[current_level] do
                cave.enemies[current_level][x]:draw()
            end

            for x = 1, #cave.items[current_level] do
                cave.items[current_level][x]:draw()
            end

            player:draw()
        love.graphics.pop()
        
        --gui
        love.graphics.setColorMode("modulate")
        love.graphics.setBlendMode("additive")
        love.graphics.draw(fireball, 0, 0)
        love.graphics.setBlendMode("alpha")

        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 832, 0, 260, 576)
        love.graphics.setColor(255, 255, 255)
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("fill", 845, 20, 165 * (player.health / player.max_health), 15)
        love.graphics.setColor(0, 0, 255)
        love.graphics.rectangle("fill", 844, 45, 165 * (player.mana / player.max_mana), 15)
        love.graphics.setColor(255, 255, 255)
    elseif gameState == "dungeon" then
        love.graphics.push()
            love.graphics.translate(player.translate_x, player.translate_y) --have the player always centered
            
            drawMap(dungeon, mapWidth, mapHeight, 15, 6)
            
            love.graphics.setColor(255, 255, 255) --because the button script sets the color to a slight blue
            
            for x = 1, #dungeon.enemies[current_level] do
                dungeon.enemies[current_level][x]:draw()
            end

            for x = 1, #dungeon.items[current_level] do
                dungeon.items[current_level][x]:draw()
            end

            player:draw()
        love.graphics.pop()
        
        --gui
        love.graphics.setBlendMode("additive")
        love.graphics.draw(fireball, 0, 0)
        love.graphics.setBlendMode("alpha")

        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 832, 0, 260, 576)
        love.graphics.setColor(255, 255, 255)
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("fill", 845, 20, 165 * (player.health/player.max_health), 15)
        love.graphics.setColor(0, 0, 255)
        love.graphics.rectangle("fill", 844, 45, 165 * (player.mana/player.max_mana), 15)
        love.graphics.setColor(255, 255, 255)
    end
    love.graphics.setColor(255, 255, 255)
end

function Game:update(dt)
    SoundManager.update()

    if love.mouse.isDown("l") then
        fireball:setPosition(love.mouse.getX(), love.mouse.getY())

        local delta_y = love.mouse.getY() - player.y
        local delta_x = love.mouse.getY() - player.x

        local direction = math.atan2(delta_y, delta_x)
        print(direction)
        fireball:setDirection(1)
        fireball:start()
    else
        fireball:stop()
    end

    fireball:update(dt)
end

function Game:mousepressed(x, y, button)
	if gameState == "world" then
        if x >= terrain.locations.cave.x and x <= terrain.locations.cave.x + 32 and y <= terrain.locations.cave.y + 32 and y >= terrain.locations.cave.y then
            gameState = "cave"
        elseif x >= terrain.locations.dungeon.x and x <= terrain.locations.dungeon.x + 32 and y <= terrain.locations.dungeon.y + 32 and y >= terrain.locations.dungeon.y then
            gameState = "dungeon"
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
        Astar:disableDiagonalMove()
    elseif key == "d" then
        gameState = "dungeon"
        Astar(dungeon.collisionMap[current_level])
        Astar:setObstValue(2)
        Astar:disableDiagonalMove()
    elseif key == "escape" then
        love.event.push("quit")
    elseif key == "1" then
        current_level = 1
        if gameState == "cave" then
            Astar(cave.collisionMap[current_level])
            Astar:setObstValue(2)
            Astar:disableDiagonalMove()
        elseif gameState == "dungeon" then
            Astar(dungeon.collisionMap[current_level])
            Astar:setObstValue(2)
            Astar:disableDiagonalMove()
        end
    elseif key == "2" then
        current_level = 2
        if gameState == "cave" then
            Astar(cave.collisionMap[current_level])
            Astar:setObstValue(2)
            Astar:disableDiagonalMove()
        elseif gameState == "dungeon" then
            Astar(dungeon.collisionMap[current_level])
            Astar:setObstValue(2)
            Astar:disableDiagonalMove()
        end
    elseif key == "3" then
        current_level = 3
        if gameState == "cave" then
            Astar(cave.collisionMap[current_level])
            Astar:setObstValue(2)
            Astar:disableDiagonalMove()
        elseif gameState == "dungeon" then
            Astar(dungeon.collisionMap[current_level])
            Astar:setObstValue(2)
            Astar:disableDiagonalMove()
        end
    end
end
