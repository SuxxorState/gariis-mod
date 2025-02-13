local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local pfFont = (require (getVar("folDir").."scripts.objects.fontHandler")):new("poker-freak")
local fldr = "minigames/casino/"

local cardvals = {"scubySnpi", "greasNene", "greasDrnl", "greasPico", "truckGirl", "truckBoy"}
local evalDecode = {["0oak"] = "Junk", ["2oak"] = "One Pair", ["tp"] = "Two Pairs", ["3oak"] = "Three of a Kind", ["fh"] = "Full House", ["4oak"] = "Four of a Kind", ["5oak"] = "Five of a Kind"}
local dlrHand = {}
local plrHand = {}
local dlrOpts = {false, false, false, false, false}
local opts = {false, false, false, false, false}
local curChoice = 1
local canChoose = false
local endChoose = false
local wgrChoose = false
local wager = 5
local holdTime = 0
local shiftMult = 1
local dlrCheatLvl = 0
local arrsine = 0
local verdict = ""
local dlrVdct = ""
local plrVdct = ""

function startCasinoGame()
    for i=1,5 do
        makeAnimatedLuaSprite('dlrcard'..i,fldr.."programmer-dark",screenWidth - ((i+2) * 75) + 10,-150)
        addAnimationByPrefix('dlrcard'..i, 'back', "cardback", 24, true)
        for j=1,6 do addAnimationByPrefix('dlrcard'..i, ''..j, cardvals[j].."Reg", 24, true) end
        playAnim('dlrcard'..i, "back")
        addLuaSprite('dlrcard'..i, true)
        setProperty('dlrcard'..i..'.antialiasing', false)
        setObjectCamera('dlrcard'..i, 'other')

        makeAnimatedLuaSprite('plrcard'..i,fldr.."programmer-dark",50 + (i * 75),720)
        addAnimationByPrefix('plrcard'..i, 'back', "cardback", 24, true)
        for j=1,6 do addAnimationByPrefix('plrcard'..i, ''..j, cardvals[j].."Reg", 24, true) end
        playAnim('plrcard'..i, "back")
        addLuaSprite('plrcard'..i, true)
        setProperty('plrcard'..i..'.antialiasing', false)
        setObjectCamera('plrcard'..i, 'other')
    end

    pfFont:createNewText("dlrTxt", 0, -150, " ")
    pfFont:setTextScale("dlrTxt", 2, 2)
        
    pfFont:createNewText("plrTxt", 0, 720, " ")
    pfFont:setTextScale("plrTxt", 2, 2)
    
    makeLuaSprite('hiearchy',fldr.."hiearchy",0,400)
    addLuaSprite('hiearchy', true)
    setProperty('hiearchy.antialiasing', false)
    setObjectCamera('hiearchy', 'other')

    makeLuaSprite('arrow',fldr.."arrow",0,530)
    addLuaSprite('arrow', true)
    setProperty('arrow.antialiasing', false)
    setProperty('arrow.visible', false)
    setObjectCamera('arrow', 'other')
    
    pfFont:createNewText("wgrTxt", 0, -150, " ")
    pfFont:setTextScale("wgrTxt", 3, 3)
        
    pfFont:createNewText("wgrAmtTxt", 0, -150, " ")
    pfFont:setTextScale("wgrAmtTxt", 3, 3)

    pfFont:createNewText("vdctTxt", 0, -150, " ")
    pfFont:setTextScale("vdctTxt", 3, 3)

    runTimer("ppStart", 0.25)
end

function chooseWager()
    cancelTimer("ppStart") --for when the player skips during an ending
    if (utils:getGariiData("pkrChips") < 5) then onDestroy()
    elseif (utils:getGariiData("pkrChips") > 999999999) then dlrCheatLvl = 4 --fuck you simulator
    elseif (utils:getGariiData("pkrChips") > 99999999) then dlrCheatLvl = 3
    elseif (utils:getGariiData("pkrChips") > 9999999) then dlrCheatLvl = 2
    elseif (utils:getGariiData("pkrChips") > 999999) then dlrCheatLvl = 1
    end   
    
    endChoose = false
    wgrChoose = true
    pfFont:setTextString("vdctTxt", " ")
    updateWager(0)
end

