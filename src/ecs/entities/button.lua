local Button = {}
Button.__index = Button

function Button:new(text, x, y, width, height)
    local item = setmetatable({}, self)
    item.text = text or ""
    item.x = x or 0
    item.y = y or 0
    item.width = width or 90
    item.height = height or 30
    item.hovered = false
    item.onActivate = function() end
    return item
end

function Button:setAction(fn)
    if type(fn) == "function" then
        self.onActivate = fn
    end
end

function Button:isHovered(mx, my)
    return mx >= self.x and mx <= self.x + self.width
       and my >= self.y and my <= self.y + self.height
end

function Button:mousePressed(mx, my, button)
    if button == 1 and self:isHovered(mx, my) then
        self.onActivate()
    end
end

function Button:render()
    love.graphics.setFont(love.graphics.newFont(14))
    local font = love.graphics.getFont()
    local textW = font:getWidth(self.text)
    local textH = font:getHeight(self.text)

    if self.hovered then
        love.graphics.setColor(0.2, 0.7, 0.3)
    else
        love.graphics.setColor(0.2, 0.6, 0.9)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 6, 6)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.text, self.x, self.y + (self.height - textH) * 0.5, self.width, "center")
end

return Button