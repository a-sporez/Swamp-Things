-- Require the game state manager and the health bar system
local GameState = require 'source.gameStateHandler'
local HealthBar = require 'source.healthBar'
local obs = obslua

-- Main module table
local EgoCombat = {}

-- Combatant data table: holds each player's current and max health
local combatants = {
    player1 = {id = 'player1', hp = 16, maxHp = 16},
    player2 = {id = 'player2', hp = 16, maxHp = 16}
}

-- Hotkey handles (OBS uses these to load/save bindings)
local hotkeys = {
    damageP1 = nil,
    damageP2 = nil,
    healP1   = nil,
    healP2   = nil
}

-- Called to begin a combat encounter
-- Sets the game state to "combat" and updates the health bar visuals
function EgoCombat.start()
    GameState.setState('combat')
    EgoCombat.updateVisuals()
end

-- Applies damage to a target
-- Clamps HP to 0, checks for crash, then refreshes visuals
function EgoCombat.damage(targetId, amount)
    local target = combatants[targetId]
    if not target then return end

    target.hp = math.max(0, target.hp - amount)
    if target.hp <= 0 then
        EgoCombat.crashOut()
    end

    EgoCombat.updateVisuals()
end

-- Applies healing to a target
-- Clamps HP to max and refreshes visuals
function EgoCombat.heal(targetId, amount)
    local target = combatants[targetId]
    if not target then return end

    target.hp = math.min(target.maxHp, target.hp + amount)
    EgoCombat.updateVisuals()
end

-- Determines the winner and transitions game state
function EgoCombat.crashOut()
    if combatants.player1.hp <= 0 then
        GameState.setState('victoryPlayer2')
        print("[DEBUG]<EgoCombat> Player 2 Wins.")
    elseif combatants.player2.hp <= 0 then
        GameState.setState('victoryPlayer1')
        print("[DEBUG]<EgoCombat> Player 1 Wins.")
    end
end

-- Registers hotkeys and their behavior
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
end

-- Saves all hotkey bindings
function EgoCombat.saveHotkeys(settings)
    for id, handle in pairs(hotkeys) do
        local keys = obs.obs_hotkey_save(handle)
        obs.obs_data_set_array(settings, id, keys)
        obs.obs_data_array_release(keys)
    end
end

-- Syncs all combatant health values with the visual health bars
function EgoCombat.updateVisuals()
    for id, entity in pairs(combatants) do
        HealthBar.setHealthBar(id, entity.hp)
    end
end

-- Returns the current combatant table (can be used for debugging or UI)
function EgoCombat.getCombatants()
    return combatants
end

return EgoCombat