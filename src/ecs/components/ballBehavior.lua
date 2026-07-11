local BallBehavior = {}
BallBehavior.__index = BallBehavior

function BallBehavior.new(radius, speed)
    return setmetatable({
        name = "ballBehavior",
        radius = radius or 6,
        speed = speed or 300,
        angle = -math.pi / 2,
        stuck = true,
        rotation = 0 
    }, BallBehavior)
end

function BallBehavior:setDirection(angle, speed)
    local velocity = self.entity and self.entity:getComponent("velocity")
    self.angle = angle or self.angle or -math.pi / 2
    self.speed = speed or self.speed or 300

    if velocity then
        velocity.dx = self.speed * math.cos(self.angle)
        velocity.dy = -self.speed * math.sin(self.angle)
    end
end

function BallBehavior:release()
    self.stuck = false
end

function BallBehavior:hit(key)
    local audioPlayer = self.entity and self.entity:getComponent("audioPlayer")
    if audioPlayer then
        if type(audioPlayer.play) == "function" then
            audioPlayer:play(key)
        end
    end
end

function BallBehavior:reset(x, y)
    local transform = self.entity and self.entity:getComponent("transform")
    if transform then
        transform.x = x or transform.x
        transform.y = y or transform.y
    end

    self:setDirection(-math.pi / 2, self.speed)
    self.stuck = true
end

function BallBehavior:reflect(normalX, normalY)
    local velocity = self.entity and self.entity:getComponent("velocity")
    if not velocity then
        return
    end

    local dot = velocity.dx * normalX + velocity.dy * normalY
    velocity.dx = velocity.dx - 2 * dot * normalX
    velocity.dy = velocity.dy - 2 * dot * normalY

    local magnitude = math.sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
    if magnitude > 0 then
        velocity.dx = velocity.dx / magnitude * self.speed
        velocity.dy = velocity.dy / magnitude * self.speed
    end

    self.angle = math.atan2(-velocity.dy, velocity.dx)
end

return BallBehavior
