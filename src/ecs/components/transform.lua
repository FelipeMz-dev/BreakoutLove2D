local Transform = {}
Transform.__index = Transform

function Transform.new(x, y, width, height)
    return setmetatable({
        name = "transform",
        x = x or 0,
        y = y or 0,
        width = width or 0,
        height = height or 0,
        angle = 0
    }, Transform)
end

return Transform
