local GameState = require 'source.gameStateHandler'
local HealthBar = require 'source.healthBar'

local EgoCombat = {}

local combatants = {
    player1 = {id = 'player1', hp = 16, maxHp = 16},
    player2 = {id = 'player2', hp = 16, maxHp = 16}
}

function EgoCombat.start()
    GameState.setState('combat')
    EgoCombat.updateVisuals()
end

function EgoCombat.damage(targetId, amount)
    local target = combatants[targetId]
    if not target then return end

    target.hp = math.max(0, target.hp - amount)
    EgoCombat.updateVisuals()
end

function EgoCombat.updateVisuals()
    for id, entity in pairs(combatants) do
        HealthBar.setHealth(id, entity.hp)
    end
end

function EgoCombat.getCombatants()
    return combatants
end

return EgoCombat