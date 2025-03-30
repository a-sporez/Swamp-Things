local obs = obslua

local HealthBar = {}

-- Sprite layout constants
-- Each health frame is one sprite tile of this width/height
local frame_width        = 458
local frame_height       = 35
local frames_per_set     = 17  -- number of distinct health values (0–16)
local flash_frame_index  = 17  -- index of white flash frame
local total_frames       = 18  -- 17 normal + 1 flash frame
local flash_duration_ms  = 150 -- how long the flash frame stays on screen (ms)

-- Player health and OBS source metadata
-- Holds source name, current health, and max health
-- OBS hotkey handles are also stored here
local players = {
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

-- Tracks if a flash animation is active for each player
local is_flashing = {
    player1 = false,
    player2 = false
}

-- Core visual logic: crops the visible frame from the sprite sheet
-- Optionally shows the white flash frame when 'use_flash' is true
local function updateCrop(player_id, use_flash)
    local player = players[player_id]
    if not player then return end

    -- Get the OBS source associated with this player's health bar
    local source = obs.obs_get_source_by_name(player.source_name)
    if source == nil then return end

    -- Calculate which frame of the sprite sheet to show
    local frame_index = use_flash and flash_frame_index or (player.max_health - player.health)
    local crop_left = frame_index * frame_width
    local crop_right = (total_frames * frame_width) - frame_width - crop_left

    -- Set cropping values
    local settings = obs.obs_data_create()
    obs.obs_data_set_int(settings, "left", crop_left)
    obs.obs_data_set_int(settings, "right", crop_right)
    obs.obs_data_set_int(settings, "top", 0)
    obs.obs_data_set_int(settings, "bottom", 0)

    -- Apply crop settings to the 'HealthCrop' filter on the image source
    local filter = obs.obs_source_get_filter_by_name(source, "HealthCrop")
    if filter ~= nil then
        obs.obs_source_update(filter, settings)
        obs.obs_source_release(filter)
    else
        print("[ERROR]<HealthBar> Could not find filter 'HealthCrop' on source '" .. player.source_name .. "'")
    end

    -- Clean up allocated memory
    obs.obs_data_release(settings)
    obs.obs_source_release(source)
end

-- Animates a brief white flash frame to signal damage taken
-- Uses obs.timer_add to switch back after a short delay
local function startFlash(player_id)
    if is_flashing[player_id] then return end
    is_flashing[player_id] = true
    updateCrop(player_id, true)

    -- Timer callback to end the flash
    local function flashTick()
        is_flashing[player_id] = false
        updateCrop(player_id, false)
        obs.timer_remove(flashTick)
    end

    obs.timer_add(flashTick, flash_duration_ms)
end

-- Public API: sets a player's health and updates visuals
-- Also triggers a flash if the new value is lower (i.e., damage)
function HealthBar.setHealthBar(playerId, value)
    local player = players[playerId]
    if not player then return end

    local old = player.health
    local new = math.max(0, math.min(player.max_health, value))
    player.health = new
    updateCrop(playerId)

    -- Only flash on damage (health decreased)
    if new < old then
        startFlash(playerId)
    end
end

-- utility function to sync source names.
function HealthBar.setSourceName(playerId, sourceName)
    local player = players[playerId]
    if player then
        player.source_name = sourceName
    end
end

return HealthBar