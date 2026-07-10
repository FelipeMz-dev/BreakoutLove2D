local World = {}
World.__index = World

function World.new()
    local self = setmetatable({}, World)
    self.entities = {}
    self.systems = {}
    self.context = {}
    return self
end

function World:addEntity(entity)
    table.insert(self.entities, entity)
    return entity
end

function World:addSystem(system)
    table.insert(self.systems, system)
    system.world = self
    return system
end

function World:update(dt)
    for _, system in ipairs(self.systems) do
        if type(system.update) == "function" then
            system:update(dt, self)
        end
    end
end

function World:draw()
    for _, system in ipairs(self.systems) do
        if type(system.draw) == "function" then
            system:draw(self)
        end
    end
end

function World:getEntitiesByTag(tag)
    local result = {}
    for _, entity in ipairs(self.entities) do
        if entity:hasTag(tag) then
            table.insert(result, entity)
        end
    end
    return result
end

function World:getEntityByTag(tag)
    for _, entity in ipairs(self.entities) do
        if entity:hasTag(tag) then
            return entity
        end
    end
    return nil
end

function World:removeEntity(entity)
    if not entity then
        return false
    end

    for index = #self.entities, 1, -1 do
        if self.entities[index] == entity then
            table.remove(self.entities, index)
            return true
        end
    end

    return false
end

function World:clear()
    self.entities = {}
end

return World
