lastN = -1
mySeed = 1
showPerlin = 0
mapWidth = 120
mapHeight = 120

class = require "30log"
Astar = require "astar"
require "TSerial"
require "map"
require "player"
require "states"
require "gui"
require "entities"

function love.load()
    love.graphics.setMode(1024, 576, false, true, 0)

    state = Menu.create()   -- current game state
    gameState = "world"

    love.keyboard.setKeyRepeat(0.01, 0.1)

    smallFont = love.graphics.newFont("textures/gui/visitor.ttf", 12)
    mediumFont = love.graphics.newFont("textures/gui/visitor.ttf", 32)
    largeFont = love.graphics.newFont("textures/gui/visitor.ttf", 64)

    tile = {}
    tile[0] = love.graphics.newImage("textures/dc-dngn/floor/rect_gray2.png")
    tile[2] = love.graphics.newImage("textures/dc-dngn/wall/stone_brick4.png")
end

function love.draw()
    state:draw()
end

function love.update(dt)
    state:update(dt)
end

function love.mousepressed(x, y, button)
    state:mousepressed(x,y,button)
end

function love.keypressed(key, unicode)
    if key == "f4" and (love.keyboard.isDown("ralt") or love.keyboard.isDown("lalt")) then
        love.event.push("quit")
    end
    
    state:keypressed(key)
end

function love.focus(f)
    if not f then
        print("LOST FOCUS")
    else
        print("GAINED FOCUS")
    end
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end
