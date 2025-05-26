local obs = obslua
local PlayerReg = require("playerRegistry")

local GutMeter = {}

-- frame layout of the spritesheet
local frame_width       = 48
local frame_height      = 48
local flash_frame_index = 4
local total_frames      = 5 -- 0–3 aura + flash
local flash_duration_ms = 150

-- store flash control
local is_flashing = {
    player1 = false,
    player2 = false
}

local function updateCrop(player_id, use_flash)
    local player = PlayerReg.get(player_id)
    if not player then return end

    local source = obs.obs_get_source_by_name(player.gut_source)
    if source == nil then return end

    local frame_index = use_flash and flash_frame_index or player.gut
    local crop_left = frame_index * frame_width
    local crop_right = (total_frames * frame_width) - frame_width - crop_left

    local settings = obs.obs_data_create()
    obs.obs_data_set_int(settings, 'left', crop_left)
    obs.obs_data_set_int(settings, 'right', crop_right)
    obs.obs_data_set_int(settings, 'top', 0)
    obs.obs_data_set_int(settings, 'bottom', 0)

    local filter = obs.obs_source_get_filter_by_name(source, "GutCrop")
    if filter ~= nil then
        obs.obs_source_update(filter, settings)
        obs.obs_source_release(filter)
    else
        print("[ERROR]<GutMeter> Could not find filter 'GutCrop' on source '"..player.gut_source.."'")
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

-- Public API
function GutMeter.setGutMeter(player_id, value)
    local player = PlayerReg.get(player_id)
    if not player then return end

    local old = player.gut or 0
    local new = math.max(0, math.min(player.max_gut, value))
    player.gut = new

    updateCrop(player_id)
    if new > old then
        startFlash(player_id)
    end
end

-- optional: allow setting source name through player registry
function GutMeter.setSourceName(player_id, source_name)
    PlayerReg.setGutSource(player_id, source_name)
end

return GutMeter