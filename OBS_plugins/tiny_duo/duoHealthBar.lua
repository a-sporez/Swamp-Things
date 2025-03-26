--[[
    Camel case functions are encapsulated in this module.
    Snake case functions are OBS reserved.
]]
obs = obslua

-- frame layout
frame_width        = 458
frame_height       = 35
frames_per_set     = 17 -- normal frames: 0–16
flash_frame_index  = 17 -- white flash frame (frame 17)
total_frames       = 18 -- 17 normal + 1 flash
flash_duration_ms  = 150

-- player state
players = {
    player1 = {
        source_name = "Player1HealthBar",
        health = 16,
        max_health = 16,
        increase_hotkey_id = nil,
        decrease_hotkey_id = nil,
    },
    player2 = {
        source_name = "Player2HealthBar",
        health = 16,
        max_health = 16,
        increase_hotkey_id = nil,
        decrease_hotkey_id = nil,
    }
}

-- flash tracking per player
local is_flashing = {
    player1 = false,
    player2 = false
}

-- update crop for a given player, optionally show flash frame
function updateCrop(player_id, use_flash)
    local p = players[player_id]
    if not p then return end

    local source = obs.obs_get_source_by_name(p.source_name)
    if source == nil then return end

    local frame_index = use_flash and flash_frame_index or (p.max_health - p.health)
    local crop_left = frame_index * frame_width
    local crop_right = (total_frames * frame_width) - frame_width - crop_left

    local settings = obs.obs_data_create()
    obs.obs_data_set_int(settings, "left", crop_left)
    obs.obs_data_set_int(settings, "right", crop_right)
    obs.obs_data_set_int(settings, "top", 0)
    obs.obs_data_set_int(settings, "bottom", 0)

    local filter = obs.obs_source_get_filter_by_name(source, "HealthCrop")
    if filter ~= nil then
        obs.obs_source_update(filter, settings)
        obs.obs_source_release(filter)
    else
        print("[ERROR]<HealthBar> Could not find filter 'HealthCrop' on source '" .. p.source_name .. "'")
    end

    obs.obs_data_release(settings)
    obs.obs_source_release(source)
end

-- trigger brief white flash for player
function startFlash(player_id)
    if is_flashing[player_id] then return end
    is_flashing[player_id] = true
    updateCrop(player_id, true)

    local function flashTick()
        is_flashing[player_id] = false
        updateCrop(player_id, false)
        obs.timer_remove(flashTick)
    end

    obs.timer_add(flashTick, flash_duration_ms)
end

-- player-specific health functions
function increaseHealthP1(pressed)
    if not pressed then return end
    local p = players.player1
    p.health = math.min(p.max_health, p.health + 1)
    updateCrop("player1")
end

function decreaseHealthP1(pressed)
    if not pressed then return end
    local p = players.player1
    p.health = math.max(0, p.health - 1)
    updateCrop("player1")
    startFlash("player1")
end

function increaseHealthP2(pressed)
    if not pressed then return end
    local p = players.player2
    p.health = math.min(p.max_health, p.health + 1)
    updateCrop("player2")
end

function decreaseHealthP2(pressed)
    if not pressed then return end
    local p = players.player2
    p.health = math.max(0, p.health - 1)
    updateCrop("player2")
    startFlash("player2")
end

-- OBS UI: text fields for source names
function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "player1_source", "Player 1 Source", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "player2_source", "Player 2 Source", obs.OBS_TEXT_DEFAULT)
    return props
end

function script_update(settings)
    players.player1.source_name = obs.obs_data_get_string(settings, "player1_source")
    players.player2.source_name = obs.obs_data_get_string(settings, "player2_source")
    updateCrop("player1")
    updateCrop("player2")
end

function script_description()
    return "Two-player health bar with a shared white flash frame.\n" ..
           "Requires a horizontal sprite sheet with 17 normal frames and 1 flash frame.\n" ..
           "Add a Crop/Pad filter named 'HealthCrop' to both sources."
end

-- OBS: hotkey registration
function script_load(settings)
    local p1 = players.player1
    local p2 = players.player2

    p1.increase_hotkey_id = obs.obs_hotkey_register_frontend("increaseHealthP1", "Increase Health - Player 1", increaseHealthP1)
    p1.decrease_hotkey_id = obs.obs_hotkey_register_frontend("decreaseHealthP1", "Decrease Health - Player 1", decreaseHealthP1)

    p2.increase_hotkey_id = obs.obs_hotkey_register_frontend("increaseHealthP2", "Increase Health - Player 2", increaseHealthP2)
    p2.decrease_hotkey_id = obs.obs_hotkey_register_frontend("decreaseHealthP2", "Decrease Health - Player 2", decreaseHealthP2)

    local p1_inc_keys = obs.obs_data_get_array(settings, "increaseHealthP1") or obs.obs_data_array_create()
    local p1_dec_keys = obs.obs_data_get_array(settings, "decreaseHealthP1") or obs.obs_data_array_create()
    local p2_inc_keys = obs.obs_data_get_array(settings, "increaseHealthP2") or obs.obs_data_array_create()
    local p2_dec_keys = obs.obs_data_get_array(settings, "decreaseHealthP2") or obs.obs_data_array_create()

    obs.obs_hotkey_load(p1.increase_hotkey_id, p1_inc_keys)
    obs.obs_hotkey_load(p1.decrease_hotkey_id, p1_dec_keys)
    obs.obs_hotkey_load(p2.increase_hotkey_id, p2_inc_keys)
    obs.obs_hotkey_load(p2.decrease_hotkey_id, p2_dec_keys)

    obs.obs_data_array_release(p1_inc_keys)
    obs.obs_data_array_release(p1_dec_keys)
    obs.obs_data_array_release(p2_inc_keys)
    obs.obs_data_array_release(p2_dec_keys)
end

-- OBS: hotkey save
function script_save(settings)
    local p1 = players.player1
    local p2 = players.player2

    local p1_inc_keys = obs.obs_hotkey_save(p1.increase_hotkey_id)
    local p1_dec_keys = obs.obs_hotkey_save(p1.decrease_hotkey_id)
    local p2_inc_keys = obs.obs_hotkey_save(p2.increase_hotkey_id)
    local p2_dec_keys = obs.obs_hotkey_save(p2.decrease_hotkey_id)

    obs.obs_data_set_array(settings, "increaseHealthP1", p1_inc_keys)
    obs.obs_data_set_array(settings, "decreaseHealthP1", p1_dec_keys)
    obs.obs_data_set_array(settings, "increaseHealthP2", p2_inc_keys)
    obs.obs_data_set_array(settings, "decreaseHealthP2", p2_dec_keys)

    obs.obs_data_array_release(p1_inc_keys)
    obs.obs_data_array_release(p1_dec_keys)
    obs.obs_data_array_release(p2_inc_keys)
    obs.obs_data_array_release(p2_dec_keys)
end