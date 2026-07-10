local Renderable = {}
Renderable.__index = Renderable

function Renderable.new(path, color, kind)
    local image = nil
    if path and type(loadImage) == "function" then
        image = loadImage(path)
    end

    return setmetatable({
        name = "renderable",
        kind = kind or "sprite",
        path = path,
        image = image,
        color = color or { 1, 1, 1 },
        scaleX = 1,
        scaleY = 1,
        originX = 0,
        originY = 0
    }, Renderable)
end

return Renderable
