local State = require("src.fms.state")
local StartGameState = setmetatable({}, { __index = State })
StartGameState.__index = StartGameState

local startSound = love.audio.newSource("assets/sounds/start.mp3", "static")
local releaseSound = love.audio.newSource("assets/sounds/release.mp3", "static")

function StartGameState.new(gameState)
    local self = setmetatable(State.new(), StartGameState)
    self.gameState = gameState
    return self
end

function StartGameState:enter(params)
    self.session = params.session or self.gameState.session
    self.paddle = self.gameState.paddle
    self.ball = self.gameState.ball
    self.launchAngle = -math.pi / 2

    startSound:play()
end

function StartGameState:exit()
    releaseSound:play()
end

function StartGameState:update(dt)
    if love.keyboard.isDown("return") and self.ball then
        local ballBehavior = self.ball:getComponent("ballBehavior")
        if ballBehavior then
            ballBehavior:setDirection(self.launchAngle, ballBehavior.speed)
            ballBehavior:release()
            self.gameState:switchTo("play", { session = self.session })
        end
    end
end

function StartGameState:mousemoved(mx, my)
    local ballTransform = self.ball and self.ball:getComponent("transform")
    local ballBehavior = self.ball and self.ball:getComponent("ballBehavior")
    if not ballTransform or not ballBehavior or not ballBehavior.stuck then
        return
    end

    local dx = mx - ballTransform.x
    local dy = my - ballTransform.y
    self.launchAngle = math.atan2(-dy, dx)
end

function StartGameState:mousepressed(x, y, button)
    if button ~= 1 or not self.ball then
        return
    end

    local ballBehavior = self.ball:getComponent("ballBehavior")
    local ballTransform = self.ball:getComponent("transform")
    if ballBehavior and ballBehavior.stuck and ballTransform then
        local angle = math.atan2(-(y - ballTransform.y), x - ballTransform.x)
        ballBehavior:setDirection(angle, ballBehavior.speed)
        ballBehavior:release()
        self.launchAngle = ballBehavior.angle
        self.gameState:switchTo("play", { session = self.session })
    end
end

function StartGameState:draw()
    love.graphics.printf("Haz click en la pantalla para lanzar la bola", 0, 250, love.graphics.getWidth(), "center")

    local ballTransform = self.ball and self.ball:getComponent("transform")
    local ballBehavior = self.ball and self.ball:getComponent("ballBehavior")
    if self.ball and ballTransform and ballBehavior and ballBehavior.stuck then
        local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
        local dx = mouseX - ballTransform.x
        local dy = mouseY - ballTransform.y
        local angle = math.atan2(-dy, dx)
        local length = math.min(80, math.max(24, math.sqrt(dx * dx + dy * dy)))
        local endX = ballTransform.x + math.cos(angle) * length
        local endY = ballTransform.y - math.sin(angle) * length

        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.line(ballTransform.x, ballTransform.y, endX, endY)
        love.graphics.circle("fill", endX, endY, 4)
    end
end

return StartGameState
