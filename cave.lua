--[[

    CAVE GENERATION

--]]
local MinerList={}
local NbMiner=0
local Act=1

local function NewMiner(x,y)
    NbMiner = NbMiner+1
    local t = {}
    t.x = x
    t.y = y
    t.Active = true
    table.insert(MinerList,t)
end

--alternate way of creating caves based around "miners" that "grow" the cave from a starting point
--this is superior because it is not possible for this to produce closed areas
--credit where credit is due: https://love2d.org/forums/viewtopic.php?f=5&t=7473
local function minerCave(Width, Height)
    local width = Width
    local height = Height
    local Map = {}
    local Dir = 0
    local max_miners = 1900
    local false_counter = 0 --number of inactive miners

    --reset the values
    MinerList = {}
    NbMiner = 0
    Act = 1

    for y = 1, height do
        Map[y] = {}
        for x = 1, width do
            Map[y][x] = 2
        end
    end

    --start in the middle
    NewMiner(width / 2, height / 2)

    while false_counter < max_miners do
        for k,v in ipairs(MinerList) do
            if v.Active == false then
                false_counter = false_counter + 1
            end
            
            if v.x >= width - 1 or v.x <= 1  or v.y >= height - 1 or v.y <= 1 then
                v.Active = false
            end
        
            if v.Active == true then
                if Map[v.y-1][v.x] == 0 and Map[v.y+1][v.x] == 0 and Map[v.y][v.x + 1] == 0 and Map[v.y][v.x-1] == 0 then
                    v.Active = false
                end
            end
        
        
            if v.Active == true then
                Dir = math.random(1, 4)
                if Dir == 1 then
                    Map[v.y - 1][v.x] = 0
                    v.y = v.y - 1
                end
                if Dir == 2 then
                    Map[v.y][v.x + 1] = 0
                    v.x = v.x + 1
                end
                if Dir == 3 then
                    Map[v.y + 1][v.x] = 0
                    v.y = v.y + 1
                end
                if Dir == 4 then
                    Map[v.y][v.x - 1] = 0
                    v.x = v.x - 1
                end
                -- NewMiner 8% de chance
                local N = math.random(0,5)
                local miner_direction =  math.random(1,4)
                if N > 3 and NbMiner < max_miners then
                    if miner_direction == 1 then
                        NewMiner(v.x, v.y - 1)
                    end
                    if miner_direction == 2 then
                        NewMiner(v.x + 1, v.y)
                    end
                    if miner_direction == 3 then
                        NewMiner(v.x, v.y + 1)
                    end
                    if miner_direction == 4 then
                        NewMiner(v.x - 1, v.y)
                    end
                end
            end
        end
        
        if false_counter ~= max_miners then
            false_counter = 0
        end

        for k,v in ipairs(MinerList) do
            if v.Active == true then
                Act = 1
                break
            else
                Act = 2
            end
        end
    end -- end while loop

    --strip out lone blocks 
    for y = 2, height - 1 do
        for x = 2, width - 1 do
            if Map[y][x + 1] == 0 and Map[y][x - 1] == 0 and Map[y + 1][x] == 0 and Map[y - 1][x] == 0 then
                Map[y][x] = 0
            end
        end
    end

    --make the edges solid
    for y = 1, height do
        for x = 1, width do
            if x == 1 then
                Map[y][x] = 2
            elseif y == 1 then
                Map[y][x] = 2
            elseif x == width then
                Map[y][x] = 2
            elseif y == height then
                Map[y][x] =2
            end
        end
    end

    return Map
end

