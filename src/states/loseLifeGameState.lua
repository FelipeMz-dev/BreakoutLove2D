local State = require("src.states.state")
local LoseLifeGameState = setmetatable({}, { __index = State })
LoseLifeGameState.__index = LoseLifeGameState

function LoseLifeGameState.new(gameState)
    local self = setmetatable(State.new(), LoseLifeGameState)
    self.gameState = gameState
    return self
end

function LoseLifeGameState:enter(params)
    self.session = params.session or self.gameState.session
    self.respawnTimer = 0
end

function LoseLifeGameState:update(dt)
    self.respawnTimer = self.respawnTimer + dt
    if self.respawnTimer >= 1.5 then
        self.gameState:switchTo("start", { session = self.session })
    end
end

function LoseLifeGameState:draw()
    love.graphics.printf("Perdiste una vida", 0, 250, love.graphics.getWidth(), "center")
    love.graphics.printf("Vidas restantes: " .. self.session.lives, 0, 280, love.graphics.getWidth(), "center")
end

return LoseLifeGameState
