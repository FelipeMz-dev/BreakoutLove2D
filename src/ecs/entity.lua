local Entity = {}
Entity.__index = Entity
Entity._counter = 0

function Entity.new(name)
    Entity._counter = (Entity._counter or 0) + 1
    local self = setmetatable({}, Entity)
    self.id = (name or "entity") .. "_" .. tostring(Entity._counter)
    self.name = name or "entity"
    self.components = {}
    self.tags = {}
    return self
end

function Entity:addComponent(component)
    assert(component and type(component) == "table", "component must be a table")
    local name = component.name or component.type
    assert(name, "component needs a name")
    self.components[name] = component
    component.entity = self
    return component
end

function Entity:getComponent(name)
    return self.components[name]
end

function Entity:hasComponent(name)
    return self.components[name] ~= nil
end

function Entity:addTag(tag)
    self.tags[tag] = true
    return self
end

function Entity:hasTag(tag)
    return self.tags[tag] == true
end

function Entity:removeComponent(name)
    self.components[name] = nil
end

return Entity