--function to generate multi-leveled caves
--each level has its own item and enemies 
function levelSystem(level_num, difficulty, Type)
    local Map = {}
    local CollisionMap = {}
    local enemies = {}
    local items = {}
    local stair = {}
    local system = {}
    local difficulty = difficulty
    local rand = 1
    local image
    local enemy_num = 5

    for level = 1, level_num do
        if Type == "cave" then
            Map[level] = minerCave(mapWidth, mapHeight)
        elseif Type == "dungeon" then
            Map[level] = createDungeon(mapWidth, mapHeight)
        end

        
        -- when assigning a value to value that is a table, lua does not set the original value to the table, but rather as a pointer to the table
        --so if I change collisionMap.x = 5 the map.x = 5 as well
        --that's why I do this abomination of code
        CollisionMap[level] = TSerial.unpack(TSerial.pack(Map[level])) --disgusting right?

        --turn the map into a reference for the images
        for y = 1, #Map[level] do
            for x = 1, #Map[level][1] do
                rand = math.random(1, #tile[Type][Map[level][y][x]])
                image = tile[Type][Map[level][y][x]][rand]
                Map[level][y][x] = {}
                Map[level][y][x].image = image
                Map[level][y][x].visibility = false
            end
        end
        
        enemies[level] = {}
        items[level] = {}
        stair[level] = {}
    end

    --difficulty settings
    if difficulty == "normal" then
        enemy_num = 5
    elseif difficulty == "hard" then
        enemy_num = 25
    end

    --put the player in a random location on the first level
    local start_x, start_y = getRandOpenTile(CollisionMap[1], mapWidth, mapHeight)
    local player_x = (start_x * 32) - 32
    local player_y = (start_y * 32) - 32

    local translate_x = (player_x - 416) * -1
    local translate_y = (player_y - 288) * -1

    Map[1].player_x = player_x
    Map[1].player_y = player_y
    Map[1].tile_x = start_x
    Map[1].tile_y = start_y
    Map[1].translate_x = translate_x
    Map[1].translate_y = translate_y

    --store our vars in a nice data structure
    system.map = Map
    system.collisionMap = CollisionMap
    system.enemies = enemies
    system.items = items
    system.stair = stair

    --add in the entities in to the maps
    for level = 1, level_num do 
        for num=1, enemy_num do
            system.enemies[level][num] = monster:new(100, "textures/dc-mon/acid_blob.png", level, CollisionMap[level], Map[level])
        end
        for num=1, 20 do
            system.items[level][num] = item:new("textures/item/potion/ruby.png", level, CollisionMap[level], Map[level])
        end
        if level ~= level_num then
            table.insert(system.stair[level], stairs:new("textures/dc-dngn/gateways/stone_stairs_down.png", "down", level, CollisionMap[level], Map[level]))
        end
        if level ~= 1 then
            table.insert(system.stair[level], stairs:new("textures/dc-dngn/gateways/stone_stairs_up.png", "up", level, CollisionMap[level], Map[level]))
        end
    end

    --on every level but the first, put the player on the up stairs to make
    --it look like the actually went down the stairs
    for level = 2, level_num do
        for i, stairs in ipairs(system.stair[level]) do
            if stairs.direction == 'up' then
                Map[level].player_x = stairs.x
                Map[level].player_y = stairs.y
                Map[level].tile_x = (stairs.x / 32) + 1
                Map[level].tile_y = (stairs.y / 32) + 1
                Map[level].translate_x = (stairs.x - 416) * -1
                Map[level].translate_y = (stairs.y - 288) * -1
            end
        end
    end
    
    return system
end

function drawMap(system, mapDisplayW, mapDisplayH, radius, sight)
    local startx = system.map[current_level].tile_x - radius
    local starty = system.map[current_level].tile_y - radius
    local endx = system.map[current_level].tile_x + radius
    local endy = system.map[current_level].tile_y + radius

    local start_x_sight = system.map[current_level].tile_x - sight
    local start_y_sight = system.map[current_level].tile_y - sight
    local end_x_sight = ((system.map[current_level].player_x / 32) + 1) + sight
    local end_y_sight = ((system.map[current_level].player_y / 32) + 1) + sight

    
    if system.map[current_level].tile_x - radius < 1 then
        startx = 1
    end

    if system.map[current_level].tile_y - radius < 1 then
        starty = 1
    end

    if system.map[current_level].tile_x - sight < 1 then
        start_x_sight = 1
    end

    if system.map[current_level].tile_y - sight < 1 then
        start_y_sight = 1
    end

    if system.map[current_level].tile_x + radius > mapWidth then
        endx = mapWidth
    end

    if system.map[current_level].tile_y + radius > mapHeight then
        endy = mapHeight
    end

    if system.map[current_level].tile_x + sight > mapWidth then
        end_x_sight = mapWidth
    end

    if system.map[current_level].tile_y + sight > mapHeight then
        end_y_sight = mapHeight
    end

    for y = starty, endy do
        for x = startx, endx do
            if y >= start_y_sight and y <= end_y_sight and x >= start_x_sight and x <= end_x_sight then
                
                bresenham.los(system.map[current_level].tile_x, system.map[current_level].tile_y, x, y, function(x,y)
                    if system.collisionMap[current_level][y][x] == 2 then 
                        system.map[current_level][y][x].visibility = true
                        return false
                    end
                    system.map[current_level][y][x].visibility = true
                    return true
                end)

            elseif not(y >= start_y_sight and y <= end_y_sight and x >= start_x_sight and x <= end_x_sight) and system.map[current_level][y][x].visibility == true then
                system.map[current_level][y][x].visibility = "fog"
            elseif system.map[current_level][y][x].visibility == "fog" then
                
            else
                system.map[current_level][y][x].visibility = false
            end
            
            if system.map[current_level][y][x].visibility == true then
                love.graphics.setColor(255, 255, 255, 255)
                love.graphics.draw(system.map[current_level][y][x].image, (x * 32) - 32, (y * 32) - 32)
            elseif system.map[current_level][y][x].visibility == "fog" then
                love.graphics.setColor(255, 255, 255, 100)
                love.graphics.draw(system.map[current_level][y][x].image, (x * 32) - 32, (y * 32) - 32)
            end
        end
    end
end