ent = {}
ent.enimines = {}

-- the monster is a 30log class with default values
monster = class{ x = 100, y = 100, health = 100, image = "textures/dc-mon/acid_blob.png" }

function monster:__init(x, y, health, image)
    self.x = x
    self.y = y
    self.path = nil
    self.health = health
    self.image = love.graphics.newImage(image)

    collisionMap[(self.y / 32) + 1][(self.x / 32) + 1] = 2
end

function monster:draw()
    love.graphics.draw(self.image, self.x, self.y)
end

function monster:turn()
    self.vector = {x = player.x - self.x, y = player.y - self.y}
    self.distance = (self.vector.x * self.vector.x) + (self.vector.y * self.vector.y)
    self.distance = math.sqrt(self.distance)
    if self.distance <= 400 then
        collisionMap[(self.y / 32) + 1][(self.x / 32) + 1] = 0
        Astar:setInitialNode((self.x / 32) + 1, (self.y / 32) + 1)
        Astar:setFinalNode((player.x / 32) + 1, (player.y / 32) + 1)
        self.path = Astar:getPath()
        self.x = (self.path[2].x * 32) - 32
        self.y = (self.path[2].y * 32) - 32
        collisionMap[(self.y / 32) + 1][(self.x / 32) + 1] = 2
    end
end