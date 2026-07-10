local AudioPlayer = {}
AudioPlayer.__index = AudioPlayer

local function normalizeClip(definition, fallbackKey, fallbackVolume, fallbackLoop)
    if type(definition) == "string" then
        return {
            path = definition,
            key = fallbackKey or definition,
            volume = fallbackVolume or 1,
            loop = fallbackLoop or false,
            sound = nil,
        }
    end

    if type(definition) == "table" then
        return {
            path = definition.path,
            key = definition.key or definition.path,
            volume = definition.volume or fallbackVolume or 1,
            loop = definition.loop ~= nil and definition.loop or (fallbackLoop or false),
            sound = nil,
        }
    end

    return nil
end

function AudioPlayer.new(source, key, volume, loop)
    local clips = {}

    if type(source) == "table" then
        if source.path or source.key then
            local clip = normalizeClip(source, key, volume, loop)
            if clip then
                table.insert(clips, clip)
            end
        elseif #source > 0 then
            for _, entry in ipairs(source) do
                local clip = normalizeClip(entry, key, volume, loop)
                if clip then
                    table.insert(clips, clip)
                end
            end
        else
            local clip = normalizeClip(source, key, volume, loop)
            if clip then
                table.insert(clips, clip)
            end
        end
    else
        local clip = normalizeClip(source, key, volume, loop)
        if clip then
            table.insert(clips, clip)
        end
    end

    local firstClip = clips[1]
    local sound = nil
    if firstClip and firstClip.path and type(loadSound) == "function" then
        sound = loadSound(firstClip.path)
        firstClip.sound = sound
    end

    local self = setmetatable({
        name = "audioPlayer",
        path = firstClip and firstClip.path,
        key = firstClip and firstClip.key,
        sound = sound,
        volume = firstClip and firstClip.volume or 1,
        loop = firstClip and firstClip.loop or false,
        clips = clips,
        lastPlayedKey = nil,
    }, AudioPlayer)

    if self.clips then
        for _, clip in ipairs(self.clips) do
            if clip and clip.path and type(loadSound) == "function" and not clip.sound then
                clip.sound = loadSound(clip.path)
            end
        end
    end

    return self
end

function AudioPlayer:play(keyOrIndex)
    local clip = nil

    if type(keyOrIndex) == "number" and self.clips and self.clips[keyOrIndex] then
        clip = self.clips[keyOrIndex]
    elseif type(keyOrIndex) == "string" then
        for _, candidate in ipairs(self.clips or {}) do
            if candidate.key == keyOrIndex then
                clip = candidate
                break
            end
        end
    elseif self.clips and #self.clips > 1 then
        clip = self.clips[math.random(1, #self.clips)]
    else
        clip = self.clips and self.clips[1]
    end

    if not clip or not clip.sound then
        return false
    end

    self.lastPlayedKey = clip.key
    self.path = clip.path
    self.key = clip.key
    self.sound = clip.sound
    self.volume = clip.volume
    self.loop = clip.loop

    love.audio.play(clip.sound)
    return true
end

function AudioPlayer:stop()
    if self.sound then
        love.audio.stop(self.sound)
    end

    if self.clips then
        for _, clip in ipairs(self.clips) do
            if clip.sound then
                love.audio.stop(clip.sound)
            end
        end
    end
end

return AudioPlayer
