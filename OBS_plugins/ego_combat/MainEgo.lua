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
local auraMeter = require 'auraMeter'
local psyMeter  = require 'psyMeter'
local gutMeter  = require 'gutMeter'
local egoCombat = require 'egoCombat'
local gameState = require 'gameStateHandler'
local playerReg = require 'playerRegistry'

-- OBS main description
function script_description()
    return "Main entry for dual health bar combat system.\n"..
            "Loads status updates, state machine and sets up OBS hotkeys + source tracking."
end

-- OBS UI properties (passed by healthBar.lua)
function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_text(props, "player1_health_source", "Player 1 Health Source", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "player1_aura_source", "Player 1 Aura Source", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "player1_psy_source", "Player 1 Psy Source", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "player1_gut_source", "Player 1 Gut Source", obs.OBS_TEXT_DEFAULT)

    obs.obs_properties_add_text(props, "player2_health_source", "Player 2 Health Source", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "player2_aura_source", "Player 2 Aura Source", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "player2_psy_source", "Player 2 Psy Source", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "player2_gut_source", "Player 2 Gut Source", obs.OBS_TEXT_DEFAULT)

    return props
end

-- OBS UI update. (loop entry)
function script_update(settings)
    local p1_health = obs.obs_data_get_string(settings, 'player1_health_source')
    local p1_aura   = obs.obs_data_get_string(settings, 'player1_aura_source')
    local p1_psy   = obs.obs_data_get_string(settings, 'player1_psy_source')
    local p1_gut   = obs.obs_data_get_string(settings, 'player1_gut_source')

    local p2_health = obs.obs_data_get_string(settings, 'player2_health_source')
    local p2_aura   = obs.obs_data_get_string(settings, 'player2_aura_source')
    local p2_psy   = obs.obs_data_get_string(settings, 'player2_psy_source')
    local p2_gut   = obs.obs_data_get_string(settings, 'player2_gut_source')

    egoCombat.setPlayerSources(p1_health, p1_aura, p1_psy, p1_gut, p2_health, p2_aura, p2_psy, p2_gut)

    -- force visual refresh
    local p1 = playerReg.get('player1')
    local p2 = playerReg.get('player2')

    if p1 then
        healthBar.setHealthBar('player1', p1.hp)
        auraMeter.setAuraMeter('player1', p1.ap)
        psyMeter.setPsyMeter('player1', p1.psy)
        gutMeter.setGutMeter('player1', p1.gut)
    end

    if p2 then
        healthBar.setHealthBar('player2', p2.hp)
        auraMeter.setAuraMeter('player2', p2.ap)
        psyMeter.setPsyMeter('player2', p2.psy)
        gutMeter.setGutMeter('player2', p2.gut)
    end

    if p1_health=="" or p1_aura=="" or p1_psy=="" or p1_gut=="" or
    p2_health=="" or p2_aura=="" or p2_psy=="" or p2_gut=="" then
        print("[WARN]<MainEgo> One or more OBS sources are unset. Check script UI settings.")
    end
end

-- OBS load (loop mark)
function script_load(settings)
--    playerReg.bindAll()
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
    obs.obs_data_set_default_string(settings, 'player1_psy_source', 'Player1Psy')
    obs.obs_data_set_default_string(settings, 'player1_gut_source', 'Player1Gut')

    obs.obs_data_set_default_string(settings, 'player2_health_source', 'Player2Health')
    obs.obs_data_set_default_string(settings, 'player2_aura_source', 'Player2Aura')
    obs.obs_data_set_default_string(settings, 'player2_psy_source', 'Player2Psy')
    obs.obs_data_set_default_string(settings, 'player2_gut_source', 'Player2Gut')
end