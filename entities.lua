monster = class{health, image, level, map}
item = class{image, level, map}

function monster:__init(health, image, level, map, image_map)
    self.level = level
    self.map = map
    self.image_map = image_map
    self.startx, self.starty = getRandOpenTile(self.map, mapWidth, mapHeight)
    self.gridx = self.startx - 1
    self.gridy = self.starty - 1
    self.x = (self.startx * 32) - 32
    self.y = (self.starty * 32) - 32
    self.path = nil
    self.health = health
    self.image = love.graphics.newImage(image)

    self.map[(self.y / 32) + 1][(self.x / 32) + 1] = 2
end

function monster:draw()
    --fog of war check
    if self.image_map[self.gridy][self.gridx].visibility == true then
        love.graphics.draw(self.image, self.x, self.y)
    end
end

function monster:turn()
    --use a simple vector magnitude to find the distance between the player and the monster
    self.vector = {x = player.x - self.x, y = player.y - self.y}
    self.distance = (self.vector.x * self.vector.x) + (self.vector.y * self.vector.y)
    self.distance = math.sqrt(self.distance)
    
    if self.distance <= 400 then
        --chase
        self.map[(self.y / 32) + 1][(self.x / 32) + 1] = 0
        
        Astar:setInitialNode((self.x / 32) + 1, (self.y / 32) + 1)
        Astar:setFinalNode((player.x / 32) + 1, (player.y / 32) + 1)
        self.path = Astar:getPath()
        
        if self.path ~= nil then
            self.x = (self.path[2].x * 32) - 32
            self.y = (self.path[2].y * 32) - 32
            self.gridx = (self.x / 32) + 1
            self.gridy = (self.y / 32) + 1
            self.map[(self.y / 32) + 1][(self.x / 32) + 1] = 2
        end
        
        self.map[(self.y / 32) + 1][(self.x / 32) + 1] = 2
    else
        --wander
    end
end

function item:__init(image, level, map, image_map)
    self.level = level
    self.map = map
    self.image_map = image_map
    self.startx, self.starty = getRandOpenTile(self.map, mapWidth, mapHeight)
    self.x = (self.startx * 32) - 32
    self.y = (self.starty * 32) - 32
    self.gridx = self.startx
    self.gridy = self.starty
    self.image = love.graphics.newImage(image)

    self.map[(self.y / 32) + 1][(self.x / 32) + 1] = 3
end

function item:draw()
    if self.image_map[self.gridy][self.gridx].visibility == true then
        love.graphics.draw(self.image, self.x, self.y)
    end
end