local AABB = require("src.core.AABB")

local Ball = {}
Ball.__index = Ball

local ballImage

function Ball:new(x, y, radius, speed)
    ballImage = loadImage("assets/sprites/Baseball.png")
    local this = {
        x = x or 0,
        y = y or 0,
        radius = radius or 6,
        speed = speed or 200,
        dx = 0,
        dy = 0,
        angle = -math.pi / 2,
        stuck = true,
        width = ballImage:getWidth(),
        aabb = AABB.new(x or 0, y or 0, (radius or 6) * 2, (radius or 6) * 2)
    }

    return setmetatable(this, Ball)
end

function Ball:setDirection(angle, speed)
    self.angle = angle or self.angle or -math.pi / 2
    self.speed = speed or self.speed or 200
    self.dx = self.speed * math.cos(self.angle)
    self.dy = -self.speed * math.sin(self.angle)
end

function Ball:launchToward(x, y)
    local angle = math.atan2(-(y - self.y), x - self.x)
    self:setDirection(angle, self.speed)
    self:release()
end

function Ball:reset(x, y)
    self.x = x or self.x
    self.y = y or self.y
    self:setDirection(-math.pi / 2, self.speed)
    self.stuck = true
end

function Ball:release()
    self.stuck = false
end

function Ball:update(dt)
    if self.stuck then
        return
    end

    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
    self:syncAABB()
end

function Ball:syncAABB()
    self.aabb.x = self.x - self.radius
    self.aabb.y = self.y - self.radius
    self.aabb.width = self.radius * 2
    self.aabb.height = self.radius * 2
end

function Ball:collidesWith(target)
    if not target or not target.aabb then
        return false
    end

    return self.aabb:overlaps(target.aabb)
end

function Ball:reflect(normalX, normalY)
    local dot = self.dx * normalX + self.dy * normalY
    self.dx = self.dx - 2 * dot * normalX
    self.dy = self.dy - 2 * dot * normalY

    local magnitude = math.sqrt(self.dx * self.dx + self.dy * self.dy)
    if magnitude > 0 then
        self.dx = self.dx / magnitude * self.speed
        self.dy = self.dy / magnitude * self.speed
    end

    self.angle = math.atan2(-self.dy, self.dx)
end

function Ball:draw()
    local scale = self.radius * 2 / self.width
    local origen = self.width / 2

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(ballImage, self.x, self.y, 0, scale, scale, origen, origen)
    --love.graphics.circle("fill", self.x, self.y, self.radius)
end

return Ball
