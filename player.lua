playerClass = class{x, y, body, health, mana}

function playerClass:__init(cave, dungeon, body, health, mana)
    self.scale = 1
    self.body = love.graphics.newImage(body)
    self.health = health
    self.max_health = health
    self.mana = mana
    self.max_mana = mana
    self.ap = 6
    self.path = nil
    self.isMoving = false
    self.speed = 80
    self.cur = nil
    self.there = nil
end

function playerClass:setTilePosition(system)
  system.map[current_level].tile_x = ((system.map[current_level].player_x - (system.map[current_level].player_x % 32)) / 32) + 1
  system.map[current_level].tile_y = ((system.map[current_level].player_y - (system.map[current_level].player_y % 32)) / 32) + 1
end

--the movement code for the player thanks to Roland Yonaba
function playerClass:orderMove(path)
  self.path = path -- the path to follow
  self.isMoving = true -- whether or not the player should start moving
  self.cur = 1 -- indexes the current reached step on the path to follow
  self.there = true -- whether or not the player has reached a step
end

function playerClass:moveToTile(goal_tile_x, goal_tile_y, dt, system)
    -- Watches if the player has reached the goal on x/y
    local reached_x, reached_y = false, false 
  
    -- Compute the goal location in pixels from the goal tile coordinates
    local goal_x = (goal_tile_x * 32) - 32
    local goal_y = (goal_tile_y * 32) - 32
  
    -- Computes the unit vector of move
    local vx = (goal_x - system.map[current_level].player_x) / math.abs(goal_x - system.map[current_level].player_x)
    local vy = (goal_y - system.map[current_level].player_y) / math.abs(goal_y - system.map[current_level].player_y)        

    local dy, dx
    -- Moves on the player on y-axis
    if (system.map[current_level].player_y ~= goal_y) then
        dy = dt * self.speed * vy
        if vy > 0 then
            system.map[current_level].player_y = system.map[current_level].player_y + math.min(dy, goal_y - system.map[current_level].player_y)
        else 
            system.map[current_level].player_y = system.map[current_level].player_y + math.max(dy, goal_y - system.map[current_level].player_y)
        end
    else
        system.map[current_level].player_y = goal_y
        reached_y = true
    end

  
    -- Moves on the player on x-axis
    if (system.map[current_level].player_x ~= goal_x) then
        dx = dt * self.speed * vx
        if vx > 0 then
            system.map[current_level].player_x = system.map[current_level].player_x + math.min(dx, goal_x - system.map[current_level].player_x)
        else
            system.map[current_level].player_x = system.map[current_level].player_x + math.max(dx, goal_x - system.map[current_level].player_x)
        end
    else 
        system.map[current_level].player_x = goal_x
        reached_x = true
    end

    system.map[current_level].translate_x = (system.map[current_level].player_x - 416) * -1
    system.map[current_level].translate_y = (system.map[current_level].player_y - 288) * -1
    
    if (reached_x and reached_y) then 
        self.there = true
    end
end

function playerClass:move(system, dt)
    if self.isMoving then
        if not self.there then
            -- Walk to the assigned location
            self:moveToTile(self.path[self.cur].x, self.path[self.cur].y, dt, system)
        else
            -- Make the next step move
            if self.path[self.cur + 1] then
                self.cur = self.cur + 1
                self.there = false
            else
                -- Reached the goal!
                self.isMoving = false
                self.path = nil
            end        
        end
    end
end

function playerClass:keypressed(key, system)
    if key == 'g' then
        --stairs up
        if system.collisionMap[current_level][system.map[current_level].tile_y][system.map[current_level].tile_x] == 4 then
            current_level = current_level - 1
        end
        --stairs down
        if system.collisionMap[current_level][system.map[current_level].tile_y][system.map[current_level].tile_x] == 5 then
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
        cave.map[current_level][grid_y][grid_x].visibility ~= false and -- and the spot is not hidden
        self.isMoving == false then -- and we are not already moving 
            --check to see if the clicked location is close enough to get to in this turn
            Astar:enableDiagonalMove()
            Astar:setInitialNode((cave.map[current_level].player_x / 32) + 1, (cave.map[current_level].player_y / 32) + 1)
            Astar:setFinalNode(grid_x, grid_y)
            cursor_path = Astar:getPath()
            
            if cursor_path ~= nil and #cursor_path <= self.ap then 
                cursor_nodes = {}
                for nodes = 1, #cursor_path do
                    node = {}
                    node.x = (cursor_path[nodes].x * 32) - 32
                    node.y = (cursor_path[nodes].y * 32) - 32
                    table.insert(cursor_nodes, node)
                end
                self:orderMove(cursor_path)
                for x = 1, #cave.enemies[current_level] do
                    cave.enemies[current_level][x]:turn()
                end
            end
        end
    elseif gameState == "dungeon" then
        grid_x, grid_y = mouseToMapCoords(dungeon, x, y)
        
        if dungeon.collisionMap[current_level][grid_y][grid_x] == 0 and --if the spot is open
        dungeon.map[current_level][grid_y][grid_x].visibility ~= false and -- and the spot is not hidden
        self.isMoving == false then -- and we are not already moving
            --check to see if the clicked location is close enough to get to in this turn
            Astar:enableDiagonalMove()
            Astar:setInitialNode((dungeon.map[current_level].player_x / 32) + 1, (dungeon.map[current_level].player_y / 32) + 1)
            Astar:setFinalNode(grid_x, grid_y)
            cursor_path = Astar:getPath()
            
            if cursor_path ~= nil and #cursor_path <= self.ap then 
                cursor_nodes = {}
                for nodes = 1, #cursor_path do
                    node = {}
                    node.x = (cursor_path[nodes].x * 32) - 32
                    node.y = (cursor_path[nodes].y * 32) - 32
                    table.insert(cursor_nodes, node)
                end
                self:orderMove(cursor_path)
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