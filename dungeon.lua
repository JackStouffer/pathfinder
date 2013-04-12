function createDungeon(width, height)
    local Map = {}

    for y = 1, height do
        Map[y] = {}
        for x = 1, width do
            Map[y][x] = 2
        end
    end

    --How many rooms?
    local minimum_rooms = (width * height) / 300
    local maximum_rooms = (width * height) / 150
    local room_count = math.random(minimum_rooms, maximum_rooms)

    --Room sizes?
    local width_root = math.sqrt(width * 2)
    local height_root = math.sqrt(height * 2)
    local minimum_width = (width * 0.5) / width_root
    local maximum_width = (width * 2.0) / width_root
    local minimum_height = (height * 0.5) / height_root
    local maximum_height = (height * 2.0) / height_root

    --Create rooms
    local roomList = {}

    for i = 0, room_count do
        local ok = false
        --This while loop runs until we find somewhere the room fits
        --There are faster ways of doing this but for the map sizes I'm
        --using, it serves my needs and is fast enough.
        while ok == false do
            local room = {}
            room.x = math.random(0, width)
            room.y = math.random(0, height)
            room.w = math.random(minimum_width, maximum_width)
            room.h = math.random(minimum_height, maximum_height)

            if room.x < 0 or
            room.x >= width or
            room.x + room.w >= width or
            room.y <= 0 or
            room.y >= height or
            room.y + room.h >= height then
                ok = false
            else
                --If we reach this point, the room can be placed
                ok = true
                table.insert(roomList, room)
            end

            -- if (room overlaps with other room)
            --     continue
        end
    end

    --Connect Rooms
    local connectionCount = room_count
    local connectedCells = {}
    for i = 1, connectionCount do
        local roomA = roomList[i]
        local roomB = roomList[math.random(1, #roomList)]

        --Increasing this number will make hallways straighter
        --Decreasing this number will make halways skewer
        local sidestepChance = 10
        local pointA = {}
        pointA.x = math.random(roomA.x, roomA.x + roomA.w)
        pointA.y = math.random(roomA.y, roomA.y + roomA.h)
        local pointB = {}
        pointB.x = math.random(roomB.x, roomB.x + roomB.w)
        pointB.y = math.random(roomB.y, roomB.y + roomB.h)

        --This is a type of drunken/lazy walk algorithm    
        while pointB.x ~= pointA.x and pointB.y ~= pointA.y do
            local num = math.random(0, 100)
            if num < sidestepChance then
                if pointB.x ~= pointA.x then
                    if pointB.x > pointA.x then
                        pointB.x = pointB.x - 1
                    else
                        pointB.x = pointB.x + 1
                    end
                    table.insert(connectedCells, {x = pointB.x, y = pointB.y})
                end
            else
                if pointB.y ~= pointA.y then
                    if pointB.y > pointA.y then
                        pointB.y = pointB.y - 1
                    else
                        pointB.y = pointB.y + 1
                    end
                    table.insert(connectedCells, {x = pointB.x, y = pointB.y})
                end
            end
        end
    end

    --Create Map Data
    for i = 1, #roomList do
        for y = roomList[i].y, roomList[i].y + roomList[i].h do
            for x = roomList[i].x, roomList[i].x + roomList[i].w do
                Map[y][x] = 0
            end
        end
    end

    for i = 1, #connectedCells do
        Map[connectedCells[i].y][connectedCells[i].x] = 0
    end

    return Map
end