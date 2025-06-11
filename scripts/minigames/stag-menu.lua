local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local font = (require (getVar("folDir").."scripts.objects.fontHandler")):new("poker-freak")
local fldr, fldrassts = "minigames/stag/", "minigames/stag/foyer/"

local nightSel, nightLerp, lastNightLerp = 1, 0, 0
local lookingAtClock = false
local canUpdate = false

function startMinigame()
    utils:setWindowTitle("Friday Night Funkin': GARII'S ARCADE: Some Time at Garii's")
    if (utils:getGariiData("STaGprog") == nil) then utils:setGariiData("STaGprog", 1) end
    nightSel = math.min(utils:getGariiData("STaGprog"),6)
    font:loadFont("poker-freak")

    utils:makeBlankBG("foyerBlack", screenWidth,screenHeight, "000000", "other")

    makeAnimatedLuaSprite('foyerDoor',fldrassts..'door',0,0)
    addAnimationByPrefix('foyerDoor', "idle", "door", 24, true) 
    addOffset('foyerDoor', "idle", -500,-96)
    for i,anim in pairs({{"gari1", -557,-210}, {"goons", -504,-196}, {"faze", -501,-264}, {"lino", -521,-205}, {"jack", -548,-146}, {"slots", -526,-217}, {"gari2", -545,-209}}) do
        addAnimationByPrefix('foyerDoor', ""..i, anim[1], 24, true) 
        addOffset('foyerDoor', ""..i, anim[2], anim[3])
    end
    playAnim("foyerDoor", "idle")
    utils:setObjectCamera('foyerDoor', 'other')
    addLuaSprite('foyerDoor')

    quickAddSpr("foyerRoom","room", 0,0)
    quickAddSpr("foyerDoorGlow","doorglow", 477,74, false,0.5)
    quickAddSpr("foyerClockGlow","clockglow", 10,35, false,0.5)
    quickAddSpr("foyerPhotosGlow","photosglow", 960,6, false,0.5)
    quickAddSpr("stagTitle","stagtitletext", 270,12, true,0)
    doTweenAlpha("stagTitle", "stagTitle", 1, 0.5, "quadout")
    
    quickAddSpr("clockClose","clockcloseup", 0,0, false)
    quickAddSpr("calendarCross","calendarcross", 710,370, false)
    quickAddSpr("amHand","clockampmhand", 362,438, false)
    quickAddSpr("hourHand","clockhourhand", 352,243, false)
    quickAddSpr("minuteHand","clockminutehand", 350,163, false)

    font:createNewText("quarterTxt", 0, 20, "< Quarter 1 >")
    font:setTextScale("quarterTxt", 3, 3)
    font:setTextCamera("quarterTxt", "other")
    font:setTextVisible("quarterTxt", false)
    font:screenCenter("quarterTxt", "X")

    nightLerp = nightSel*2160
    lastNightLerp = nightLerp
    changeNightSel(0)
    canUpdate = true
end

function quickAddSpr(name, file, daX, daY, sprVisible, sprAlpha)
    if (sprVisible == nil) then sprVisible = true end
    if (sprAlpha == nil) then sprAlpha = 1 end
    makeLuaSprite(name,fldrassts..file,daX,daY)
    utils:setObjectCamera(name, 'other')
    setProperty(name..".visible", sprVisible)
    setProperty(name..".alpha", sprAlpha)
    addLuaSprite(name) --have to set it to true or else 1 singular thing breaks </3
end

function onUpdate()
    if (not canUpdate) then return end
    utils:setDiscord("In GARII'S ARCADE", "Some Time at Garii's")

    if (nightLerp ~= (nightSel*2160)) then
        nightLerp = utils:lerp(nightLerp, (nightSel*2160), 0.025)
        if (math.floor(nightLerp+0.5) == (nightSel*2160)) then nightLerp = (nightSel*2160) end
        updateClockVis()
    end

    if (lookingAtClock) then
        if (keyJustPressed("ui_left")) then changeNightSel(-1)
        elseif (keyJustPressed("ui_right")) then changeNightSel(1)
        elseif (keyJustPressed("back")) then lookAtClock(false)
        end
        if (not mouseClicked()) then return end

        if (utils:mouseWithinBounds({354,29, 383,74}, "other")) then changeNightSel(-1)
        elseif (utils:mouseWithinBounds({900,29, 929, 74}, "other")) then changeNightSel(1)
        end
    else
        local curSel = 0
        for i,bnd in ipairs({{500,96, 763,498}, {29,56, 273,712}}) do
            if (utils:mouseWithinBounds(bnd, "other")) then curSel = i end
        end
        if (curSel ~= 0) then callOnLuas("cursorPlayAnim", {"enter"})
        else callOnLuas("cursorPlayAnim")
        end
        for i,spr in ipairs({"Door", "Clock"}) do
            setProperty("foyer"..spr.."Glow"..".visible", i == curSel)
        end

        if (mouseReleased()) then
            callOnLuas("cursorPlayAnim")
            if (curSel == 1) then openDoor()
            elseif (curSel == 2) then lookAtClock(true)
            end
        end
        
        if (keyJustPressed("back")) then 
            callOnLuas("placeStickers")
            runTimer("destroy", 1)
            canUpdate = false
        end
    end
