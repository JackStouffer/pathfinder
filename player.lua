playerClass = class{x, y, body, health, mana}

function playerClass:__init(x, y, body, health, mana)
    self.x = x
    self.y = y
    self.translate_x = 0
    self.translate_y = 0
    self.body = love.graphics.newImage(body)
    self.health = health
    self.max_health = health
    self.mana = mana
    self.max_mana = mana
    collisionMap[(self.y / 32) + 1][(self.x / 32) + 1] = 1
end

function playerClass:keypressed(key)
    if key == 'up' and testMapEdge(0, -32, mapWidth, mapHeight) == false then -- if the player pushes up and is not at the end of the world
        if testCollisionTile(0, -1) == false then --then check for collision, this is done this way so testCollisionTile won't try to index a value that doesn't exist
            collisionMap[(self.y / 32) + 1][(self.x / 32) + 1] = 0
            self.y = self.y - 32
            self.translate_y = self.translate_y + 32
            collisionMap[(self.y / 32) + 1][(self.x / 32) + 1] = 1
        end
        for x=1,#ent.enimines do
            ent.enimines[x]:turn()
        end
    end

    if key == 'down' and testMapEdge(0, 32, mapWidth, mapHeight) == false then
        if testCollisionTile(0, 1) == false then
            collisionMap[(self.y / 32) + 1][(self.x / 32) + 1] = 0
            self.y = self.y + 32
            self.translate_y = self.translate_y - 32
            collisionMap[(self.y / 32) + 1][(self.x / 32) + 1] = 1
        end
        for x=1,#ent.enimines do
            ent.enimines[x]:turn()
        end
    end
   
    if key == 'left' and testMapEdge(-32, 0, mapWidth, mapHeight) == false then
        if testCollisionTile(-1, 0) == false then
            collisionMap[(self.y / 32) + 1][(self.x / 32) + 1] = 0
            self.x = self.x - 32
            self.translate_x = self.translate_x + 32
            collisionMap[(self.y / 32) + 1][(self.x / 32) + 1] = 1
        end
        for x=1,#ent.enimines do
            ent.enimines[x]:turn()
        end
    end

    if key == 'right' and testMapEdge(32, 0, mapWidth, mapHeight) == false then
        if testCollisionTile(1, 0) == false then
            collisionMap[(self.y / 32) + 1][(self.x / 32) + 1] = 0
            self.x = self.x + 32
            self.translate_x = self.translate_x - 32
            collisionMap[(self.y / 32) + 1][(self.x / 32) + 1] = 1
        end
        for x=1,#ent.enimines do
            ent.enimines[x]:turn()
        end
    end
end

function playerClass:draw()
    love.graphics.draw(self.body, self.x, self.y)
end