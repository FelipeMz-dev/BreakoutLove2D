local State = require("src.states.state")
local GameOverGameState = setmetatable({}, { __index = State })
GameOverGameState.__index = GameOverGameState

function GameOverGameState.new(gameState)
    local self = setmetatable(State.new(), GameOverGameState)
    self.gameState = gameState
    return self
end

function GameOverGameState:enter(params)
    self.session = params.session or self.gameState.session
end

function GameOverGameState:update(dt)
    if love.keyboard.isDown("return") then
        self.gameState:restart()
    end
end

function GameOverGameState:draw()
    love.graphics.printf("GAME OVER", 0, 250, love.graphics.getWidth(), "center")
    love.graphics.printf("Puntaje Final: " .. self.session.score, 0, 280, love.graphics.getWidth(), "center")
    love.graphics.printf("Presiona ENTER para reiniciar", 0, 310, love.graphics.getWidth(), "center")
end

return GameOverGameState
