local State = require("src.states.state")
local StartGameState = setmetatable({}, { __index = State })
StartGameState.__index = StartGameState

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
end

function StartGameState:update(dt)
    if love.keyboard.isDown("return") and self.ball then
        self.ball:setDirection(self.launchAngle, self.ball.speed)
        self.ball:release()
        self.gameState:switchTo("play", { session = self.session })
    end
end

function StartGameState:mousemoved(mx, my)
    if not self.ball or not self.ball.stuck then
        return
    end

    local dx = mx - self.ball.x
    local dy = my - self.ball.y
    self.launchAngle = math.atan2(-dy, dx)
end

function StartGameState:mousepressed(x, y, button)
    if button ~= 1 or not self.ball then
        return
    end

    if self.ball.stuck then
        self.ball:launchToward(x, y)
        self.launchAngle = self.ball.angle
        self.gameState:switchTo("play", { session = self.session })
    end
end

function StartGameState:draw()
    love.graphics.printf("Haz click en la pantalla para lanzar la bola", 0, 250, love.graphics.getWidth(), "center")

    if self.ball and self.ball.stuck then
        local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
        local dx = mouseX - self.ball.x
        local dy = mouseY - self.ball.y
        local angle = math.atan2(-dy, dx)
        local length = math.min(80, math.max(24, math.sqrt(dx * dx + dy * dy)))
        local endX = self.ball.x + math.cos(angle) * length
        local endY = self.ball.y - math.sin(angle) * length

        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.line(self.ball.x, self.ball.y, endX, endY)
        love.graphics.circle("fill", endX, endY, 4)
    end
end

return StartGameState
