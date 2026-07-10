local Json = require("src.utils.simpleJson")

local LevelLoader = {}
LevelLoader.__index = LevelLoader

function LevelLoader.new()
    local self = setmetatable({}, LevelLoader)
    self.levels = {}
    return self
end

function LevelLoader:loadAll()
    self.levels = {}
    
    local items = love.filesystem.getDirectoryItems("levels")
    if not items then
        print("[LevelLoader] Carpeta 'levels' no encontrada o no accesible.")
        return
    end

    if type(items) == "table" and #items > 0 then
        print("[LevelLoader] Directorio 'levels' contiene: " .. table.concat(items, ", "))
    else
        print("[LevelLoader] Carpeta 'levels' está vacía.")
    end

    for _, filename in ipairs(items) do
        if filename:sub(-5) == ".json" then
            local path = "levels/" .. filename
            local text, readErr = love.filesystem.read(path)
            if not text then
                print("[LevelLoader] Error leyendo archivo: " .. path .. ": " .. tostring(readErr))
            else
                local data, err = Json.decode(text)
                if not data then
                    print("[LevelLoader] Error cargando nivel: " .. path .. ": " .. tostring(err))
                elseif type(data) == "table" then
                    table.insert(self.levels, data)
                    print("[LevelLoader] Nivel cargado: " .. tostring(data.id) .. " - " .. tostring(data.name))
                end
            end
        end
    end

    table.sort(self.levels, function(a, b)
        return (a.id or 0) < (b.id or 0)
    end)
    print("[LevelLoader] Total de niveles cargados: " .. tostring(#self.levels))
end

function LevelLoader:getLevels()
    return self.levels
end

function LevelLoader:getLevel(levelId)
    for _, level in ipairs(self.levels) do
        if level.id == levelId then
            return level
        end
    end
    return nil
end

function LevelLoader:createBricks(levelConfig)
    if not levelConfig then
        error("LevelLoader:createBricks received nil levelConfig")
    end

    local bricks = {}
    local rows = levelConfig.rows or 5
    local columns = levelConfig.columns or 10
    local brickWidth = levelConfig.brickWidth or 75
    local brickHeight = levelConfig.brickHeight or 20
    local padding = levelConfig.padding or 5
    local offsetX = levelConfig.offsetX or 40
    local offsetY = levelConfig.offsetY or 40
    local colors = levelConfig.colors or {{0.8, 0.3, 0.3}}
    local rowResistances = levelConfig.rowResistances or {}

    for row = 1, rows do
        local resistance = rowResistances[row] or 1
        local rowColors = {}
        for i = 1, resistance do
            table.insert(rowColors, colors[((i - 1) % #colors) + 1])
        end

        for col = 1, columns do
            local x = offsetX + (col - 1) * (brickWidth + padding)
            local y = offsetY + (row - 1) * (brickHeight + padding)
            local brick = {
                x = x,
                y = y,
                width = brickWidth,
                height = brickHeight,
                resistance = resistance,
                colors = rowColors,
                color = rowColors[1]
            }
            table.insert(bricks, brick)
        end
    end

    return bricks
end

return LevelLoader
