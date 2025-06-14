local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local glbX = 0
local glbY = 0
local glbWidth = 0
local glbHeight = 0
local glbAlpha = 1
local glbVis = true
local glbScale = 0.8

local showTimer = 0
local targetY = 0
local targetAlpha = 0

function initLuas()
    setPropertyFromClass("flixel.FlxG", "game.soundTray.silent", true)

    makeLuaSprite("stBG", "soundTray/volumebox")
    setProperty("stBG.scale.x", glbScale)
    setProperty("stBG.scale.y", glbScale)
    updateHitbox("stBG")
    glbWidth = getProperty("stBG.width")
    glbHeight = getProperty("stBG.height")
    utils:setObjectCamera("stBG", "other")
    addLuaSprite("stBG")

    for i=1,10 do
        makeLuaSprite("stBar"..i, "soundTray/bars_"..i)
        setProperty("stBar"..i..".scale.x", glbScale)
        setProperty("stBar"..i..".scale.y", glbScale)
        updateHitbox("stBar"..i)
        utils:setObjectCamera("stBar"..i, "other")
        addLuaSprite("stBar"..i)
    end

    setTrayX((screenWidth - glbWidth) / 2)
    setTrayY(-glbHeight)
end

function onUpdate(elp)
    updateST(elp)
end

--[[function onCustomSubstateCreate()
    removeLuaSprite("stBG", false)
    insertToCustomSubstate('stBG')
    for i=1,10 do
        removeLuaSprite("stBar"..i, false)
        insertToCustomSubstate("stBar"..i)
    end
end]]

function onCustomSubstateUpdate(css, elp)
    updateST(elp)
end

--[[function onCustomSubstateDestroy(tag)
    removeLuaSprite("stBG", false)
    addLuaSprite("stBG")
    for i=1,10 do
        removeLuaSprite("stBar"..i, false)
        addLuaSprite("stBar"..i)
    end
end]]

function updateST(elp)
    setPropertyFromClass("flixel.FlxG", "game.soundTray.visible", false)
    setPropertyFromClass("flixel.FlxG", "game.soundTray.active", false)
    if (getPropertyFromClass("flixel.FlxG", "game.soundTray.y") > -100) then setPropertyFromClass("flixel.FlxG", "game.soundTray.y", -100) end
    setTrayY(funkinLerp(glbY, targetY, 0.1, elp))
    setTrayAlpha(funkinLerp(glbAlpha, targetAlpha, 0.25, elp))

    if showTimer > 0 then
        showTimer = showTimer - (elp / 1)
        targetAlpha = 0.9
    elseif (glbY > -glbHeight) then
        targetY = -glbHeight-10
        targetAlpha = 0
    end
    if (keyReleased("volume_mute") or keyReleased("volume_up") or keyReleased("volume_down")) then
        showST(keyReleased("volume_up"))
    end
end

function showST(presUp)
    targetY = -5
    targetAlpha = 1
    presUp = presUp or false

    bringTrayToFront()
    showTimer = 1
    local glbVolume = math.floor((getPropertyFromClass("flixel.FlxG", "sound.volume")*10)+0.5) --shoutout to that one dude that indirectly showed me a better way of grabbing the volume level
    if (getPropertyFromClass("flixel.FlxG", "sound.muted")) then glbVolume = 0 end
    setTrayY(0)

    for i=1,10 do
        if (i == glbVolume) then setProperty("stBar"..i..".visible", true)
        else setProperty("stBar"..i..".visible", false)
        end
    end

    if true then
        local volSound = "Volup"
        if (not presUp) then volSound = "Voldown"
        elseif (glbVolume >= 10) then volSound = "volMAX" end
        playSound("soundtray/"..volSound)
    end
end

function onDestroy()
    setPropertyFromClass("flixel.FlxG", "game.soundTray.silent", false)
end

function setTrayX(newX)
    glbX = newX
    setProperty("stBG.x", newX)
    for i=1,10 do
        setProperty("stBar"..i..".x", newX + 28)
    end
end

function setTrayY(newY)
    glbY = newY
    setProperty("stBG.y", newY)
    for i=1,10 do
        setProperty("stBar"..i..".y", newY + 25)
    end
end

function setTrayAlpha(newAlp)
    glbAlpha = newAlp
    setProperty("stBG.alpha", newAlp)
    for i=1,10 do
        setProperty("stBar"..i..".alpha", newAlp * 0.9)
    end
end

function bringTrayToFront()
    setObjectOrder("stBG", getProperty("members.length")+1)
    for i=1,10 do
        setObjectOrder("stBar"..i, getProperty("members.length")+1)
    end
end

function funkinLerp(base, target, ratio, elp)
    return base + ((ratio * elp / (1 / 60)) * (target - base))
end