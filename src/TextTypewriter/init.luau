--!strict

-- Text Typewriter Class


---------- Constants ----------

local Constants = {}

Constants.random = Random.new()

Constants.defaultCharSpeed = 48
Constants.defaultRegex_pauseDelay = {
    ["[%w]%s"] = 0.02,
    ["[%w]$"] = 0.02,

    ["[,]%s"] = 0.1,
    ["[,]$"] = 0.1,

    ["[%.%?!]%s"] = 0.3,
    ["[%.%?!]$"] = 0.3,

    ["%.%.%.%s"] = 0.5,
    ["%.%.%.$"] = 0.5,
} :: {[string]: number?}
do
    local defaultCharSounds = script:WaitForChild("TypingSounds"):GetChildren() :: {Sound}
    Constants.defaultSoundPerCharCallback = function(char: string)
        if string.find(char, "%w") then
            local randomIndex = Constants.random:NextInteger(1, #defaultCharSounds)
            local chosenTemplate = defaultCharSounds[randomIndex]
            local soundClone = chosenTemplate:Clone()
            soundClone.PlayOnRemove = true
            soundClone.Looped = false
            soundClone.Parent = workspace
            soundClone:Destroy()
        end
    end
end
Constants.defaultCustomPerCharCallback = function() end

local function deepFreeze(t: {any}?)
    if type(t) == "table" then
        table.freeze(t)
        for _, v in t do
            deepFreeze(v :: {any}?)
        end
    end
end
deepFreeze(Constants)


---------- Module ----------

local Module = {}
Module.__index = Module


----- Module types -----

type MFieldData = {
    isSkipping: boolean,
    config: {
        charSpeed: number,
        regex_pauseDelay: {[string]: number?},
        soundPerCharCallback: ((char: string) -> ()),
        customPerCharCallback: (() -> ()),
    },
}

export type MObjectType = typeof(setmetatable({} :: MFieldData, Module))


----- Module fields -----

function Module.new(): MObjectType
    local self = setmetatable({} :: MFieldData, Module) :: MObjectType
    self.isSkipping = false
    self.config = {
        charSpeed = Constants.defaultCharSpeed,
        regex_pauseDelay = Constants.defaultRegex_pauseDelay,
        soundPerCharCallback = Constants.defaultSoundPerCharCallback,
        customPerCharCallback = Constants.defaultCustomPerCharCallback,
    }
    return self
end


--- Setters ---

function Module.setIsSkipping(self: MObjectType, isSkipping: boolean)
    self.isSkipping = isSkipping
end

function Module.setCharSpeed(self: MObjectType, charSpeed: number)
    self.config.charSpeed = charSpeed
end

function Module.setRegexPauseDelay(self: MObjectType, regex_pauseDelay: {[string]: number?})
    self.config.regex_pauseDelay = regex_pauseDelay
end

function Module._setSoundPerCharCallback(self: MObjectType, soundPerCharCallback: ((char: string) -> ()))
    self.config.soundPerCharCallback = soundPerCharCallback
end

function Module.setSoundPerChar(self: MObjectType, soundTemplates: {Sound}, playAtCharRegex: string)
    self:_setSoundPerCharCallback(function(char: string)
        if string.find(char, playAtCharRegex) then
            local randomIndex = Constants.random:NextInteger(1, #soundTemplates)
            local chosenTemplate = soundTemplates[randomIndex]
            local soundClone = chosenTemplate:Clone()
            soundClone.PlayOnRemove = true
            soundClone.Looped = false
            soundClone.Parent = workspace
            soundClone:Destroy()
        end
    end)
end

function Module.setCustomPerCharCallback(self: MObjectType, customPerCharCallback: (() -> ()))
    self.config.customPerCharCallback = customPerCharCallback
end


--- Write text ---

function Module.writeText(self: MObjectType, textInstance: Instance, text: string, skippable: boolean)
    if textInstance:IsA("TextBox") or textInstance:IsA("TextButton") or textInstance:IsA("TextLabel") then
        local tempInstance = textInstance :: TextLabel
        tempInstance.Text = ""

        -- Initialize states
        local typedMessage = ""
        local typedCharCount = 0
        local summedPauseDelay = 0
        local messageLength = string.len(text)

        -- Process pauses
        local index_pause = table.create(messageLength, 0)
        for regex, delay in self.config.regex_pauseDelay do
            -- Validate delay
            if not delay or delay == 0 then
                continue
            end

            -- Find pause indices
            local searchIndex = 1
            while true do
                local _, endIndex = string.find(text, regex, searchIndex)
                if endIndex then
                    index_pause[endIndex] = math.max(index_pause[endIndex] or 0, delay)
                    searchIndex = endIndex + 1
                else
                    break
                end
            end
        end

        -- Type text
        local startTime = time()
        while typedCharCount < messageLength do
            -- Check skipped
            if skippable and self.isSkipping then
                break
            end

            -- Type character
            typedCharCount += 1
            local char = string.sub(text, typedCharCount, typedCharCount)
            typedMessage ..= char
            tempInstance.Text = typedMessage
            summedPauseDelay += index_pause[typedCharCount]
            task.defer(self.config.soundPerCharCallback, char)
            task.defer(self.config.customPerCharCallback)

            -- Handle delay
            while typedCharCount / self.config.charSpeed + summedPauseDelay >= (time() - startTime) do
                if skippable and self.isSkipping then
                    break
                end
                task.wait()
            end
        end
        tempInstance.Text = text
    end
end


---------- Return module ----------

table.freeze(Module)
return Module
