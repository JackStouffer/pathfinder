systemClass = Class('systemClass')

function systemClass:initialize(num_levels, difficulty, kind)
    self.map = {}
    self.collision_map = {}
    self.enemies = {}
    self.items = {}
    self.stair = {}
    self.system = {}
    
    self.difficulty = difficulty
    self.kind = kind
    self.image = nil

    self.enemy_num = 5
    -- which level the player is on
    self.current_level = 1
    -- which level we are currently generating
    self.levels = 1
    -- the total number of levels
    self.num_levels = num_levels
    -- if all of the monsters in the system are dead
    self.clear = false

    for i = 1, self.num_levels do
        self:createLevel()
    end

    --on every level but the first, put the player on the up stairs to make
    --it look like the actually went down the stairs
    for level = 2, self.num_levels do
        for i, stairs in ipairs(self.stair[level]) do
            if stairs.direction == 'up' then
                self.map[level].player_x = stairs.x
                self.map[level].player_y = stairs.y
                self.map[level].tile_x = (stairs.x / 32) + 1
                self.map[level].tile_y = (stairs.y / 32) + 1
                self.map[level].translate_x = (stairs.x - 416) * -1
                self.map[level].translate_y = (stairs.y - 288) * -1
            end
        end
    end
end

function systemClass:update()
    self:turnManager()
end

function systemClass:draw(radius, sight)
    --limit the total amount of tiles drawn to just what can be seen by the player

    --calculate the bounds of the player's view
    local start_x = self.map[self.current_level].tile_x - radius
    local start_y = self.map[self.current_level].tile_y - radius
    local end_x = self.map[self.current_level].tile_x + radius
    local end_y = self.map[self.current_level].tile_y + radius

    --calculate the area of the player's sight
    local start_x_sight = self.map[self.current_level].tile_x - sight
    local start_y_sight = self.map[self.current_level].tile_y - sight
    local end_x_sight = ((self.map[self.current_level].player_x / 32) + 1) + sight
    local end_y_sight = ((self.map[self.current_level].player_y / 32) + 1) + sight

    --makes sure none of our values go outside the range of the map
    if self.map[self.current_level].tile_x - radius < 1 then
        start_x = 1
    end

    if self.map[self.current_level].tile_y - radius < 1 then
        start_y = 1
    end

    if self.map[self.current_level].tile_x - sight < 1 then
        start_x_sight = 1
    end

    if self.map[self.current_level].tile_y - sight < 1 then
        start_y_sight = 1
    end

    if self.map[self.current_level].tile_x + radius > self.map[self.current_level].map_width then
        end_x = self.map[self.current_level].map_width
    end

    if self.map[self.current_level].tile_y + radius > self.map[self.current_level].map_height then
        end_y = self.map[self.current_level].map_height
    end

    if self.map[self.current_level].tile_x + sight > self.map[self.current_level].map_width then
        end_x_sight = self.map[self.current_level].map_width
    end

    if self.map[self.current_level].tile_y + sight > self.map[self.current_level].map_height then
        end_y_sight = self.map[self.current_level].map_height
    end

    for y = start_y, end_y do
        for x = start_x, end_x do
            if y >= start_y_sight and y <= end_y_sight and x >= start_x_sight and x <= end_x_sight then
                if self.map[self.current_level][y][x].visibility == true then
                    self.map[self.current_level][y][x].visibility = "fog"
                end

                -- calculate what the player can see with the bresenham line algorithm
                bresenham.los(self.map[self.current_level].tile_x, system.map[current_level].tile_y, x, y, function(x,y)
                    if self.collisionMap[self.current_level][y][x] == 2 then --we still want the walls to be lit
                        self.map[self.current_level][y][x].visibility = true
                        return false
                    end
                    self.map[self.current_level][y][x].visibility = true
                    return true
                end)

            elseif not(y >= start_y_sight and y <= end_y_sight and x >= start_x_sight and x <= end_x_sight) and 
            self.map[self.current_level][y][x].visibility == true then
                self.map[self.current_level][y][x].visibility = "fog"
            elseif self.map[self.current_level][y][x].visibility == "fog" then
                -- don't do anything to the fog
            else
                self.map[self.current_level][y][x].visibility = false
            end
            
            if self.map[self.current_level][y][x].visibility == true then
                love.graphics.setColor(255, 255, 255, 255)
                love.graphics.draw(self.map[self.current_level][y][x].image, (x * 32) - 32, (y * 32) - 32)
            elseif self.map[self.current_level][y][x].visibility == "fog" then
                love.graphics.setColor(255, 255, 255, 100)
                love.graphics.draw(self.map[self.current_level][y][x].image, (x * 32) - 32, (y * 32) - 32)
            end
        end
    end
