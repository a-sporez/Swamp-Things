local obs = obslua
local PlayerReg = require("playerRegistry")

local HealthBar = {}

-- Sprite layout constants
local frame_width        = 512
local frame_height       = 35
local frames_per_set     = 17
local flash_frame_index  = 17
local total_frames       = 18
local flash_duration_ms  = 150

-- Track whether each player is flashing
local is_flashing = {
    player1 = false,
    player2 = false
}

local function updateCrop(player_id, use_flash)
    local player = PlayerReg.get(player_id)
    if not player then return end

    local source = obs.obs_get_source_by_name(player.health_source)
    if not source then return end

    -- Determine which frame to show
    local frame_index = use_flash and flash_frame_index or (player.max_hp - player.hp)

    -- Clamp the frame index to avoid invalid crop
    frame_index = math.max(0, math.min(frame_index, total_frames - 1))

    -- Calculate cropping
    local crop_left = frame_index * frame_width
    local crop_right = (total_frames * frame_width) - frame_width - crop_left

    -- Apply crop to 'HealthCrop' filter
    local settings = obs.obs_data_create()
    obs.obs_data_set_int(settings, "left", crop_left)
    obs.obs_data_set_int(settings, "right", crop_right)
    obs.obs_data_set_int(settings, "top", 0)
    obs.obs_data_set_int(settings, "bottom", 0)

    local filter = obs.obs_source_get_filter_by_name(source, "HealthCrop")
    if filter then
        obs.obs_source_update(filter, settings)
        obs.obs_source_release(filter)
    else
        print("[ERROR]<HealthBar> Could not find filter 'HealthCrop' on source '" .. player.health_source .. "'")
    end

    obs.obs_data_release(settings)
    obs.obs_source_release(source)
end

local function startFlash(player_id)
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

-- Public API: update health and visuals
function HealthBar.setHealthBar(player_id, value)
    local player = PlayerReg.get(player_id)
    if not player then return end

    local old = player.hp
    local new = math.max(0, math.min(player.max_hp, value))
    player.hp = new
    updateCrop(player_id)

    if new < old then
        startFlash(player_id)
    end
end

-- Public API: update source name via PlayerRegistry
function HealthBar.setSourceName(player_id, source_name)
    PlayerReg.setHealthSource(player_id, source_name)
end

return HealthBar