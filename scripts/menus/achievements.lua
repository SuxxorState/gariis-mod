local utils = (require (getVar("folDir").."scripts.backend.utils")):new()

local categories = {
    {"Garii's Mod", {"fuzzy-dice-fc","full-house-fc","episode-ii-fc","story-deaths","garii-hud-death","no-pose","expert2simple","fuzzy-dice-ex-fc","full-house-ex-fc","episode-ii-ex-fc", "all-achievements"}},
    {"SKOBELOFF CASINO", {"100k-chips","true-bjs","tb-foak"}},
    {"Some Time At Garii's", {"stag-quarters","no-power-save","no-doors-save","the-yapper","stag-deaths"}},
    {"Bushtrimmer", {"bt-simple","bt-5simple","bt-speedy","bt-expert","bt-5expert","bt-exp-speed"}},
    {"Fuzzlings!", {"fl-everyfruit","fl-everytrash","fl-pacifist","fl-sadist","fl-16levels","fl-64levels","fl-deaths","fl-rebirth","fl-2rebirth"}}
}
local achievements = {
    ["fuzzy-dice-fc"] = {title = "Capicola Gang", description = "100% Clear Fuzzy Dice", iconFile = "fuzzydice", secret = false, gariiPoints = 10},
    ["fuzzy-dice-ex-fc"] = {title = "All Bark No Bite", description = "100% Clear Fuzzy Dice EX", iconFile = "gariimedal", secret = true, gariiPoints = 20},

    ["full-house-fc"] = {title = "The Power Of Two", description = "100% Clear Full House", iconFile = "fullhouse", secret = false, gariiPoints = 10},
    ["full-house-ex-fc"] = {title = "Decked Out", description = "100% Clear Full House EX", iconFile = "goonmedal", secret = true, gariiPoints = 20},
    ["garii-hud-death"] = {title = "KNOCK IT OFF!!!", description = "Die because Garii was messing with your HUD", iconFile = "", secret = false, gariiPoints = 10},
    ["no-pose"] = {title = "Not Feelin' It", description = "Beat Full House without ever hitting a pose note", iconFile = "poseless", secret = false, gariiPoints = 10},

    ["episode-ii-fc"] = {title = "Show Off", description = "100% Clear Episode ][ without dying once", iconFile = "episodeii", secret = false, gariiPoints = 25},
    ["episode-ii-ex-fc"] = {title = "You Made Your Point", description = "100% Clear Episode ][ EX without dying once", iconFile = "truckermedal", secret = true, gariiPoints = 50},
    ["expert2simple"] = {title = "Chat Told Me To", description = "Play a Simple Chart After Beating every Normal and Expert Chart in a Row", iconFile = "", secret = false, gariiPoints = 25},
    ["story-deaths"] = {title = "The Part Where He Kills You", description = "Experience every possible death Episode ][ has to offer", iconFile = "portal2", secret = false, gariiPoints = 25},
    ["all-achievements"] = {title = "Don't You Have Anything Better to Do?", description = "Unlock every achievement, including this one.", iconFile = "", secret = true, gariiPoints = 20},

    ["100k-chips"] = {title = "The Big Cheese", description = "Get one hundred thousand or more poker chips in the casino", iconFile = "", secret = false, gariiPoints = 50},
    ["true-bjs"] = {title = "The House Is Cheating!", description = "End in a draw with both you and the house having a true blackjack", iconFile = "cheating", secret = false, gariiPoints = 25},
    ["tb-foak"] = {title = "Planet X", description = "Get the highest Five of a Kind you can get in Picture Poker", iconFile = "balatro", secret = false, gariiPoints = 25},
    --["no-fish"] = {title = "Go...Fish?", description = "It doesn't exist. You're hallucinating.", iconFile = "", secret = false, gariiPoints = 10},

    ["stag-quarters"] = {title = "Dollar Fitty", description = "Survive all six quarters at Garii's Manor", iconFile = "garimascot", secret = false, gariiPoints = 50},
    ["no-power-save"] = {title = "Saved By The Bell", description = "Hit the end of a quarter whilst in a blackout", iconFile = "carvmascot", secret = false, gariiPoints = 25},
    ["no-doors-save"] = {title = "Lino's Bad Day", description = "Hit the end of a quarter with all three of your doors disabled", iconFile = "linomascot", secret = false, gariiPoints = 20},
    ["the-yapper"] = {title = "Keep Talking and I'll Explode", description = "Skip every Garii broadcast", iconFile = "garitv", secret = false, gariiPoints = 10},
    ["stag-deaths"] = {title = "Rocket Science", description = "Die to every lethal character at Garii's Manor", iconFile = "hntemascot", secret = false, gariiPoints = 20},
    --["stag-7-20"] = {title = "7/20 Blazin", description = "Survive Night-mare at Garii's Manor", iconFile = "", secret = false, gariiPoints = 75},

    ["bt-simple"] = {title = "Who Put These Here?", description = "Clear your first round.", iconFile = "mine", secret = false, gariiPoints = 10},
    ["bt-5simple"] = {title = "Handle With Care", description = "Clear 5 rounds in a row.", iconFile = "flag", secret = false, gariiPoints = 25},
    ["bt-speedy"] = {title = "Little Smiley Face", description = "Clear a round in under a minute.", iconFile = "smiley", secret = false, gariiPoints = 20},
    ["bt-expert"] = {title = "Minefield in a Bush", description = "Clear your first round on Expert.", iconFile = "mine-bush", secret = false, gariiPoints = 25},
    ["bt-5expert"] = {title = "Clusterluck", description = "Clear 5 rounds in a row on Expert.", iconFile = "boom", secret = false, gariiPoints = 50},
    ["bt-exp-speed"] = {title = "Horticulturist", description = "Clear a round on Expert in under five minutes.", iconFile = "shears", secret = false, gariiPoints = 75},

    ["fl-everyfruit"] = {title = "Pic-a-nic Basket", description = "Gather Every Food and Drink", iconFile = "", secret = false, gariiPoints = 10},
    ["fl-everytrash"] = {title = "Junkyard", description = "Collect Every Type of Trash", iconFile = "", secret = false, gariiPoints = 25},
    ["fl-pacifist"] = {title = "Green Hamm", description = "Avoid Sending the Fuzzlings Back to Their Base—for 16+ Levels in a row", iconFile = "", secret = false, gariiPoints = 25},
    ["fl-sadist"] = {title = "Seeing Red Wine", description = "Send EVERY fuzzling back to their base for EVERY energizer you eat in a level—for 4+ Levels in a row", iconFile = "", secret = false, gariiPoints = 25},
    ["fl-16levels"] = {title = "Salad Dressing", description = "Beat 16 Levels", iconFile = "", secret = false, gariiPoints = 20},
    ["fl-64levels"] = {title = "Sandwich Tower", description = "Beat 64 Levels", iconFile = "", secret = false, gariiPoints = 50},
    ["fl-rebirth"] = {title = "Byte Overflow", description = "Rebirth", iconFile = "", secret = false, gariiPoints = 100},
    ["fl-2rebirth"] = {title = "Exquisitely Stuffed", description = "Rebirth as Both Boy and Girl", iconFile = "", secret = false, gariiPoints = 250},
    ["fl-deaths"] = {title = "Knuckle Sandwich", description = "Die to every fuzzling as both Boy and Girl", iconFile = "", secret = false, gariiPoints = 25},
}

