local utils = (require (getVar("folDir").."scripts.backend.utils")):new() 
local achievements = {
    ["garii's-mod"] = {
        {save = "fuzzy-dice-fc", title = "Capicola Gang", description = "100% Clear Fuzzy Dice", iconFile = "fuzzydice", secret = false, gariiPoints = 10},
        {save = "full-house-fc", title = "The Power Of Two", description = "100% Clear Full House", iconFile = "", secret = false, gariiPoints = 10},
        {save = "episode-ii-fc", title = "Show Off", description = "100% Clear Episode ][ without dying once", iconFile = "", secret = false, gariiPoints = 25},

        --{save = "fuzzy-dice-rm-fc", title = "All Bark No Bite", description = "100% Clear Fuzzy Dice rematch", iconFile = "", secret = false, gariiPoints = 20},
        --{save = "full-house-rm-fc", title = "Decked Out", description = "100% Clear Full House rematch", iconFile = "", secret = false, gariiPoints = 20},
        --{save = "episode-ii-rm-fc", title = "You Made Your Point", description = "100% Clear Episode ][ rematch without dying once", iconFile = "", secret = false, gariiPoints = 50},

        {save = "story-deaths", title = "The Part Where He Kills You", description = "Experience every possible death Episode ][ has to offer", iconFile = "portal2", secret = false, gariiPoints = 25},
        {save = "no-pose", title = "Not Feelin' It", description = "Beat Full House without ever hitting a pose note", iconFile = "", secret = false, gariiPoints = 10},
    },

    ["skobeloff-casino"] = {
        {save = "100k-chips", title = "The Big Cheese", description = "Get one hundred thousand or more poker chips in the casino", iconFile = "", secret = false, gariiPoints = 50},
        {save = "true-bjs", title = "The House Is Cheating!", description = "End in a draw with both you and the house having a true blackjack", iconFile = "", secret = false, gariiPoints = 25},
        {save = "tb-foak", title = "Planet X", description = "Get the highest Five of a Kind you can get in Picture poker", iconFile = "", secret = false, gariiPoints = 25},
        {save = "no-fish", title = "Go...Fish?", description = "It doesn't exist. You're hallucinating.", iconFile = "", secret = false, gariiPoints = 10},
    },

    ["some-time-at-garii's"] = {
        {save = "stag-quarters", title = "Dollar Fitty", description = "Survive all six quarters at Garii's Manor", iconFile = "", secret = false, gariiPoints = 50},
        {save = "no-power-save", title = "Saved By The Bell", description = "Hit the end of a quarter whilst in a blackout", iconFile = "", secret = false, gariiPoints = 25},
        {save = "no-doors-save", title = "Lino's Bad Day", description = "Hit the end of a quarter with all three of your doors disabled", iconFile = "", secret = false, gariiPoints = 20},
        {save = "the-yapper", title = "Keep Talking and I'll Explode", description = "Skip every Garii broadcast", iconFile = "", secret = false, gariiPoints = 10},
        {save = "stag-deaths", title = "Rocket Science", description = "Die to every lethal character at Garii's Manor", iconFile = "", secret = false, gariiPoints = 20},
        --{save = "stag-7-20", title = "7/20 Blazin", description = "Survive Night-mare at Garii's Manor", iconFile = "", secret = false, gariiPoints = 75},
    },

    ["bushtrimmer"] = {
        {save = "bt-simple", title = "Who Put These Here?", description = "Beat a round of Bushtrimmer", iconFile = "mine", secret = false, gariiPoints = 10},
        {save = "bt-5simple", title = "Handle With Care", description = "Beat 5 rounds of Bushtrimmer", iconFile = "flag", secret = false, gariiPoints = 25},
        {save = "bt-speedy", title = "Little Smiley Face", description = "Beat a round of Bushtrimmer in under a minute", iconFile = "smiley", secret = false, gariiPoints = 20},
        {save = "bt-expert", title = "Minefield in a Bush", description = "Beat a round of Bushtrimmer on Expert", iconFile = "mine-bush", secret = false, gariiPoints = 25},
        {save = "bt-5expert", title = "Clusterluck", description = "Beat 5 rounds of Bushtrimmer in a row on Expert", iconFile = "boom", secret = false, gariiPoints = 50},
        {save = "bt-exp-speed", title = "Horticulturist", description = "Beat a round of Bushtrimmer on Expert in under two minutes", iconFile = "shears", secret = false, gariiPoints = 75},
    },
    
    ["fuzzlings!"] = {
        {save = "fl-everyfruit", title = "Pic-a-nic Basket", description = "Gather Every Food and Drink in Fuzzlings!", iconFile = "", secret = false, gariiPoints = 10},
        {save = "fl-everytrash", title = "Junkyard", description = "Collect Every Type of Trash in Fuzzlings!", iconFile = "", secret = false, gariiPoints = 25},
        {save = "fl-16levels", title = "Salad Dressing", description = "Beat 16 Levels in Fuzzlings!", iconFile = "", secret = false, gariiPoints = 20},
        {save = "fl-64levels", title = "Sandwich Tower", description = "Beat 64 Levels in Fuzzlings!", iconFile = "", secret = false, gariiPoints = 50},
        --{save = "fl-256levels", title = "Byte Overflow", description = "Beat the 256/0th Level in Fuzzlings!", iconFile = "", secret = false, gariiPoints = 100},
        --{save = "fl-512levels", title = "Exquisitely Stuffed", description = "Beat the 256/0th Level With Both Boy and Girl", iconFile = "", secret = false, gariiPoints = 250},
        {save = "fl-deaths", title = "Knuckle Sandwich", description = "Die to every fuzzling as both Boy and Girl", iconFile = "", secret = false, gariiPoints = 25},
    }
}

