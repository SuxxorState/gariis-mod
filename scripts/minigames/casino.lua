local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local pfFont = (require (getVar("folDir").."scripts.objects.fontHandler")):new("poker-freak")

local fldr = "minigames/casino/"
local dispChips = 0
local chipLerp = 0
local lastChip = 0
local curOpt = 1
local opts = {"blackjack", "picture-poker"}
local selOpt = ""
local inGame = false
local maxCntr = 1
local destroyed = false
local canRecalculate = true

function startMinigame()
    utils:setWindowTitle("Friday Night Funkin': GARII'S ARCADE: Skobeloff Casino")
    if (utils:getGariiData("pkrChips") == nil) then utils:setGariiData("pkrChips", 100) end --starting allowance
    dispChips = utils:getGariiData("pkrChips")

    utils:makeBlankBG("blankBG", screenWidth,screenHeight, "000000", "hud")

    makeLuaSprite('table',fldr..'bacl',0,0)
    addLuaSprite('table')
    utils:setObjectCamera('table', 'hud')

    makeLuaSprite('chipicon', fldr.."pokerchip",100,18)
    addLuaSprite('chipicon')
    setProperty('chipicon.antialiasing', false)
    scaleObject('chipicon', 2, 2)
    utils:setObjectCamera('chipicon', 'other')
    updateChipCount(0)

    utils:playSound(fldr.."music", 0.5, "casinomusic")

    for i,opt in pairs(opts) do
        makeAnimatedLuaSprite('menu'..opt,fldr.."gamesnobacon",200 + ((i-1) * 300),100)
        addAnimationByPrefix('menu'..opt, 'reg', opt, 24, true)
        addLuaSprite('menu'..opt)
        setProperty('menu'..opt..'.antialiasing', false)
        if (i ~= curOpt) then setProperty('menu'..opt..'.alpha', 0.5) end
        utils:setObjectCamera('menu'..opt, 'other')
    end
    
    pfFont:createNewText("chipNumTxt", 10, 20, " ")
    pfFont:setTextScale("chipNumTxt", 2, 2)
        
    pfFont:createNewText("chipAddTxt", 0, 20, " ")
    pfFont:setTextScale("chipAddTxt", 2, 2)
end

function onUpdatePost()
    if (destroyed == true) then return end

    if (false and keyboardJustPressed("FOUR")) then
        updateChipCount(100)
    end
    if (dispChips ~= chipLerp and canRecalculate) then
        chipLerp = utils:lerp(chipLerp, dispChips, 0.1)
        if (math.floor(chipLerp+0.5) == dispChips) then chipLerp = dispChips end
        updateChipVis()
    end

    if (inGame) then return end

    utils:setDiscord("In GARII'S ARCADE", "SKOBELOFF CASINO")
    local curSel = 0
    for i,bnd in ipairs(opts) do
        if (utils:mouseWithinBounds({200 + ((i-1) * 300),100, 550 + ((i-1) * 300),350})) then curSel = i end
    end
    if (curSel > 0) then callOnLuas("cursorPlayAnim", {"enter"})
    else callOnLuas("cursorPlayAnim")
    end
    for i,spr in ipairs(opts) do
        if (i == curSel) then setProperty('menu'..spr..'.alpha', 1)
        else setProperty('menu'..spr..'.alpha', 0.5) 
        end
    end

    if (mouseReleased() and curSel > 0) then
        callOnLuas("cursorPlayAnim")
        inGame = true
        for i,opt in pairs(opts) do setProperty('menu'..opt..'.visible', false) end 
        selOpt = opts[curSel]
        addLuaScript('scripts/minigames/'..selOpt)
        callOnLuas("startCasinoGame")
    end

    if (keyJustPressed("back")) then runTimer("onDestroy",1)
        destroyed = true
        callOnLuas("placeStickers")
    end 
end

function updateChipCount(amt, delay)
    dispChips = dispChips + amt
    utils:setGariiData("pkrChips", dispChips)
    if (amt < 0) then pfFont:setTextString("chipAddTxt", "-"..math.abs(amt))
    elseif (amt > 0) then pfFont:setTextString("chipAddTxt", "+"..amt)
    end
    if (delay ~= nil and delay > 0) then canRecalculate = false
        runTimer("chipAddTimer", delay)
    end
    if (utils:getGariiData("pkrChips") >= 100000) then
        callOnLuas("unlockAchievement", {"100k-chips"})
    end
end

function updateChipVis()
    if (lastChip ~= math.floor(chipLerp)) then
        lastChip = math.floor(chipLerp)
        stopSound("chip")
        utils:playSound(fldr.."chip"..getRandomInt(1,5), 0.25, "chip")
    end
    local chipstr = utils:numToStr(math.floor(chipLerp))
    if (#chipstr > maxCntr) then maxCntr = #chipstr end

    setProperty("chipicon.x", 25 + ((#chipstr-1) * 30))
    if (math.floor(chipLerp+0.5) == dispChips) then pfFont:setTextString("chipAddTxt", " ")
    elseif (chipLerp > dispChips) then pfFont:setTextString("chipAddTxt", "-"..math.abs(dispChips-math.floor(chipLerp)))
    else pfFont:setTextString("chipAddTxt", "+"..(dispChips-math.floor(chipLerp)))
    end
    pfFont:setTextX("chipAddTxt", 20 + ((#chipstr + 1) * 30))

    pfFont:setTextString("chipNumTxt", ""..math.floor(chipLerp))
end

function chgOpt(inc)
    curOpt = curOpt + inc
    if (curOpt > #opts) then curOpt = 1
    elseif (curOpt < 1) then curOpt = #opts
    end

    for i,opt in pairs(opts) do
        if (i == curOpt) then setProperty('menu'..opt..'.alpha', 1)
        else setProperty('menu'..opt..'.alpha', 0.5) 
        end
    end
end

function seleOpt()
    inGame = true
    for i,opt in pairs(opts) do setProperty('menu'..opt..'.visible', false) end 
    selOpt = opts[curOpt]
    addLuaScript('scripts/minigames/'..selOpt)
    callOnLuas("startCasinoGame")
end

function returnToCasino()
    selOpt = ""
    for i,opt in pairs(opts) do setProperty('menu'..opt..'.visible', true) end 
    inGame = false
end

function onTimerCompleted(tmr)
    if (tmr == "chipAddTimer") then canRecalculate = true 
    elseif (tmr == "onDestroy") then onDestroy()
    end
end

function onSoundFinished(tag)
    if tag == 'casinomusic' then utils:playSound(fldr.."music", 0.5, "casinomusic") end
end

function onDestroy()
    destroyed = true
    stopSound("casinomusic")
    removeLuaSprite("blankBG", true)
    removeLuaSprite("table", true)
    removeLuaSprite("chipicon", true)
    for i,opt in pairs(opts) do removeLuaSprite("menu"..opt, true) end
    pfFont:destroyAll()
    close()
    callOnLuas("backToMinigameHUB")
end