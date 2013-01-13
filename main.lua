--[[

This code is property of Jack Stouffer. Any use of this code without the
express permission of Jack Stouffer will suffer the consequences of the
law.

--]]

require "states"
require "button"
require "map"

function love.load()
    love.graphics.setMode(720, 480, false, true, 0)

    state = Menu.create()   -- current game state

    love.keyboard.setKeyRepeat(0.01, 0.1)

    player = {
        x = 352,
        y = 240,
        grid_x = 352,
        grid_y = 240,
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

