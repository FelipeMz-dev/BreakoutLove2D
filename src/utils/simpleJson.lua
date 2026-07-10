local Json = {}

local function skipWhitespace(text, index)
    while index <= #text and text:sub(index, index):match("%s") do
        index = index + 1
    end
    return index
end

local function parseString(text, index)
    index = skipWhitespace(text, index)
    assert(text:sub(index, index) == '"')
    index = index + 1
    local result = {}

    while index <= #text do
        local char = text:sub(index, index)
        if char == '"' then
            return table.concat(result), index + 1
        elseif char == "\\" then
            index = index + 1
            local escape = text:sub(index, index)
            local escapeMap = {
                ["\""] = '"',
                ["\\"] = "\\",
                ["/"] = "/",
                ["b"] = "\b",
                ["f"] = "\f",
                ["n"] = "\n",
                ["r"] = "\r",
                ["t"] = "\t"
            }

            if escapeMap[escape] then
                table.insert(result, escapeMap[escape])
            elseif escape == "u" then
                local hex = text:sub(index + 1, index + 4)
                if #hex ~= 4 then
                    error("Invalid unicode escape")
                end
                local codepoint = tonumber(hex, 16)
                if codepoint then
                    table.insert(result, utf8.char(codepoint))
                else
                    error("Invalid unicode escape")
                end
                index = index + 4
            else
                error("Invalid escape sequence")
            end
        else
            table.insert(result, char)
        end

        index = index + 1
    end

    error("Unterminated string")
end

local function parseNumber(text, index)
    local start = index
    if text:sub(index, index) == "-" then
        index = index + 1
    end

    while index <= #text and text:sub(index, index):match("%d") do
        index = index + 1
    end

    if index <= #text and text:sub(index, index) == "." then
        index = index + 1
        while index <= #text and text:sub(index, index):match("%d") do
            index = index + 1
        end
    end

    if index <= #text and text:sub(index, index):match("[eE]") then
        index = index + 1
        if index <= #text and text:sub(index, index):match("[+-]") then
            index = index + 1
        end
        while index <= #text and text:sub(index, index):match("%d") do
            index = index + 1
        end
    end

    local numberText = text:sub(start, index - 1)
    return tonumber(numberText), index
end

local function parseValue(text, index)
    index = skipWhitespace(text, index)
    if index > #text then
        error("Unexpected end of input")
    end

    local char = text:sub(index, index)
    if char == "{" then
        return parseObject(text, index)
    elseif char == "[" then
        return parseArray(text, index)
    elseif char == '"' then
        return parseString(text, index)
    elseif char == "t" and text:sub(index, index + 3) == "true" then
        return true, index + 4
    elseif char == "f" and text:sub(index, index + 4) == "false" then
        return false, index + 5
    elseif char == "n" and text:sub(index, index + 3) == "null" then
        return nil, index + 4
    elseif char == "-" or char:match("%d") then
        return parseNumber(text, index)
    end

    error("Unexpected token at position " .. index)
end

function parseObject(text, index)
    assert(text:sub(index, index) == "{")
    local result = {}
    index = index + 1
    index = skipWhitespace(text, index)

    if index <= #text and text:sub(index, index) == "}" then
        return result, index + 1
    end

    while true do
        local key, nextIndex = parseString(text, index)
        index = skipWhitespace(text, nextIndex)
        if text:sub(index, index) ~= ":" then
            error("Expected ':' after object key")
        end
        index = skipWhitespace(text, index + 1)
        local value
        value, index = parseValue(text, index)
        result[key] = value

        index = skipWhitespace(text, index)
        local separator = text:sub(index, index)
        if separator == "," then
            index = index + 1
        elseif separator == "}" then
            return result, index + 1
        else
            error("Expected ',' or '}'")
        end
    end
end

function parseArray(text, index)
    assert(text:sub(index, index) == "[")
    local result = {}
    index = index + 1
    index = skipWhitespace(text, index)

    if index <= #text and text:sub(index, index) == "]" then
        return result, index + 1
    end

    while true do
        local value
        value, index = parseValue(text, index)
        table.insert(result, value)

        index = skipWhitespace(text, index)
        local separator = text:sub(index, index)
        if separator == "," then
            index = index + 1
        elseif separator == "]" then
            return result, index + 1
        else
            error("Expected ',' or ']'")
        end
    end
end

function Json.decode(text)
    if type(text) ~= "string" then
        return nil, "JSON input must be a string"
    end

    text = text:gsub("^%s*\239\187\191", "")

    local ok, result, index = pcall(function()
        local value, nextIndex = parseValue(text, 1)
        nextIndex = skipWhitespace(text, nextIndex)
        if nextIndex <= #text then
            error("Unexpected trailing content")
        end
        return value, nextIndex
    end)

    if not ok then
        return nil, result
    end

    return result
end

return Json
