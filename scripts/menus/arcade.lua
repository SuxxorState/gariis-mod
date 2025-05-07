local utils = (require (getVar("folDir").."scripts.backend.utils")):new()

function onStartCountdown()
    utils:disableHUD({"iconP1", "iconP2", "healthBar", "scoreTxt", "botplayTxt"})
    startMenu()
    return Function_Stop;
end

local canUpdate = true

function startMenu()
    utils:setWindowTitle("Friday Night Funkin': GARII'S ARCADE")
    callOnScripts("initCursor")

    utils:playSound("minigames/arcade/base", 1, "base")
    local xylist = {{0,0}, {834,126}, {0,205}, {353,203}, {0,0}, {379,515}, {0,478}, {1057,0}, {387,-194}}
    for i,spr in ipairs({"backlayer", "treesglow", "icparlorglow", "skobeloffglow", "frontlayer", "bushglow", "exitsignglow", "gariimanorglow", "sinopiatext"}) do
        makeLuaSprite(spr, "minigames/sinopia/"..spr, xylist[i][1], xylist[i][2])
        utils:setObjectCamera(spr, "hud")
        addLuaSprite(spr)
        if (stringEndsWith(spr:lower(), "glow")) then setProperty(spr..".alpha", 0.5) end
        setProperty(spr..".visible", not stringEndsWith(spr:lower(), "glow"))
        utils:playSound("minigames/arcade/"..i, 0, "game"..i)
    end

    runTimer("stinkytween", 0.75)
end

local sprs = {"trees", "icparlor", "skobeloff", "bush", "exitsign", "gariimanor"}
local bounds = {{854,145, 1248,518}, {10,227, 311,489}, {373,225, 791,566}, {400,537, 729,715}, {10,500, 178,699}, {1077,0, 1279,694}}
function onUpdate(elp)
    if (not canUpdate) then return end
    utils:setDiscord("In GARII'S ARCADE", "Sinopia Sanctuary")

    local curSel = 0
    for i,bnd in ipairs(bounds) do --this has a priority system--the further in the list the bounds are, the more they are prioritized, for shit like layering selectable layers on top of each other
        if (utils:mouseWithinBounds(bnd)) then curSel = i end
    end
    if (curSel ~= 0) then callOnLuas("cursorPlayAnim", {"enter"})
        if (getSoundVolume("base") > 0) then setSoundVolume("base", getSoundVolume("base") - (elp*2)) end
    else callOnLuas("cursorPlayAnim")
        if (getSoundVolume("base") < 1) then setSoundVolume("base", getSoundVolume("base") + (elp*2)) end
    end
    for i,spr in ipairs(sprs) do
        setProperty(spr.."glow"..".visible", i == curSel)
        if (i == curSel and getSoundVolume("game"..i) < 1) then setSoundVolume("game"..i, getSoundVolume("game"..i) + (elp*2))
        elseif (getSoundVolume("game"..i) > 0) then setSoundVolume("game"..i, getSoundVolume("game"..i) - (elp*2))
        end
    end

    if (keyJustPressed("back")) then utils:exitToMenu() 
        canUpdate = false
    end
    if (mouseReleased()) then
        canUpdate = false
        callOnLuas("cursorPlayAnim")
        if (curSel == 1) then callOnLuas("placeStickers", {'minigames/fuzzlings', "startMinigame"})
        --elseif (curSel == 2) then 
        elseif (curSel == 3) then callOnLuas("placeStickers", {'minigames/casino', "startMinigame"})
        elseif (curSel == 4) then callOnLuas("placeStickers", {'minigames/minesweeper', "startMinigame"})
        elseif (curSel == 5) then utils:exitToMenu()
        elseif (curSel == 6) then callOnLuas("placeStickers", {'minigames/stag-menu', "startMinigame"})
        else canUpdate = true
        end
        if (not canUpdate) then
            stopSound("base")
            for i=1,6 do stopSound("game"..i) end
        end
    end
end

function backToMinigameHUB() 
    utils:setWindowTitle("Friday Night Funkin': GARII'S ARCADE")
    canUpdate = true 
end

function onSoundFinished(snd)
    if (snd == 'base') then utils:playSound("minigames/arcade/base", 1, "base")
        for i=1,6 do
            utils:playSound("minigames/arcade/"..i, 0, "game"..i)
        end
    end
end

function onTimerCompleted(tmr)
    if (tmr == "stinkytween") then doTweenY("sinopiatextdown", "sinopiatext", 40, 1.5, "backOut") end
end