-- Safely determine the script's own folder (cross-platform)
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

local HealthBar = require("healthBar")

function script_description()
    return "Main entry for dual health bar combat system.\nLoads healthBar module and sets up OBS hotkeys + UI."
end

function script_properties()
    return HealthBar.getProperties()
end

function script_update(settings)
    HealthBar.updateFromSettings(settings)
end

function script_load(settings)
    HealthBar.load(settings)
end

function script_save(settings)
    HealthBar.save(settings)
end