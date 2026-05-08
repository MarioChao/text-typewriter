# text-typewriter

Facile module for rendering texts character by character.

Inspired by many other typewriter effects.
- [Scribble](https://github.com/JujuAdams/Scribble)

Usage:
```luau
local textLabel: TextLabel
local text = "Text to write"
local skippable = true
local typewriter = TextTypewriter.new()
typewriter:writeText(textLabel, text, skippable)
-- Call `typewriter:setIsSkipping(true)` from another thread to skip the main text
```
