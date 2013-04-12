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
    local newData = {}
    local P = 0
    local Q = 0
    local R = 0
    local S = 0
    local x = 0
    
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
    local rawData = {}
    local finalData = {}
    local interpData = {}
    
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
    local data = {}
    local compInterp = 0
    local compAmplitude = 0
    local comp = {}
    local data = {}
    
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
    local newData1 = {}
    local newData2 = {}
    local P = 0
    local Q = 0
    local R = 0
    local S = 0
    local x = 0

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
    local rawData = {}
    local finalData = {}
    local interpData = {}
    
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
    local data = {}
    local comp = 0
    local compInterp = 0
    local compAmplitude = 0

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
    local terrain = {}
    
    if seed == nil then seed = os.time() end
    
    terrain.seed = seed
    terrain.perlin = perlin2D(seed, 341, 256, 0.55, 7, 1.5)
    terrain.value = {}
    terrain.locations = {}

    local found = false
    local x = 1
    local y = 1
    
    for r = 1, #terrain.perlin do
        terrain.value[r] = {}
        for c = 1, #(terrain.perlin[r]) do
            value = terrain.perlin[r][c]
            terrain.value[r][c] = round(value, 1)
        end
    end

    while found == false do
        x = math.random(1, #terrain.value[1])
        y = math.random(1, #terrain.value)
        if terrain.value[y][x] >= -.9 and terrain.value[y][x] < -.7 then 
            found = true 
        end
    end

    terrain.locations.cave = {}
    terrain.locations.cave.gridx = x
    terrain.locations.cave.gridy = y
    terrain.locations.cave.x = (terrain.locations.cave.gridx-1)/(#(terrain.value[1]))*love.graphics.getWidth()
    terrain.locations.cave.y = (terrain.locations.cave.gridy-1)/(#terrain.value)*love.graphics.getHeight()
    terrain.locations.cave.image = love.graphics.newImage("textures/dc-dngn/dngn_open_door.png")
    
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
    
    love.graphics.draw(terrain.locations.cave.image, terrain.locations.cave.x, terrain.locations.cave.y)
end