function newRound()
    wgrChoose = false
    pfFont:setTextString("wgrTxt", " ")
    pfFont:setTextString("wgrAmtTxt", " ")
    for i=1,5 do playAnim('dlrcard'..i, "back") end
    dlrHand = {}
    plrHand = {}
    for i=1,5 do
        table.insert(dlrHand, getRandomInt(1+dlrCheatLvl,6))
        table.insert(plrHand, getRandomInt(1,6))
        playAnim('plrcard'..i, ""..plrHand[i])
        doTweenY("plrcard"..i, "plrcard"..i, 600, 0.25)
        doTweenY("dlrcard"..i, "dlrcard"..i, -20, 0.25)
    end

    allowCardSwap()
    changeChoice(0)
end

function allowCardSwap()
    opts = {false, false, false, false, false}
    setProperty('arrow.visible', true)
    canChoose = true
end

function onUpdatePost(elp)
    if (luaSpriteExists("arrow") and getProperty('arrow.visible')) then
        arrsine = arrsine + (180 * (elp/2))
        if (arrsine >= 360) then arrsine = 0 end --overflow prevention
        setProperty('arrow.y', 530 + math.floor(math.sin((math.pi * arrsine) / 180) * 10))
    end
    if (canChoose) then
        if (keyJustPressed("accept")) then swapCards()
        elseif (keyJustPressed("ui_left")) then changeChoice(-1)
        elseif (keyJustPressed("ui_right")) then changeChoice(1)
        elseif (keyJustPressed("ui_down")) then selectCard()
        end 
    elseif (endChoose) then
        if (keyJustPressed("accept")) then chooseWager()
        elseif (keyJustPressed("back")) then onDestroy()
        end 
    elseif (wgrChoose) then
        if (keyJustPressed("accept")) then newRound()
            callOnLuas("updateChipCount", {-wager})
        elseif (keyJustPressed("back")) then onDestroy()
        end 
        if (keyboardPressed("SHIFT")) then shiftMult = 10
        else shiftMult = 1
        end

        if (keyJustPressed("ui_left")) then updateWager(-shiftMult) 
            holdTime = 0
        end
        if (keyJustPressed("ui_right")) then updateWager(shiftMult) 
            holdTime = 0
        end
        if (keyPressed("ui_left") or keyPressed("ui_right")) then
            local lastHold = math.floor((holdTime - 0.5) * 10)
            holdTime = holdTime + elp
            local newHold = math.floor((holdTime - 0.5) * 10)

            if (newHold - lastHold > 0) then 
                if (holdTime > 10) then
                    if (keyPressed("ui_left")) then updateWager(((newHold - lastHold) * -shiftMult) * 10) 
                    else updateWager(((newHold - lastHold) * shiftMult) * 10) 
                    end
                elseif (holdTime > 0.5) then
                    if (keyPressed("ui_left")) then updateWager((newHold - lastHold) * -shiftMult) 
                    else updateWager((newHold - lastHold) * shiftMult) 
                    end
                end
            end
        end
    end
end

function updateWager(inc)
    local leftIndi = "<"
    local rightIndi = ">"
    local maxChips = utils:getGariiData("pkrChips")
    wager = wager + inc
    if (wager >= math.min(maxChips, 100)) then wager = math.min(maxChips, 100)
        rightIndi = " "
    elseif (wager <= 5) then wager = 5
        leftIndi = " "
    end
    wager = math.max(wager, 0)

    pfFont:setTextString("wgrTxt", "Current Wager:")
    pfFont:screenCenter("wgrTxt")
    pfFont:setTextY("wgrTxt", 300)
    
    pfFont:setTextString("wgrAmtTxt", leftIndi.." "..wager.." "..rightIndi)
    pfFont:screenCenter("wgrAmtTxt")
    pfFont:setTextY("wgrAmtTxt", 400)
end

function selectCard()
    opts[curChoice] = not opts[curChoice]
    cancelTween("plrcard"..curChoice)
    if (opts[curChoice]) then doTweenY("plrcard"..curChoice, "plrcard"..curChoice, 580, 0.075, "quadOut")
    else doTweenY("plrcard"..curChoice, "plrcard"..curChoice, 600, 0.075, "quadOut")
    end
end

