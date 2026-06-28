local ProgressionManager = {}
ProgressionManager.__index = ProgressionManager

function ProgressionManager.new()
    local self = setmetatable({}, ProgressionManager)
    self.filename = "save_data.ini"
    self.levels = {}
    self:defaultSettings()
    return self
end

-- Configuración inicial por defecto
function ProgressionManager:defaultSettings()
    self.levels = {
        [1] = true,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,
        [6] = false
    }
end

-- Carga los datos desde el archivo .ini
function ProgressionManager:load()
    -- love.filesystem.getInfo verifica si el archivo existe en la carpeta de guardado de LÖVE
    if not love.filesystem.getInfo(self.filename) then
        -- Si no existe, creamos el archivo con la configuración inicial
        self:save()
        return
    end

    -- Leer el archivo línea por línea de forma limpia
    for line in love.filesystem.lines(self.filename) do
        -- Ignorar secciones tipo [Niveles] o comentarios
        if not line:match("^%[") and line:match("=") then
            local key, value = line:match("([^=]+)=([^=]+)")
            if key and value then
                -- Limpiar espacios en blanco
                key = tonumber(key:match("^%s*(.-)%s*$"))
                value = value:match("^%s*(.-)%s*$")
                
                -- Convertir el string "true"/"false" a booleano real en Lua
                if key then
                    self.levels[key] = (value == "true")
                end
            end
        end
    end
end

-- Guarda el estado actual de la memoria en el archivo .ini
function ProgressionManager:save()
    local content = "[Progreso]\n"
    
    -- Ordenar las llaves para que el archivo .ini quede legible de forma secuencial
    for i = 1, #self.levels do
        content = content .. string.format("%d=%s\n", i, tostring(self.levels[i]))
    end

    -- Escribe de forma segura en el almacenamiento de LÖVE
    local success, message = love.filesystem.write(self.filename, content)
    if not success then
        print("Error al guardar la progresión: " .. tostring(message))
    end
end

-- Método limpio para desbloquear el siguiente nivel (SOLID - Regla de negocio)
function ProgressionManager:unlockLevel(levelId)
    if self.levels[levelId] ~= nil then
        self.levels[levelId] = true
        self:save()
    end
end

-- Método de consulta para el LevelSelectState
function ProgressionManager:isUnlocked(levelId)
    return self.levels[levelId] == true
end

return ProgressionManager