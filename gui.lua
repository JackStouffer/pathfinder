function drawGUI(system)
    -- gui background
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.rectangle("fill", 0, 490, 1024, 100)

    -- health bar
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle("fill", 20, 510, 165 * (player.health / player.max_health), 15)

    -- health indicator
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(player.health .. "/" .. player.max_health, 85, 512)

    -- mana bar
    love.graphics.setColor(0, 0, 255)
    love.graphics.rectangle("fill", 20, 540, 165 * (player.mana / player.max_mana), 15)

    -- mana indicator
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(player.mana .. "/" .. player.max_mana, 85, 542)
    
    -- turn state indicator label
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(smallFont)
    love.graphics.print("Turn State:", 200, 510)

    -- turn state indicator
    if current_player == 0 then
        if turn_state == 0 then
            love.graphics.print("Movement", 280, 510)
        elseif turn_state == 1 then
            love.graphics.print("Attack", 280, 510)
        elseif turn_state == 3 then
            love.graphics.print("End", 280, 510)
        end
    else
        love.graphics.print("Enemy Turn", 280, 510)
    end

    love.graphics.print("Current Level:   " .. current_level .. "/3", 200, 530)

    if system.map[current_level].clear == true then
        love.graphics.print("Level Clear", 200, 545)
    end

    love.graphics.setColor(255, 255, 255, 255)
end

--[[

    Menu

]]--

menu_new = loveframes.Create("button")
menu_new:SetSize(250, 50)
menu_new:SetPos(390, 240)
menu_new:SetText("New Game")
menu_new:SetState("menu")
menu_new.OnClick = function(object)
    love.audio.play(clickSound)
    createWorld()
    state = Game.create()
end
menu_new.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
menu_new.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end

menu_instructions = loveframes.Create("button")
menu_instructions:SetSize(250, 50)
menu_instructions:SetPos(390, 300)
menu_instructions:SetText("Instructions")
menu_instructions:SetState("menu")
menu_instructions.OnClick = function(object)
    love.audio.play(clickSound)
    state = Instructions.create(false)
end
menu_instructions.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
menu_instructions.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end

menu_options = loveframes.Create("button")
menu_options:SetSize(250, 50)
menu_options:SetPos(390, 360)
menu_options:SetText("Options")
menu_options:SetState("menu")
menu_options.OnClick = function(object)
    love.audio.play(clickSound)
    state = Options.create(false)
end
menu_options.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
menu_options.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end

menu_quit = loveframes.Create("button")
menu_quit:SetSize(250, 50)
menu_quit:SetPos(390, 420)
menu_quit:SetText("Quit")
menu_quit:SetState("menu")
menu_quit.OnClick = function(object)
    love.audio.play(clickSound)
    love.event.quit()
end
menu_quit.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
menu_quit.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end

--[[

    Instructions

]]--

instructions_frame = loveframes.Create("frame")
instructions_frame:SetSize(1024, 576)
instructions_frame:SetPos(0, 0)
instructions_frame:SetName("Instructions")
instructions_frame:SetState("instructions")
instructions_frame:SetDraggable(false)
instructions_frame:ShowCloseButton(false)

instructions_panel = loveframes.Create("panel")
instructions_panel:SetHeight(280)

instructions_intro_text = loveframes.Create("text", instructions_panel)
instructions_intro_text:SetPos(5, 5)
instructions_intro_text:SetMaxWidth(580)
instructions_intro_text:SetText("Pathfinder is a mix between a rougelike and chess. At the start of the game, a randomized world will be generated with a overworld map and several locations in the world, represented by small icons. Click in on each of these icons will put you into that location. There are three types of locations (from easiest to hardest): caves, dungeons, and mazes.  \n \n The game is split into turns with one action per turn, e.g. attacking or drinking a potion, while your range of movement is dictated by your MP, or movement points. Click the mouse to select where to move and 'g' picks items up or activates things under you.")

