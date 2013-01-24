Jumper = require('Jumper')
require "pickle"
require "states"
require "button"
require "map"

function love.load()
    water = 0
    grass = 1
    dirt = 3

    lastN = -1
    mySeed = 1
    showPerlin = 0
  
    terrain = makeTerrain()

    love.graphics.setMode(736, 480, false, true, 0)

    state = Menu.create()   -- current game state
    gameState = "world"

    love.keyboard.setKeyRepeat(0.01, 0.1)

    smallFont = love.graphics.newFont(12)
    mediumFont = love.graphics.newFont(32)

    player = {
        x = 384,
        y = 256,
        translate_x = 0,
        translate_y = 0,
        body = love.graphics.newImage("textures/player/base/human_m.png"),
        health = 100
    }
        
    tile = {}
    for i=0,3 do -- change 3 to the number of tile images minus 1.
       tile[i] = love.graphics.newImage( "textures/tile"..i..".png" )
    end
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

