local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local pfFont = (require (getVar("folDir").."scripts.objects.fontHandler")):new("poker-freak")

local fold = "minigames/minesweeper/"
local canPlay = true
local time = -1
local x = 256
local y = 128
local width = 36
local height = 18
local mines = 70
local minesleft = 0
local diff = "reg"
local data = {}
local queuedUpTiles = {}

function startMinigame()
    utils:setWindowTitle("Friday Night Funkin': GARII'S ARCADE: Bushtrimmer")
    setProperty("camHUD.zoom", 2)
    callOnScripts("initCursor")

    utils:makeBlankBG("blankBG", screenWidth,screenHeight, "000000", "hud")

    width = math.min(width, 36)
    height = math.min(height, 18)
    x = (screenWidth - (width * 16)) / 2
    y = ((screenHeight - (height * 16)) / 2) + 16
    mines = math.min(mines, math.floor((width * height) * 0.85))
    if (mines >= 99) then diff = "exp" end
    
    makeLuaSprite('grass',fold..'grass',x-32,y-52)
    setProperty("grass.antialiasing", false)
    addLuaSprite('grass')
    setObjectCamera('grass', 'hud')

    makeLuaSprite('minebgbgbg','',x - 12,y - 12)
    makeGraphic("minebgbgbg", (width * 16) + 24, (height * 16) + 24, "000000")
    addLuaSprite('minebgbgbg')
    setObjectCamera('minebgbgbg', 'hud')

    makeLuaSprite('minebgbg','',x - 10,y - 10)
    makeGraphic("minebgbg", (width * 16) + 20, (height * 16) + 20, "7e464f")
    addLuaSprite('minebgbg')
    setObjectCamera('minebgbg', 'hud')

    makeLuaSprite('minebg','',x - 2,y - 2)
    makeGraphic("minebg", (width * 16) + 4, (height * 16) + 4, "000000")
    addLuaSprite('minebg')
    setObjectCamera('minebg', 'hud')
    
    makeAnimatedLuaSprite("smileyicon", fold.."smiley", 600,184)
    for _,anim in pairs{"reg-idle","reg-click","reg-dead","reg-win","exp-idle","exp-click","exp-dead","exp-win"} do
        addAnimationByPrefix("smileyicon", anim, anim)
    end
    playAnim("smileyicon", diff.."-idle")
    screenCenter("smileyicon", "x")
    setObjectCamera("smileyicon", "hud")
    setProperty("smileyicon.antialiasing", false)
    addLuaSprite("smileyicon")

    makeLuaSprite("timeicon", fold.."timething", 0,184)
    setObjectCamera("timeicon", "hud")
    setProperty("timeicon.antialiasing", false)
    addLuaSprite("timeicon")
    
    makeLuaSprite("mineicon", fold.."lemine", 0,185)
    setObjectCamera("mineicon", "hud")
    setProperty("mineicon.antialiasing", false)
    addLuaSprite("mineicon")

    pfFont:createNewText("timeTxt", 0, 190, "0")
    pfFont:setTextCamera("timeTxt", "hud")
        
    pfFont:createNewText("mineTxt", 0, 190, mines.."")
    pfFont:setTextCamera("mineTxt", "hud")

    setupGame()
end

function setupGame()
    time = 0
    for i = 1,height do
        for j=1,width do
            removeLuaSprite("tile"..i.."-"..j)
            makeAnimatedLuaSprite("tile"..i.."-"..j, fold.."minesweeper", x + ((j-1) * 16), y + ((i-1) * 16))
            addAnimationByPrefix("tile"..i.."-"..j, "reg", "tilereg", 24, true)
            addAnimationByPrefix("tile"..i.."-"..j, "start", "tilestart", 24, true)
            addAnimationByPrefix("tile"..i.."-"..j, "marked", "tileunsure", 24, true)
            addAnimationByPrefix("tile"..i.."-"..j, "flagged", "tileflagged", 24, true)
            addAnimationByPrefix("tile"..i.."-"..j, "mine", "tilemine", 24, true)
            addAnimationByPrefix("tile"..i.."-"..j, "minetrigger", "tiletriggeredmine", 24, true)
            addAnimationByPrefix("tile"..i.."-"..j, "flaggedmine", "tilecorrectflag", 24, true)
            addAnimationByPrefix("tile"..i.."-"..j, "wrongflag", "tilewrongflag", 24, true)
            for k=0,9 do addAnimationByPrefix("tile"..i.."-"..j, k.."mines", "tile"..k.."mines", 24, true) end
            setProperty("tile"..i.."-"..j..".antialiasing", false)
            playAnim("tile"..i.."-"..j, "reg")
            addLuaSprite("tile"..i.."-"..j)
            setObjectCamera("tile"..i.."-"..j, "hud")
        end
    end
    data.mines = {}
    data.opentiles = {}
    data.flaggedtiles = {}
    data.markedtiles = {}

    while #data.mines < mines do
        local newmine = {getRandomInt(1, width), getRandomInt(1, height)}
        if not (compareIndexTables(data.mines, newmine)) then 
            table.insert(data.mines, newmine) 
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

