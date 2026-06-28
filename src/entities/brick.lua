local Brick = {}
Brick.__index = Brick

function Brick:new(x, y, width, height, resistance, colors)
    local this = {
        x = x or 0,
        y = y or 0,
        width = width or 75,
        height = height or 20,
        active = true,
        resistance = resistance or 1,
        maxResistance = resistance or 1,
        colors = colors or {{0.8, 0.3, 0.3}},
        colorIndex = 1,
    }

    return setmetatable(this, Brick)
end

function Brick:takeHit()
    if not self.active then
        return false
    end

    self.resistance = self.resistance - 1
    if self.resistance <= 0 then
        self.active = false
        return true
    end

    self.colorIndex = math.max(1, math.min(#self.colors, self.colorIndex + 1))
    return false
end

function Brick:draw()
    local color = self.colors and self.colors[self.colorIndex] or {0.8, 0.3, 0.3}
    love.graphics.setColor(color[1], color[2], color[3])
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

return Brick
