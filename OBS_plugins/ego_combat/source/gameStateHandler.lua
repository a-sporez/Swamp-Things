local GameStateHandler = {}

local currentState = nil
local enterCallbacks = {}

function GameStateHandler.setState(state)
    if currentState ~= state then
        currentState = state
        if enterCallbacks[state] then
            enterCallbacks[state]()
        end
    end
end

function GameStateHandler.getState()
    return currentState
end

function GameStateHandler.onEnter(state, callback)
    enterCallbacks[state] = callback
end

return GameStateHandler