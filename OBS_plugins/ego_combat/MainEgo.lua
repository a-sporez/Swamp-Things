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
local auraMeter = require 'auraMeter'

-- OBS main description
function script_description()
    return "Main entry for dual health bar combat system.\n"..
            "Loads healthBar module and sets up OBS hotkeys + UI."
end

-- OBS UI properties (passed by healthBar.lua)
function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_text(props, "player1_health_source", "Player 1 Health Source", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "player1_aura_source", "Player 1 Aura Source", obs.OBS_TEXT_DEFAULT)

    obs.obs_properties_add_text(props, "player2_health_source", "Player 2 Health Source", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "player2_aura_source", "Player 2 Aura Source", obs.OBS_TEXT_DEFAULT)

    return props
end

-- OBS UI update. (loop entry)
function script_update(settings)
    local p1_health = obs.obs_data_get_string(settings, 'player1_health_source')
    local p1_aura   = obs.obs_data_get_string(settings, 'player1_aura_source')
    local p2_health = obs.obs_data_get_string(settings, 'player2_health_source')
    local p2_aura   = obs.obs_data_get_string(settings, 'player2_aura_source')

    egoCombat.setPlayerSources(p1_health, p1_aura, p2_health, p2_aura)

    -- force visual refresh
    local PlayerReg = require("playerRegistry") -- lazy-load to avoid top-level circular deps
    local p1 = PlayerReg.get('player1')
    local p2 = PlayerReg.get('player2')

    if p1 then
        healthBar.setHealthBar('player1', p1.hp)
        auraMeter.setAuraMeter('player1', p1.ap)
    end

    if p2 then
        healthBar.setHealthBar('player2', p2.hp)
        auraMeter.setAuraMeter('player2', p2.ap)
    end

    if p1_health == "" or p1_aura == "" or p2_health == "" or p2_aura == "" then
        print("[WARN]<MainEgo> One or more OBS sources are unset. Check script UI settings.")
    end
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

-- set default values.
function script_defaults(settings)
    obs.obs_data_set_default_string(settings, 'player1_health_source', 'Player1Health')
    obs.obs_data_set_default_string(settings, 'player1_aura_source', 'Player1Aura')

    obs.obs_data_set_default_string(settings, 'player2_health_source', 'Player2Health')
    obs.obs_data_set_default_string(settings, 'player2_aura_source', 'Player2Aura')
end