
local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
function onCreate()
    addLuaScript("scripts/objects/extraCharacter")
    setProperty("skipCountdown", true)

    callOnLuas("addExtraOpp", {"hunte", "hunte", -310,150})
    setProperty("hunte.visible", false)
end

function onCreatePost()
    if (timeBarType ~= "Disabled") then setProperty("iconTimehunte.x", -150) end
    setProperty("dad.x", getProperty("dad.x") - 100)
    setProperty("spkr2.visible", false)
end


function onStepHit()
    if (curStep == 1 or (curStep % 4 == 0 and curBeat < 5)) then
        callOnScripts("onCountdownTick", {curBeat})
        utils:newCountdown(curBeat)
    end
    if (curStep == 130) or (curStep == 720) then
        setProperty("spkr2.visible", true)
        if (curStep == 130) then triggerEvent("Change Character", "gf", "truckergirl") end
        setProperty("gf.scrollFactor.x", 1)
        setProperty("gf.scrollFactor.y", 1)
        setObjectOrder('gfGroup', getObjectOrder('boyfriendGroup')+1)
        setProperty("gf.flipX", false)
        setProperty("gf.x", 1060 + getProperty("gf.positionArray")[1])
        setProperty("gf.y", 200 + getProperty("gf.positionArray")[2])
    elseif (curStep == 144) then setProperty("hunte.visible", true)
    elseif (curStep == 208) then canIcon = true
    end
end

function onUpdate()
    if canIcon then
        setProperty("iconTimehunte.x", utils:lerp(getProperty("iconTimehunte.x"), 0, 0.1))
        if (getProperty("iconTimehunte.x") > -1) then canIcon = false
            setProperty("iconTimehunte.x", 0)
        end
    end
end

function onTweenCompleted(tag)
    if (stringStartsWith(tag, "count")) then removeLuaSprite(tag, true) end
end

function onEvent(name, value1, value2, strumTime)
    local event = utils:lwrKebab(name)
    local val1 = value1:lower()
    local val2 = value2:lower()

	if (event == "change-character") and (val1 == "gf" or val1 == "girlfriend" or val1 == "1") then
		setProperty("gf.flipX", false)
    elseif (event == "hunte-be-evil") then
    end
end