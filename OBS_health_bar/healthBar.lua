--[[
    Camel case functions are encapsulated in this module.
    Snake case functions are OBS reserved.
]]
obs = obslua

-- setting constants as global variables for OBS.
source_name  = "" -- string
health       = 16 -- current health (0 to 16)
max_health   = 16 -- total frames (16 = full health)
frame_width  = 710
frame_height = 216

-- hotkey ID handles (OBS requires these to save/load)
local increase_hotkey_id = nil
local decrease_hotkey_id = nil

-- lets just crop the area of the sprite sheet that needs displayed.
function updateCrop()
    local source = obs.obs_get_source_by_name(source_name)
    if source == nil then return end

    local total_width = 710 * 17
    local visible_width = 710
    local crop_left = (max_health - health) * visible_width
    local crop_right = total_width - visible_width - crop_left

    local settings = obs.obs_data_create()
    obs.obs_data_set_int(settings, 'left', crop_left)
    obs.obs_data_set_int(settings, 'right', crop_right)
    obs.obs_data_set_int(settings, 'top', 0)
    obs.obs_data_set_int(settings, 'bottom', 0)

    local filter = obs.obs_source_get_filter_by_name(source, 'HealthCrop')
    if filter ~= nil then
        obs.obs_source_update(filter, settings)
        obs.obs_source_release(filter)
    else
        print("[ERROR]<HealthBar> Could not find filter 'HealthCrop' on source '" .. source_name .. "'")
    end

    obs.obs_data_release(settings)
    obs.obs_source_release(source)
end

-- Hotkey: decrease health
function decreaseHealth(pressed)
    if not pressed then return end
    health = math.max(0, health - 1)
    updateCrop()
end

function increaseHealth(pressed)
    if not pressed then return end
    health = math.min(max_health, health + 1)
    updateCrop()
end

-- Script's UI for OBS.
function script_properties()
    local properties = obs.obs_properties_create()
    obs.obs_properties_add_text(properties, 'source_name', "Source Name", obs.OBS_TEXT_DEFAULT)
    return properties
end

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, 'source_name')
    updateCrop()
end

function script_description()
    return "Health bar crop for spritesheet. \nRequires an image source with a filter named 'HealthCrop'."
end

function script_load(settings)
    increase_hotkey_id = obs.obs_hotkey_register_frontend('increaseHealth', "Increase Health", increaseHealth)
    decrease_hotkey_id = obs.obs_hotkey_register_frontend('decreaseHealth', "Decrease Health", decreaseHealth)

    local inc_keys = obs.obs_data_get_array(settings, 'increaseHealth') or obs.obs_data_array_create()
    local dec_keys = obs.obs_data_get_array(settings, 'decreaseHealth') or obs.obs_data_array_create()

    obs.obs_hotkey_load(increase_hotkey_id, inc_keys)
    obs.obs_hotkey_load(decrease_hotkey_id, dec_keys)

    obs.obs_data_array_release(inc_keys)
    obs.obs_data_array_release(dec_keys)
end

function script_save(settings)
    local inc_keys = obs.obs_hotkey_save(increase_hotkey_id)
    local dec_keys = obs.obs_hotkey_save(decrease_hotkey_id)

    obs.obs_data_set_array(settings, 'increaseHealth', inc_keys)
    obs.obs_data_set_array(settings, 'decreaseHealth', dec_keys)

    obs.obs_data_array_release(inc_keys)
    obs.obs_data_array_release(dec_keys)
end