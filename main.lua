lastN = -1
mySeed = 1
showPerlin = 0
mapWidth = 120
mapHeight = 120
current_level = 1

class = require "30log"
Astar = require "astar"
SoundManager = require 'sound_manager'
Settings = require 'settings'
require "TSerial"
require "map"
require "player"
require "states"
require "gui"
require "entities"

function love.load()
    love.graphics.setMode(1024, 576, false, true, 0)

    level_num = 3

    Settings.load()
    SoundManager.load()

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
    tile[0] = {}
    tile[0][1] = love.graphics.newImage("textures/dc-dngn/floor/rect_gray0.png")
    tile[0][2] = love.graphics.newImage("textures/dc-dngn/floor/rect_gray1.png")
    tile[0][3] = love.graphics.newImage("textures/dc-dngn/floor/rect_gray2.png")
    tile[0][4] = love.graphics.newImage("textures/dc-dngn/floor/rect_gray3.png")
    tile[2] = {}
    tile[2][1] = love.graphics.newImage("textures/dc-dngn/wall/stone_brick1.png")
    tile[2][2] = love.graphics.newImage("textures/dc-dngn/wall/stone_brick2.png")
    tile[2][3] = love.graphics.newImage("textures/dc-dngn/wall/stone_brick3.png")
    tile[2][4] = love.graphics.newImage("textures/dc-dngn/wall/stone_brick4.png")
    tile[2][5] = love.graphics.newImage("textures/dc-dngn/wall/stone_brick5.png")
    tile[2][6] = love.graphics.newImage("textures/dc-dngn/wall/stone_brick6.png")

    state = Menu.create()   -- current game state
    gameState = "world"
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

function take_screenshot()
    local screenshot = love.graphics.newScreenshot()

    local time_string = os.date('%Y-%m-%d_%H-%M-%S')
    local filename = 'warp_run_' .. time_string .. '.' .. ".png"

    if not love.filesystem.exists('screenshots')
      or not love.filesystem.isDirectory('screenshots') then
        love.filesystem.mkdir('screenshots')
    end

    screenshot:encode('screenshots/' .. filename,".png")
end