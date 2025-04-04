local GameState = require 'source.gameStateHandler'
local HealthBar = require 'source.healthBar'
local AuraMeter = require 'source.auraMeter'
local PlayerReg = require 'source.playerRegistry'
local obs = obslua

local EgoCombat = {}

-- Hotkey handles
local hotkeys = {
    damageP1 = nil,
    damageP2 = nil,
    healP1   = nil,
    healP2   = nil,
    addAuraP1 = nil,
    addAuraP2 = nil,
    removeAuraP1 = nil,
    removeAuraP2 = nil
}

-- Starts a combat encounter
function EgoCombat.start()
    GameState.setState('combat')
    EgoCombat.updateVisuals()
end

-- Sets health + aura source names
function EgoCombat.setPlayerSources(p1_health, p1_aura, p2_health, p2_aura)
    PlayerReg.setSources('player1', p1_health, p1_aura)
    PlayerReg.setSources('player2', p2_health, p2_aura)
end

-- Damage a target, then check for defeat
function EgoCombat.damage(target_id, value)
    local target = PlayerReg.get(target_id)
    if not target then return end

    target.hp = math.max(0, target.hp - value)
    EgoCombat.updateVisuals()

    if target.hp <= 0 then
        EgoCombat.crashOut()
    end
end

-- Heal a target
function EgoCombat.heal(target_id, value)
    local target = PlayerReg.get(target_id)
    if not target then return end

    target.hp = math.min(target.max_hp, target.hp + value)
    EgoCombat.updateVisuals()
end

-- Add aura
function EgoCombat.gainAura(target_id, value)
    local target = PlayerReg.get(target_id)
    if not target then return end

    target.ap = math.min(target.max_ap, (target.ap or 0) + value)
    EgoCombat.updateVisuals()
end

-- Remove aura
function EgoCombat.removeAura(target_id, value)
    local target = PlayerReg.get(target_id)
    if not target then return end

    target.ap = math.max(0, target.ap - value)
    EgoCombat.updateVisuals()
end

-- Check if someone won
function EgoCombat.crashOut()
    local p1 = PlayerReg.get('player1')
    local p2 = PlayerReg.get('player2')

    if p1.hp <= 0 then
        GameState.setState('victoryPlayer2')
        print("[DEBUG]<EgoCombat> Player 2 Wins.")
    elseif p2.hp <= 0 then
        GameState.setState('victoryPlayer1')
        print("[DEBUG]<EgoCombat> Player 1 Wins.")
    end
end

-- Register all combat hotkeys
function EgoCombat.bindHotkeys(settings)
    local function register(id, name, callback)
        hotkeys[id] = obs.obs_hotkey_register_frontend(id, name, callback)
        local keys = obs.obs_data_get_array(settings, id) or obs.obs_data_array_create()
        obs.obs_hotkey_load(hotkeys[id], keys)
        obs.obs_data_array_release(keys)
    end

    register('damageP1', "Damage Player 1", function(pressed)
        if pressed then EgoCombat.damage('player1', 1) end
    end)
    register('damageP2', "Damage Player 2", function(pressed)
        if pressed then EgoCombat.damage('player2', 1) end
    end)

    register('healP1', "Heal Player 1", function(pressed)
        if pressed then EgoCombat.heal('player1', 1) end
    end)
    register('healP2', "Heal Player 2", function(pressed)
        if pressed then EgoCombat.heal('player2', 1) end
    end)

    register('addAuraP1', "Add Aura Player 1", function(pressed)
        if pressed then EgoCombat.gainAura('player1', 1) end
    end)
    register('addAuraP2', "Add Aura Player 2", function(pressed)
        if pressed then EgoCombat.gainAura('player2', 1) end
    end)

    register('removeAuraP1', "Remove Aura Player 1", function(pressed)
        if pressed then EgoCombat.removeAura('player1', 1) end
    end)
    register('removeAuraP2', "Remove Aura Player 2", function(pressed)
        if pressed then EgoCombat.removeAura('player2', 1) end
    end)
end

-- Save hotkey bindings
function EgoCombat.saveHotkeys(settings)
    for id, handle in pairs(hotkeys) do
        local keys = obs.obs_hotkey_save(handle)
        obs.obs_data_set_array(settings, id, keys)
        obs.obs_data_array_release(keys)
    end
end

-- Update both players' visuals
function EgoCombat.updateVisuals()
    local p1 = PlayerReg.get('player1')
    local p2 = PlayerReg.get('player2')

    if p1 then
        HealthBar.setHealthBar('player1', p1.hp)
        AuraMeter.setAuraMeter('player1', p1.ap)
    end

    if p2 then
        HealthBar.setHealthBar('player2', p2.hp)
        AuraMeter.setAuraMeter('player2', p2.ap)
    end
end

-- Return player data
function EgoCombat.getChatters()
    return {
        player1 = PlayerReg.get('player1'),
        player2 = PlayerReg.get('player2')
    }
end

return EgoCombat