ent = {}
ent.enimines = {}

-- the monster is a 30log class with default values
monster = class{ x = 100, y = 100, health = 100, image = "textures/dc-mon/acid_blob.png" }

function monster:__init(x, y, health, image)
    self.x = x
    self.y = y
    self.health = health
    self.image = love.graphics.newImage(image)
end

function monster:draw()
    love.graphics.draw(self.image, self.x, self.y)
end

function monster:update(dt)
    self.angle = math.atan2(player.y - self.y, player.x - self.x)
    -- <cos(x), sin(x)>
    self.x = self.x + math.cos(self.angle) * dt * 50
    self.y = self.y + math.sin(self.angle) * dt * 50
end

ent.enimines[0] = monster:new(100, 100, 100, "textures/dc-mon/acid_blob.png")