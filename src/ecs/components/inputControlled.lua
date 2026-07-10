local InputControlled = {}
InputControlled.__index = InputControlled

function InputControlled.new(speed)
    return setmetatable({
        name = "inputControlled",
        speed = speed or 300
    }, InputControlled)
end

return InputControlled
