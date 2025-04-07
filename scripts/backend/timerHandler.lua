local Timers = setmetatable({}, {__index = self})
local timerList = {}
local globalElapsed = 0
function Timers:new() return self end --making a custom timer handler bc the one in psych literally only gives you two functions to work with and its kinda buns

function Timers:runTimer(name, duration, loops)
    if (loops == nil) then loops = 1 end
    if (duration == nil) then duration = 1 end
    table.insert(timerList, {name = name, startTime = globalElapsed, duration = duration, loops = loops, paused = false, globalPaused = false})
end

function Timers:onUpdate(elp)
    globalElapsed = globalElapsed + elp
    if (globalElapsed >= 2147483647) then --i dont think this is necessary at all but i like to be thorough
        for _,tmr in pairs(timerList) do tmr.startTime = tmr.startTime - globalElapsed end
        globalElapsed = 0
    end

    for i,tmr in pairs(timerList) do
        if (tmr.paused or tmr.globalPaused) then
            tmr.startTime = tmr.startTime + elp --offsets the start time so resuming the timer acts as if you just started the timer later
        elseif ((globalElapsed - tmr.startTime) % tmr.duration == 0 and globalElapsed ~= tmr.startTime) then
            debugPrint(globalElapsed)
            runTimer(tmr.name, 0.00000001)
            callOnLuas("onTimerCompleted", {tmr.name, tmr.loops, tmr.loops - math.floor((globalElapsed - tmr.startTime)/tmr.duration)})
            if (((globalElapsed - tmr.startTime) / tmr.duration) >= tmr.loops and tmr.loops > 0) then table.remove(timerList, i) end
        end
    end
end

function Timers:pauseTimer(name)
    for _,tmr in pairs(timerList) do
        if (tmr.name == name) then tmr.paused = true end
    end
end

function Timers:pauseAllKnownTimers()
    for _,tmr in pairs(timerList) do tmr.globalPaused = true end --there are two different pauses in case you call a global pause whilst a timer is ALREADY paused; so when you resume it, it doesnt start up when it should be paused
end

function Timers:resumeTimer(name, ignoreGlobalPause)
    if (ignoreGlobalPause == nil) then ignoreGlobalPause = false end --in case you want to override a global pause on a specific timer
    for _,tmr in pairs(timerList) do
        if (tmr.name == name) then tmr.paused = false
            if (ignoreGlobalPause) then tmr.globalPaused = false end
        end
    end
end

function Timers:resumeAllKnownTimers(forceResume)
    if (forceResume == nil) then forceResume = false end --ditto but in reverse
    for _,tmr in pairs(timerList) do tmr.globalPaused = false
        if (forceResume) then tmr.paused = false end
    end
end

function Timers:cancelTimer(name)
    for i,tmr in pairs(timerList) do
        if (tmr.name == name) then
            table.remove(timerList, i)
            break
        end
    end
end

function Timers:cancelAllKnownTimers() timerList = {} end

return Timers