end

function systemClass:mousepressed()
    --
end

function systemClass:keypressed()
    --
end

function systemClass:createLevel()
    local map_width = 40 + self.levels ^ 4
    local map_height = 40 + self.levels ^ 4

    self.enemies[self.levels] = {}
    self.items[self.levels] = {}
    self.stair[self.levels] = {}
    self.map[self.levels] = {}

    if self.kind == "cave" then
        self.map[self.levels] = minerCave(map_width, map_height)
    elseif self.kind == "dungeon" then
        self.map[self.levels] = createDungeon(map_width, map_height)
    end

    -- when assigning a value to value that is a table, lua does not set the original value to the table, 
    --but rather as a pointer to the table
    --so if I change collisionMap.x = 5 the map.x = 5 as well
    --that's why I do this abomination of code
    self.collision_map[self.levels] = TSerial.unpack(TSerial.pack(self.map[self.levels])) --disgusting right?

    --turn the map into a reference for the images
    for y = 1, #self.map[self.levels] do
        for x = 1, #self.map[self.levels][1] do
            rand = math.random(1, #tile[self.kind][self.map[self.levels][y][x]])
            image = tile[self.kind][self.map[self.levels][y][x]][rand]
            self.map[self.levels][y][x] = {}
            self.map[self.levels][y][x].image = image
            self.map[self.levels][y][x].visibility = false
        end
    end

    self.map[self.levels].clear = false
    self.map[self.levels].map_width = map_width
    self.map[self.levels].map_height = map_height

    if self.levels == 1 then
        --put the player in a random location on the first level
        local start_x, start_y = getRandOpenTile(self.collision_map[1], mapWidth, mapHeight)
        local player_x = (start_x * 32) - 32
        local player_y = (start_y * 32) - 32

        local translate_x = (player_x - 416) * -1
        local translate_y = (player_y - 288) * -1

        --only the player's location on the first level is random
        self.map[1].player_x = player_x
        self.map[1].player_y = player_y
        self.map[1].tile_x = start_x
        self.map[1].tile_y = start_y
        self.map[1].translate_x = translate_x
        self.map[1].translate_y = translate_y
    end

    for num = 1, self.enemy_num do
        self.enemies[self.levels][num] = monster:new(30, 
            "textures/dc-mon/acid_blob.png",
            self.levels,
            self.collision_map[self.levels],
            self.map[self.levels])
    end

    --organize the entities based on speed
    table.sort(self.enemies[self.levels], function(a, b) return a:getSpeed() < b:getSpeed() end)

    for num = 1, 20 do
        self.items[self.levels][num] = item:new("textures/item/potion/ruby.png",
            self.levels,
            self.collision_map[self.levels],
            self.map[self.levels])
    end

    if self.levels ~= self.num_levels then
        table.insert(self.stair[self.levels],
            stairs:new("textures/dc-dngn/gateways/stone_stairs_down.png",
            "down",
            self.levels,
            self.collision_map[self.levels],
            self.map[self.levels]))
    end
    
    if self.levels ~= 1 then
        table.insert(self.stair[self.levels],
            stairs:new("textures/dc-dngn/gateways/stone_stairs_up.png",
            "up",
            self.levels,
            self.collision_map[self.levels],
            self.map[self.levels]))
    end

    self.levels = self.levels + 1
end

function systemClass:turnManager()
    --credit for the pseudo code for this goes to spacecoote on reddit

    if turn_state == 0 then -- entity is in the moving stage of the turn.    
        if current_player ~= 0 then
            self.enemies[self.current_level][current_player]:turn()
        end
    elseif turn_state == 1 then -- entity is in the attack stage of the turn.    
        if current_player ~= 0 then
            self.enemies[self.current_level][current_player]:turn()
        end
    elseif turn_state == 2 then --entity is in the final stage of the turn.    
        --do stuff
    elseif turn_state == 3 then --entity has ended their turn.    
        --do end-of-turn stuff
        current_player = current_player + 1
        if current_player > #self.enemies[self.current_level] then       
            current_player = 0
        end
        turn_state = 0
    end
end