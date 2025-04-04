local PlayerRegistry = {}

local players = {
    player1 = {
        id = 'player1',
        hp = 16,
        max_hp = 16,
        ap = 0,
        max_ap = 3,
        health_source = 'Player1Health',
        aura_source = 'Player1Aura'
    },

    player2 = {
        id = 'player2',
        hp = 16,
        max_hp = 16,
        ap = 0,
        max_ap = 3,
        health_source = 'Player2Health',
        aura_source = 'Player2Aura'
    }
}

function PlayerRegistry.get(id)
    return players[id]
end

function PlayerRegistry.setHealthSource(id, source_name)
    if players[id] then
        players[id].health_source = source_name
    end
end

function PlayerRegistry.setAuraSource(id, source_name)
    if players[id] then
        players[id].aura_source = source_name
    end
end

function PlayerRegistry.setSources(id, health_source, aura_source)
    if players[id] then
        players[id].health_source = health_source
        players[id].aura_source = aura_source
    end
end

return PlayerRegistry