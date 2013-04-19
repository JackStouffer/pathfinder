--
-- Copyright 2012 Aaron MacDonald
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
-- implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

local SoundManager = {}

local MAX_DISTANCE = 1024

local static_sound_data

local current_sounds
local sound_pool = {}

local listener_pos = {}

----------------------------------------------------------------------

local function load()
    static_sound_data = {}
    current_sounds = {}
    sound_pool = {}

    listener_pos.x = 0
    listener_pos.y = 0
end
SoundManager.load = load

local function set_listener(x, y)
    listener_pos.x = x
    listener_pos.y = y
end
SoundManager.set_listener = set_listener

local function reset_listener()
    listener_pos.x = 0
    listener_pos.y = 0
end
SoundManager.reset_listener = reset_listener

-- unclearable = Not affected by SoundManager.clear.  Source has to
--               finish playing on its own.
-- persist = Not removed even if stopped, unless SoundManager.clear is
--           used.
local function new_sound(file_name, x, y, max_hearing_dist, loops, unclearable, start_stopped, persist)
    local new_sound = {file_name = file_name}
    local volume = 1

    if x then
        assert(y)
        new_sound.pos = {}
        new_sound.pos.x = 0
        new_sound.pos.y = 0

        local max_dist = MAX_DISTANCE
        if max_hearing_dist then
            max_dist = max_hearing_dist
        end
        new_sound.max_dist = max_dist

        local vector = {x = listener_pos.x - x, y = listener_pos.y - y}
        local distance = (vector.x * vector.x) + (vector.y * vector.y)
        distance = math.sqrt(distance)

        volume = math.max(0, 1 - (distance / max_dist))
    end

    if sound_pool[file_name] and (#sound_pool[file_name] > 0) then
        new_sound.source = table.remove(sound_pool[file_name])
    else
        if not static_sound_data[file_name] then
            local file_path = "sounds"
              .. '/' .. file_name
              .. '.' .. "ogg"
            static_sound_data[file_name]
              = love.sound.newSoundData(file_path)
        end
        new_sound.source
          = love.audio.newSource(static_sound_data[file_name])
    end

    new_sound.source:setVolume(volume * Settings.get('volume'))
    new_sound.source:setLooping(loops)

    if not start_stopped then
        new_sound.source:play()
    else
        assert(persist)
    end

    new_sound.unclearable = unclearable
    new_sound.persist = persist

    table.insert(current_sounds, new_sound)

    return new_sound
end
SoundManager.new_sound = new_sound

local function clear(completely)
    for _, s in ipairs(current_sounds) do
        if completely or not s.unclearable then
            s.source:stop()
            if not sound_pool[s.file_name] then
                sound_pool[s.file_name] = {}
            end
            table.insert(sound_pool[s.file_name], s.source)
        end
    end
    current_sounds = {}
    if completely then
        -- Scorched earth policy
        static_sound_data = {}
        sound_pool = {}
    end
end
SoundManager.clear = clear

local function pause_current()
    for _, s in ipairs(current_sounds) do
        s.source:pause()
    end
end
SoundManager.pause_current = pause_current

local function resume()
    for _, s in ipairs(current_sounds) do
        s.source:resume()
    end
end
SoundManager.resume = resume

local function update()
    local i = 1
    while i <= #current_sounds do
        local s = current_sounds[i]

        if s.source:isStopped() and not s.persist then
            if not sound_pool[s.file_name] then
                sound_pool[s.file_name] = {}
            end
            table.insert(sound_pool[s.file_name], s.source)

            table.remove(current_sounds, i)
        else
            if s.pos then
                local max_dist = MAX_DISTANCE
                if s.max_dist then
                    max_dist = s.max_dist
                end

                local vector = {x = listener_pos.x - s.pos.x, y = listener_pos.y - s.pos.y}
                local distance = (vector.x * vector.x) + (vector.y * vector.y)
                distance = math.sqrt(distance)
                local volume = math.max(0, 1 - (distance / max_dist))
                s.source:setVolume(volume * Settings.get('volume'))
            end

            i = i + 1
        end
    end
end
SoundManager.update = update

----------------------------------------------------------------------

return SoundManager