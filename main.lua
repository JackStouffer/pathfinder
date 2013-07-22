--[[

    Copyright (c) 2013 Jack Stouffer

    This software is provided 'as-is', without any express or implied
    warranty. In no event will the authors be held liable for any damages
    arising from the use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

       1. The origin of this software must not be misrepresented; you must not
       claim that you wrote the original software. If you use this software
       in a product, an acknowledgment in the product documentation would be
       appreciated but is not required.

       2. Altered source versions must be plainly marked as such, and must not be
       misrepresented as being the original software.

       3. This notice may not be removed or altered from any source
       distribution.

    
    Legal attribution for the loveframes library goes to Kenny Shields
]]--

lastN = -1
mySeed = 1
showPerlin = 0
mapWidth = 120
mapHeight = 120
current_level = 1

Astar = require "astar"

SoundManager = require 'sound_manager'
Settings = require 'settings'
require "vendor/TSerial"

Settings.load()
SoundManager.load()

bresenham = require 'vendor/bresenham'
ROT = require 'vendor/rotLove/rot'
require "vendor.loveframes"

require "map"
require "cave"
require "system"
require "dungeon"
require "player"
require "states"
require "gui"
require "entities"
require "utilities"

function love.load()
    love.graphics.setMode(1024, 576, false, true, 0)
    love.graphics.setCaption("Pathfinder")

    level_num = 3

    love.keyboard.setKeyRepeat(0.01, 0.1)

    smallFont = love.graphics.newFont("textures/gui/visitor.ttf", 12)
    mediumFont = love.graphics.newFont("textures/gui/visitor.ttf", 32)
    largeFont = love.graphics.newFont("textures/gui/visitor.ttf", 64)

    --Music/Sound
    clickSound = love.audio.newSource("sounds/click1.wav")
    rolloverSound = love.audio.newSource("sounds/rollover1.wav")

    menuMusic = SoundManager.new_sound("music/AlaFlair", 512, 288, 6000, 100, true, true, true)
    caveMusic = SoundManager.new_sound("music/radakan-cave ambience", 512, 288, 6000, 100, true, true, true)

    tile = {}
    tile.cave = {}
    tile.dungeon = {}
    tile.dungeon[0] = {}
    tile.dungeon[0][1] = love.graphics.newImage("textures/dc-dngn/floor/rect_gray0.png")
    tile.dungeon[0][2] = love.graphics.newImage("textures/dc-dngn/floor/rect_gray1.png")
    tile.dungeon[0][3] = love.graphics.newImage("textures/dc-dngn/floor/rect_gray2.png")
    tile.dungeon[0][4] = love.graphics.newImage("textures/dc-dngn/floor/rect_gray3.png")
    tile.dungeon[2] = {}
    tile.dungeon[2][1] = love.graphics.newImage("textures/dc-dngn/wall/stone_brick1.png")
    tile.dungeon[2][2] = love.graphics.newImage("textures/dc-dngn/wall/stone_brick2.png")
    tile.dungeon[2][3] = love.graphics.newImage("textures/dc-dngn/wall/stone_brick3.png")
    tile.dungeon[2][4] = love.graphics.newImage("textures/dc-dngn/wall/stone_brick4.png")
    tile.dungeon[2][5] = love.graphics.newImage("textures/dc-dngn/wall/stone_brick5.png")
    tile.dungeon[2][6] = love.graphics.newImage("textures/dc-dngn/wall/stone_brick6.png")
    tile.cave[0] = {}
    tile.cave[0][1] = love.graphics.newImage("textures/dc-dngn/floor/grey_dirt0.png")
    tile.cave[0][2] = love.graphics.newImage("textures/dc-dngn/floor/grey_dirt1.png")
    tile.cave[0][3] = love.graphics.newImage("textures/dc-dngn/floor/grey_dirt2.png")
    tile.cave[0][4] = love.graphics.newImage("textures/dc-dngn/floor/grey_dirt3.png")
    tile.cave[2] = {}
    tile.cave[2][1] = love.graphics.newImage("textures/dc-dngn/wall/stone_dark0.png")
    tile.cave[2][2] = love.graphics.newImage("textures/dc-dngn/wall/stone_dark1.png")
    tile.cave[2][3] = love.graphics.newImage("textures/dc-dngn/wall/stone_dark2.png")
    tile.cave[2][4] = love.graphics.newImage("textures/dc-dngn/wall/stone_dark3.png")

    ladder_img_down = love.graphics.newImage("textures/dc-dngn/gateways/stone_stairs_down.png")
    ladder_img_up = love.graphics.newImage("textures/dc-dngn/gateways/stone_stairs_up.png")

    cursor_img = love.graphics.newImage("textures/dc-misc/cursor.png")

    state = Menu.create()   -- current game state
    game_state = "world"
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

function love.mousereleased(x, y, button)
    state:mousereleased(x, y, button)
end

function love.keypressed(key, unicode)
    if key == "f4" and (love.keyboard.isDown("ralt") or love.keyboard.isDown("lalt")) then
        love.event.push("quit")
    end
    
    state:keypressed(key)
end

function love.keyreleased(key)
    state:keyreleased(key)
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