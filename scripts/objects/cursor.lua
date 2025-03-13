local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local curIdleState = "idle"

function initCursor()
    setPropertyFromClass("flixel.FlxG", "mouse.visible", false)
    if (luaSpriteExists("gariiCursor")) then return end
    makeAnimatedLuaSprite('gariiCursor',"minigames/cursor",0,0)
    for i,anim in pairs({"idle", "enter", "good", "bad", "clickhold"}) do
        addAnimationByPrefix('gariiCursor', anim, "cursor"..anim, 24, true) 
    end
    addAnimationByPrefix('gariiCursor', "clickstart", "cursorclickstart", 24, false) 
    playAnim("gariiCursor", "idle")
    utils:setObjectCamera('gariiCursor', 'other')
    addLuaSprite('gariiCursor', true)
end

function onUpdatePost()
    if (not luaSpriteExists("gariiCursor")) then return end
    setProperty("gariiCursor.x", getMouseX("other") - 4)
    setProperty("gariiCursor.y", getMouseY("other") - 1)
    setObjectOrder("gariiCursor", getProperty("members.length")) --trolled.

    if (getProperty("gariiCursor.animation.curAnim.name") ~= "idle" and (not stringStartsWith(getProperty("gariiCursor.animation.curAnim.name"), "click"))) then return end
    if (mouseClicked()) then 
        curIdleState = "clickstart"
        cursorPlayAnim("clickstart") 
    end
    if (getProperty("gariiCursor.animation.curAnim.name") == "clickstart" and getProperty("gariiCursor.animation.curAnim.finished")) then
        curIdleState = "clickhold"
        cursorPlayAnim("clickhold")
    end
    if (mouseReleased() and stringStartsWith(getProperty("gariiCursor.animation.curAnim.name"), "click")) then
        curIdleState = "idle"
        cursorPlayAnim()
    end
end

function cursorPlayAnim(anim)
    if (anim == nil) then anim = curIdleState end
    if (getProperty("gariiCursor.animation.curAnim.name") == anim) then return end

    playAnim("gariiCursor", anim)
end

function toggleCursor(visible)
    setProperty("gariiCursor.visible", visible)
end