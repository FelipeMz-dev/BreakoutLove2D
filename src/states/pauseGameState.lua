local State = require("src.states.state")
local PauseGameState = setmetatable({}, { __index = State })
PauseGameState.__index = PauseGameState

function PauseGameState.new(gameState)
    local self = setmetatable(State.new(), PauseGameState)
    self.gameState = gameState
    return self
end

function PauseGameState:enter(params)
    self.session = params.session or self.gameState.session
end

function PauseGameState:play()
    self.gameState:switchTo("play")
end

function PauseGameState:draw()
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("Pausa", 0, 250, love.graphics.getWidth(), "center")
end

return PauseGameState
