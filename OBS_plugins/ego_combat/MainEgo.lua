-- Determine the script's own folder
local script_path = debug.getinfo(1, "S").source
if script_path:sub(1, 1) == "@" then
    script_path = script_path:sub(2)
end

-- Normalize and extract directory
local script_dir = script_path:match("^(.*[\\/])") or "./"
script_dir = script_dir:gsub("\\", "/")

-- Append source/ folder to package.path
package.path = script_dir .. "source/?.lua;" .. package.path

obs = obslua

local healthBar = require 'healthBar'
local egoCombat = require 'egoCombat'
local gameState = require 'gameStateHandler'

-- OBS main description
function script_description()
    return "Main entry for dual health bar combat system.\n"..
            "Loads healthBar module and sets up OBS hotkeys + UI."
end

-- OBS UI properties (passed by healthBar.lua)
function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "player1_source", "Player 1 Source", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "player2_source", "Player 2 Source", obs.OBS_TEXT_DEFAULT)
    return props
end

-- OBS UI update. (loop entry)
function script_update(settings)
    local p1_source = obs.obs_data_get_string(settings, 'player1_source')
    local p2_source = obs.obs_data_get_string(settings, 'player2_source')

    healthBar.setSourceName('player1', p1_source)
    healthBar.setSourceName('player2', p2_source)

    -- force visual refresh
    healthBar.setHealthBar('player1', 16)
    healthBar.setHealthBar('player2', 16)
end

-- OBS load (loop mark)
function script_load(settings)
    -- hook into game state handler
    gameState.onEnter('combat', function ()
        print("[DEBUG]<main> Entered Ego Combat.")
    end)
    -- initialize combat when script is loaded.
    egoCombat.start()
    egoCombat.bindHotkeys(settings)
end

-- OBS save (loop end)
function script_save(settings)
    egoCombat.saveHotkeys(settings)
end