function changeChoice(inc)
    curChoice = curChoice + inc
    if (curChoice > #opts) then curChoice = 1
    elseif (curChoice < 1) then curChoice = #opts
    end
    setProperty("arrow.x", getProperty("plrcard"..curChoice..".x") + ((getProperty("plrcard"..curChoice..".frameWidth") - getProperty("arrow.width"))/2))
end

function swapCards()
    canChoose = false
    setProperty('arrow.visible', false)
    local hold = true
    for i=1,5 do
        if (opts[i]) then 
            hold = false
            plrHand[i] = getRandomInt(1,6)
            doTweenY("plrcard"..i, "plrcard"..i, 720, 0.25)
        end
    end
    if (hold) then runTimer("dlrTurn", 0.5)
    else runTimer("dumboStinky", 0.75)
    end
end

function dealerAI()
    local rarity = {0,0,0,0,0,0}
    local curBest = 1

    for _,i in pairs(dlrHand) do rarity[i] = rarity[i] + 1 end

    for i=1,5 do dlrOpts[i] = (rarity[dlrHand[i]] < 2) end

    local hold = true
    for i=1,5 do
        if (dlrOpts[i]) then 
            hold = false
            dlrHand[i] = getRandomInt(1+dlrCheatLvl,6)
            doTweenY("dlrcard"..i, "dlrcard"..i, -150, 0.25)
        end
    end

    if (hold) then runTimer("tally", 0.5)
    else runTimer("dealerpull", 0.75)
    end
end

function tallyScores()
    for i=1,5 do playAnim('dlrcard'..i, ""..dlrHand[i]) end

    local dlrRarity = {0,0,0,0,0,0} --first tallies up all the cards into their seperate groups
    local plrRarity = {0,0,0,0,0,0}
    for _,i in pairs(dlrHand) do dlrRarity[i] = dlrRarity[i] + 1 end
    for _,i in pairs(plrHand) do plrRarity[i] = plrRarity[i] + 1 end

    local dlrEval = {0, 0} --then grabs every *prominent* set/group of cards
    local plrEval = {0, 0}

    for i,j in pairs(dlrRarity) do 
        if (j > 1) then 
            if (dlrEval[1] ~= 0) then 
                if (j > dlrEval[1]) then
                    local temp = dlrEval
                    dlrEval = {j,i}
                    table.insert(dlrEval, temp[1])
                    table.insert(dlrEval, temp[2])
                else
                    table.insert(dlrEval, j)
                    table.insert(dlrEval, i)
                end
            else dlrEval = {j,i} 
            end
        end
    end

    for i,j in pairs(plrRarity) do 
        if (j > 1) then 
            if (plrEval[1] ~= 0) then 
                if (j > plrEval[1]) then
                    local temp = plrEval
                    plrEval = {j,i}
                    table.insert(plrEval, temp[1])
                    table.insert(plrEval, temp[2])
                else
                    table.insert(plrEval, j)
                    table.insert(plrEval, i)
                end
            else plrEval = {j,i} 
            end
        end
    end

    --then compares the twos stats
    if (#dlrEval > 2 or #plrEval > 2) then --two pair && full house edge cases
        if (#dlrEval <= 2) then --pretty easy to determine from here; just gotta see who's better than who since its impossible that their hands are the same
            dlrVdct = dlrEval[1].."oak"
            if (plrEval[1] == 3 and plrEval[3] == 2) then
                plrVdct = "fh"
                if (dlrEval[1] >= 4) then verdict = "l"
                else verdict = "w"
                end
            else
                plrVdct = "tp"
                if (dlrEval[1] >= 3) then verdict = "l"
                else verdict = "w"
                end
            end
        elseif (#plrEval <= 2) then
            plrVdct = plrEval[1].."oak"
            if (dlrEval[1] == 3 and dlrEval[3] == 2) then
                dlrVdct = "fh"
                if (plrEval[1] >= 4) then verdict = "w"
                else verdict = "l"
                end
            else
                dlrVdct = "tp"
                if (plrEval[1] >= 3) then verdict = "w"
                else verdict = "l"
                end
            end
        else --this is where it becomes fucked- first check what the dealer has
            if (dlrEval[1] == 3 and dlrEval[3] == 2) then
                dlrVdct = "fh"
                if (plrEval[1] == 3 and plrEval[3] == 2) then --then check what the player has, to give an easy l or w
                    plrVdct = "fh"
                    if (dlrEval[2] > plrEval[2]) then verdict = "l"
                    elseif (dlrEval[2] < plrEval[2]) then verdict = "w"
                    else
                        if (dlrEval[4] > plrEval[4]) then verdict = "l"
                        elseif (dlrEval[4] < plrEval[4]) then verdict = "w"
                        else verdict = "d" --if you somehow get a draw from THIS id be honestly impressed
                        end
                    end
                else plrVdct = "tp"
                    verdict = "l"
                end
            else
                dlrVdct = "tp"
                if (plrEval[1] == 3 and plrEval[3] == 2) then verdict = "w"
                    plrVdct = "fh"
                else 
                    plrVdct = "tp"
                    if (dlrEval[2] > plrEval[2]) then verdict = "l"
                    elseif (dlrEval[2] < plrEval[2]) then verdict = "w"
                    else
                        if (dlrEval[4] > plrEval[4]) then verdict = "l"
                        elseif (dlrEval[4] < plrEval[4]) then verdict = "w"
                        else verdict = "d"
                        end
                    end
                end
            end
        end
    else --default eval
        dlrVdct = dlrEval[1].."oak"
        plrVdct = plrEval[1].."oak"
        if (dlrEval[1] > plrEval[1]) then verdict = "l"
        elseif (dlrEval[1] < plrEval[1]) then verdict = "w"
        else
            if (dlrEval[2] > plrEval[2]) then verdict = "l"
            elseif (dlrEval[2] < plrEval[2]) then verdict = "w"
            else verdict = "d"
            end
        end
    end
    if (#plrEval <= 2 and plrEval[1] == 5 and plrEval[2] == 6) then
        callOnLuas("unlockAchievement", {"tb-foak"})
    end

    runTimer("whowon", 0.75)
    
    pfFont:setTextString("dlrTxt", evalDecode[dlrVdct])
    pfFont:setTextString("plrTxt", evalDecode[plrVdct])
    pfFont:screenCenter("dlrTxt", "x")
    pfFont:screenCenter("plrTxt", "x")
    pfFont:setTextX("dlrTxt", pfFont:getTextX("dlrTxt") + 325)
    pfFont:setTextX("plrTxt", pfFont:getTextX("plrTxt") - 315)
    pfFont:tweenTextY("dlrTxt", 155, 0.5)
    pfFont:tweenTextY("plrTxt", 520, 0.5)
end

function finalThing(vdct)
    if (vdct == "d") then
        callOnLuas("updateChipCount", {wager, 1})
        pfFont:setTextString("vdctTxt", "Draw")
        pfFont:setTextColour("vdctTxt", "f4f3ad")
    elseif (vdct == "l") then 
        pfFont:setTextString("vdctTxt", "Too Bad...")
        pfFont:setTextColour("vdctTxt", "c55252")
    elseif (vdct == "w") then
        pfFont:setTextString("vdctTxt", "You Win")
        pfFont:setTextColour("vdctTxt", "8fc79b")
        if (plrVdct == "5oak") then callOnLuas("updateChipCount", {wager * 16, 1})
        elseif (plrVdct == "4oak") then callOnLuas("updateChipCount", {wager * 8, 1})
        elseif (plrVdct == "fh") then callOnLuas("updateChipCount", {wager * 6, 1})
        elseif (plrVdct == "3oak") then callOnLuas("updateChipCount", {wager * 4, 1})
        elseif (plrVdct == "tp") then callOnLuas("updateChipCount", {wager * 3, 1})
        elseif (plrVdct == "2oak") then callOnLuas("updateChipCount", {wager * 2, 1})  
        end
    end
    pfFont:screenCenter("vdctTxt")
    runTimer("addChips", 1)
end

function addChips()
    endChoose = true
    runTimer("ppStart", 2)
    pfFont:setTextY("dlrTxt", -150)
    pfFont:setTextY("plrTxt", 720)

    for i=1,5 do
        doTweenY("plrcard"..i, "plrcard"..i, 720, 0.25)
        doTweenY("dlrcard"..i, "dlrcard"..i, -150, 0.25)
    end
end

function onTimerCompleted(tmr)
    if (tmr == "ppStart") then chooseWager() 
    elseif (tmr == "dumboStinky") then
        for i=1,5 do
            if (opts[i]) then 
                cancelTween("plrcard"..i)
                playAnim('plrcard'..i, ""..plrHand[i])
                doTweenY("plrcard"..i, "plrcard"..i, 600, 0.25)
            end
        end
        opts = {false, false, false, false, false}
        runTimer("dlrTurn", 0.5)
    elseif (tmr == "dealerpull") then 
        for i=1,5 do
            if (dlrOpts[i]) then 
                cancelTween("dlrcard"..i)
                doTweenY("dlrcard"..i, "dlrcard"..i, -20, 0.25)
            end
        end
        runTimer("tally", 0.5)
    elseif (tmr == "dlrTurn") then dealerAI()
    elseif (tmr == "tally") then tallyScores()
    elseif (tmr == "whowon") then finalThing(verdict)
    elseif (tmr == "addChips") then addChips()
    end
end

function onDestroy()
    callOnLuas("returnToCasino")
    close()

    pfFont:destroyAll()
    removeLuaSprite('arrow', true)
    removeLuaSprite('hiearchy', true)

    for i=1,5 do 
        removeLuaSprite('dlrcard'..i, true)
        removeLuaSprite('plrcard'..i, true) 
    end
end