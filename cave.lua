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

    --start at the player position
    NewMiner(13, 9)

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
    local system = {}
    local difficulty = difficulty
    local rand = 1
    local image

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
                rand = math.random(1, #tile[Map[level][y][x]])
                image = tile[Map[level][y][x]][rand]
                Map[level][y][x] = {}
                Map[level][y][x].image = image
                Map[level][y][x].visibility = false
            end
        end
        
        enemies[level] = {}
        items[level] = {}
    end

    system.map = Map
    system.collisionMap = CollisionMap
    system.enemies = enemies
    system.items = items
    return system
end

function drawMap(Map, mapDisplayW, mapDisplayH, radius, sight)
    local startx = ((player.x / 32) + 1) - radius
    local starty = ((player.y / 32) + 1) - radius
    local endx = ((player.x / 32) + 1) + radius
    local endy = ((player.y / 32) + 1) + radius

    local start_x_sight = ((player.x / 32) + 1) - sight
    local start_y_sight = ((player.y / 32) + 1) - sight
    local end_x_sight = ((player.x / 32) + 1) + sight
    local end_y_sight = ((player.y / 32) + 1) + sight

    
    if ((player.x / 32) + 1) - radius < 1 then
        startx = 1
    end

    if ((player.y / 32) + 1) - radius < 1 then
        starty = 1
    end

    if ((player.x / 32) + 1) - sight < 1 then
        start_x_sight = 1
    end

    if ((player.y / 32) + 1) - sight < 1 then
        start_y_sight = 1
    end

    for y = starty, endy do
        for x = startx, endx do
            if y >= start_y_sight and y <= end_y_sight and x >= start_x_sight and x <= end_x_sight then
                Map[y][x].visibility = true                
            elseif not(y >= start_y_sight and y <= end_y_sight and x >= start_x_sight and x <= end_x_sight) and Map[y][x].visibility == true then
                Map[y][x].visibility = "fog"
            elseif Map[y][x].visibility == "fog" then
                
            else
                Map[y][x].visibility = false
            end
            
            if Map[y][x].visibility == true then
                love.graphics.setColor(255, 255, 255, 255)
                love.graphics.draw(Map[y][x].image, (x * 32) - 32, (y * 32) - 32)
            elseif Map[y][x].visibility == "fog" then
                love.graphics.setColor(255, 255, 255, 100)
                love.graphics.draw(Map[y][x].image, (x * 32) - 32, (y * 32) - 32)
            end
        end
    end
end

function getRandOpenTile(Map, mapW, mapH)
    --find a open tile randomly on the map
    local found = false
    local x = 0
    local y = 0
    
    while found == false do
        x = math.random(1, mapW)
        y = math.random(1, mapH)
        if Map[y][x] == 0 then found = true end
    end
    
    if found then return x,y end
end

function testCollisionTile(CollisionMap, x, y)
    -- I add an extra one due to the way lua handles table indexing with zero not being the first
    -- number, what a stupid design decision
    if CollisionMap[player.y/32 + 1 + y][player.x/32 + 1 + x] == 2 then
        return true
    end
    return false
end

function testMapEdge(x, y, mapW, mapH)
    --if the player's input is going to send him off the map, then return true
    --rather than an actual pixel amount, the x and y are vectors that represent the direction to be checked
    if  player.x + x < 0 or
        player.x + x == (mapW * 32) or
        player.y + y < 0 or
        player.y + y == (mapH * 32) then
        return true
    end
    return false
end