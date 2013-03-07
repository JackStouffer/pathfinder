lastN = -1
mySeed = 1
showPerlin = 0
mapWidth = 120
mapHeight = 120

class = require "30log"
Astar = require "astar"
require "TSerial"
require "states"
require "button"
require "map"
require "entities"

function love.load()
    love.graphics.setMode(1024, 576, false, true, 0)

    state = Menu.create()   -- current game state
    gameState = "world"

    love.keyboard.setKeyRepeat(0.01, 0.1)

    smallFont = love.graphics.newFont("textures/gui/8-BIT-WONDER.TTF", 12)
    mediumFont = love.graphics.newFont("textures/gui/8-BIT-WONDER.TTF", 32)
    largeFont = love.graphics.newFont("textures/gui/8-BIT-WONDER.TTF", 64)

    player = {
        x = 512,
        y = 288,
        translate_x = 0,
        translate_y = 0,
        body = love.graphics.newImage("textures/player/base/human_m.png"),
        health = 100,
        magic = 100
    }
    
    tile = {}
    for i=0,3 do -- change 3 to the number of tile images minus 1.
       tile[i] = love.graphics.newImage( "textures/tile"..i..".png" )
    end

    guiBar = love.graphics.newImage("textures/gui/bar.png")
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
