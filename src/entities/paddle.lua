local Paddle = {}
Paddle.__index = Paddle

function Paddle:new(x, y)
    local this = {
        x = x or 1,
        y = y or 1,
        width = 80,
        height = 16,
        dx = 0,
        speed = 300,
    }

    return setmetatable(this, Paddle)
end

function Paddle:setPosition(x, y)
    self.x = x or self.x
    self.y = y or self.y
end

function Paddle:update(dt, screenWidth)
    if love.keyboard.isDown('left') then
        self.dx = -self.speed
    elseif love.keyboard.isDown('right') then
        self.dx = self.speed
    else
        self.dx = 0
    end

    self.x = self.x + self.dx * dt

    if self.x < 0 then
        self.x = 0
    elseif self.x + self.width > screenWidth then
        self.x = screenWidth - self.width
    end
end

function Paddle:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Paddle