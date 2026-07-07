local State = require("src.states.state")
local CollisionSystem = require("src.systems.collisionSystem")

local PlayGameState = setmetatable({}, { __index = State })
PlayGameState.__index = PlayGameState

function PlayGameState.new(gameState)
    local self = setmetatable(State.new(), PlayGameState)
    self.gameState = gameState
    self.collisionSystem = CollisionSystem.new()
    return self
end

function PlayGameState:enter(params)
    self.session = params.session or self.gameState.session
    self.paddle = self.gameState.paddle
    self.ball = self.gameState.ball
    self.bricks = self.gameState.bricks
    self.ball:release()
end

function PlayGameState:update(dt)
    if self.ball.stuck then
        return
    end

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    self.paddle:update(dt, screenWidth)
    self.ball:update(dt)

    self.collisionSystem:resolveBallWithBounds(self.ball, screenWidth)

    if self.collisionSystem:resolveBallWithPaddle(self.ball, self.paddle) then
        self.session:addScore(1)
    end

    local remainingBricks = false
    for _, brick in ipairs(self.bricks) do
        if brick.active then
            local hit, destroyed = self.collisionSystem:resolveBallWithBrick(self.ball, brick)
            remainingBricks = true
            if hit then
                if destroyed then
                    self.session:addScore(10)
                else
                    self.session:addScore(3)
                end
                break
            end
        end
    end

    if not remainingBricks then
        self.gameState.progression:unlockLevel(self.gameState.currentLevel + 1)
        self.gameState:switchTo("win", { session = self.session })
        return
    end

    if self.ball.y - self.ball.radius > screenHeight then
        self.session:loseLife()
        if self.session:isGameOver() then
            self.gameState:switchTo("gameOver")
        else
            self.ball:reset(self.paddle.x + self.paddle.width / 2, self.paddle.y - self.ball.radius - 1)
            self.gameState:switchTo("loseLife")
        end
    end
end

function PlayGameState:pause()
    self.gameState:switchTo("pause")
end


return PlayGameState
