local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local pfFont = (require (getVar("folDir").."scripts.objects.fontHandler")):new("poker-freak")
local fldr = "minigames/casino/"

local canChoose = false
local playerStatus = ""
local dealerStatus = ""
local curChoice = 1
local prevOpts = {}
local options = {}
local defCards = {} --teag
local cards = {}
local curCards = {}
local curHand = 0
local dlrCards = {}
local delrHand = 0
local curBet = 0
local wgrChoose = false
local endChoose = false
local wager = 5
local holdTime = 0
local shiftMult = 1

function startCasinoGame()
    defCards = {}
    for i,suit in pairs({"Diamonds", "Hearts", "Spades", "Clubs"}) do
        for i,rank in pairs({"ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king"}) do
            table.insert(defCards, rank..suit)
        end
    end
    cards = utils:copyTable(defCards)

    pfFont:createNewText("plrCnt", 0, 640, " ")
    pfFont:setTextScale("plrCnt", 2,2)

    pfFont:createNewText("dlrCnt", 0, 30, " ")
    pfFont:setTextScale("dlrCnt", 2,2)
    
    pfFont:createNewText("wgrTxt", 0, -150, " ")
    pfFont:setTextScale("wgrTxt", 3, 3)
        
    pfFont:createNewText("wgrAmtTxt", 0, -150, " ")
    pfFont:setTextScale("wgrAmtTxt", 3, 3)
    
    pfFont:createNewText("vdctTxt", 0, -150, " ")
    pfFont:setTextScale("vdctTxt", 3, 3)

    runTimer("bjStart", 0.25)
end

function onUpdatePost(elp)
    utils:setDiscord("In GARII'S ARCADE", "SKOBELOFF CASINO: Blackjack")
    if (canChoose) then
        if (keyJustPressed("accept")) then selectOption()
        elseif (keyJustPressed("ui_left")) then changeOption(-1)
        elseif (keyJustPressed("ui_right")) then changeOption(1)
        end 
    elseif (endChoose) then
        if (keyJustPressed("accept")) then chooseWager()
        elseif (keyJustPressed("back")) then onDestroy()
        end 
    elseif (wgrChoose) then
        if (keyJustPressed("accept")) then callOnLuas("updateChipCount", {-wager})
            newRound()
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
                if (holdTime > 5) then
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

function chooseWager()
    if (utils:getGariiData("pkrChips") < 5) then onDestroy() end
    
    endChoose = false
    wgrChoose = true
    pfFont:setTextString("vdctTxt", " ")
    updateWager(0)
end

function updateWager(inc)
    local leftIndi = "<"
    local rightIndi = ">"
    local maxChips = utils:getGariiData("pkrChips")
    wager = wager + inc
    if (wager >= math.min(maxChips, 1000)) then wager = math.min(maxChips, 1000)
        rightIndi = " "
    elseif (wager <= 10) then wager = 10
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

function newRound()
    wgrChoose = false
    pfFont:setTextString("wgrTxt", " ")
    pfFont:setTextString("wgrAmtTxt", " ")
    pfFont:setTextString("vdctTxt", " ")
    playerStatus = ""
    dealerStatus = ""
    for i=1,#dlrCards do removeLuaSprite('dlrcard'..i, true) end
    for i=1,#curCards do removeLuaSprite('card'..i, true) end
    curCards = {}
    dlrCards = {}
    endChoose = false
    options = {"Hit", "Stand", "Double Down"}
    prevOpts = options
    reloadOptions()
    
    for i=1,4 do addToHand(i%2 == 0) end

    giveChoices()
end

function giveChoices()
    if (playerStatus ~= "" or dealerStatus == "blackjack") then 
        if (dealerStatus ~= "" or playerStatus == "bust" or playerStatus == "blackjack") then tallyScores()
        else runDealerAI()
        end
    else
        canChoose = true
        reloadOptions()
    end
end

