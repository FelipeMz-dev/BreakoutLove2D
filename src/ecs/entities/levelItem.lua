local LevelItem = {}
LevelItem.__index = LevelItem

local SQUARE_SIZE = 64
local HOVER_PULSE_SPEED = 6
local HOVER_PULSE_AMOUNT = 0.08

function LevelItem:new(number, x, y, locked)
    local item = setmetatable({}, self)
    item.number = number or 1
    item.locked = locked == true
    item.x = x or 0
    item.y = y or 0
    item.width = SQUARE_SIZE
    item.height = SQUARE_SIZE
    item.hovered = false
    item.hoverTimer = 0
    item.onActivate = function() end
    return item
end

function LevelItem:setAction(fn)
    if type(fn) == "function" then
        self.onActivate = fn
    end
end

function LevelItem:update(dt)
    if self.hovered then
        self.hoverTimer = self.hoverTimer + dt
    else
        self.hoverTimer = 0
    end
end

function LevelItem:isHovered(mx, my)
    return mx >= self.x and mx <= self.x + self.width
       and my >= self.y and my <= self.y + self.height
end

function LevelItem:handleMouseMoved(mx, my)
    self.hovered = self:isHovered(mx, my)
end

function LevelItem:mousePressed(mx, my, button)
    if button == 1 and self:isHovered(mx, my) and not self.locked then
        self.onActivate()
    end
end

function LevelItem:render()
    local pulse = 1
    if self.hovered then
        pulse = 1 + math.sin(self.hoverTimer * HOVER_PULSE_SPEED) * HOVER_PULSE_AMOUNT
    end

    local halfW = self.width * 0.5
    local halfH = self.height * 0.5
    local cx = self.x + halfW
    local cy = self.y + halfH

    love.graphics.push()
    love.graphics.translate(cx, cy)
    love.graphics.scale(pulse, pulse)
    love.graphics.translate(-cx, -cy)

    if self.locked then
        love.graphics.setColor(0.35, 0.35, 0.4)
    else
        love.graphics.setColor(0.2, 0.6, 0.9)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 8, 8)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 8, 8)
    love.graphics.setFont(love.graphics.newFont(20))

    local text = tostring(self.number)
    local font = love.graphics.getFont()
    local textW = font:getWidth(text)
    local textH = font:getHeight()
    love.graphics.print(text, self.x + (self.width - textW) * 0.5, self.y + (self.height - textH) * 0.5)
    love.graphics.setFont(love.graphics.newFont(12))

    if self.locked then
        local lockText = "LOCKED"
        local lockW = font:getWidth(lockText)
        local lockH = font:getHeight(lockText)
        love.graphics.print(lockText, self.x + (lockW - self.width) * 0.5, self.y + self.height - textH + 4)
    end

    love.graphics.pop()
end

return LevelItem