instructions_collapse = loveframes.Create("collapsiblecategory", instructions_frame)
instructions_collapse:SetPos(230, 30)
instructions_collapse:SetSize(600, 300)
instructions_collapse:SetText("Introduction")
instructions_collapse:SetObject(instructions_panel)

instructions_back = loveframes.Create("button", instructions_frame)
instructions_back:SetSize(400, 40)
instructions_back:SetPos(300, 520)
instructions_back:SetText("Back")
instructions_back.OnClick = function(object)
    love.audio.play(clickSound)
    state = Menu.create()
end
instructions_back.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
instructions_back.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end

--[[

    Instructions (Pause)

]]--

instructions_frame_pause = loveframes.Create("frame")
instructions_frame_pause:SetSize(1024, 576)
instructions_frame_pause:SetPos(0, 0)
instructions_frame_pause:SetName("Instructions")
instructions_frame_pause:SetState("instructions_pause")
instructions_frame_pause:SetDraggable(false)
instructions_frame_pause:ShowCloseButton(false)

instructions_panel_pause = loveframes.Create("panel")
instructions_panel_pause:SetHeight(280)

instructions_intro_text_pause = loveframes.Create("text", instructions_panel_pause)
instructions_intro_text_pause:SetPos(5, 5)
instructions_intro_text_pause:SetMaxWidth(580)
instructions_intro_text_pause:SetText("Pathfinder is a mix between a rougelike and chess. At the start of the game, a randomized world will be generated with a overworld map and several locations in the world, represented by small icons. Click in on each of these icons will put you into that location. There are three types of locations (from easiest to hardest): caves, dungeons, and mazes.  \n \n The game is split into turns with one action per turn, e.g. attacking or drinking a potion, while your range of movement is dictated by your MP, or movement points. Click the mouse to select where to move and 'g' picks items up or activates things under you.")

instructions_collapse_pause = loveframes.Create("collapsiblecategory", instructions_frame_pause)
instructions_collapse_pause:SetPos(230, 30)
instructions_collapse_pause:SetSize(600, 300)
instructions_collapse_pause:SetText("Introduction")
instructions_collapse_pause:SetObject(instructions_panel)

instructions_back_pause = loveframes.Create("button", instructions_frame_pause)
instructions_back_pause:SetSize(400, 40)
instructions_back_pause:SetPos(300, 520)
instructions_back_pause:SetText("Back")
instructions_back_pause.OnClick = function(object)
    love.audio.play(clickSound)
    state = Pause.create()
end
instructions_back_pause.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
instructions_back_pause.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end

--[[

    Options

]]--

options_frame = loveframes.Create("frame")
options_frame:SetSize(1024, 576)
options_frame:SetPos(0, 0)
options_frame:SetName("Options")
options_frame:SetState("options")
options_frame:SetDraggable(false)
options_frame:ShowCloseButton(false)

options_audio_text = loveframes.Create("text", options_frame)
options_audio_text:SetPos(420, 35)
options_audio_text:SetText("Audio:")

options_warning_text = loveframes.Create("text", options_frame)
options_warning_text:SetPos(320, 400)
options_warning_text:SetText("Most changes made here require a restart to take effect.")

options_audio_slider = loveframes.Create("slider", options_frame)
options_audio_slider:SetPos(500, 30)
options_audio_slider:SetMinMax(0, 100)
options_audio_slider:SetWidth(300)
options_audio_slider:SetValue(Settings.get("volume") * 100)
options_audio_slider.OnRelease = function(object, checked)
    local volume = math.floor(options_audio_slider:GetValue()) / 100
    Settings.set("volume", volume)
end

options_back = loveframes.Create("button", options_frame)
options_back:SetSize(400, 40)
options_back:SetPos(300, 520)
options_back:SetText("Back")
options_back.OnClick = function(object)
    love.audio.play(clickSound)
    state = Menu.create()
end
options_back.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
options_back.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end

--[[

    Options (Pause)

]]--

options_frame_pause = loveframes.Create("frame")
options_frame_pause:SetSize(1024, 576)
options_frame_pause:SetPos(0, 0)
options_frame_pause:SetName("Options")
options_frame_pause:SetState("options_pause")
options_frame_pause:SetDraggable(false)
options_frame_pause:ShowCloseButton(false)

