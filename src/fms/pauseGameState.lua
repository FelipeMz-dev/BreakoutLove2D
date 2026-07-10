local State = require("src.fms.state")
local PauseGameState = setmetatable({}, { __index = State })
PauseGameState.__index = PauseGameState

local pauseOnSound = love.audio.newSource("assets/sounds/pause_on.mp3", "static")
local pauseOffSound = love.audio.newSource("assets/sounds/pause_off.mp3", "static")

function PauseGameState.new(gameState)
    local self = setmetatable(State.new(), PauseGameState)
    self.gameState = gameState
    return self
end

function PauseGameState:enter(params)
    self.session = params.session or self.gameState.session

    pauseOnSound:play()
end

function PauseGameState:exit()
    pauseOffSound:play()
end

function PauseGameState:play()
    self.gameState:switchTo("play")
end

function PauseGameState:draw()
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("PAUSED", 0, 250, love.graphics.getWidth(), "center")
end

return PauseGameState
