local CollisionSystem = {}
CollisionSystem.__index = CollisionSystem

function CollisionSystem.new()
    return setmetatable({}, CollisionSystem)
end

local function getRectAABB(entity)
    return {
        x = entity.x or 0,
        y = entity.y or 0,
        width = entity.width or 0,
        height = entity.height or 0,
    }
end

local function getBallAABB(ball)
    return {
        x = ball.x - ball.radius,
        y = ball.y - ball.radius,
        width = ball.radius * 2,
        height = ball.radius * 2,
    }
end

local function aabbOverlap(aabbA, aabbB)
    return aabbA.x < aabbB.x + aabbB.width
        and aabbA.x + aabbA.width > aabbB.x
        and aabbA.y < aabbB.y + aabbB.height
        and aabbA.y + aabbA.height > aabbB.y
end

function CollisionSystem:resolveBallWithBounds(ball, screenWidth)
    if not ball then
        return false
    end

    local touched = false
    local radius = ball.radius

    if ball.x - radius <= 0 then
        ball.x = radius
        ball:reflect(-1, 0)
        touched = true
    elseif ball.x + radius >= screenWidth then
        ball.x = screenWidth - radius
        ball:reflect(1, 0)
        touched = true
    end

    if ball.y - radius <= 40 then
        ball.y = 40 + radius
        ball:reflect(0, -1)
        touched = true
    end

    return touched
end

function CollisionSystem:resolveBallWithPaddle(ball, paddle)
    if not ball or not paddle then
        return false
    end

    local ballBounds = getBallAABB(ball)
    local paddleBounds = getRectAABB(paddle)
    if not aabbOverlap(ballBounds, paddleBounds) then
        return false
    end

    local overlapX = math.min(ballBounds.x + ballBounds.width, paddleBounds.x + paddleBounds.width) - math.max(ballBounds.x, paddleBounds.x)
    local overlapY = math.min(ballBounds.y + ballBounds.height, paddleBounds.y + paddleBounds.height) - math.max(ballBounds.y, paddleBounds.y)

    if ball.y < paddle.y + paddle.height * 0.5 then
        ball.y = paddle.y - ball.radius - 1

        local relativeImpact = (ball.x - (paddle.x + paddle.width * 0.5)) / (paddle.width * 0.5)
        relativeImpact = math.max(-1, math.min(1, relativeImpact))
        local maxAngle = math.rad(70)
        local launchAngle = math.pi / 2 - relativeImpact * maxAngle
        local plusSpeed = ball.speed + 5

        ball:setDirection(launchAngle, plusSpeed)
        return true
    end

    if overlapX < overlapY then
        local normalX = ball.x < paddle.x + paddle.width * 0.5 and -1 or 1
        ball:reflect(normalX, 0)
        if normalX < 0 then
            ball.x = paddle.x - ball.radius - 1
        else
            ball.x = paddle.x + paddle.width + ball.radius + 1
        end
    else
        local normalY = ball.y < paddle.y + paddle.height * 0.5 and -1 or 1
        ball:reflect(0, normalY)
        if normalY < 0 then
            ball.y = paddle.y - ball.radius - 1
        else
            ball.y = paddle.y + paddle.height + ball.radius + 1
        end
    end

    return true
end

function CollisionSystem:resolveBallWithBrick(ball, brick)
    if not ball or not brick or not brick.active then
        return false
    end

    local ballBounds = getBallAABB(ball)
    local brickBounds = getRectAABB(brick)
    if not aabbOverlap(ballBounds, brickBounds) then
        return false
    end

    local overlapX = math.min(ballBounds.x + ballBounds.width, brickBounds.x + brickBounds.width) - math.max(ballBounds.x, brickBounds.x)
    local overlapY = math.min(ballBounds.y + ballBounds.height, brickBounds.y + brickBounds.height) - math.max(ballBounds.y, brickBounds.y)

    if overlapX < overlapY then
        local normalX = ball.x < brick.x + brick.width * 0.5 and -1 or 1
        ball:reflect(normalX, 0)
        if normalX < 0 then
            ball.x = brick.x - ball.radius - 1
        else
            ball.x = brick.x + brick.width + ball.radius + 1
        end
    else
        local normalY = ball.y < brick.y + brick.height * 0.5 and -1 or 1
        ball:reflect(0, normalY)
        if normalY < 0 then
            ball.y = brick.y - ball.radius - 1
        else
            ball.y = brick.y + brick.height + ball.radius + 1
        end
    end

    local destroyed = brick:takeHit()
    return true, destroyed
end

return CollisionSystem
