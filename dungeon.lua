function createDungeon(width, height)
    local Map = {}

    for y = 1, height do
        Map[y] = {}
        for x = 1, width do
            Map[y][x] = 0
        end
    end

    local rog = ROT.Map.Rogue(width, height)
    
    rog:create(function (x, y, val)
        if val == 1 then
            Map[y][x] = 2
        else
            Map[y][x] = 0
        end
    end)

    return Map
end