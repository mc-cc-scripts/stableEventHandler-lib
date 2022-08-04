# CC-EventHandler
A Eventhandler that allows you to add Callbacks to CC-Events

### Work in progess
---
The intent is to have one single eventhandler which listens to all CC-Events, outside of complex events like `read()`
You just add your function like this:
`EventHandler:add(<function|thread> param1)`

## Example
```lua
local eHandler = require("lib/CC-EventHandler")

local function timer1()
    local timerID = os.startTimer(3)
    while true do
        event = {os.pullEvent("timer")}
        if event[2] == timerID then
            print("Timer 3")
            --dostuff
            timerID = os.startTimer(3)
        end
    end
end
local function timer2()
    local timerID = os.startTimer(6)
    while true do
        event = {os.pullEvent("timer")}
        if event[2] == timerID then
            print("Timer 6")
            --dostuff
            timerID = os.startTimer(6)
        end
    end
end

local function main()
    eHandler:add(timer1)
    eHandler:add(timer2)
end

eHandler:add(main)
eHandler:start()
```