local falseSave = {["garii's-mod"] = {{true, 1737474278}, nil, nil, {true, 1737474278}, {true, 1937474278}}, ["bushtrimmer"] = {{true, 1737474278}, {true, 1737474278}, {true, 1937474278}, {true, 1937474278}, {true, 1737474278}, {true, 1937474278}}}
local gameNames = {"Garii's Mod", "Some Time At Garii's", "SKOBELOFF CASINO", "Bushtrimmer", "Fuzzlings!"}
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
    playSound(fold.."openmenu")
    utils:setGariiData("achievements", falseSave)

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

    for i=1,#gameNames do
        makeLuaSprite("gameIcon"..i, fold.."/icons/game", offset.x+9, offset.y+(68.5*(i-1)) + 5)
        quickAddScrollSprite("gameIcon"..i)

        makeLuaText('gameTitleTxt'..i, gameNames[i])
        utils:quickFormatTxt('gameTitleTxt'..i, "segoe.ttf", 25, "000000")
        setProperty('gameTitleTxt'..i..".x", offset.x + 75)
        setProperty('gameTitleTxt'..i..".y", offset.y + math.floor((68.5*(i-1))) + 1)
        quickAddScrollSprite('gameTitleTxt'..i, true)
        
        makeLuaText('gameUnlockTxt'..i, tallyGameAmt(utils:lwrKebab(gameNames[i])).." of "..(utils:tableLen(achievements[utils:lwrKebab(gameNames[i])])).." Achievements")
        utils:quickFormatTxt('gameUnlockTxt'..i, "segoe.ttf", 24, "000000")
        setProperty('gameUnlockTxt'..i..".x", offset.x + 75)
        setProperty('gameUnlockTxt'..i..".y", offset.y + math.floor((68.5*(i-1))) + 31)
        quickAddScrollSprite('gameUnlockTxt'..i, true)

        makeAnimatedLuaSprite("gariiPointIcon"..i, fold.."gariipoints", offset.x+817, offset.y+(68.5*(i-1)) + 25)
        addAnimationByPrefix("gariiPointIcon"..i, "sel", "sel")
        addAnimationByPrefix("gariiPointIcon"..i, "desel", "desel")
        quickAddScrollSprite("gariiPointIcon"..i)

        makeLuaText('gariiPointTxt'..i, ""..tallyGameScore(utils:lwrKebab(gameNames[i])))
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
    setObjectCamera(name, "other")
    setProperty(name..".visible", initShow)
    if (isText) then addLuaText(name)
    else addLuaSprite(name)
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
            openGameAchievements(gameNames[curSel])
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

        if (keyJustPressed("ui_up") and utils:tableLen(achievements[utils:lwrKebab(gameNames[curSel])]) > 8) then changeAch(-8)
        elseif (keyJustPressed("ui_down") and utils:tableLen(achievements[utils:lwrKebab(gameNames[curSel])]) > 8) then changeAch(8)   
        elseif (keyJustPressed("ui_left")) then changeAch(-1)    
        elseif (keyJustPressed("ui_right")) then changeAch(1)     
        end
    end
