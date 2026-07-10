local State = require("src.fms.state")

local WinGameState = setmetatable({}, { __index = State })
WinGameState.__index = WinGameState

local winSound = love.audio.newSource("assets/sounds/win.mp3", "static")

function WinGameState.new(gameState)
    local self = setmetatable(State.new(), WinGameState)
    self.gameState = gameState
    return self
end

function WinGameState:enter(params)
    self.session = params.session or self.gameState.session
    winSound:play()
end

function WinGameState:update(dt)
    if love.keyboard.isDown("return") then
        if self.gameState and type(self.gameState.goToMenu) == "function" then
            self.gameState:goToMenu()
        end
    end
end

function WinGameState:draw()
    love.graphics.printf("¡Nivel completado!", 0, 220, love.graphics.getWidth(), "center")
    love.graphics.printf("Puntaje: " .. self.session.score, 0, 255, love.graphics.getWidth(), "center")
    love.graphics.printf("Presiona ENTER para volver al menú", 0, 290, love.graphics.getWidth(), "center")
end

return WinGameState
