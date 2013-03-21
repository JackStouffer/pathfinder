monster = class{health, image}
item = class{image}

function monster:__init(health, image, level)
    self.gridx, self.gridy = getRandOpenTile(cave.map[level], mapWidth, mapHeight)
    self.x = (self.gridx * 32) - 32
    self.y = (self.gridy * 32) - 32
    self.path = nil
    self.health = health
    self.image = love.graphics.newImage(image)

    cave.collisionMap[current_level][(self.y / 32) + 1][(self.x / 32) + 1] = 2
end

function monster:draw()
    love.graphics.draw(self.image, self.x, self.y)
end

function monster:turn()
    --use a simple vector magnitude to find the distance between the player and the monster
    self.vector = {x = player.x - self.x, y = player.y - self.y}
    self.distance = (self.vector.x * self.vector.x) + (self.vector.y * self.vector.y)
    self.distance = math.sqrt(self.distance)
    
    if self.distance <= 400 then
        --chase
        cave.collisionMap[current_level][(self.y / 32) + 1][(self.x / 32) + 1] = 0
        Astar:setInitialNode((self.x / 32) + 1, (self.y / 32) + 1)
        Astar:setFinalNode((player.x / 32) + 1, (player.y / 32) + 1)
        self.path = Astar:getPath()
        if self.path ~= nil then
            self.x = (self.path[2].x * 32) - 32
            self.y = (self.path[2].y * 32) - 32
            cave.collisionMap[current_level][(self.y / 32) + 1][(self.x / 32) + 1] = 2
        end
        cave.collisionMap[current_level][(self.y / 32) + 1][(self.x / 32) + 1] = 2
    else
        --wander
    end
end

function item:__init(image, level)
    self.gridx, self.gridy = getRandOpenTile(cave.map[level], mapWidth, mapHeight)
    self.x = (self.gridx * 32) - 32
    self.y = (self.gridy * 32) - 32
    self.image = love.graphics.newImage(image)

    cave.collisionMap[current_level][(self.y / 32) + 1][(self.x / 32) + 1] = 3
end

function item:draw()
    love.graphics.draw(self.image, self.x, self.y)
end