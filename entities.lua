ent = {}
ent.enimines = {}
local moves = 0

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

function monster:turn()
    --using jumper to find the path with the jump point search algorithm
    local path, length = myPath:getPath(self.x/32, self.y/32, player.x/32, player.y/32)
    if path then
        moves = moves + 1
        print(moves)
        for node, count in path:iter() do
            if count == 2 then
                self.x = node.x * 32
                self.y = node.y * 32
            end
        end
    end
end

ent.enimines[0] = monster:new(160, 160, 100, "textures/dc-mon/acid_blob.png")