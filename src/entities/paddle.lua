local AABB = require("src.core.AABB")

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
        aabb = AABB.new(x or 1, y or 1, 80, 16),
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
    self:syncAABB()

    if self.x < 0 then
        self.x = 0
    elseif self.x + self.width > screenWidth then
        self.x = screenWidth - self.width
    end
end

function Paddle:syncAABB()
    self.aabb.x = self.x
    self.aabb.y = self.y
    self.aabb.width = self.width
    self.aabb.height = self.height
end

function Paddle:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Paddle