local megaloEasterEgg, megaloCounter, megaloNotes = false, 1, {1,1,2,1.583, 1.5, 1.4167, 1.25, 1, 1.25, 1.4167}
local backVariables, scrollVariables, gameVariables = {}, {}, {}
local offset = {x = 208, y = 90}
local zoomBoxCounter = 1
local menuMoves = {{"Select", "accept", "52B80E"}, {"Back", "back", "A90F27"} --[[, {"About Gariiscore", "reset", "F3910A"}, {"Share Achievement", "debug_1", "0C579D"}]] }
local keyedBinds = {"shift", "enter", "caps", "escape", "pgup", "tab", "bckspc", "alt", "end", "pgdown", "home", "delete", "break", "numlock", "ctrl", "up", "down", "left", "right", "menu", "windows", "scroll-lock", "insert", "space"}
local fold = "achievements/"
local scrollMenu, gameMenu = false, false
local curSel, curAch = 1, 1

function openAchievementsMenu()
    openCustomSubstate("achievementsMenu", true)
    callOnLuas("toggleCursor", {false})
end

function onCustomSubstateCreate(tag)
    if (tag ~= "achievementsMenu") then return end
    utils:pauseAllKnownSounds()
    playSound(fold.."openmenu")

    makeLuaSprite("menuBlackout")
    makeGraphic("menuBlackout", screenWidth,screenHeight, "000000")
    setProperty("menuBlackout.alpha", 0.95)
    quickAddBackSprite("menuBlackout")

    makeLuaSprite("menuZoomBox", "", offset.x + (864/2), offset.y + (522/2))
    makeGraphic("menuZoomBox", 1,1, "FFFFFF")
    quickAddBackSprite("menuZoomBox")

    makeLuaSprite("arrowIndiBi", fold.."pageindi", offset.x + 864 - 40, offset.y + 522 - 27)
    --quickAddBackSprite("arrowIndiBi")
    setProperty("arrowIndiBi.flipY", true)
    setProperty("arrowIndiBi.visible", false)

    makeLuaSprite("arrowIndiUp", fold.."pageindi", offset.x + 864 - 65, offset.y + 522 - 27)
    --quickAddBackSprite("arrowIndiUp")
    setProperty("arrowIndiUp.visible", false)

    local buttonOff = {x = offset.x + 27, y = offset.y + 529}
    for _,button in pairs(menuMoves) do
        makeLuaSprite("commandButtonBack"..button[1], fold.."buttonback", buttonOff.x, buttonOff.y)
        setProperty("commandButtonBack"..button[1]..".color", getColorFromHex(button[3]))
        quickAddBackSprite("commandButtonBack"..button[1])
        setProperty('commandButtonBack'..button[1]..".visible", false)

        local keyButton = utils:lwrKebab(utils:getKeyFromBind(button[2]))
        if (utils:tableContains(keyedBinds, keyButton)) then
            makeAnimatedLuaSprite("commandButtonSymb"..button[1], fold.."keysymbols", buttonOff.x, buttonOff.y)
            addAnimationByPrefix("commandButtonSymb"..button[1], "reg", keyButton)
            quickAddBackSprite("commandButtonSymb"..button[1])
        else 
            makeLuaText('commandButtonSymb'..button[1], keyButton:upper())
            utils:quickFormatTxt('commandButtonSymb'..button[1], "segoe-semi.ttf", 16, "FFFFFF")
            setProperty('commandButtonSymb'..button[1]..".x", buttonOff.x + ((24 - getProperty('commandButtonSymb'..button[1]..".width"))/2))
            setProperty('commandButtonSymb'..button[1]..".y", buttonOff.y - 1)
            quickAddBackSprite('commandButtonSymb'..button[1], true)
        end
        setProperty('commandButtonSymb'..button[1]..".visible", false)

        makeLuaText('commandButtonTxt'..button[1], button[1])
        utils:quickFormatTxt('commandButtonTxt'..button[1], "segoe-semi.ttf", 19, "FFFFFF")
        setProperty('commandButtonTxt'..button[1]..".x", buttonOff.x + 28)
        setProperty('commandButtonTxt'..button[1]..".y", buttonOff.y - 2)
        quickAddBackSprite('commandButtonTxt'..button[1], true)
        setProperty('commandButtonTxt'..button[1]..".visible", false)
        buttonOff.x = buttonOff.x + getProperty('commandButtonTxt'..button[1]..".width") + 40
    end
    
    makeLuaText('achTopTxt', "Achievements")
    utils:quickFormatTxt("achTopTxt", "segoe.ttf", 24.5, "FFFFFF")
    setProperty("achTopTxt.x", offset.x + 25)
    setProperty("achTopTxt.y", offset.y - 38)
    quickAddScrollSprite('achTopTxt', true)
        
    makeLuaText('topTimeTxt', "00:00  PM")
    utils:quickFormatTxt("topTimeTxt", "segoe.ttf", 22.5, "FFFFFF")
    setProperty("topTimeTxt.x", offset.x + 834 - (getProperty("topTimeTxt.width")))
    setProperty("topTimeTxt.y", offset.y - 36)
    quickAddBackSprite('topTimeTxt', true)
    setProperty("topTimeTxt.visible", false)

    local pfps = {}
    for j,pfp in pairs(utils:dirFileList('images/achievements/pfp-avatars/')) do
        if (stringEndsWith(pfp, ".png")) then table.insert(pfps, string.sub(pfp, 1, #pfp - 4)) end
    end
    makeLuaSprite("menuPlayerIcon", fold.."pfp-avatars/"..pfps[getRandomInt(1, #pfps)], offset.x + 410, offset.y -53)
    scaleObject("menuPlayerIcon", 0.5, 0.5)
    quickAddBackSprite("menuPlayerIcon")
    setProperty("menuPlayerIcon.visible", false)

    for i=1,7 do
        makeLuaSprite("menuGameBorder"..i, "", offset.x, offset.y+(68.5*i))
        makeGraphic("menuGameBorder"..i, 864,2, "C1C6CA")
        quickAddScrollSprite("menuGameBorder"..i)
    end
    
    makeLuaSprite("menuSelectBack", fold.."gameselectgradient", offset.x, offset.y)
    scaleObject("menuSelectBack", 864, 1)
    quickAddScrollSprite("menuSelectBack")

    for i=1,#categories do
        makeLuaSprite("gameIcon"..i, fold.."/icons/game", offset.x+9, offset.y+(68.5*(i-1)) + 5)
        quickAddScrollSprite("gameIcon"..i)

        makeLuaText('gameTitleTxt'..i, categories[i][1])
        utils:quickFormatTxt('gameTitleTxt'..i, "segoe.ttf", 25, "000000")
        setProperty('gameTitleTxt'..i..".x", offset.x + 75)
        setProperty('gameTitleTxt'..i..".y", offset.y + math.floor((68.5*(i-1))) + 1)
        quickAddScrollSprite('gameTitleTxt'..i, true)
        
        makeLuaText('gameUnlockTxt'..i, tallyGameAmt(i).." of "..(utils:tableLen(categories[i][2])).." Achievements")
        utils:quickFormatTxt('gameUnlockTxt'..i, "segoe.ttf", 24, "000000")
        setProperty('gameUnlockTxt'..i..".x", offset.x + 75)
        setProperty('gameUnlockTxt'..i..".y", offset.y + math.floor((68.5*(i-1))) + 31)
        quickAddScrollSprite('gameUnlockTxt'..i, true)

        makeAnimatedLuaSprite("gariiPointIcon"..i, fold.."gariipoints", offset.x+817, offset.y+(68.5*(i-1)) + 25)
        addAnimationByPrefix("gariiPointIcon"..i, "sel", "sel")
        addAnimationByPrefix("gariiPointIcon"..i, "desel", "desel")
        quickAddScrollSprite("gariiPointIcon"..i)

        makeLuaText('gariiPointTxt'..i, ""..tallyGameScore(i))
        utils:quickFormatTxt('gariiPointTxt'..i, "segoe.ttf", 24, "000000")
        setProperty('gariiPointTxt'..i..".x", offset.x + (806 - getProperty("gariiPointTxt"..i..".width")))
        setProperty('gariiPointTxt'..i..".y", (offset.y + math.floor((68.5*(i-1))) + 17) - (i%2))
        quickAddScrollSprite('gariiPointTxt'..i, true)
    end
    runTimer("zoomBoxTimer", 1/framerate, 0)
    changeSel(0)
end

function quickAddBackSprite(name, isText) quickAddSprite(name, isText, true, "back") end
function quickAddScrollSprite(name, isText) quickAddSprite(name, isText, false, "scroll") end
function quickAddGameSprite(name, isText) quickAddSprite(name, isText, true, "game") end
function quickAddSprite(name, isText, initShow, category)
    isText = isText or false
    initShow = initShow or false
    utils:setObjectCamera(name, "other")
    setProperty(name..".visible", initShow)
    if (isText) then addLuaText(name)
    else addLuaSprite(name, true)
    end
    if (category == "back") then table.insert(backVariables, name)
    elseif (category == "scroll") then table.insert(scrollVariables, name)
    elseif (category == "game") then table.insert(gameVariables, name)
    end
end

function onCustomSubstateUpdate(tag)
    if (tag ~= "achievementsMenu") then return end

    local theDate = os.date("%I"..":".."%M".."  ".."%p", os.time(os.date('*t'))):upper()
    if (stringStartsWith(theDate, "0")) then theDate = string.sub(theDate, 2, #theDate) end
    if (theDate ~= getTextString("topTimeTxt")) then setTextString("topTimeTxt", theDate) end

    if (scrollMenu) then
        if (keyJustPressed("back")) then 
            playSound(fold.."declick")
            runTimer("exitsnd", 0.1)
            scrollMenu = false
            for i,spr in pairs(backVariables) do
                if (stringStartsWith(spr, "commandButton")) then
                    removeLuaSprite(spr, true)
                    removeLuaText(spr, true)
                end
            end
            for i,spr in pairs(scrollVariables) do
                removeLuaSprite(spr, true)
                removeLuaText(spr, true)
            end
            for i,spr in pairs(gameVariables) do
                removeLuaSprite(spr, true)
                removeLuaText(spr, true)
            end
            setProperty("menuPlayerIcon.visible", false)
            setProperty("topTimeTxt.visible", false)
            runTimer('deZoomBoxTimer', 1/framerate, 0)
        end
        if (keyJustPressed("accept")) then 
            playSound(fold.."click")
            scrollMenu = false
            openGameAchievements(categories[curSel])
        end

        if (keyJustPressed("ui_up")) then changeSel(-1)
        elseif (keyJustPressed("ui_down")) then changeSel(1)
        end
    elseif (gameMenu) then
        if (keyJustPressed("back")) then
            playSound(fold.."declick")
            gameMenu = false
            closeGameAchievements()
        end

        if (keyJustPressed("ui_up") and utils:tableLen(categories[curSel][2]) > 8) then changeAch(-8)
        elseif (keyJustPressed("ui_down") and utils:tableLen(categories[curSel][2]) > 8) then changeAch(8)
        elseif (keyJustPressed("ui_left")) then changeAch(-1)    
        elseif (keyJustPressed("ui_right")) then changeAch(1)     
        end
    end
end

function openGameAchievements(game)
    curAch = 1
    for _,spr in pairs(scrollVariables) do
        doTweenAlpha(spr.."tween", spr, 0, 0.1)
    end

    makeLuaSprite("gameTopBox", fold.."gamegradient", offset.x, offset.y)
    scaleObject("gameTopBox", 864, 1)
    setProperty("gameTopBox.alpha", 0)
    quickAddGameSprite("gameTopBox")
    
    makeLuaText('gameNameTxt', game[1])
    utils:quickFormatTxt('gameNameTxt', "segoe.ttf", 24, "FFFFFF")
    setProperty('gameNameTxt.x', offset.x + 16)
    setProperty('gameNameTxt.y', offset.y + 13)
    quickAddGameSprite('gameNameTxt', true)
    
    makeAnimatedLuaSprite("gariiPoints", fold.."gariipoints", offset.x+864-44, offset.y+ 22)
    addAnimationByPrefix("gariiPoints", "sel", "sel")
    quickAddGameSprite("gariiPoints")

    makeLuaText('gameScoreTxt', achievements[categories[curSel][2][curAch]].gariiPoints)
    utils:quickFormatTxt('gameScoreTxt', "segoe.ttf", 24, "FFFFFF")
    setProperty('gameScoreTxt.x', offset.x + 416)
    setProperty('gameScoreTxt.y', offset.y + 13)
    quickAddGameSprite('gameScoreTxt', true)
    
    makeLuaText('achDateTxt', "99/99/9999")
    utils:quickFormatTxt('achDateTxt', "segoe.ttf", 24, "BFC8CD")
    setProperty('achDateTxt.x', offset.x + 416)
    setProperty('achDateTxt.y', offset.y + 47)
    quickAddGameSprite('achDateTxt', true)

    makeLuaText('achNameTxt', achievements[categories[curSel][2][curAch]].title)
    utils:quickFormatTxt('achNameTxt', "segoe.ttf", 24, "BFC8CD")
    setProperty('achNameTxt.x', offset.x + 16)
    setProperty('achNameTxt.y', offset.y + 47)
    quickAddGameSprite('achNameTxt', true)
    
    makeLuaText('descNameTxt', achievements[categories[curSel][2][curAch]].description,840,0,832)
    utils:quickFormatTxt('descNameTxt', "segoe.ttf", 24, "BFC8CD")
    setTextAlignment("descNameTxt", "left")
    setProperty('descNameTxt.x', offset.x + 16)
    setProperty('descNameTxt.y', offset.y + 82)
    quickAddGameSprite('descNameTxt', true)
    
    makeLuaSprite("gameSelectBox", fold.."selectgradient", offset.x + 38, offset.y + 175.5)
    scaleObject("gameSelectBox", 100, 1)
    setProperty("gameSelectBox.alpha", 0)
    quickAddGameSprite("gameSelectBox")

    local testMode = false
    for i,ach in pairs(categories[curSel][2]) do
        local saveShit = getAchievementSave(ach)
        local iconThing = "award"
        if (testMode) then iconThing = achievements[ach].iconFile
        else
            if (checkFileExists("images/"..fold.."icons/"..achievements[ach].iconFile..'.png')) then iconThing = achievements[ach].iconFile end
            if (saveShit[1] ~= true or saveShit[1] == nil) then iconThing = "lockedach" end
        end
        makeLuaSprite("gameAchievement"..i, fold.."icons/"..iconThing, offset.x + 56 + (((i-1)%8) * 99), offset.y + 193.5 + (math.floor((i-1)/8) * 100))
        setProperty("gameAchievement"..i..".antialiasing", getProperty("gameAchievement"..i..".width") >= 64)
        setGraphicSize("gameAchievement"..i, 64, 64)
        setProperty("gameAchievement"..i..".alpha", 0)
        quickAddGameSprite("gameAchievement"..i)
    end

    makeLuaText('gameUnlockTxt', tallyGameAmt(curSel).." of "..(utils:tableLen(categories[curSel][2])).." unlocked")
    utils:quickFormatTxt("gameUnlockTxt", "segoe.ttf", 21, "000000")
    setProperty("gameUnlockTxt.x", offset.x + 36)
    setProperty("gameUnlockTxt.y", (offset.y + 522) - 46)
    quickAddGameSprite('gameUnlockTxt', true)

    changeAch(0)
    for i,spr in pairs(gameVariables) do
        setProperty(spr..".alpha", 0)
    end
    runTimer("loadBuffer", 0.25)
end

function closeGameAchievements()
    for i,spr in pairs(gameVariables) do
        doTweenAlpha(spr.."tween", spr, 0, 0.1)
    end
    doTweenAlpha("achTopTxttween", "achTopTxt", 0, 0.1)
    runTimer("ridMeOfThesePeasants", 0.1)
    runTimer("loadBuffer2", 0.25)
end

function changeSel(inc)
    local lastSel = curSel
    curSel = curSel + inc
    if (curSel < 1) then curSel = #categories
    elseif (curSel > #categories) then curSel = 1
    end
    if (curSel ~= lastSel) then playMoveSound() end

    setProperty("menuSelectBack.y", math.min(math.max(offset.y + (68.5 * (curSel-1)), offset.y), offset.y + (68.5 * 6)))
    for i=1,#categories do
        if (curSel == i) then playAnim("gariiPointIcon"..i, "sel")
            setTextColor('gariiPointTxt'..i, "FFFFFF")
            setTextColor('gameTitleTxt'..i, "FFFFFF")
            setTextColor('gameUnlockTxt'..i, "FFFFFF")
        else playAnim("gariiPointIcon"..i, "desel")
            setTextColor('gariiPointTxt'..i, "000000")
            setTextColor('gameTitleTxt'..i, "000000")
            setTextColor('gameUnlockTxt'..i, "000000")
        end
    end
end

function changeAch(inc)
    local lastAch = curAch
    curAch = curAch + inc
    if (curAch < 1) then curAch = utils:tableLen(categories[curSel][2])
    elseif (curAch > utils:tableLen(categories[curSel][2])) then curAch = 1
    end
    if (curAch ~= lastAch) then playMoveSound() end

    setProperty("gameSelectBox.x", offset.x + 38 + (((curAch-1)%8) * 99))
    setProperty("gameSelectBox.y", offset.y + 175.5 + (math.floor((curAch-1)/8) * 99))

    local dateUnlock = os.date("%m".."/".."%d".."/".."%Y", getAchievementSave(categories[curSel][2][curAch])[2]):upper()
    if (getAchievementSave(categories[curSel][2][curAch])[2] == nil) then dateUnlock = "" end
    if (stringStartsWith(dateUnlock, "0")) then dateUnlock = string.sub(dateUnlock, 2, #dateUnlock) end
    setTextString("achDateTxt", dateUnlock)
    setProperty("achDateTxt.x", offset.x + 864 - (getProperty("achDateTxt.width") + 22))

    local secret = ((getAchievementSave(categories[curSel][2][curAch])[1] == false or getAchievementSave(categories[curSel][2][curAch])[1] == nil) and (achievements[categories[curSel][2][curAch]].secret))
    if (secret) then
        setTextString("achNameTxt", "Secret")
        setTextString("descNameTxt", "This is a secret achievement. Unlock it to find out more about it.")
        setTextString("gameScoreTxt", "--")
        setProperty("gameScoreTxt.x", offset.x + 864 - (getProperty("gameScoreTxt.width") + 20))
    else
        setTextString("achNameTxt", achievements[categories[curSel][2][curAch]].title)
        setTextString("descNameTxt", achievements[categories[curSel][2][curAch]].description)
        setTextString("gameScoreTxt", achievements[categories[curSel][2][curAch]].gariiPoints)
        setProperty("gameScoreTxt.x", offset.x + 864 - (getProperty("gameScoreTxt.width") + 50))
    end
    setProperty("gariiPoints.visible", not secret)
end

function playMoveSound()
    playSound(fold.."move", 1, "move")

    if (getRandomInt(0,65535) == 0 and megaloCounter == 1) then megaloEasterEgg = true end
    if (megaloEasterEgg) then
        setProperty("sound_move.pitch", megaloNotes[megaloCounter])
        megaloCounter = megaloCounter + 1
        if (megaloCounter > #megaloNotes) then megaloEasterEgg = false end
    end
end

function getAchievementSave(ach)
    if (utils:getGariiData("achievements") == nil) then utils:setGariiData("achievements", {}) end
    local save = utils:getGariiData("achievements")
    if (save[ach] == nil) then
        return {false, nil}
    end
    return save[ach]
end

function tallyGameScore(game)
    local score = 0
    for _,ach in pairs(categories[game][2]) do
        if (getAchievementSave(ach)[1] == true) then
            score = score + achievements[ach].gariiPoints
        end
    end
    return score
end

function tallyGameAmt(game)
    local score = 0
    for _,ach in pairs(categories[game][2]) do
        if (getAchievementSave(ach)[1] == true) then
            score = score + 1
        end
    end
    return score
end

function onTimerCompleted(tmr)
	if (tmr == 'zoomBoxTimer') then
        zoomBoxCounter = math.min(zoomBoxCounter + (3840/framerate), 864)
        scaleObject("menuZoomBox", zoomBoxCounter, zoomBoxCounter * 522/864)
        setProperty("menuZoomBox.x", offset.x + ((864 - getProperty("menuZoomBox.scale.x"))/2))
        setProperty("menuZoomBox.y", offset.y + ((522 - getProperty("menuZoomBox.scale.y"))/2))
        if (zoomBoxCounter >= 864) then
            cancelTimer('zoomBoxTimer')
            for i,spr in pairs(backVariables) do
                setProperty(spr..".visible", true)
            end
            for i,spr in pairs(scrollVariables) do
                setProperty(spr..".visible", true)
            end
            setProperty("menuPlayerIcon.visible", true)
            setProperty("topTimeTxt.visible", true)
            scrollMenu = true
        end
    elseif (tmr == 'deZoomBoxTimer') then
        zoomBoxCounter = math.max(zoomBoxCounter - (3840/framerate), 1)
        scaleObject("menuZoomBox", zoomBoxCounter, zoomBoxCounter * 522/864)
        setProperty("menuZoomBox.x", offset.x + ((864 - getProperty("menuZoomBox.scale.x"))/2))
        setProperty("menuZoomBox.y", offset.y + ((522 - getProperty("menuZoomBox.scale.y"))/2))
        if (zoomBoxCounter <= 1) then
            cancelTimer('deZoomBoxTimer')
            closeMenu()
        end
    elseif (tmr == "loadBuffer") then
        for i,spr in pairs(gameVariables) do
            doTweenAlpha(spr.."tween", spr, 1, 0.1)
        end
        doTweenAlpha("achTopTxttween", "achTopTxt", 1, 0.1)
        gameMenu = true
    elseif (tmr == "loadBuffer2") then
        for i,spr in pairs(scrollVariables) do
            doTweenAlpha(spr.."tween", spr, 1, 0.1)
        end
        doTweenAlpha("achTopTxttween", "achTopTxt", 1, 0.1)
        scrollMenu = true
    elseif (tmr == "ridMeOfThesePeasants") then
        for i,spr in pairs(gameVariables) do
            removeLuaSprite(spr, true)
            removeLuaText(spr, true)
        end
    elseif (tmr == "exitsnd") then playSound(fold.."exit")
    end
end

function closeMenu()
    utils:resumeAllKnownSounds()
    callOnLuas("toggleCursor", {true})
    for i,spr in pairs(backVariables) do
        removeLuaSprite(spr, true)
        removeLuaText(spr, true)
    end
    closeCustomSubstate("achievementsMenu")
    close()
end