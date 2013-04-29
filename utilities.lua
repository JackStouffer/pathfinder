--Screen to tiles coordinates
--credit for this function goes to Yonaba on github
function mouseToMapCoords(system, x, y)
    local mx, my = x, y
    
    if not mx or not my then 
        mx, my = love.mouse.getPosition() 
    end
    
    local translation_x = system.map[current_level].translate_x - (system.map[current_level].translate_x % 32)
    local translation_y = system.map[current_level].translate_y - (system.map[current_level].translate_y % 32)

    local _x = (math.floor(mx / 32) + 1) + ((translation_x / 32) * -1)
    local _y = (math.floor(my / 32) + 1) + ((translation_y / 32) * -1)

    if system.collisionMap[current_level][_y] and system.collisionMap[current_level][_y][_x]  then
        return _x, _y
    end

    return nil
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

function testCollisionTile(system, x, y)
    -- I add an extra one due to the way lua handles table indexing with zero not being the first
    -- number; what a stupid design decision
    if system.collisionMap[current_level][system.map[current_level].player_y/32 + 1 + y][system.map[current_level].player_x/32 + 1 + x] == 2 then
        return true
    end
    
    return false
end

function testMapEdge(system, x, y, mapW, mapH)
    --if the player's input is going to send him off the map, then return true
    --rather than an actual pixel amount, the x and y are vectors that represent the direction to be checked
    if  system.map[current_level].player_x + x < 0 or
        system.map[current_level].player_x + x == (mapW * 32) or
        system.map[current_level].player_y + y < 0 or
        system.map[current_level].player_y + y == (mapH * 32) then
        return true
    end
    
    return false
end

--this function is from Warp Run
function take_screenshot()
    local screenshot = love.graphics.newScreenshot()

    local time_string = os.date('%Y-%m-%d_%H-%M-%S')
    local filename = 'pathfinder_' .. time_string .. '.' .. ".png"

    if not love.filesystem.exists('screenshots')
      or not love.filesystem.isDirectory('screenshots') then
        love.filesystem.mkdir('screenshots')
    end

    screenshot:encode('screenshots/' .. filename,".png")
end