end

function lookAtClock(looking)
    lookingAtClock = looking
    for i,spr in pairs({"clockClose", "amHand", "hourHand", "minuteHand"}) do
        setProperty(spr..".visible", lookingAtClock)
    end
    font:setTextVisible("quarterTxt", lookingAtClock)
    changeNightSel(0)
end

function changeNightSel(addamt)
    if (math.min(utils:getGariiData("STaGprog"),6) == 1) then return end
    nightSel = nightSel + addamt

    local less, more = "<", ">"
    if (nightSel <= 1) then less = " " 
        nightSel = 1 
    end
    if (nightSel >= math.min(utils:getGariiData("STaGprog"),6)) then more = " "
        nightSel = math.min(utils:getGariiData("STaGprog"),6) 
    end

    font:setTextString("quarterTxt", less.." Quarter "..nightSel.." "..more)
    setProperty("calendarCross.visible", lookingAtClock and nightSel > 4)
    updateClockVis()
end

function updateClockVis()
    if (lastNightLerp ~= math.floor(nightLerp) and math.floor(nightLerp) % 6 == 0 and ((not luaSoundExists("tick")) or getSoundTime("tick") > 50)) then
        lastNightLerp = math.floor(nightLerp)
        utils:playSound(fldr.."tick", 0.25, "tick")
    end
    setProperty("amHand.angle", ((nightLerp)/24)+90)
    setProperty("hourHand.angle", ((nightLerp)/12)-180)
    setProperty("minuteHand.angle", nightLerp)
end

function openDoor()
    canUpdate = false
    setProperty("foyerDoorGlow.visible", false)
    callOnLuas("cursorPlayAnim", {"good"})
    playAnim("foyerDoor", ""..nightSel)
    doTweenAlpha("stagTitle", "stagTitle", 0, 1, "quadin")
    utils:playSound(fldr.."bell", 1)
    runTimer("transStart", 3)
end

function setNight()
    startMinigame()
end

function transToNight()
    destroyMenu(false)
    utils:playSound(fldr.."changecam", 0.75)
    callOnLuas("cursorPlayAnim")
    runTimer("nightStart", 2)

    font:createNewText("curQtrTxt", 0, 20, "Quarter "..nightSel)
    font:setTextCamera("curQtrTxt", "other")
    font:setTextScale("curQtrTxt", 3,3)
    font:screenCenter("curQtrTxt")
    font:setTextY("curQtrTxt", font:getTextY("curQtrTxt") - 100)

    font:createNewText("curTimeTxt", 0, 20, "Current Time: "..calcAMPM(6*(nightSel-1)))
    font:setTextCamera("curTimeTxt", "other")
    font:setTextScale("curTimeTxt", 2,2)
    font:screenCenter("curTimeTxt")
    
    font:createNewText("surviveUntilTxt", 0, 20, "Survive Until Noon")
    font:setTextCamera("surviveUntilTxt", "other")
    font:setTextScale("surviveUntilTxt", 2,2)
    font:screenCenter("surviveUntilTxt")
    font:setTextY("surviveUntilTxt", font:getTextY("surviveUntilTxt") + 100)
    if (nightSel % 4 ~= 2) then quickAddSpr("timeSticky", utils:lwrKebab('survive'..calcAMPM(6*nightSel)), 794,font:getTextY("surviveUntilTxt") - 30) end
    
    addLuaScript('scripts/minigames/stag-gameplay')
    callOnLuas("preloadGame", {nightSel})
        
    font:loadFont("rom-byte")
    font:createNewText("preloadingTxt", 950, 690, "PRELOADING ASSETS...")
    font:setTextCamera("preloadingTxt", "other")
    font:setTextScale("preloadingTxt", 2,2)
end

function onTimerCompleted(tag)
    if (tag == "transStart") then transToNight()
    elseif (tag == "nightStart") then 
        destroyMenu(true)
        callOnLuas("activateFNAF")
    elseif (tag == "destroy") then             
        callOnLuas("backToMinigameHUB")
        destroyMenu()
        removeLuaScript('scripts/minigames/stag-gameplay')
        close()
    end
end

function calcAMPM(uncutTime)
    local suffix = "AM"
    local cutTime = uncutTime % 12
    if (cutTime == 0) then cutTime = 12 end
    if (uncutTime % 24) >= 12 then suffix = "PM" end

    return cutTime.." "..suffix
end

function destroyMenu(destroyBlackBG)
    if (destroyBlackBG == nil) then destroyBlackBG = true end
    canUpdate = false

    if (destroyBlackBG) then removeLuaSprite("foyerBlack", true) end
    for i,spr in pairs({"foyerDoor", "foyerRoom", "foyerDoorGlow", "foyerClockGlow", "foyerPhotosGlow", "stagTitle", "clockClose", "calendarCross", "amHand", "minuteHand", "hourHand", "timeSticky"}) do
        removeLuaSprite(spr, true)
    end
    font:destroyAll()
end