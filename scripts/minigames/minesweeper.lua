local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local pfFont = (require (getVar("folDir").."scripts.objects.fontHandler")):new("poker-freak")

local fold = "minigames/minesweeper/"
local diffs = {"Beginner","Novice","Intermediate","Advanced","Expert","Custom"}
local diffStats = {
    ["beginner"] = {width = 9, height = 9, mines = 10, flowers = 0},
    ["novice"] = {width = 16, height = 16, mines = 40, flowers = 0},
    ["intermediate"] = {width = 36, height = 18, mines = 99, flowers = 0},
    ["advanced"] = {width = 18, height = 18, mines = 60, flowers = 2},
    ["expert"] = {width = 30, height = 16, mines = 99, flowers = 4}
}
local curDiff = 1
local canPlay, canChoose = false, true
local time = -1
local x = 0
local y = 0
local width = 0
local height = 0
local mines = 0
local flowers = 0
local diff = "reg"
local data = {}
local queuedUpTiles = {}

function startMinigame()
    utils:setWindowTitle("Friday Night Funkin': GARII'S ARCADE: Bushtrimmer")
    setProperty("camHUD.zoom", 2)
    callOnScripts("initCursor")

    makeLuaSprite('grass',fold..'grass',320,180)
    quickAddSprite("grass")

    for i,dif in pairs(diffs) do
        makeLuaSprite(dif:lower(),fold..dif:lower(),359 + (200 * ((i-1)%3)),186 + (180 * math.floor((i-1) /3)))
        quickAddSprite(dif:lower())
    end
end

function firstTimeSetup()
    width = math.min(diffStats[utils:lwrKebab(diffs[curDiff])].width, 36)
    height = math.min(diffStats[utils:lwrKebab(diffs[curDiff])].height, 18)
    x = (screenWidth - (width * 16)) / 2
    y = ((screenHeight - (height * 16)) / 2) + 16
    mines = math.min(diffStats[utils:lwrKebab(diffs[curDiff])].mines, math.floor((width * height) * 0.85))
    flowers = math.min(diffStats[utils:lwrKebab(diffs[curDiff])].flowers, 5)
    if (mines >= 99) then diff = "exp" end
    
    makeLuaSprite('minebgbgbg','',x - 12,y - 12)
    makeGraphic("minebgbgbg", (width * 16) + 24, (height * 16) + 24, "000000")
    quickAddSprite("minebgbgbg")

    makeLuaSprite('minebgbg','',x - 10,y - 10)
    makeGraphic("minebgbg", (width * 16) + 20, (height * 16) + 20, "7e464f")
    quickAddSprite("minebgbg")

    makeLuaSprite('minebg','',x - 2,y - 2)
    makeGraphic("minebg", (width * 16) + 4, (height * 16) + 4, "000000")
    quickAddSprite("minebg")
    
    makeAnimatedLuaSprite("smileyicon", fold.."smiley", 600,184)
    for _,anim in pairs{"reg-idle","reg-click","reg-dead","reg-win","exp-idle","exp-click","exp-dead","exp-win"} do
        addAnimationByPrefix("smileyicon", anim, anim)
    end
    playAnim("smileyicon", diff.."-idle")
    screenCenter("smileyicon", "x")
    quickAddSprite("smileyicon")

    makeLuaSprite("timeicon", fold.."timething", 0,184)
    quickAddSprite("timeicon")
    
    makeLuaSprite("mineicon", fold.."lemine", 0,185)
    quickAddSprite("mineicon")

    pfFont:createNewText("timeTxt", 0, 190, "0")
    pfFont:setTextCamera("timeTxt", "hud")
        
    pfFont:createNewText("mineTxt", 0, 190, mines.."")
    pfFont:setTextCamera("mineTxt", "hud")

    setupGame()
end

