local Scene = require("src.scenes.scene")
local StateMachine = require("src.core.stateMachine")
local GameSession = require("src.core.gameSession")
local ECSWorld = require("src.ecs.world")
local ECSFactory = require("src.ecs.factory")
local MovementSystem = require("src.ecs.systems.movementSystem")
local CollisionSystem = require("src.ecs.systems.collisionSystem")
local RenderSystem = require("src.ecs.systems.renderSystem")
local StartGameState = require("src.fms.startGameState")
local PlayGameState = require("src.fms.playGameState")
local LoseLifeGameState = require("src.fms.loseLifeGameState")
local PauseGameState = require("src.fms.pauseGameState")
local GameOverGameState = require("src.fms.gameOverGameState")
local WinGameState = require("src.fms.winGameState")
local GameHud = require("src.core.gameHud")

local GameScene = {}
GameScene.__index = GameScene

local backgroundImage = love.graphics.newImage("assets/images/background.png")

function GameScene.new(navigator, progression, levelLoader)
    local self = setmetatable(Scene.new(), GameScene)
    self.navigator = navigator
    self.progression = progression
    self.levelLoader = levelLoader
    self.stateMachine = StateMachine.new()
    self.stateMachine.states = {
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
    self.activePowerups = {}
    self.hud = GameHud.new(self)
    self.ecsWorld = ECSWorld.new()
    self.ecsWorld:addSystem(MovementSystem.new())
    self.ecsWorld:addSystem(CollisionSystem.new())
    self.ecsWorld:addSystem(RenderSystem.new())
    return self
end

function GameScene:enter(params)
    local levelId = params and params.level or 1
    self:loadLevel(levelId)
    self:switchTo("start", { session = self.session })

    stopLoopSound()
end

function GameScene:loadLevel(levelId)
    local dificult = 5 * (levelId or 1)
    local middleWidth = love.graphics.getWidth() / 2
    local levelData = self.levelLoader and self.levelLoader:getLevel(levelId)
    local brickTemplates = self.levelLoader and self.levelLoader:createBricks(levelData) or {}

    if not levelData then
        print("Nivel no encontrado: " .. tostring(levelId) .. ". Buscando primer nivel disponible.")
        local availableLevels = self.levelLoader and self.levelLoader:getLevels()
        if availableLevels and #availableLevels > 0 then
            levelData = availableLevels[1]
        end
    end

    self.currentLevel = levelData.id or 1
    self.levelData = levelData
    self.session = GameSession.new(3)
    self.activePowerups = {}

    self.ecsWorld = ECSWorld.new()
    self.ecsWorld:addSystem(MovementSystem.new())
    self.ecsWorld:addSystem(CollisionSystem.new())
    self.ecsWorld:addSystem(RenderSystem.new())
    self.ecsWorld.context = {
        screenWidth = love.graphics.getWidth(),
        screenHeight = love.graphics.getHeight(),
        gameScreen = self
    }

    self.paddle = ECSFactory.createPaddle(middleWidth - 40, love.graphics.getHeight() - 40)
    self.ball = ECSFactory.createBall(middleWidth, love.graphics.getHeight() - 60, 16, 300 + dificult)

    self.ecsWorld:addEntity(self.paddle)
    self.ecsWorld:addEntity(self.ball)

    self.bricks = {}
    for _, brickTemplate in ipairs(brickTemplates) do
        local ecsBrick = ECSFactory.createBrick(brickTemplate.x, brickTemplate.y, brickTemplate.width, brickTemplate.height, brickTemplate.resistance, brickTemplate.colors)
        self.ecsWorld:addEntity(ecsBrick)
        table.insert(self.bricks, ecsBrick)
    end
end

function GameScene:addPowerup(effectType)
    if not effectType then
        return
    end

    table.insert(self.activePowerups, effectType)
end

function GameScene:switchTo(stateName, params)
    if self.stateMachine and type(self.stateMachine.change) == "function" then
        self.stateMachine:change(stateName, params or {})
    end
end

function GameScene:restart()
    self:loadLevel(self.currentLevel or 1)
    self:switchTo("start", { session = self.session })
end

function GameScene:togglePause()
    if not self.stateMachine or not self.stateMachine.current then
        return
    end

    if type(self.stateMachine.current.pause) == "function" then
        self.hud:setStateName("PLAY")
        self:switchTo("pause", { session = self.session })
    elseif type(self.stateMachine.current.play) == "function" then
        self.hud:setStateName()
        self:switchTo("play", { session = self.session })
    end
end

function GameScene:goToMenu()
    if self.navigator and type(self.navigator.goTo) == "function" then
        self.navigator:goTo("menu")
    end
end

function GameScene:update(dt)
    if self.stateMachine and type(self.stateMachine.update) == "function" then
        self.stateMachine:update(dt)
    end
end

function GameScene:draw()
    love.graphics.clear(0.15, 0.15, 0.15)

    love.graphics.setColor(1, 1, 1)
    if backgroundImage then
        love.graphics.draw(backgroundImage, 0, 0, 0, love.graphics.getWidth() / backgroundImage:getWidth(), love.graphics.getHeight() / backgroundImage:getHeight())
    end

    if self.ecsWorld then
        self.ecsWorld:draw()
    end

    if self.hud then
        self.hud:draw()
    end

    if self.stateMachine and type(self.stateMachine.draw) == "function" then
        self.stateMachine:draw()
    end
end

function GameScene:mousemoved(mx, my, ...)
    if self.stateMachine.current and self.stateMachine.current.mousemoved then
        self.stateMachine.current:mousemoved(mx, my, ...)
    end
end

function GameScene:mousepressed(x, y, button, ...)
    if self.hud and self.hud:handleMousePressed(x, y, button) then
        return
    end

    if self.stateMachine.current and self.stateMachine.current.mousepressed then
        self.stateMachine.current:mousepressed(x, y, button, ...)
    end
end

function GameScene:keypressed(key, ...)
    if key == "p" then
        self:togglePause()
    end

    if self.stateMachine.current and self.stateMachine.current.keypressed then
        self.stateMachine.current:keypressed(key, ...)
    end
end

return GameScene