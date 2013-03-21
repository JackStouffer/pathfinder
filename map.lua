lastN = -1
mySeed = 1
showPerlin = 0
mapWidth = 120
mapHeight = 120
current_level = 1

--[[

    PERLIN NOISE

--]]

--Props go to middlerun on the LOVE forums for this awesome perlin code that
--is much better than what I was making

local function rand(seed, n)
  if n <= 0 then return nil end
  if seed ~= mySeed or lastN < 0 or n <= lastN then
    mySeed = seed
    math.randomseed(seed)
    lastN = 0
  end
  while lastN < n do
    num = math.random()
    lastN = lastN + 1
  end
  return num - 0.5
end

-- takes table of L values and returns N*(L-3) interpolated values
local function round(num, idp)
    local mult = 10^(idp or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult end
end

local function interpolate1D(values, N)
  newData = {}
  for i = 1, #values - 3 do
    P = (values[i+3] - values[i+2]) - (values[i] - values[i+1])
    Q = (values[i] - values[i+1]) - P
    R = (values[i+2] - values[i])
    S = values[i+1]
    for j = 0, N-1 do
      x = j/N
      table.insert(newData, P*x^3 + Q*x^2 + R*x + S)
    end
  end
  return newData
end

local function perlinComponent1D(seed, length, N, amplitude)
  rawData = {}
  finalData = {}
  for i = 1, math.ceil(length/N) + 3 do
    rawData[i] = amplitude * rand(seed, i)
  end
  interpData = interpolate1D(rawData, N)
  assert(#interpData >= length)
  for i = 1, length do
    finalData[i] = interpData[i]
  end
  return finalData
end

local function perlin1D(seed, length, persistence, N, amplitude)
  data = {}
  for i = 1, length do
    data[i] = 0
  end
  for i = N, 1, -1 do
    compInterp = 2^(i-1)
    compAmplitude = amplitude * persistence^(N-i)
    comp = perlinComponent1D(seed+i, length, compInterp, compAmplitude)
    for i = 1, length do
      data[i] = data[i] + comp[i]
    end
  end
  return data
end

local function interpolate2D(values, N)
  newData1 = {}
  for r = 1, #values do
    newData1[r] = {}
    for c = 1, #values[r] - 3 do
      P = (values[r][c+3] - values[r][c+2]) - (values[r][c] - values[r][c+1])
      Q = (values[r][c] - values[r][c+1]) - P
      R = (values[r][c+2] - values[r][c])
      S = values[r][c+1]
      for j = 0, N-1 do
        x = j/N
        table.insert(newData1[r], P*x^3 + Q*x^2 + R*x + S)
      end
    end
  end
  
  newData2 = {}
  for r = 1, (#newData1-3) * N do
    newData2[r] = {}
  end
  for c = 1, #newData1[1] do
    for r = 1, #newData1 - 3 do
      P = (newData1[r+3][c] - newData1[r+2][c]) - (newData1[r][c] - newData1[r+1][c])
      Q = (newData1[r][c] - newData1[r+1][c]) - P
      R = (newData1[r+2][c] - newData1[r][c])
      S = newData1[r+1][c]
      for j = 0, N-1 do
        x = j/N
        newData2[(r-1)*N+j+1][c] = P*x^3 + Q*x^2 + R*x + S
      end
    end
  end
  
  return newData2
end

local function perlinComponent2D(seed, width, height, N, amplitude)
  rawData = {}
  finalData = {}
  for r = 1, math.ceil(height/N) + 3 do
    rawData[r] = {}
    for c = 1, math.ceil(width/N) + 3 do
      rawData[r][c] = amplitude * rand(seed+r, c)
    end
  end
  interpData = interpolate2D(rawData, N)
  assert(#interpData >= height and #interpData[1] >= width)
  for r = 1, height do
    finalData[r] = {}
    for c = 1, width do
      finalData[r][c] = interpData[r][c]
    end
  end
  return finalData
end

local function perlin2D(seed, width, height, persistence, N, amplitude)
  data = {}
  for r = 1, height do
    data[r] = {}
    for c = 1, width do
      data[r][c] = 0
    end
  end
  for i = N, 1, -1 do
    compInterp = 2^(i-1)
    compAmplitude = amplitude * persistence^(N-i)
    comp = perlinComponent2D(seed+i*1000, width, height, compInterp, compAmplitude)
    for r = 1, height do
      for c = 1, width do
        data[r][c] = data[r][c] + comp[r][c]
      end
    end
  end
  return data
end

function plot1D(values)
  love.graphics.line(0, love.graphics.getHeight()/2 - 200, love.graphics.getWidth(), love.graphics.getHeight()/2 - 200)
  love.graphics.line(0, love.graphics.getHeight()/2 + 200, love.graphics.getWidth(), love.graphics.getHeight()/2 + 200)
  for i = 1, #values - 1 do
    love.graphics.line((i-1)/(#values-1)*love.graphics.getWidth(), love.graphics.getHeight()/2 - values[i] * 400, (i)/(#values-1)*love.graphics.getWidth(), love.graphics.getHeight()/2 - values[i+1] * 400)
  end
end

function plot2D(values)
  for r = 1, #values do
    for c = 1, #(values[1]) do
      love.graphics.setColor(128 + 40 * values[r][c], 128 + 40 * values[r][c], 128 + 40 * values[r][c], 255)
      love.graphics.rectangle("fill", (c-1)/(#(values[1]))*love.graphics.getWidth(), (r-1)/(#values)*love.graphics.getHeight(), love.graphics.getWidth()/#(values[1]), love.graphics.getHeight()/#values)
    end
  end
end

function makeTerrain(seed)
    terrain = {}
    if seed == nil then seed = os.time() end
    terrain.seed = seed
    terrain.perlin = perlin2D(seed, 341, 256, 0.55, 7, 1.5)
    terrain.value = {}
    for r = 1, #terrain.perlin do
        terrain.value[r] = {}
        for c = 1, #(terrain.perlin[r]) do
            value = terrain.perlin[r][c]
            terrain.value[r][c] = round(value, 1)
        end
    end
    return terrain
end

function drawTerrain(terrain)
    for r = 1, #terrain.value do
        for c = 1, #(terrain.value[1]) do
            if terrain.value[r][c] >= 0 then
                love.graphics.setColor(0, 0, 225, 255)
            elseif terrain.value[r][c] >= -.1 and terrain.value[r][c] < 0 then
                love.graphics.setColor(244, 240, 123, 255)
            elseif terrain.value[r][c] >= -.7 and terrain.value[r][c] < -.1 then
                love.graphics.setColor(26, 148, 22, 255)
            elseif terrain.value[r][c] >= -.9 and terrain.value[r][c] < -.7 then
                love.graphics.setColor(128, 128, 128, 255)
            elseif terrain.value[r][c] >= -2 and terrain.value[r][c] < -.9 then
                love.graphics.setColor(225, 225, 225, 255)
            else
                love.graphics.setColor(225, 0, 0, 255)
            end
            love.graphics.rectangle("fill", (c-1)/(#(terrain.value[1]))*love.graphics.getWidth(), (r-1)/(#terrain.value)*love.graphics.getHeight(), love.graphics.getWidth()/#(terrain.value[1]), love.graphics.getHeight()/#terrain.value)
        end
    end
end

--[[

    DUNGEON GENERATION

--]]

function createRoom(x, y, width, height, dungeonMap)    
    for u = y/32, height + y/32 do
        print(string.format("y: %i, height: %i"), y, height + y)
        for v = x/32, width + x/32 do
            dungeonMap[u][v] = 0
        end
    end
    return dungeonMap
end

function createDungeon()
    -- Fill the whole map with solid earth
    -- Dig out a single room in the center of the map
    -- Pick a wall of any room
    -- Decide upon a new feature to build
    -- See if there is room to add the new feature through the chosen wall
    -- If yes, continue. If no, go back to step 3
    -- Add the feature through the chosen wall
    -- Go back to step 3, until the dungeon is complete
    -- Add the up and down staircases at random points in map
    -- Finally, sprinkle some monsters and items liberally over dungeon

    local width = 500
    local height = 500
    dungeonMap = {}

    for y = 1, height do
        dungeonMap[y] = {}
        for x = 1, width do
            dungeonMap[y][x] = 2
        end
    end

    

    return dungeonMap
end

--[[

    CAVE GENERATION

--]]

function createCave(Width, Height)
    -- 0 is empty 
    -- 2 is thing to avoid
    local width = Width
    local height = Height
    local p = 55
    local i = 2 --counter.
    local c = 0
    local map = {}
    map.current = {}
    map.new = {}
    for y = 1, height do
        map.current[y] = {}
        for x = 1, width do
            if math.random(1, 100) <= p then
                map.current[y][x] = 2
            else
                map.current[y][x] = 0
            end
        end
    end
    
    map.new = map.current

    for l=1, i do 
        for y = 1, height do
            for x = 1, width do 
                --get the number of neighbors that are closed
                if y == 1 and x == 1 then --top left corner
                    if map.current[y + 1][x] == 2 then
                        c = c + 1
                    end
                    if map.current[y][x + 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y + 1][x + 1] == 2 then
                        c = c + 1
                    end
                elseif y == 1 and x == width then -- top right corner
                    if map.current[y + 1][x] == 2 then
                        c = c + 1
                    end
                    if map.current[y][x - 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y + 1][x - 1] == 2 then
                        c = c + 1
                    end
                elseif y == height and x == 1 then -- bottom left corner
                    if map.current[y - 1][x] == 2 then
                        c = c + 1
                    end
                    if map.current[y][x + 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y - 1][x + 1] == 2 then
                        c = c + 1
                    end
                elseif y == height and x == width then -- bottom right corner
                    if map.current[y - 1][x] == 2 then
                        c = c + 1
                    end
                    if map.current[y][x - 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y - 1][x - 1] == 2 then
                        c = c + 1
                    end
                elseif x == 1 and (y ~= 1 and y ~= height) then -- left side
                    if map.current[y - 1][x] == 2 then
                        c = c + 1
                    end
                    if map.current[y - 1][x + 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y][x + 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y + 1][x + 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y + 1][x - 1] == 2 then
                        c = c + 1
                    end
                elseif x == width and (y ~= 1 and y ~= height) then -- right side
                    if map.current[y - 1][x] == 2 then
                        c = c + 1
                    end
                    if map.current[y - 1][x - 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y][x - 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y + 1][x - 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y + 1][x] == 2 then
                        c = c + 1
                    end
                elseif y == 1 and (x ~= 0 and x ~= width) then -- top side
                    if map.current[y][x - 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y + 1][x - 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y + 1][x] == 2 then
                        c = c + 1
                    end
                    if map.current[y + 1][x + 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y][x + 1] == 2 then
                        c = c + 1
                    end
                elseif y == height and (x ~= 0 and x ~= width) then -- bottom side
                    if map.current[y][x - 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y - 1][x - 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y - 1][x] == 2 then
                        c = c + 1
                    end
                    if map.current[y - 1][x + 1] == 2 then
                        c = c + 1
                    end
                    if map.current[y][x + 1] == 2 then
                        c = c + 1
                    end
                else -- everything else
                    if map.current[y - 1][x - 1] == 2 then
                        c = c + 1
                    end

                    if map.current[y - 1][x] == 2 then
                        c = c + 1
                    end

                    if map.current[y - 1][x + 1] == 2 then
                        c = c + 1
                    end

                    if map.current[y][x + 1] == 2 then
                        c = c + 1
                    end

                    if map.current[y + 1][x + 1] == 2 then
                        c = c + 1
                    end

                    if map.current[y + 1][x] == 2 then
                        c = c + 1
                    end
                    if map.current[y + 1][x - 1] == 2 then
                        c = c + 1
                    end

                    if map.current[y][x - 1] == 2 then
                        c = c + 1
                    end
                end
                --decide if we should close or open the cell
                if c <= 3 then
                    map.new[y][x] = 0
                elseif c > 5 then
                    map.new[y][x] = 2
                end

                c = 0
            end
        end

        map.current = map.new
    end

    for x = 1, width do
        map.current[1][x] = 2
    end

    return map.current
end

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

--alternate way of creating caves based around "miners"
--this is superior because it is not possible for this to produce closed areas
function minerCave(Width, Height)
    local width = Width
    local height = Height
    local Map = {}
    local Dir = 0
    local max_miners = 1600
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

    return Map
end

--function to generate multi-leveled caves
--each level has its own item and enemies 
function caveSystem(level_num, difficulty)
    local Map = {}
    local CollisionMap = {}
    local enemies = {}
    local items = {}
    local system = {}
    local difficulty = difficulty

    for level = 1, level_num do
        Map[level] = minerCave(mapWidth, mapHeight)
        print("map")
        -- when assigning a value to value that is a table, lua does not set the original value to the table, but rather as a pointer to the table
        --so if I change collisionMap.x = 5 the map.x = 5 as well
        --that's why I do this abomination of code
        CollisionMap[level] = TSerial.unpack(TSerial.pack(Map[level]))
        print("collisionMap")
        enemies[level] = {}
        items[level] = {}
    end

    system.map = Map
    system.collisionMap = CollisionMap
    system.enemies = enemies
    system.items = items
    return system
end

--[[

    UTILITIES

]]--

function drawMap(Map, mapDisplayW, mapDisplayH, radius)
    local startx = ((player.x / 32) + 1) - radius
    local starty = ((player.y / 32) + 1) - radius
    local endx = ((player.x / 32) + 1) + radius
    local endy = ((player.y / 32) + 1) + radius
    
    if ((player.x / 32) + 1) - radius < 1 then
        startx = 1
    end

    if ((player.y / 32) + 1) - radius < 1 then
        starty = 1
    end

    for y = starty, endy do
        for x = startx, endx do                                                         
            love.graphics.draw(tile[Map[y][x]], (x * 32) - 32, (y * 32) - 32)
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