function setupGame()
    time = 0
    data.mines = {}
    data.flowers = {}
    data.opentiles = {}
    data.flaggedtiles = {}
    data.markedtiles = {}

    while #data.mines < mines do
        local newmine = {getRandomInt(1, width), getRandomInt(1, height)}
        if not (compareIndexTables(data.mines, newmine)) then
            table.insert(data.mines, newmine)
        end
    end

    if (flowers >= 1) then
        while #data.flowers < flowers do
            local newflwr = {getRandomInt(1, width), getRandomInt(1, height)}
            if (not (compareIndexTables(data.mines, newflwr) or compareIndexTables(data.flowers, newflwr))) then
                table.insert(data.flowers, newflwr)
            end
        end
    end

    for i = 1,height do
        for j=1,width do
            removeLuaSprite("tile"..i.."-"..j)
            makeAnimatedLuaSprite("tile"..i.."-"..j, fold.."tiles", x + ((j-1) * 16), y + ((i-1) * 16))
            addAnimationByPrefix("tile"..i.."-"..j, "reg", "tilereg", 24, true)
            addAnimationByPrefix("tile"..i.."-"..j, "open", "tileopen", 24, true)
            addAnimationByPrefix("tile"..i.."-"..j, "dead", "tiledead", 24, true)
            quickAddSprite("tile"..i.."-"..j)

            if (compareIndexTables(data.mines, {j,i})) then
                local curMine = bigIndexOf(data.mines, {j,i}) --prevents desync because a simple counter can sometimes... be wrong
                removeLuaSprite("mine"..curMine)
                makeAnimatedLuaSprite("mine"..curMine, fold.."tiles", x + ((j-1) * 16), y + ((i-1) * 16))
                addAnimationByPrefix("mine"..curMine, "reg", "mine", 24, true)
                quickAddSprite("mine"..curMine, false)
            elseif (compareIndexTables(data.flowers, {j,i})) then
                local curFlwr = bigIndexOf(data.flowers, {j,i})
                removeLuaSprite("flower"..curFlwr)
                makeAnimatedLuaSprite("flower"..curFlwr, fold.."tiles", x + ((j-1) * 16), y + ((i-1) * 16))
                addAnimationByPrefix("flower"..curFlwr, "reg", "flower", 24, true)
                addAnimationByPrefix("flower"..curFlwr, "open", "openflower", 24, true)
                quickAddSprite("flower"..curFlwr, false)
            end
            removeLuaSprite("flag"..i.."-"..j)
            makeAnimatedLuaSprite("flag"..i.."-"..j, fold.."tiles", x + ((j-1) * 16), y + ((i-1) * 16))
            addAnimationByPrefix("flag"..i.."-"..j, "flag", "flag", 24, true)
            addAnimationByPrefix("flag"..i.."-"..j, "mark", "mark", 24, true)
            quickAddSprite("flag"..i.."-"..j, false)

            removeLuaSprite("data"..i.."-"..j)
            makeAnimatedLuaSprite("data"..i.."-"..j, fold.."infostuff", x + ((j-1) * 16), y + ((i-1) * 16))
            local adjcount = countAdjacentMines(j, i)
            local colours = {[0] = "ffffff"; "a284b9","9ad6ff","8fc79b","f4f3ad","dbaf85","ea9fd0","c55252","7e464f","ffffff","c0c0c0","635245","000000","4e7faf"}
            setProperty("data"..i.."-"..j..".color", getColorFromHex(colours[adjcount.mines]))
            if (adjcount.mines >= 1 and adjcount.flowers <= 0) then addAnimationByPrefix("data"..i.."-"..j, "num", adjcount.mines.."num", 24, true)
            elseif (adjcount.flowers >= 1) then addAnimationByPrefix("data"..i.."-"..j, "num", (adjcount.mines + adjcount.flowers).."fakenum", 24, true)
            else setProperty("data"..i.."-"..j..".color", getColorFromHex("434253"))
            end
            addAnimationByPrefix("data"..i.."-"..j, "x", "x", 24, true)
            quickAddSprite("data"..i.."-"..j, false)
        end
    end

    checkForOptimalStartPos()
    playSound("minigames/start")
    runTimer("timerup",0.0000001)

    playAnim("smileyicon", diff.."-idle")
    pfFont:setTextString("mineTxt", ""..(mines-(#data.flaggedtiles)))
    pfFont:screenCenter("mineTxt", "X")
    pfFont:setTextX("mineTxt", pfFont:getTextX("mineTxt") + 120)
    setProperty("mineicon.x", pfFont:getTextX("mineTxt") - 24)
    canPlay = true
end

function quickAddSprite(spr, visible)
    setProperty(spr..".visible", visible == nil or visible == true)
    setProperty(spr..".antialiasing", false)
    setProperty(spr..".active", false) --optimization
    setObjectCamera(spr, "hud")
    addLuaSprite(spr)
end

function onUpdate()
    if (keyJustPressed("back")) then
        callOnLuas("placeStickers")
        runTimer("destroy", 1)
        canPlay = false
     end

    if (luaSpriteExists("smileyicon")) then
        if ((mouseReleased() or mouseReleased("right")) and utils:mouseWithinBounds({getProperty("smileyicon.x"),getProperty("smileyicon.y"), getProperty("smileyicon.x")+getProperty("smileyicon.width"),getProperty("smileyicon.y")+getProperty("smileyicon.height")}, "hud")) then
            cancelTimer("delayboom")
            stopSound("winmusic")
            setupGame()
        end
    end
    if (canPlay) then
        if (mousePressed() and utils:mouseWithinBounds({x,y, x + (16 * width),y + (16 * height)}, "hud")) then
            playAnim("smileyicon", diff.."-click")
        end

        if (mouseReleased() or mouseReleased("right")) then
            playAnim("smileyicon", diff.."-idle")
            if (utils:mouseWithinBounds({x,y, x + (16 * width),y + (16 * height)}, "hud")) then
                interactWithTile(math.floor(1 + (getMouseX("camHUD") - x) / 16), math.floor(1 + (getMouseY("camHUD") - y) / 16), mouseReleased("right"))
            end
        end
        while #queuedUpTiles >= 1 do
            interactWithTile(queuedUpTiles[1][1],queuedUpTiles[1][2], false, true)
            table.remove(queuedUpTiles, 1)
        end
        if (#data.flaggedtiles == mines) then
            checkFlaggedTiles()
        end
        if (#data.opentiles == ((width * height) - mines)) then
            winStuff()
        end
    end

    if (not canChoose) then return end
    local curChoice = 0
    for i,spr in pairs(diffs) do
        local dif = utils:lwrKebab(spr)
        if (utils:mouseWithinBounds({getProperty(dif..".x"), getProperty(dif..".y"), getProperty(dif..".x")+getProperty(dif..".width"), getProperty(dif..".y")+getProperty(dif..".height")}, "hud")) then
            curChoice = i
        end
    end
    if (curChoice ~= 0) then callOnLuas("cursorPlayAnim", {"enter"})
        if ((mouseReleased() or mouseReleased("right"))) then
            debugPrint("dick")
            canChoose = false
            curDiff = curChoice
            for _,jif in pairs(diffs) do
                removeLuaSprite(utils:lwrKebab(jif))
            end
            firstTimeSetup()
            canPlay = true
            callOnLuas("cursorPlayAnim")
        end
    else callOnLuas("cursorPlayAnim")
    end
end

function interactWithTile(tilex, tiley, flag, massopen)
    if (tilex < 1 or tiley < 1) then return end
    flag = flag or false
    massopen = massopen or false
    playAnim("smileyicon", diff.."-idle")
    if not compareIndexTables(data.opentiles, {tilex, tiley}) then
        if (flag) then
            if compareIndexTables(data.markedtiles, {tilex, tiley}) then
                data.markedtiles[bigIndexOf(data.markedtiles, {tilex, tiley})] = nil
            elseif compareIndexTables(data.flaggedtiles, {tilex, tiley}) then
                data.flaggedtiles[bigIndexOf(data.flaggedtiles, {tilex, tiley})] = nil
                table.insert(data.markedtiles, {tilex, tiley})
                playAnim("flag"..tiley.."-"..tilex, "mark")
            else
                table.insert(data.flaggedtiles, {tilex, tiley})
                playAnim("flag"..tiley.."-"..tilex, "flag")
            end
            setProperty("flag"..tiley.."-"..tilex..".visible", compareIndexTables(data.flaggedtiles, {tilex, tiley}) or compareIndexTables(data.markedtiles, {tilex, tiley}))
            pfFont:setTextString("mineTxt", ""..(mines-(#data.flaggedtiles)))
            pfFont:screenCenter("mineTxt", "X")
            pfFont:setTextX("mineTxt", pfFont:getTextX("mineTxt") + 120)
            setProperty("mineicon.x", pfFont:getTextX("mineTxt") - 24)
        elseif (not compareIndexTables(data.flaggedtiles, {tilex, tiley})) and (not compareIndexTables(data.markedtiles, {tilex, tiley})) then
            if compareIndexTables(data.mines, {tilex, tiley}) then
                canPlay = false
                cancelTimer("timerup")
                if (countAdjacentMines(tilex, tiley).mines == 9) then
                    playAnim("tile"..tiley.."-"..tilex, "9mines")
                    playSound("minigames/fuckedup")
                    runTimer("delayboom", 2)
                else loseStuff()
                    playAnim("tile"..tiley.."-"..tilex, "dead")
                end
            else
                table.insert(data.opentiles, {tilex, tiley})
                if compareIndexTables(data.flowers, {tilex, tiley}) then
                    playAnim("flower"..(bigIndexOf(data.flowers, {tilex, tiley})), "open")
                    setProperty("flower"..(bigIndexOf(data.flowers, {tilex, tiley}))..".visible", true)
                else setProperty("data"..tiley.."-"..tilex..".visible", true)
                end
                local adjtiles = countAdjacentMines(tilex, tiley)
                playAnim("tile"..tiley.."-"..tilex, "open")
                if ((adjtiles.mines + adjtiles.flowers) < 1 and (not compareIndexTables(data.flowers, {tilex, tiley}))) then
                    if (not luaSoundExists("bigclick")) and (not massopen) then playSound("minigames/click", 1, "bigclick") end
                    intWithAdjTiles(tilex, tiley)
                end
            end
        end
    end
end

function loseStuff()
    canPlay = false
    playAnim("smileyicon", diff.."-dead")
    revealMines(true)
end

function revealMines(bad)
    bad = bad or false
    for i = 1,#data.mines do
        if (bad) then playSound("minigames/lose_minesweeper", 1, "losemine") end
        setProperty("mine"..i..".visible", true)
    end
    for i = 1,#data.flaggedtiles do
        if (not compareIndexTables(data.mines, data.flaggedtiles[i])) then
            playAnim("data"..data.flaggedtiles[i][2].."-"..data.flaggedtiles[i][1], "x")
            setProperty("data"..data.flaggedtiles[i][2].."-"..data.flaggedtiles[i][1]..".color", getColorFromHex("7e464f"))
            setProperty("data"..data.flaggedtiles[i][2].."-"..data.flaggedtiles[i][1]..".visible", true)
        end
    end
    for i = 1,#data.flowers do
        setProperty("flower"..i..".visible", true)
    end
end

function intWithAdjTiles(tilex, tiley)
    for i= tiley-1, tiley+1 do
        for j= tilex-1, tilex+1 do
            if (not ((j == tilex and i == tiley) or (j < 1 or j > width or i < 1 or i > height))) then --likes to open up tiles that are out of bounds, screwing with the open tile counter
                table.insert(queuedUpTiles, {j,i})
            end
        end
    end
end

function countAdjacentMines(tilex, tiley)
    local minecount = 0
    local adjTiles = {{-1,-1},{0,-1},{1,-1},{-1,0},{1,0},{-1,1},{0,1},{1,1}}
    for _,t in pairs(adjTiles) do
        if (compareIndexTables(data.mines, {tilex + t[1], tiley + t[2]})) then
            minecount = minecount + 1
        end
    end
    if (flowers <= 0) then return {mines = minecount, flowers = 0} end
    local flowercount = 0
    local adjTilesBig = {{-2,-2},{-1,-2},{0,-2},{1,-2},{2,-2},{-2,-1},{-1,-1},{0,-1},{1,-1},{2,-1},{-2,0},{-1,0},{1,0},{2,0},{-2,1},{-1,1},{0,1},{1,1},{2,1},{-2,2},{-1,2},{0,2},{1,2},{2,2}}
    for _,t in pairs(adjTilesBig) do
        if (compareIndexTables(data.flowers, {tilex + t[1], tiley + t[2]})) then
            flowercount = flowercount + 1
        end
    end
    return {mines = minecount, flowers = flowercount}
end

function checkFlaggedTiles()
    local win = true
    if (#data.flaggedtiles ~= mines) then return end
    for _,tile in pairs(data.flaggedtiles) do
        if (not compareIndexTables(data.mines, tile)) then
            win = false
        end
    end
    if (win) then winStuff() end
end

function winStuff()
    canPlay = false
    cancelTimer("timerup")
    playAnim("smileyicon", diff.."-win")
    playSound("results/resultsEXCELLENT", 1, "winmusic")
    revealMines()
end

function checkForOptimalStartPos()
    local stinkyspaces = {}
    for i = 1,height do
        for j=1,width do
            if (countAdjacentMines(j,i).mines == 0 and countAdjacentMines(j,i).flowers == 0 and j>math.floor((width/9)*2) and i>math.floor((height/9)*2) and i<height-math.floor((width/9)*2) and j<width-math.floor((height/9)*2)) then table.insert(stinkyspaces, {j,i}) end
        end
    end
    if (#stinkyspaces < 1) then return end

    local highscoremines = mines
    local bestpos = {}
    for _,tile in pairs(stinkyspaces) do
        if (not (compareIndexTables(data.mines, {tile[1], tile[2]}) or compareIndexTables(data.flowers, {tile[1], tile[2]}))) then
            local minecount = 0
            for i= (tile[2]-math.floor((height/9)*2)), (tile[2]+math.floor((height/9)*2)) do
                for j= (tile[1]-math.floor((width/9)*2)), (tile[1]+math.floor((width/9)*2)) do
                    if (compareIndexTables(data.mines, {j,i})) then --wonder if flowers will fuck shit up
                        minecount = minecount + 1
                    end
                end
            end
            if (minecount < highscoremines) then 
                highscoremines = minecount
                bestpos = tile
            end
        end
    end
    if (#bestpos < 1) then return end
    setProperty("data"..bestpos[2].."-"..bestpos[1]..".visible", true)
end


function compareIndexTables(bigtable, indexes)
    if (#bigtable < 1 or #indexes < 2) then return false end
    for _,var in pairs(bigtable) do
        if (var[1] == indexes[1] and var[2] == indexes[2]) then
            return true
        end
    end
    return false
end

function bigIndexOf(bigtable, indexes)
    if (#bigtable < 1 or #indexes < 2) then return nil end
    for i,var in pairs(bigtable) do
        if (var[1] == indexes[1] and var[2] == indexes[2]) then
            return i
        end
    end
    return nil
end

function onTimerCompleted(tag)
    if tag == "delayboom" then loseStuff()
    elseif tag == "timerup" then time = time + 1
        pfFont:setTextString("timeTxt", time.."")
        pfFont:screenCenter("timeTxt", "X")
        pfFont:setTextX("timeTxt", pfFont:getTextX("timeTxt") - 100)
        setProperty("timeicon.x", pfFont:getTextX("timeTxt") - 25)
        runTimer("timerup", 1)
    elseif tag == "destroy" then onDestroy()
    end
end

function onDestroy()
    canPlay = false
    setProperty("camHUD.zoom", 1)
    stopSound("winmusic")
    for _,tmr in pairs({"delayboom", "timerup", "destroy"}) do cancelTimer(tmr) end
    for _,spr in pairs({"blankBG", "minebgbgbg", "minebgbg", "minebg", "timeicon", "mineicon", "smileyicon", "grass"}) do removeLuaSprite(spr) end
    for i = 1,height do
        for j=1,width do 
            removeLuaSprite("tile"..i.."-"..j)
            removeLuaSprite("flag"..i.."-"..j)
            removeLuaSprite("data"..i.."-"..j)
        end
    end
    for i = 1,mines do removeLuaSprite("mine"..i) end
    for i = 1,flowers do removeLuaSprite("flower"..i) end
    for _,jif in pairs(diffs) do
        removeLuaSprite(utils:lwrKebab(jif))
    end
    pfFont:destroyAll()
    close()
    callOnLuas("backToMinigameHUB")
end