function onUpdate()
    if (keyJustPressed("back")) then 
        callOnLuas("placeStickers")
        runTimer("destroy", 1)
        canPlay = false
     end

    if ((mouseReleased() or mouseReleased("right")) and utils:mouseWithinBounds({getProperty("smileyicon.x"),getProperty("smileyicon.y"), getProperty("smileyicon.x")+getProperty("smileyicon.width"),getProperty("smileyicon.y")+getProperty("smileyicon.height")}, "hud")) then
        setupGame()
    end

    if (not canPlay) then return end
    if (mousePressed() and utils:mouseWithinBounds({x,y, x + (16 * width),y + (16 * height)}, "hud")) then
        playAnim("smileyicon", diff.."-click")
    end

    if ((mouseReleased() or mouseReleased("right"))) then
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
                playAnim("tile"..tiley.."-"..tilex, "reg")
            elseif compareIndexTables(data.flaggedtiles, {tilex, tiley}) then
                data.flaggedtiles[bigIndexOf(data.flaggedtiles, {tilex, tiley})] = nil
                table.insert(data.markedtiles, {tilex, tiley})
                playAnim("tile"..tiley.."-"..tilex, "marked")
            else
                table.insert(data.flaggedtiles, {tilex, tiley})
                playAnim("tile"..tiley.."-"..tilex, "flagged")
            end
            pfFont:setTextString("mineTxt", ""..(mines-(#data.flaggedtiles)))
            pfFont:screenCenter("mineTxt", "X")
            pfFont:setTextX("mineTxt", pfFont:getTextX("mineTxt") + 120)
            setProperty("mineicon.x", pfFont:getTextX("mineTxt") - 24)
        elseif (not compareIndexTables(data.flaggedtiles, {tilex, tiley})) and (not compareIndexTables(data.markedtiles, {tilex, tiley})) then
            if compareIndexTables(data.mines, {tilex, tiley}) then
                canPlay = false
                cancelTimer("timerup")
                if (countAdjacentMines(tilex, tiley) == 9) then 
                    playAnim("tile"..tiley.."-"..tilex, "9mines")
                    playSound("minigames/fuckedup")
                    runTimer("delayboom", 2)
                else revealMines()
                    playAnim("tile"..tiley.."-"..tilex, "minetrigger")
                end
            else
                table.insert(data.opentiles, {tilex, tiley})
                local adjmines = countAdjacentMines(tilex, tiley)
                playAnim("tile"..tiley.."-"..tilex, adjmines.."mines")
                if (adjmines < 1) then
                    if (not luaSoundExists("bigclick")) and (not massopen) then playSound("minigames/click", 1, "bigclick") end
                    intWithAdjTiles(tilex, tiley)
                end
            end
        end
    end
end

function revealMines()
    playAnim("smileyicon", diff.."-dead")
    for _,tile in pairs(data.mines) do
        playSound("minigames/lose_minesweeper", 1, "losemine")
        if (compareIndexTables(data.flaggedtiles, {tile[1], tile[2]})) then playAnim("tile"..tile[2].."-"..tile[1], "flaggedmine")
        else playAnim("tile"..tile[2].."-"..tile[1], "mine")
        end
    end
    for _,tile in pairs(data.flaggedtiles) do
        if not (compareIndexTables(data.mines, {tile[1], tile[2]})) then playAnim("tile"..tile[2].."-"..tile[1], "wrongflag") end
    end
end

function intWithAdjTiles(tilex, tiley)
    for i= tiley-1, tiley+1 do
        for j= tilex-1, tilex+1 do
            if not (j == tilex and i == tiley) then
                table.insert(queuedUpTiles, {j,i})
            end
        end
    end
end

function countAdjacentMines(tilex, tiley)
    local minecount = 0
    for i= tiley-1, tiley+1 do
        for j= tilex-1, tilex+1 do
            if (compareIndexTables(data.mines, {j,i})) then
                minecount = minecount + 1
            end
        end
    end
    return minecount
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
    playSound("results/resultsEXCELLENT")
end

function checkForOptimalStartPos()
    local stinkyspaces = {}
    for i = 1,height do
        for j=1,width do
            if (countAdjacentMines(j,i) == 0 and j>math.floor((width/9)*2) and i>math.floor((height/9)*2) and i<height-math.floor((width/9)*2) and j<width-math.floor((height/9)*2)) then table.insert(stinkyspaces, {j,i}) end
        end
    end
    if (#stinkyspaces < 1) then return end

    local highscoremines = mines
    local bestpos = {}
    for _,tile in pairs(stinkyspaces) do
        local minecount = 0
        for i= (tile[2]-math.floor((height/9)*2)), (tile[2]+math.floor((height/9)*2)) do
            for j= (tile[1]-math.floor((width/9)*2)), (tile[1]+math.floor((width/9)*2)) do
                if (compareIndexTables(data.mines, {j,i})) then
                    minecount = minecount + 1
                end
            end
        end
        if (minecount < highscoremines) then 
            highscoremines = minecount
            bestpos = tile
        end
    end
    if (#bestpos < 1) then return end
    playAnim("tile"..bestpos[2].."-"..bestpos[1], "start")
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

function onTimerCompleted(tag, left, elp)
    if tag == "delayboom" then revealMines() 
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
    for _,tmr in pairs({"delayboom", "timerup", "destroy"}) do cancelTimer(tmr) end
    for _,spr in pairs({"blankBG", "minebgbgbg", "minebgbg", "minebg", "timeicon", "mineicon", "smileyicon", "grass"}) do removeLuaSprite(spr) end
    for i = 1,height do
        for j=1,width do removeLuaSprite("tile"..i.."-"..j, true) end
    end
    pfFont:destroyAll()
    close()
    callOnLuas("backToMinigameHUB")
end