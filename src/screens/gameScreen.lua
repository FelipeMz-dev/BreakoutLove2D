local Screen = require("src.screens.screen")
local StateMachine = require("src.core.stateMachine")
local GameSession = require("src.core.gameSession")
local Paddle = require("src.entities.paddle")
local Ball = require("src.entities.ball")
local StartGameState = require("src.states.startGameState")
local PlayGameState = require("src.states.playGameState")
local LoseLifeGameState = require("src.states.loseLifeGameState")
local PauseGameState = require("src.states.pauseGameState")
local GameOverGameState = require("src.states.gameOverGameState")
local WinGameState = require("src.states.winGameState")
local GameHud = require("src.ui.gameHud")

local GameScreen = {}
GameScreen.__index = GameScreen

function GameScreen.new(navigator, progression, levelLoader)
    local self = setmetatable(Screen.new(), GameScreen)
    self.navigator = navigator
    self.progression = progression
    self.levelLoader = levelLoader
    self.screenStateMachine = StateMachine.new()
    self.screenStateMachine.states = {
        ["start"] = StartGameState.new(self),
        ["play"] = PlayGameState.new(self),
        ["loseLife"] = LoseLifeGameState.new(self),
        ["pause"] = PauseGameState.new(self),
        ["gameOver"] = GameOverGameState.new(self),
        ["win"] = WinGameState.new(self)
    }
    self.currentLevel = nil
    self.levelData = nil
    self.bricks = {}
    self.paddle = nil
    self.ball = nil
    self.session = nil
    self.hud = GameHud.new(self)
    return self
end

function GameScreen:enter(params)
    local levelId = params and params.level or 1
    self:loadLevel(levelId)
    self:switchTo("start", { session = self.session })
end

function GameScreen:loadLevel(levelId)
    local levelData = self.levelLoader and self.levelLoader:getLevel(levelId)
    if not levelData then
        print("Nivel no encontrado: " .. tostring(levelId) .. ". Buscando primer nivel disponible.")
        local availableLevels = self.levelLoader and self.levelLoader:getLevels()
        if availableLevels and #availableLevels > 0 then
            levelData = availableLevels[1]
        end
    end

    if not levelData then
        error("No hay niveles cargados para iniciar el juego.")
    end

    local dificult = 5 * levelData.id or 1 

    self.currentLevel = levelData.id or 1
    self.levelData = levelData
    self.session = GameSession.new(3)
    self.paddle = Paddle:new(love.graphics.getWidth() / 2 - 40, love.graphics.getHeight() - 40)
    self.ball = Ball:new(love.graphics.getWidth() / 2, love.graphics.getHeight() - 60, 16, 200 + dificult)
    self.bricks = self.levelLoader and self.levelLoader:createBricks(levelData) or {}
end

function GameScreen:switchTo(stateName, params)
    if self.screenStateMachine and type(self.screenStateMachine.change) == "function" then
        self.screenStateMachine:change(stateName, params or {})
    end
end

function GameScreen:restart()
    self:loadLevel(self.currentLevel or 1)
    self:switchTo("start", { session = self.session })
end

function GameScreen:togglePause()
    if not self.screenStateMachine or not self.screenStateMachine.current then
        return
    end

    if type(self.screenStateMachine.current.pause) == "function" then
        self.hud:setStateName("PLAY")
        self:switchTo("pause", { session = self.session })
    elseif type(self.screenStateMachine.current.play) == "function" then    
        self.hud:setStateName()
        self:switchTo("play", { session = self.session })
    end
end

function GameScreen:goToMenu()
    if self.navigator and type(self.navigator.goTo) == "function" then
        self.navigator:goTo("menu")
    end
end

function GameScreen:update(dt)
    if self.screenStateMachine and type(self.screenStateMachine.update) == "function" then
        self.screenStateMachine:update(dt)
    end
end

function GameScreen:draw()
    love.graphics.clear(0.1, 0.1, 0.1)

    if self.paddle then
        self.paddle:draw()
    end

    if self.ball then
        self.ball:draw()
    end

    for _, brick in ipairs(self.bricks) do
        if brick.active then
            brick:draw()
        end
    end

    if self.hud then
        self.hud:draw()
    end

    if self.screenStateMachine and type(self.screenStateMachine.draw) == "function" then
        self.screenStateMachine:draw()
    end
end

function GameScreen:mousemoved(mx, my, ...)
    if self.screenStateMachine.current and self.screenStateMachine.current.mousemoved then
        self.screenStateMachine.current:mousemoved(mx, my, ...)
    end
end

function GameScreen:mousepressed(x, y, button, ...)
    if self.hud and self.hud:handleMousePressed(x, y, button) then
        return
    end

    if self.screenStateMachine.current and self.screenStateMachine.current.mousepressed then
        self.screenStateMachine.current:mousepressed(x, y, button, ...)
    end
end

function GameScreen:keypressed(key, ...)
    if key == "p" then
        self:switchTo("pause", { session = self.session })
        return
    end

    if self.screenStateMachine.current and self.screenStateMachine.current.keypressed then
        self.screenStateMachine.current:keypressed(key, ...)
    end
end

return GameScreen