end

function openGameAchievements(game)
    curAch = 1
    for i,spr in pairs(scrollVariables) do
        doTweenAlpha(spr.."tween", spr, 0, 0.1)
    end

    makeLuaSprite("gameTopBox", fold.."gamegradient", offset.x, offset.y)
    scaleObject("gameTopBox", 864, 1)
    setProperty("gameTopBox.alpha", 0)
    quickAddGameSprite("gameTopBox")
    
    makeLuaText('gameNameTxt', game)
    utils:quickFormatTxt('gameNameTxt', "segoe.ttf", 24, "FFFFFF")
    setProperty('gameNameTxt.x', offset.x + 16)
    setProperty('gameNameTxt.y', offset.y + 13)
    quickAddGameSprite('gameNameTxt', true)
    
    makeAnimatedLuaSprite("gariiPoints", fold.."gariipoints", offset.x+864-44, offset.y+ 22)
    addAnimationByPrefix("gariiPoints", "sel", "sel")
    quickAddGameSprite("gariiPoints")

    makeLuaText('gameScoreTxt', achievements[utils:lwrKebab(game)][curAch].gariiPoints)
    utils:quickFormatTxt('gameScoreTxt', "segoe.ttf", 24, "FFFFFF")
    setProperty('gameScoreTxt.x', offset.x + 416)
    setProperty('gameScoreTxt.y', offset.y + 13)
    quickAddGameSprite('gameScoreTxt', true)
    
    makeLuaText('achDateTxt', os.date("%m".."/".."%d".."/".."%Y", getAchievementSave(utils:lwrKebab(game), 1)[2]):upper())
    utils:quickFormatTxt('achDateTxt', "segoe.ttf", 24, "BFC8CD")
    setProperty('achDateTxt.x', offset.x + 416)
    setProperty('achDateTxt.y', offset.y + 47)
    quickAddGameSprite('achDateTxt', true)

    makeLuaText('achNameTxt', achievements[utils:lwrKebab(game)][curAch].title)
    utils:quickFormatTxt('achNameTxt', "segoe.ttf", 24, "BFC8CD")
    setProperty('achNameTxt.x', offset.x + 16)
    setProperty('achNameTxt.y', offset.y + 47)
    quickAddGameSprite('achNameTxt', true)
    
    makeLuaText('descNameTxt', achievements[utils:lwrKebab(game)][curAch].description,0,0,832)
    utils:quickFormatTxt('descNameTxt', "segoe.ttf", 24, "BFC8CD")
    setProperty('descNameTxt.x', offset.x + 16)
    setProperty('descNameTxt.y', offset.y + 82)
    quickAddGameSprite('descNameTxt', true)
    
    makeLuaSprite("gameSelectBox", fold.."selectgradient", offset.x + 38, offset.y + 175.5)
    scaleObject("gameSelectBox", 100, 1)
    setProperty("gameSelectBox.alpha", 0)
    quickAddGameSprite("gameSelectBox")

    for i,stats in pairs(achievements[utils:lwrKebab(game)]) do
        local saveShit = getAchievementSave(utils:lwrKebab(game), i)
        local iconThing = "lockedach"
        if (saveShit[1] == true) then iconThing = "award" end
        if (checkFileExists("images/"..fold.."icons/"..stats.iconFile..'.png')) then iconThing = stats.iconFile end
        makeLuaSprite("gameAchievement"..i, fold.."icons/"..iconThing, offset.x + 56 + (((i-1)%8) * 99), offset.y + 193.5 + (math.floor((i-1)/8) * 100))
        setGraphicSize("gameAchievement"..i, 64, 64)
        setProperty("gameAchievement"..i..".alpha", 0)
        quickAddGameSprite("gameAchievement"..i)
    end

    makeLuaText('gameUnlockTxt', tallyGameAmt(utils:lwrKebab(game)).." of "..(utils:tableLen(achievements[utils:lwrKebab(game)])).." unlocked")
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
    if (curSel < 1) then curSel = #gameNames
    elseif (curSel > #gameNames) then curSel = 1
    end
    if (curSel ~= lastSel) then playMoveSound() end

    setProperty("menuSelectBack.y", math.min(math.max(offset.y + (68.5 * (curSel-1)), offset.y), offset.y + (68.5 * 6)))
    for i=1,#gameNames do
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
    if (curAch < 1) then curAch = utils:tableLen(achievements[utils:lwrKebab(gameNames[curSel])])
    elseif (curAch > utils:tableLen(achievements[utils:lwrKebab(gameNames[curSel])])) then curAch = 1
    end
    if (curAch ~= lastAch) then playMoveSound() end

    setProperty("gameSelectBox.x", offset.x + 38 + (((curAch-1)%8) * 99))
    setProperty("gameSelectBox.y", offset.y + 175.5 + (math.floor((curAch-1)/8) * 99))
    setTextString("achNameTxt", achievements[utils:lwrKebab(gameNames[curSel])][curAch].title)
    setTextString("descNameTxt", achievements[utils:lwrKebab(gameNames[curSel])][curAch].description)
    local dateUnlock = os.date("%m".."/".."%d".."/".."%Y", getAchievementSave(utils:lwrKebab(gameNames[curSel]), curAch)[2]):upper()
    if (getAchievementSave(utils:lwrKebab(gameNames[curSel]), curAch)[2] == nil) then dateUnlock = "" end
    if (stringStartsWith(dateUnlock, "0")) then dateUnlock = string.sub(dateUnlock, 2, #dateUnlock) end
    setTextString("achDateTxt", dateUnlock)
    setProperty("achDateTxt.x", offset.x + 864 - (getProperty("achDateTxt.width") + 22))
    setTextString("gameScoreTxt", achievements[utils:lwrKebab(gameNames[curSel])][curAch].gariiPoints)
    setProperty("gameScoreTxt.x", offset.x + 864 - (getProperty("gameScoreTxt.width") + 50))
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

function getAchievementSave(cat, ind)
    if (utils:getGariiData("achievements") == nil) then utils:setGariiData("achievements", {}) end
    local save = utils:getGariiData("achievements")
    if (save[cat] == nil or save[cat][ind] == nil) then 
        return {false, nil} 
    end
    return save[cat][ind]
end

function tallyGameScore(game)
    local score = 0
    for i,ach in pairs(achievements[game]) do
        if (getAchievementSave(game,i)[1] == true) then
            score = score + ach.gariiPoints
        end
    end
    return score
end

function tallyGameAmt(game)
    local score = 0
    for i,ach in pairs(achievements[game]) do
        if (getAchievementSave(game,i)[1] == true) then
            score = score + 1
        end
    end
    return score
end

function onTimerCompleted(tmr, loops, loopsLeft)
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
    callOnLuas("toggleCursor", {true})
    for i,spr in pairs(backVariables) do
        removeLuaSprite(spr, true)
        removeLuaText(spr, true)
    end
    closeCustomSubstate("achievementsMenu")
    close()
end