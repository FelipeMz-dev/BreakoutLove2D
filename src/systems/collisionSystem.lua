local CollisionSystem = {}
CollisionSystem.__index = CollisionSystem

function CollisionSystem.new()
    return setmetatable({}, CollisionSystem)
end

local function rectToCircleCollision(ball, target)
    local closestX = math.max(target.x, math.min(ball.x, target.x + target.width))
    local closestY = math.max(target.y, math.min(ball.y, target.y + target.height))
    local dx = ball.x - closestX
    local dy = ball.y - closestY
    return (dx * dx + dy * dy) <= (ball.radius * ball.radius), dx, dy
end

function CollisionSystem:resolveBallWithPaddle(ball, paddle)
    if not ball or not paddle then
        return false
    end

    local hit = rectToCircleCollision(ball, paddle)
    if not hit then
        return false
    end

    ball.y = paddle.y - ball.radius -1

    local relativeImpact = (ball.x - (paddle.x + paddle.width * 0.5)) / (paddle.width * 0.5)
    relativeImpact = math.max(-1, math.min(1, relativeImpact))
    local maxAngle = math.rad(70)
    local launchAngle = math.pi / 2 - relativeImpact * maxAngle

    local plusSpeed = ball.speed + 5

    ball:setDirection(launchAngle, ball.speed)
    return true
end

function CollisionSystem:resolveBallWithBrick(ball, brick)
    if not ball or not brick or not brick.active then
        return false
    end

    local hit, dx, dy = rectToCircleCollision(ball, brick)
    if not hit then
        return false
    end

    if math.abs(dx) > math.abs(dy) then
        local normalX = dx > 0 and 1 or -1
        ball:reflect(normalX, 0)
    else
        local normalY = dy > 0 and 1 or -1
        ball:reflect(0, normalY)
    end

    local destroyed = brick:takeHit()
    return true, destroyed
end

return CollisionSystem
