-- Defintions
---@class stableEvent
---@field eventID number
---@field func function
---@field callback function
---@field referenceTbl table|nil
---@field parameters table|nil
---@field luaEvent table
---@field sendEventItself boolean

---@class Events
---@field [number] stableEvent
---@field currentID number


---@class stableEventHandler
--- Handles all Events the normally get called by os.pullEvent
local stableEventHandler = {
    ---@class Events
    Events = {},
    ---@class Events
    Queue = {},
    listen = true,
    listenToRawEvents = false,
    currentID = 0
}

---comment
---@param handler stableEventHandler
---@return stableEventHandler
local function callEventCallbacks(handler)
    while (handler.listen) do
        coroutine.yield()
        for _, event in pairs(handler.Queue) do
            if event then
                if event.referenceTbl ~= nil then
                    if event.sendEventItself then
                        event.callback(event.referenceTbl, event, event.parameters)
                    else
                        event.callback(event.referenceTbl, event.parameters)
                    end
                else
                    if event.sendEventItself then
                        event.callback(event, event.parameters)
                    else
                        event.callback(event.parameters)
                    end
                end
            end
            event = nil
        end
        handler.Queue = {}
    end
end

---comment
---@param handler stableEventHandler
local function listen(handler)
    local eventTriggerd
    while (handler.listen) do
        if handler.listenToRawEvents then
            eventTriggerd = { os.pullEventRaw() }
        else
            eventTriggerd = { os.pullEvent() }
        end
        for _, event in ipairs(handler.Events) do
            if (event.func(eventTriggerd, event.parameters)) then
                event.luaEvent = eventTriggerd
                table.insert(handler.Queue, event)
            end
        end
    end
end

---adds an Event to be checked for and a Callback to be executed after
---@param checkFunction function checks if the Event is correct. Must return a boolean.
---@param callback function The function to be executed after the Event
---@param referenceTbl table|nil A referenz to an object, to enable "self".
---If not provided, nothing will be provided to the function, not even nil
---@param parameters any parameters will be provided to the Check-Function and the Callback-Function
---@param sendEventItself boolean if true, the Callback-Function will get the stableEvent
--- as the first argument and then the parameters, otherwise just the parameters
---@return stableEvent - access the cc Event by using: stableEvent.luaEvent
function stableEventHandler:addCallback(checkFunction, callback, referenceTbl, parameters, sendEventItself)
    self.currentID = self.currentID + 1
    local event = {
        ["eventID"] = self.currentID,
        ["func"] = checkFunction,
        ["callback"] = callback,
        ["referenceTbl"] = referenceTbl,
        ["parameters"] = parameters,
        ["sendEventItself"] = sendEventItself
    }
    table.insert(self.Events, event)
    return event;
end

---removes an stableEvent from the List
---@param eventID number
function stableEventHandler:removeCallback(eventID)
    for i, value in ipairs(self.Events) do
        if value.eventID == eventID then
            table.remove(self.Events, i)
        end
    end
end

--- Starts the EventListener.
---
--- Can be stoped by <stableEventHandler.listen = false>
---
--- And triggering ANY event eg. <os.queueEvent('Anything')>
---
--- The last step is required as the EventHandler is constantly listening to
--- Events and wont continue its code unless one is triggert
function stableEventHandler:start()
    self.listen = true
    parallel.waitForAll(function() listen(self) end, function() callEventCallbacks(self) end)
end

return stableEventHandler
