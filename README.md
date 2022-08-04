# CC-EventHandler
A Eventhandler that allows you to add Callbacks to CC-Events

### Work in progess
---
The intent is to have one single eventhandler which listens to all CC-Events, outside of complex events like `read()`
You just add your function like this:
`EventHandler:add(<function>function, <any>parameter, <string>eventname, <table|nil>eventdata)`

## Example
```lua
local eHandler = require("lib/EventHandler")

local function runMe(text)
  print(text)
end
eHandler:add(runMe, "I ran", "timer", {1}) -- {1} beeing the timer-ID
```