options_audio_text_pause = loveframes.Create("text", options_frame_pause)
options_audio_text_pause:SetPos(420, 35)
options_audio_text_pause:SetText("Audio:")

options_warning_text_pause = loveframes.Create("text", options_frame_pause)
options_warning_text_pause:SetPos(320, 400)
options_warning_text_pause:SetText("Most changes made here require a restart to take effect.")

options_audio_slider_pause = loveframes.Create("slider", options_frame_pause)
options_audio_slider_pause:SetPos(500, 30)
options_audio_slider_pause:SetMinMax(0, 100)
options_audio_slider_pause:SetWidth(300)
options_audio_slider_pause:SetValue(Settings.get("volume") * 100)
options_audio_slider_pause.OnRelease = function(object, checked)
    local volume = math.floor(options_audio_slider:GetValue()) / 100
    Settings.set("volume", volume)
end

options_back_pause = loveframes.Create("button", options_frame_pause)
options_back_pause:SetSize(400, 40)
options_back_pause:SetPos(300, 520)
options_back_pause:SetText("Back")
options_back_pause.OnClick = function(object)
    love.audio.play(clickSound)
    state = Pause.create()
end
options_back_pause.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
options_back_pause.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end

--[[

    Game GUI

]]--

game_turn = loveframes.Create("button")
game_turn:SetSize(100, 40)
game_turn:SetPos(800, 510)
game_turn:SetText("Turn")
game_turn:SetState("game")
game_turn.OnClick = function(object)
    love.audio.play(clickSound)
    if current_player == 0 then
        turn_state = 3
    end
end
game_turn.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
game_turn.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end

--[[

    Pause Screen

]]--

pause_new = loveframes.Create("button")
pause_new:SetSize(250, 50)
pause_new:SetPos(390, 240)
pause_new:SetText("Resume Game")
pause_new:SetState("pause")
pause_new.OnClick = function(object)
    love.audio.play(clickSound)
    state = Game.create()
end
pause_new.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
pause_new.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end

pause_instructions = loveframes.Create("button")
pause_instructions:SetSize(250, 50)
pause_instructions:SetPos(390, 300)
pause_instructions:SetText("Instructions")
pause_instructions:SetState("pause")
pause_instructions.OnClick = function(object)
    love.audio.play(clickSound)
    state = Instructions.create(true)
end
pause_instructions.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
pause_instructions.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end

pause_options = loveframes.Create("button")
pause_options:SetSize(250, 50)
pause_options:SetPos(390, 360)
pause_options:SetText("Options")
pause_options:SetState("pause")
pause_options.OnClick = function(object)
    love.audio.play(clickSound)
    state = Options.create(true)
end
pause_options.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
pause_options.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end

pause_quit = loveframes.Create("button")
pause_quit:SetSize(250, 50)
pause_quit:SetPos(390, 420)
pause_quit:SetText("Main Menu")
pause_quit:SetState("pause")
pause_quit.OnClick = function(object)
    love.audio.play(clickSound)
    state = Menu.create()
end
pause_quit.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
pause_quit.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end

--[[

    Death Screen

]]--

death_menu = loveframes.Create("button")
death_menu:SetSize(250, 50)
death_menu:SetPos(390, 300)
death_menu:SetText("Main Menu")
death_menu:SetState("death")
death_menu.OnClick = function(object)
    love.audio.play(clickSound)
    state = Menu.create()
end
death_menu.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
death_menu.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end

death_quit = loveframes.Create("button")
death_quit:SetSize(250, 50)
death_quit:SetPos(390, 360)
death_quit:SetText("Quit")
death_quit:SetState("death")
death_quit.OnClick = function(object)
    love.audio.play(clickSound)
    love.event.quit()
end
death_quit.OnMouseEnter = function(object)
    love.audio.play(rolloverSound)
end
death_quit.OnMouseExit = function(object2)
    love.audio.stop(rolloverSound)
end