function reloadOptions()
    if (prevOpts ~= options and #prevOpts >= 1) then
        for i,opt in pairs(prevOpts) do
            if (pfFont:textExists(opt..'Txt')) then
                pfFont:setTextVisible(opt.."Txt", false)
            end
        end
    end
    prevOpts = options

    for i,opt in pairs(options) do
        if (not pfFont:textExists(opt..'Txt')) then
            pfFont:createNewText(opt..'Txt', 550 + (((i-1)%2) * 250), (500 - (math.floor((#options-1)/2) * 75)) + (math.floor((i-1)/2) * 75), opt)
            pfFont:setTextScale(opt..'Txt', 2,2)
        end
        pfFont:setTextVisible(opt.."Txt", true)
        pfFont:setTextString(opt..'Txt', opt)
    end
    changeOption(0)
end

function changeOption(up)
    curChoice = curChoice + up
    if (curChoice > #options) then curChoice = 1
    elseif (curChoice < 1) then curChoice = #options
    end

    for i,opt in pairs(options) do
        if (i == curChoice) then pfFont:setTextColour(opt.."Txt", "FFFFFF")
        else pfFont:setTextColour(opt.."Txt", "333333")
        end
    end
end

function selectOption()
    canChoose = false

    local optn = utils:lwrKebab(options[curChoice])
    if (optn == "hit") then addToHand()
        options = {"Hit", "Stand"} --doubling down cannot be done with 3+ cards. house rules
        giveChoices()
    elseif (optn == "stand") then playerStatus = "stand"
        runDealerAI()
    elseif (optn == "double-down") then
        playerStatus = "dd"
        addToHand()
        callOnLuas("updateChipCount", {-wager})
        wager = wager * 2
        runDealerAI()
    elseif (optn == "play-again") then chooseWager()
    elseif (optn == "quit") then onDestroy()
    end
end

function runDealerAI()
    if (dealerStatus == "") then
        if (delrHand <= 16) then addToHand(true)
        else dealerStatus = "stand"
        end
    end

    giveChoices()
end

function tallyScores()
    curChoice = 1
    endChoose = true

    for _,opt in pairs(options) do pfFont:setTextString(opt..'Txt', " ") end
    pfFont:setTextString("dlrCnt", ""..delrHand)
    playAnim("dlrcard1", "front")

    local verdict = ""  --this system reeks
    if (curHand == 21 and delrHand ~= 21) then verdict = "Blackjack"
        pfFont:setTextColour("vdctTxt", "8fc79b")
        callOnLuas("updateChipCount", {wager * 3})
    elseif (delrHand == 21 and curHand ~= 21) then verdict = "Dealer Blackjack"
        pfFont:setTextColour("vdctTxt", "c55252")
    elseif (playerStatus == "bust") then verdict = "Bust"
        pfFont:setTextColour("vdctTxt", "c55252")
    elseif (dealerStatus == "bust") then verdict = "Dealer Bust"
        pfFont:setTextColour("vdctTxt", "8fc79b")
        callOnLuas("updateChipCount", {wager * 2})
    elseif (curHand > delrHand) then verdict = "Win"
        pfFont:setTextColour("vdctTxt", "8fc79b")
        callOnLuas("updateChipCount", {wager * 2})
    elseif (curHand < delrHand) then verdict = "Too Bad..."
        pfFont:setTextColour("vdctTxt", "c55252")
    else verdict = "Push"
        if (curHand == 21 and delrHand == 21 and #curCards == 2 and #dlrCards == 2) then --would check for specific cards like ace and face/10 but like this does the job fine as is
            callOnLuas("unlockAchievement", {"true-bjs"})
        end
        pfFont:setTextColour("vdctTxt", "f4f3ad")
        callOnLuas("updateChipCount", {wager})
    end

    pfFont:setTextString("vdctTxt", verdict)
    pfFont:screenCenter("vdctTxt")
end

function addToHand(dealer)
    if (dealer == nil) then dealer = false end
    if (#cards < 1) then shuffleDeck() end

    local selHand = curCards
    if (dealer) then selHand = dlrCards end

    local chosenCard = table.remove(cards, getRandomInt(1, #cards))
    table.insert(selHand, chosenCard)

    local selAmt = 0
    for i,crd in pairs(selHand) do
        if (not stringStartsWith(crd, "ace")) then
            if (stringStartsWith(crd, "jack") or stringStartsWith(crd, "queen") or stringStartsWith(crd, "king")) then selAmt = selAmt + 10
            else 
                selAmt = selAmt + utils:extractNum(crd)
            end
        end
    end
    for i,crd in pairs(selHand) do --saves ace calculations for last
        if (stringStartsWith(crd, "ace")) then
            if (selAmt + 11 > 21) then selAmt = selAmt + 1
            else selAmt = selAmt + 11
            end
        end
    end

    local selStatus = ""
    if (selAmt > 21) then selStatus = "bust"
    elseif (selAmt == 21) then selStatus = "blackjack"
    end

    if (dealer) then
        dlrCards = selHand
        delrHand = selAmt
        if (dealerStatus == "") then dealerStatus = selStatus end
        pfFont:setTextString("dlrCnt", "??")
        pfFont:setTextX("dlrCnt", screenWidth - (((#dlrCards+3) * 85) - 40))

        makeAnimatedLuaSprite('dlrcard'..#dlrCards,fldr.."programmer-dark",screenWidth - ((#dlrCards+2) * 75),-20)
        addAnimationByPrefix('dlrcard'..#dlrCards, 'back', "cardback", 24, true)
        addAnimationByPrefix('dlrcard'..#dlrCards, 'front', dlrCards[#dlrCards], 24, true)
        if (#dlrCards == 1) then playAnim('dlrcard'..#dlrCards, "back") end
        addLuaSprite('dlrcard'..#dlrCards, true)
        setProperty('dlrcard'..#dlrCards..'.antialiasing', false)
        utils:setObjectCamera('dlrcard'..#dlrCards, 'other')
    else
        curCards = selHand
        curHand = selAmt
        if ((playerStatus == "" or playerStatus == "dd") and selStatus ~= "") then playerStatus = selStatus end --doubling down in the long run doesnt do anything, so it can be replaced by something more meaningful
        pfFont:setTextString("plrCnt", ""..curHand)
        pfFont:setTextX("plrCnt", 210 + (#curCards * 85))

        makeAnimatedLuaSprite('card'..#curCards,fldr.."programmer-dark",100 + (#curCards * 75),720)
        addAnimationByPrefix('card'..#curCards, 'reg', curCards[#curCards], 24, true)
        addLuaSprite('card'..#curCards, true)
        setProperty('card'..#curCards..'.antialiasing', false)
        doTweenY('card'..#curCards, 'card'..#curCards, 600, 0.25)
        utils:setObjectCamera('card'..#curCards, 'other')
    end
end

function shuffleDeck()
    cards = utils:copyTable(defCards)
    for i,crd in pairs(curCards) do
        table.remove(cards, utils:indexOf(cards, crd))
    end
    for i,crd in pairs(dlrCards) do
        table.remove(cards, utils:indexOf(cards, crd))
    end
    debugPrint("shuffled deck")
end

function onTimerCompleted(tmr)
    if (tmr == "bjStart") then chooseWager()
    end
end

function onDestroy()
    callOnLuas("returnToCasino")
    close()

    pfFont:destroyAll()

    for i=1,#dlrCards do removeLuaSprite('dlrcard'..i, true) end
    for i=1,#curCards do removeLuaSprite('card'..i, true) end
end