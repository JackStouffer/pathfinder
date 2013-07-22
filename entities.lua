monster = class('monster')
item = class('item')
stairs = class('stairs')

function monster:initialize(health, image, level, map, image_map)
    self.level = level -- int that represents its current level
    self.map = map -- the collision map
    self.image_map = image_map -- the system.map
    
    self.start_x, self.start_y = getRandOpenTile(self.map, mapWidth, mapHeight)
    self.grid_x = self.start_x - 1
    self.grid_y = self.start_y - 1
    self.x = (self.start_x * 32) - 32
    self.y = (self.start_y * 32) - 32
    
    self.health = health
    self.image = love.graphics.newImage(image)

    self.speed = 3 + math.random(0, 2) -- determines movement order in each turn
    self.perception = 8 -- crit chance in %
    self.strength = 15 -- base attack score
    self.defense = 5 -- base defense score
    
    self.mp = 4 -- movement points
    self.path = nil
    self.path_to_player = nil
    self.isMoving = false
    self.isAttacking = false
    
    -- speed at which the entity is drawn moving from one tile to another
    -- has no bearing on the speed which is used to determine turn order
    self.drawing_speed = 80 
    self.cur = nil
    self.there = nil
    
    self.dead = false

    -- set the location of the monster as occupied in the collision map
    self.map[self.grid_y][self.grid_x] = 2
end

function monster:setTilePosition(system)
    -- function to update the monster's current tile when moving
    self.grid_x = ((self.x - (self.x % 32)) / 32) + 1
    self.grid_y = ((self.y - (self.y % 32)) / 32) + 1
end

function monster:orderMove(path)
  self.path = path -- the path to follow
  self.isMoving = true -- whether or not the player should start moving
  self.cur = 1 -- indexes the current reached step on the path to follow
  self.there = true -- whether or not the player has reached a step
end

function monster:turn()
    local monster_path = {}
    local adjacent
    local base_attack
    
    if self.dead == false and self.image_map[self.grid_y][self.grid_x].visibility == true then --if the monster can see us 
        if self.isMoving == false and turn_state == 0 then -- if we aren't already in a turn
            --chase
            self.map[self.grid_y][self.grid_x] = 0
            
            if Astar:setInitialNode(self.grid_x, self.grid_y) == false then
                self.dead = true
                turn_state = 3
                return
            end
            Astar:setFinalNode(self.image_map.tile_x, self.image_map.tile_y)
            self.path_to_player = Astar:getPath()
            
            if self.path_to_player ~= nil then
                if #self.path_to_player > self.mp then
                    for nodes = 1, self.mp do
                        node = {}
                        node.x = self.path_to_player[nodes].x
                        node.y = self.path_to_player[nodes].y
                        table.insert(monster_path, node)
                    end

                    self:orderMove(monster_path)
                elseif #self.path_to_player == self.mp then
                    for nodes = 1, self.mp - 1 do
                        node = {}
                        node.x = self.path_to_player[nodes].x
                        node.y = self.path_to_player[nodes].y
                        table.insert(monster_path, node)
                    end

                    self:orderMove(monster_path)
                elseif #self.path_to_player < self.mp then
                    for nodes = 1, #self.path_to_player - 1 do
                        node = {}
                        node.x = self.path_to_player[nodes].x
                        node.y = self.path_to_player[nodes].y
                        table.insert(monster_path, node)
                    end

                    self:orderMove(monster_path)
                end
            end
        elseif turn_state == 1 then
            adjacent = getAdjacentTiles({x = self.x, y = self.y})
            if table.containsTable(adjacent, {x = self.image_map.player_x, y = self.image_map.player_y}) == true then
                if math.random(0, 99) < self.perception then
                    base_attack = self.strength
                else
                    base_attack = self.strength / 2
                end
                player.health = player.health - (base_attack - player.defense)
                turn_state = 3
            else
                turn_state = 3
            end
        end
    else
        turn_state = 3
    end
end

function monster:moveToTile(goal_tile_x, goal_tile_y, dt, system)
    -- Watches if the player has reached the goal on x/y
    local reached_x, reached_y = false, false 
  
    -- Compute the goal location in pixels from the goal tile coordinates
    local goal_x = (goal_tile_x * 32) - 32
    local goal_y = (goal_tile_y * 32) - 32
  
    -- Computes the unit vector of move
    local vx = (goal_x - self.x) / math.abs(goal_x - self.x)
    local vy = (goal_y - self.y) / math.abs(goal_y - self.y)        

    local dy, dx
    -- Moves on the player on y-axis
    if (self.y ~= goal_y) then
        dy = dt * self.drawing_speed * vy
        if vy > 0 then
            self.y = self.y + math.min(dy, goal_y - self.y)
        else
            self.y = self.y + math.max(dy, goal_y - self.y)
        end
    else
        self.y = goal_y
        reached_y = true
    end

  
    -- Moves on the player on x-axis
    if (self.x ~= goal_x) then
        dx = dt * self.drawing_speed * vx
        if vx > 0 then
            self.x = self.x + math.min(dx, goal_x - self.x)
        else
            self.x = self.x + math.max(dx, goal_x - self.x)
        end
    else 
        self.x = goal_x
        reached_x = true
    end
    
    if (reached_x and reached_y) then 
        self.there = true
    end
end

function monster:move(system, dt)
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
                turn_state = 1
                self.map[self.grid_y][self.grid_x] = 2
            end        
        end
    end
end

function monster:getSpeed()
    --function for the speed based turn scheduler
    return self.speed
end

function monster:update(dt, system)
    self:setTilePosition(system)
    self:move(system, dt)

    if self.health <= 0 then
        self.dead = true
        self.map[self.grid_y][self.grid_x] = 0
        self.x = 0
        self.y = 0
    end
end

function monster:draw()
    --fog of war check
    if self.image_map[self.grid_y][self.grid_x].visibility == true and self.dead == false then
        love.graphics.draw(self.image, self.x, self.y)
    end
end

function item:initialize(image, level, map, image_map)
    --base item class
    
    self.level = level
    self.map = map
    self.image_map = image_map
    self.start_x, self.start_y = getRandOpenTile(self.map, mapWidth, mapHeight)
    self.x = (self.start_x * 32) - 32
    self.y = (self.start_y * 32) - 32
    self.gridx = self.start_x
    self.gridy = self.start_y
    self.image = love.graphics.newImage(image)

    self.map[(self.y / 32) + 1][(self.x / 32) + 1] = 3
end

function item:draw()
    if self.image_map[self.gridy][self.gridx].visibility == true then
        love.graphics.draw(self.image, self.x, self.y)
    end
end

function stairs:initialize(image, direction, level, map, image_map)
    self.level = level
    self.direction = direction
    self.map = map
    self.image_map = image_map
    self.start_x, self.start_y = getRandOpenTile(self.map, mapWidth, mapHeight)
    self.x = (self.start_x * 32) - 32
    self.y = (self.start_y * 32) - 32
    self.gridx = self.start_x
    self.gridy = self.start_y
    self.image = love.graphics.newImage(image)

    if self.direction == "up" then 
        self.map[(self.y / 32) + 1][(self.x / 32) + 1] = 4
    elseif self.direction == "down" then
        self.map[(self.y / 32) + 1][(self.x / 32) + 1] = 5
    end
end

function stairs:draw()
    if self.image_map[self.gridy][self.gridx].visibility == true then
        love.graphics.draw(self.image, self.x, self.y)
    end
end