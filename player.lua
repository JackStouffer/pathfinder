playerClass = class{x, y, body, health, mana}

function playerClass:__init(cave, dungeon, body, health, mana)
    self.scale = 1
    self.body = love.graphics.newImage(body)
    self.health = health
    self.max_health = health
    self.mana = mana
    self.max_mana = mana

    SoundManager.set_listener(self.x, self.y)
end

function playerClass:keypressed(key, system)
    if key == 'up' and testMapEdge(system, 0, -32, mapWidth, mapHeight) == false then -- if the player pushes up and is not at the end of the world
        if testCollisionTile(system, 0, -1) == false then --then check for collision, this is done this way so testCollisionTile won't try to index a value that doesn't exist
            
            system.map[current_level].player_y = system.map[current_level].player_y - 32
            system.map[current_level].translate_y = system.map[current_level].translate_y + 32
            
            SoundManager.set_listener(system.map[current_level].player_x, system.map[current_level].player_y)
        end
        
        for x = 1,#system.enemies[current_level] do
            system.enemies[current_level][x]:turn()
        end
    end

    if key == 'down' and testMapEdge(system, 0, 32, mapWidth, mapHeight) == false then
        if testCollisionTile(system, 0, 1) == false then
            
            system.map[current_level].player_y = system.map[current_level].player_y + 32
            system.map[current_level].translate_y = system.map[current_level].translate_y - 32
            
            SoundManager.set_listener(system.map[current_level].player_x, system.map[current_level].player_y)
        end
        
        for x = 1,#system.enemies[current_level] do
            system.enemies[current_level][x]:turn()
        end
    end
   
    if key == 'left' and testMapEdge(system, -32, 0, mapWidth, mapHeight) == false then
        if testCollisionTile(system, -1, 0) == false then
            
            system.map[current_level].player_x = system.map[current_level].player_x - 32
            system.map[current_level].translate_x = system.map[current_level].translate_x + 32
            
            SoundManager.set_listener(system.map[current_level].player_x, system.map[current_level].player_y)
        end
        
        for x = 1,#system.enemies[current_level] do
            system.enemies[current_level][x]:turn()
        end
    end

    if key == 'right' and testMapEdge(system, 32, 0, mapWidth, mapHeight) == false then
        if testCollisionTile(system, 1, 0) == false then
            
            system.map[current_level].player_x = system.map[current_level].player_x + 32
            system.map[current_level].translate_x = system.map[current_level].translate_x - 32
            
            SoundManager.set_listener(system.map[current_level].player_x, system.map[current_level].player_y)
        end
        
        for x = 1,#system.enemies[current_level] do
            system.enemies[current_level][x]:turn()
        end
    end

    if key == 'g' then
        print(system.collisionMap[current_level][(system.map[current_level].player_y / 32) + 1][(system.map[current_level].player_x / 32) + 1])
        --stairs up
        if system.collisionMap[current_level][(system.map[current_level].player_y / 32) + 1][(system.map[current_level].player_x / 32) + 1] == 4 then
            current_level = current_level + 1
        end
        --stairs down
        if system.collisionMap[current_level][(system.map[current_level].player_y / 32) + 1][(system.map[current_level].player_x / 32) + 1] == 5 then
            current_level = current_level - 1
        end
    end
end

function playerClass:draw(system)
    love.graphics.draw(self.body, system.map[current_level].player_x, system.map[current_level].player_y)
end