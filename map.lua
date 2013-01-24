function drawMap()
   --legacy code is bad M'kay, need to replace this
   for y=1, map_display_h do
      for x=1, map_display_w do                                                         
         love.graphics.draw(tile[map[y+map_y][x+map_x]], (x*tile_w)+map_offset_x, (y*tile_h)+map_offset_y)
      end
   end
end

function testCollisionTile(x, y)
    -- if the tile is rock or water, return true
    -- I add an extra one due to the way lua handles table indexing with zero not being the first
    -- number, what a stupid design decision
    if  map[player.y/32 + 1 + y][player.x/32 + 1 + x] == 2 or 
        map[player.y/32 + 1 + y][player.x/32 + 1 + x] == 3 then
        return true
    end
    return false

end

function testMapEdge(x, y)
    --if the player's input is going to send him off the map, then return true
    if  player.x + x < 0 or
        player.x + x == 2048 or
        player.y + y < 0 or
        player.y + y == 1408 then
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
    dirtMargin = (256-r) * 0.01
    for c = 1, #(terrain.perlin[r]) do
      value = terrain.perlin[r][c]
      if r < 128 then
        value = value + (128 - r) * 0.025
      end
      terrain.value[r][c] = value
    end
  end
  return terrain
end

function drawTerrain(terrain)
  for r = 1, #terrain.perlin do
    for c = 1, #(terrain.perlin[1]) do
        love.graphics.setColor(128 + 40 * terrain.perlin[r][c], 128 + 40 * terrain.perlin[r][c], 128 + 40 * terrain.perlin[r][c], 255)
        love.graphics.rectangle("fill", (c-1)/(#(terrain.value[1]))*love.graphics.getWidth(), (r-1)/(#terrain.value)*love.graphics.getHeight(), love.graphics.getWidth()/#(terrain.value[1]), love.graphics.getHeight()/#terrain.value)
    end
  end
end

--[[

    DUNGEON GENERATION

--]]

function createDungeon()
    local width = 150
    local height = 150
    local p = 55
    local i = 2 --counter.
    local c = 0
    local map = {}
    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            if math.random(1, 100) <= p then
                map[y][x] = 2
            else
                map[y][x] = 0
            end
        end
    end
    
    -- The procedure is as follows:
    -- Randomly choose a cell from map
    -- If the cell is open use a p to determine whether we close it.
    -- Get c
    -- Repeat steps 1-3 i number of times.
    for l=1, i do 
        for y = 1, height do
            for x = 1, width do 
                --get the number of neighbors that are closed
                if y == 1 and x == 1 then --top left corner
                    if map[y + 1][x] == 2 then
                        c = c + 1
                    end
                    if map[y][x + 1] == 2 then
                        c = c + 1
                    end
                    if map[y + 1][x + 1] == 2 then
                        c = c + 1
                    end
                elseif y == 1 and x == width then -- top right corner
                    if map[y + 1][x] == 2 then
                        c = c + 1
                    end
                    if map[y][x - 1] == 2 then
                        c = c + 1
                    end
                    if map[y + 1][x - 1] == 2 then
                        c = c + 1
                    end
                elseif y == height and x == 1 then -- bottom left corner
                    if map[y - 1][x] == 2 then
                        c = c + 1
                    end
                    if map[y][x + 1] == 2 then
                        c = c + 1
                    end
                    if map[y - 1][x + 1] == 2 then
                        c = c + 1
                    end
                elseif y == height and x == width then -- bottom right corner
                    if map[y - 1][x] == 2 then
                        c = c + 1
                    end
                    if map[y][x - 1] == 2 then
                        c = c + 1
                    end
                    if map[y - 1][x - 1] == 2 then
                        c = c + 1
                    end
                elseif x == 1 and (y ~= 1 and y ~= height) then -- left side
                    if map[y - 1][x] == 2 then
                        c = c + 1
                    end
                    if map[y - 1][x + 1] == 2 then
                        c = c + 1
                    end
                    if map[y][x + 1] == 2 then
                        c = c + 1
                    end
                    if map[y + 1][x + 1] == 2 then
                        c = c + 1
                    end
                    if map[y + 1][x - 1] == 2 then
                        c = c + 1
                    end
                elseif x == width and (y ~= 1 and y ~= height) then -- right side
                    if map[y - 1][x] == 2 then
                        c = c + 1
                    end
                    if map[y - 1][x - 1] == 2 then
                        c = c + 1
                    end
                    if map[y][x - 1] == 2 then
                        c = c + 1
                    end
                    if map[y + 1][x - 1] == 2 then
                        c = c + 1
                    end
                    if map[y + 1][x] == 2 then
                        c = c + 1
                    end
                elseif y == 1 and (x ~= 0 and x ~= width) then -- top side
                    if map[y][x - 1] == 2 then
                        c = c + 1
                    end
                    if map[y + 1][x - 1] == 2 then
                        c = c + 1
                    end
                    if map[y + 1][x] == 2 then
                        c = c + 1
                    end
                    if map[y + 1][x + 1] == 2 then
                        c = c + 1
                    end
                    if map[y][x + 1] == 2 then
                        c = c + 1
                    end
                elseif y == height and (x ~= 0 and x ~= width) then -- bottom side
                    if map[y][x - 1] == 2 then
                        c = c + 1
                    end
                    if map[y - 1][x - 1] == 2 then
                        c = c + 1
                    end
                    if map[y - 1][x] == 2 then
                        c = c + 1
                    end
                    if map[y - 1][x + 1] == 2 then
                        c = c + 1
                    end
                    if map[y][x + 1] == 2 then
                        c = c + 1
                    end
                else -- everything else
                    if map[y - 1][x - 1] == 2 then
                        c = c + 1
                    end

                    if map[y - 1][x] == 2 then
                        c = c + 1
                    end

                    if map[y - 1][x + 1] == 2 then
                        c = c + 1
                    end

                    if map[y][x + 1] == 2 then
                        c = c + 1
                    end

                    if map[y + 1][x + 1] == 2 then
                        c = c + 1
                    end

                    if map[y + 1][x] == 2 then
                        c = c + 1
                    end
                    if map[y + 1][x - 1] == 2 then
                        c = c + 1
                    end

                    if map[y][x - 1] == 2 then
                        c = c + 1
                    end
                end
                print(string.format("c = %i", c))
                --decide if we should close or open the cell
                if c <= 3 then
                    map[y][x] = 0
                elseif c > 5 then
                    map[y][x] = 2
                end

                c = 0
            end
        end
    end

    for x = 1, width do
        map[1][x] = 2
    end

    return map
end

-- map variables
map_w = 500
map_h = 500
map_x = 0
map_y = 0
map_offset_x = -32 --to make the map appear at the edge of the screen and not have a black border
map_offset_y = -32 --to make the map appear at the edge of the screen and not have a black border
map_display_w = 64
map_display_h = 44
tile_w = 32
tile_h = 32
rect = love.graphics.newImage("textures/square.png")