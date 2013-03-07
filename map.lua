function max(t, fn)
    if #t == 0 then return nil, nil end
    local key, value = 1, t[1]
    for i = 2, #t do
        if fn(value, t[i]) then
            key, value = i, t[i]
        end
    end
    return key, value
end

function round(num, idp)
    local mult = 10^(idp or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult end
end

function testCollisionTile(x, y)
    -- if the tile is rock or water, return true
    -- I add an extra one due to the way lua handles table indexing with zero not being the first
    -- number, what a stupid design decision
    if  collisionMap[player.y/32 + 1 + y][player.x/32 + 1 + x] == 2 or 
        collisionMap[player.y/32 + 1 + y][player.x/32 + 1 + x] == 3 then
        return true
    end
    return false
end

--[[

    PERLIN NOISE

--]]

--Props go to middlerun on the LOVE forums for this awesome perlin code that
--is much better than what I was making

-- takes table of L values and returns N*(L-3) interpolated values
function interpolate1D(values, N)
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

function perlinComponent1D(seed, length, N, amplitude)
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

function perlin1D(seed, length, persistence, N, amplitude)
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

function interpolate2D(values, N)
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

function perlinComponent2D(seed, width, height, N, amplitude)
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

function perlin2D(seed, width, height, persistence, N, amplitude)
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

function rand(seed, n)
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
    print(width)
    print(height)
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

function drawMap(Map, mapDisplayW, mapDisplayH)
   for y = 1, mapDisplayH do
      for x = 1, mapDisplayW do                                                         
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

function testMapEdge(x, y, mapW, mapH)
    --if the player's input is going to send him off the map, then return true
    if  player.x + x < 0 or
        player.x + x == (mapW * 32) or
        player.y + y < 0 or
        player.y + y == (mapH * 32) then
        return true
    end
    return false
end

rect = love.graphics.newImage("textures/square.png")