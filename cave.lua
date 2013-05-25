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

function minerCave(Width, Height)
    --cave generation based around "miners" that "grow" the cave from a starting point
    --this is superior to the previous cellular automaton method because it is not possible for this to produce closed areas
    --credit where credit is due: https://love2d.org/forums/viewtopic.php?f=5&t=7473

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

    --initialize the map as filled
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
                
                -- 8% chance of a new miner being spawned
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
        
        --reset the counter after every loop
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
    end

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
                Map[y][x] = 2
            end
        end
    end

    return Map
end