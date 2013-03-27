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

local Settings = {}

----------------------------------------------------------------------

local FILE = 'settings.txt'

local DEFAULTS = {}
DEFAULTS.volume = 1
DEFAULTS.key_north = 'w'
DEFAULTS.key_east = 'd'
DEFAULTS.key_south = 's'
DEFAULTS.key_west = 'a'

Settings.DEFAULTS = DEFAULTS

local KEY_CONTROLS = {
    'key_north',
    'key_east',
    'key_south',
    'key_west'
}
Settings.KEY_CONTROLS = KEY_CONTROLS

local current_settings = {}

----------------------------------------------------------------------

local function load()
    local write_defaults = not love.filesystem.exists(FILE)
        or not love.filesystem.isFile(FILE)

    local file = love.filesystem.newFile(FILE)

    if write_defaults then
        file:open('w')
        file:write( TSerial.pack(DEFAULTS) )
        file:close()
    end

    file:open('r')
    current_settings = TSerial.unpack( file:read() )
    file:close()

    for k, _ in pairs(DEFAULTS) do
        assert(current_settings[k] ~= nil)
    end
end
Settings.load = load

local function save()
    assert(love.filesystem.exists(FILE))
    assert(love.filesystem.isFile(FILE))

    file = love.filesystem.newFile(FILE)
    file:open('w')
    file:write( TSerial.pack(current_settings) )
    file:close()
end

----------------------------------------------------------------------

local function get(key)
    assert(current_settings[key] ~= nil, 'Invalid setting: ' .. key)
    return current_settings[key]
end
Settings.get = get

-- For printing keyboard controls
local function get_key_control_name(key)
    assert(current_settings[key] ~= nil, 'Invalid setting: ' .. key)
    assert(string.find(key, 'key_'), 'Not a key control: ' .. key)

    local result = current_settings[key]
    if result == ' ' then
        result = 'space'
    end

    return result
end
Settings.get_key_control_name = get_key_control_name

local function set(key, value)
    assert(current_settings[key] ~= nil, 'Invalid setting: ' .. key)
    assert(value ~= nil)
    current_settings[key] = value
    save()
end
Settings.set = set

local function is_mute()
    local volume = get('volume')
    if volume == 0 then return true else return false end
end
Settings.is_mute = is_mute

----------------------------------------------------------------------

return Settings