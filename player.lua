playerClass = class{x, y, body, health, mana}

function playerClass:__init(cave, dungeon, body, health, mana)
    self.scale = 1
    self.body = love.graphics.newImage(body)
    self.health = health
    self.max_health = health
    self.mana = mana
    self.max_mana = mana
    self.ap = 6

    SoundManager.set_listener(self.x, self.y)
end

function playerClass:moveTo(system, grid_x, grid_y)
    system.map[current_level].player_x = (grid_x * 32) - 32
    system.map[current_level].player_y = (grid_y * 32) - 32
    system.map[current_level].translate_x = (system.map[current_level].player_x - 416) * -1
    system.map[current_level].translate_y = (system.map[current_level].player_y - 288) * -1
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
            current_level = current_level - 1
        end
        --stairs down
        if system.collisionMap[current_level][(system.map[current_level].player_y / 32) + 1][(system.map[current_level].player_x / 32) + 1] == 5 then
            current_level = current_level + 1
        end
    end
end

function playerClass:mousepressed(x, y, button)
    local grid_x
    local grid_y
    local cursor_path = nil
    local node

    if gameState == "cave" then
        grid_x, grid_y = mouseToMapCoords(cave, x, y)
        
        if cave.collisionMap[current_level][grid_y][grid_x] == 0 and --if the spot is open 
        cave.map[current_level][grid_y][grid_x].visibility ~= false then -- and the spot is not hidden
            --check to see if the clicked location is close enough to get to in this turn
            Astar:enableDiagonalMove()
            Astar:setInitialNode((cave.map[current_level].player_x / 32) + 1, (cave.map[current_level].player_y / 32) + 1)
            Astar:setFinalNode(grid_x, grid_y)
            cursor_path = Astar:getPath()
            
            if cursor_path ~= nil and #cursor_path <= player.ap then 
                cursor_nodes = {}
                for nodes = 1, #cursor_path do
                    node = {}
                    node.x = (cursor_path[nodes].x * 32) - 32
                    node.y = (cursor_path[nodes].y * 32) - 32
                    table.insert(cursor_nodes, node)
                end
                player:moveTo(cave, cursor_path[#cursor_path].x, cursor_path[#cursor_path].y)
                for x = 1, #cave.enemies[current_level] do
                    cave.enemies[current_level][x]:turn()
                end
            end
        end
    elseif gameState == "dungeon" then
        grid_x, grid_y = mouseToMapCoords(dungeon, x, y)
        
        if dungeon.collisionMap[current_level][grid_y][grid_x] == 0 and --if the spot is open
        dungeon.map[current_level][grid_y][grid_x].visibility ~= false then -- and the spot is not hidden
            --check to see if the clicked location is close enough to get to in this turn
            Astar:enableDiagonalMove()
            Astar:setInitialNode((dungeon.map[current_level].player_x / 32) + 1, (dungeon.map[current_level].player_y / 32) + 1)
            Astar:setFinalNode(grid_x, grid_y)
            cursor_path = Astar:getPath()
            
            if cursor_path ~= nil and #cursor_path <= player.ap then 
                cursor_nodes = {}
                for nodes = 1, #cursor_path do
                    node = {}
                    node.x = (cursor_path[nodes].x * 32) - 32
                    node.y = (cursor_path[nodes].y * 32) - 32
                    table.insert(cursor_nodes, node)
                end
                player:moveTo(dungeon, cursor_path[#cursor_path].x, cursor_path[#cursor_path].y)
                for x = 1, #dungeon.enemies[current_level] do
                    dungeon.enemies[current_level][x]:turn()
                end
            end
        end
    end
end

function playerClass:draw(system)
    love.graphics.draw(self.body, system.map[current_level].player_x, system.map[current_level].player_y)
end