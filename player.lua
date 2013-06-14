playerClass = class('playerClass')

function playerClass:initialize(cave, dungeon, body, health, mana)
    self.scale = 1

    self.body = love.graphics.newImage(body)

    self.health = health -- current health
    self.max_health = health -- base health
    self.mana = mana -- current mana
    self.max_mana = mana -- base mana
    self.mp = 7 -- movement points

    self.agility = 10 -- determines turn placement
    self.perception = 8 -- crit chance in %
    self.strength = 30 -- base attack score
    self.defense = 2 -- base defense score

    self.path = nil
    self.isMoving = false
    self.drawing_speed = 80
    self.cur = nil
    self.there = nil
end

function playerClass:setTilePosition(system)
    system.map[current_level].tile_x = ((system.map[current_level].player_x - (system.map[current_level].player_x % 32)) / 32) + 1
    system.map[current_level].tile_y = ((system.map[current_level].player_y - (system.map[current_level].player_y % 32)) / 32) + 1
end

function playerClass:orderMove(path)
    -- the movement code for the player thanks to Roland Yonaba
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
        dy = dt * self.drawing_speed * vy
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
        dx = dt * self.drawing_speed * vx
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
                cursor_nodes = {}
                self.isMoving = false
                self.path = nil
                turn_state = 1
            end        
        end
    end
end

function playerClass:getSpeed()
    --function for the speed based turn scheduler
    return self.agility
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
    elseif key == "o" then
        self.health = 0
    end
end

function playerClass:mousepressed(x, y, button)
    local grid_x
    local grid_y
    local cursor_path = nil
    local node
    local position
    local adjacent
    local base_attack

    if gameState == "cave" then
        grid_x, grid_y = mouseToMapCoords(cave, x, y)
        
        if cave.collisionMap[current_level][grid_y][grid_x] ~= 2 and --if the spot is open 
        cave.map[current_level][grid_y][grid_x].visibility ~= false and -- and the spot is not hidden
        self.isMoving == false and -- and we are not already moving
        current_player == 0 and -- and its our turn
        turn_state == 0 then --and its the movement stage
            
            --check to see if the clicked location is close enough to get to in this turn
            Astar:enableDiagonalMove()
            Astar:setInitialNode(cave.map[current_level].tile_x, cave.map[current_level].tile_y)
            Astar:setFinalNode(grid_x, grid_y)
            cursor_path = Astar:getPath()
            
            if cursor_path ~= nil and #cursor_path <= self.mp then 
                self:orderMove(cursor_path)
            end
        elseif turn_state == 1 then
            position = {x = cave.map[current_level].player_x, y = cave.map[current_level].player_y}
            adjacent = getAdjacentTiles(position)
            if table.containsTable(adjacent, {x = (grid_x * 32) - 32, y = (grid_y * 32) - 32}) == true then
                --the selected tile is next to the player
                for x = 1, #cave.enemies[current_level] do
                    if  cave.enemies[current_level][x].grid_x == grid_x and
                        cave.enemies[current_level][x].grid_y == grid_y then
                            if math.random(0, 99) < self.perception then
                                print("crit")
                                base_attack = self.strength -- eventually will add weapon damage to this as well
                            else
                                base_attack = self.strength / 2 -- eventually will add weapon damage to this as well
                            end
                            cave.enemies[current_level][x].health = cave.enemies[current_level][x].health - (base_attack - cave.enemies[current_level][x].defense) -- base attack minus the defense
                            turn_state = 3
                    else
                        --there is nothing in that tile
                    end
                end
            else
                --player clicked more than one tile away
            end
        end
    elseif gameState == "dungeon" then
        grid_x, grid_y = mouseToMapCoords(dungeon, x, y)
        
        if dungeon.collisionMap[current_level][grid_y][grid_x] ~= 2 and --if the spot is open
        dungeon.map[current_level][grid_y][grid_x].visibility ~= false and -- and the spot is not hidden
        self.isMoving == false and -- and we are not already moving
        current_player == 0 and -- and its our turn
        turn_state == 0 then --and its the movement stage
            --check to see if the clicked location is close enough to get to in this turn
            Astar:enableDiagonalMove()
            Astar:setInitialNode(dungeon.map[current_level].tile_x, dungeon.map[current_level].tile_y)
            Astar:setFinalNode(grid_x, grid_y)
            cursor_path = Astar:getPath()
            
            if cursor_path ~= nil and #cursor_path <= self.mp then 
                cursor_nodes = {}
                for nodes = 1, #cursor_path do
                    node = {}
                    node.x = (cursor_path[nodes].x * 32) - 32
                    node.y = (cursor_path[nodes].y * 32) - 32
                    table.insert(cursor_nodes, node)
                end
                self:orderMove(cursor_path)
            end
        elseif turn_state == 1 then
            position = {x = dungeon.map[current_level].player_x, y = dungeon.map[current_level].player_y}
            adjacent = getAdjacentTiles(position)
            if table.containsTable(adjacent, {x = (grid_x * 32) - 32, y = (grid_y * 32) - 32}) == true then
                --the selected tile is next to the player
                for x = 1, #dungeon.enemies[current_level] do
                    if  dungeon.enemies[current_level][x].grid_x == grid_x and
                        dungeon.enemies[current_level][x].grid_y == grid_y then
                            if math.random(0, 99) < self.perception then
                                print("crit")
                                base_attack = self.strength -- eventually will add weapon damage to this as well
                            else
                                base_attack = self.strength / 2 -- eventually will add weapon damage to this as well
                            end
                            dungeon.enemies[current_level][x].health = dungeon.enemies[current_level][x].health - (base_attack - dungeon.enemies[current_level][x].defense) -- base attack minus the defense
                            turn_state = 3
                    else
                        --there is nothing in that tile
                    end
                end
            else
                --player clicked more than one tile away
            end
        end
    end
end

function playerClass:draw(system)
    love.graphics.draw(self.body, system.map[current_level].player_x, system.map[current_level].player_y)
end

function playerClass:update(dt, system)
    self:setTilePosition(system)
    self:move(system, dt)

    if self.health <= 0 then
        state = Death.create()
    end
end