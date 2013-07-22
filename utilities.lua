function turnManager(system)
    --credit for the pseudo code for this goes to spacecoote on reddit
    
    if turn_state == 0 then -- entity is in the moving stage of the turn.    
        if current_player ~= 0 then
            system.enemies[current_level][current_player]:turn()
        end
    elseif turn_state == 1 then -- entity is in the attack stage of the turn.    
        if current_player ~= 0 then
            system.enemies[current_level][current_player]:turn()
        end
    elseif turn_state == 2 then --entity is in the final stage of the turn.    
        --do stuff
    elseif turn_state == 3 then --entity has ended their turn.    
        --do end-of-turn stuff
        current_player = current_player + 1
        if current_player > #system.enemies[current_level] then       
            current_player = 0
        end
        turn_state = 0
    end
end

function createWorld()
    cave = levelSystem(level_num, "normal", "cave")
    print("cave")

    dungeon = levelSystem(level_num, "hard", "dungeon")
    print("dungeon")
    
    player = playerClass:new(cave, dungeon, "textures/player/base/human_m.png", 100, 100)

    current_player = 0
    turn_state = 0

    terrain = makeTerrain()
end

function mouseToMapCoords(system, x, y)
    --Screen to tiles coordinates
    --credit for the original function goes to Yonaba on github

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
    -- find a open tile randomly on the map
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

function getAdjacentTiles(position)
    -- code adapted from Warp Run
    -- returns table of coords of all adjacent tiles
    local result = {}
    local tile
    local dirs = {
        north     = {x = 0, y = -32},
        northeast = {x = 32, y = -32},
        east      = {x = 32, y = 0},
        southeast = {x = 32, y = 32},
        south     = {x = 0, y = 32},
        southwest = {x = -32, y = 32},
        west      = {x = -32, y = 0},
        northwest = {x = -32, y = -32}
    }

    for _, delta in pairs(dirs) do
        tile = {}
        tile.x = position.x + delta.x
        tile.y = position.y + delta.y
        table.insert(result, tile)
    end

    return result
end

function table.containsTable(table, element)
    --adapted from Wookai on stackoverflow
    for _, value in pairs(table) do
        if compareTables(value, element) == true then
            return true
        end
    end
    return false
end

function compareTables(t1, t2)
    if #t1 ~= #t2 then return false end
    
    for k,v in pairs(t1) do
        if t1[k] ~= t2[k] then return false end
    end
    
    return true
end

function crash()
    --this function is for examining the console output by crashing the game because
    --I need to examine print statements that are happening every frame and I need a way to stop the
    --game without closing the console window

    error("crash")
end

function take_screenshot()
    --this function is from Warp Run
    local screenshot = love.graphics.newScreenshot()

    local time_string = os.date('%Y-%m-%d_%H-%M-%S')
    local filename = 'pathfinder_' .. time_string .. '.' .. ".png"

    if not love.filesystem.exists('screenshots')
      or not love.filesystem.isDirectory('screenshots') then
        love.filesystem.mkdir('screenshots')
    end

    screenshot:encode('screenshots/' .. filename,".png")
end
