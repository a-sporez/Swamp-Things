-- GameStateHandler manages named states and enter callbacks
local GameStateHandler = {}

-- Current active state name (e.g., "combat", "victory")
local currentState = nil

-- Table of functions to call when a specific state is entered
local enterCallbacks = {}

-- Changes the current state and calls any onEnter callback
function GameStateHandler.setState(state)
    if currentState ~= state then
        currentState = state
        if enterCallbacks[state] then
            enterCallbacks[state]()
        end
    end
end

-- Returns the current active state name
function GameStateHandler.getState()
    return currentState
end

-- Registers a function to be called when a state is entered
function GameStateHandler.onEnter(state, callback)
    enterCallbacks[state] = callback
end

return GameStateHandler