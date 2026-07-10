local BrickBehavior = {}
BrickBehavior.__index = BrickBehavior

function BrickBehavior.new(resistance, colors)
    return setmetatable({
        name = "brickBehavior",
        resistance = resistance or 1,
        maxResistance = resistance or 1,
        colors = colors or { { 0.8, 0.3, 0.3 } },
        colorIndex = #colors or 1,
        active = true
    }, BrickBehavior)
end

function BrickBehavior:takeHit()
    if not self.active then
        return false
    end

    self.resistance = self.resistance - 1
    if self.resistance <= 0 then
        self.active = false
        return true
    end

    self.colorIndex = math.max(1, self.colorIndex - 1)
    return false
end

return BrickBehavior
