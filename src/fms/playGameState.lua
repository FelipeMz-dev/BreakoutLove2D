local State = require("src.fms.state")

local PlayGameState = setmetatable({}, { __index = State })
PlayGameState.__index = PlayGameState

function PlayGameState.new(gameState)
    local self = setmetatable(State.new(), PlayGameState)
    self.gameState = gameState
    return self
end

function PlayGameState:enter(params)
    self.session = params.session or self.gameState.session
    self.paddle = self.gameState.paddle
    self.ball = self.gameState.ball
    self.bricks = self.gameState.bricks

    local ballBehavior = self.ball and self.ball:getComponent("ballBehavior")
    if ballBehavior then
        ballBehavior:release()
    end
end

function PlayGameState:update(dt)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    self.gameState.ecsWorld.context = {
        screenWidth = screenWidth,
        screenHeight = screenHeight,
        session = self.session,
        gameState = self.gameState,
        state = self
    }

    self.gameState.ecsWorld:update(dt)

    local ballEntity = self.gameState.ecsWorld:getEntityByTag("ball")
    local ballTransform = ballEntity and ballEntity:getComponent("transform")
    local ballBehavior = ballEntity and ballEntity:getComponent("ballBehavior")

    if not ballEntity or not ballTransform or not ballBehavior or ballBehavior.stuck then
        return
    end

    local remainingBricks = false
    for _, brick in ipairs(self.bricks or {}) do
        local brickBehavior = brick and brick:getComponent("brickBehavior")
        if brickBehavior and brickBehavior.active then
            remainingBricks = true
            break
        end
    end

    if not remainingBricks then
        self.gameState.progression:unlockLevel(self.gameState.currentLevel + 1)
        self.gameState:switchTo("win", { session = self.session })
        return
    end

    if ballTransform.y - ballBehavior.radius > screenHeight then
        self.session:loseLife()
        if self.session:isGameOver() then
            self.gameState:switchTo("gameOver")
        else
            local paddleTransform = self.paddle and self.paddle:getComponent("transform")
            local resetX = paddleTransform and (paddleTransform.x + paddleTransform.width / 2) or ballTransform.x
            local resetY = paddleTransform and (paddleTransform.y - ballBehavior.radius - 1) or (ballTransform.y - ballBehavior.radius - 1)
            ballBehavior:reset(resetX, resetY)
            self.gameState:switchTo("loseLife")
        end
    end
end

function PlayGameState:pause()
    self.gameState:switchTo("pause")
end

return PlayGameState
