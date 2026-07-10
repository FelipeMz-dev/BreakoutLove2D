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

    local balls = self.gameState.ecsWorld:getEntitiesByTag("ball")
    local activeBalls = {}

    for _, ballEntity in ipairs(balls) do
        local ballTransform = ballEntity and ballEntity:getComponent("transform")
        local ballBehavior = ballEntity and ballEntity:getComponent("ballBehavior")

        if ballTransform and ballBehavior and not ballBehavior.stuck then
            if ballTransform.y - ballBehavior.radius > screenHeight then
                self.gameState.ecsWorld:removeEntity(ballEntity)
            else
                table.insert(activeBalls, ballEntity)
            end
        end
    end

    if #activeBalls == 0 then
        local baseBall = balls[1] or self.gameState.ball
        local ballTransform = baseBall and baseBall:getComponent("transform")
        local ballBehavior = baseBall and baseBall:getComponent("ballBehavior")

        if not ballBehavior then
            return
        end

        local paddleTransform = self.paddle and self.paddle:getComponent("transform")
        local resetX = paddleTransform and (paddleTransform.x + paddleTransform.width / 2) or (ballTransform and ballTransform.x) or 0
        local resetY = paddleTransform and (paddleTransform.y - ballBehavior.radius - 1) or (ballTransform and ballTransform.y) or 0

        for _, ballEntity in ipairs(balls) do
            self.gameState.ecsWorld:removeEntity(ballEntity)
        end

        local newBall = require("src.ecs.factory").createBall(resetX, resetY, ballBehavior.radius, ballBehavior.speed)
        local newBallBehavior = newBall:getComponent("ballBehavior")
        if newBallBehavior then
            newBallBehavior:reset(resetX, resetY)
        end

        self.gameState.ball = newBall
        self.ball = newBall
        self.gameState.ecsWorld:addEntity(newBall)

        self.session:loseLife()
        if self.session:isGameOver() then
            self.gameState:switchTo("gameOver")
        else
            self.gameState:switchTo("loseLife")
        end
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
end

function PlayGameState:pause()
    self.gameState:switchTo("pause")
end

return PlayGameState
