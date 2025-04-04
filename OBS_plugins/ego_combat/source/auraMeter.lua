local obs = obslua
local PlayerReg = require("playerRegistry")

local AuraMeter = {}

-- frame layout of the spritesheet
local frame_width       = 150
local frame_height      = 35
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

    local source = obs.obs_get_source_by_name(player.aura_source)
    if source == nil then return end

    local frame_index = use_flash and flash_frame_index or player.ap
    local crop_left = frame_index * frame_width
    local crop_right = (total_frames * frame_width) - frame_width - crop_left

    local settings = obs.obs_data_create()
    obs.obs_data_set_int(settings, 'left', crop_left)
    obs.obs_data_set_int(settings, 'right', crop_right)
    obs.obs_data_set_int(settings, 'top', 0)
    obs.obs_data_set_int(settings, 'bottom', 0)

    local filter = obs.obs_source_get_filter_by_name(source, "AuraCrop")
    if filter ~= nil then
        obs.obs_source_update(filter, settings)
        obs.obs_source_release(filter)
    else
        print("[ERROR]<AuraMeter> Could not find filter 'AuraCrop' on source '"..player.aura_source.."'")
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
function AuraMeter.setAuraMeter(player_id, value)
    local player = PlayerReg.get(player_id)
    if not player then return end

    local old = player.ap or 0
    local new = math.max(0, math.min(player.max_ap, value))
    player.ap = new

    updateCrop(player_id)
    if new > old then
        startFlash(player_id)
    end
end

-- optional: allow setting source name through player registry
function AuraMeter.setSourceName(player_id, source_name)
    PlayerReg.setAuraSource(player_id, source_name)
end

return AuraMeter