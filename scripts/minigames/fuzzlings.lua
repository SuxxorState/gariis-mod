local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local font = (require (getVar("folDir").."scripts.objects.fontHandler")):new("rom-byte")
local fldr = "minigames/fuzzlings/"

local gameOffsets = {x = 528, y = 240}
local trucker = {}
local ghost = {}
local dirIndex = {["right"] = {x = 1, y = 0}, ["down"] = {x = 0, y = 1}, ["left"] = {x = -1, y = 0}, ["up"] = {x = 0, y = -1}}
local levelFruits = {"carrot", "grapes", "pineapple", "lemon", "cherries", "salad", "sandwich", "spirit"}
local fruitPoints = {["carrot"] = 100, ["grapes"] = 300, ["pineapple"] = 500, ["lemon"] = 700, ["cherries"] = 1000, ["salad"] = 2000, ["sandwich"] = 3000, ["spirit-boy"] = 4000, ["spirit-girl"] = 4000, ["tire"] = 5000, ["notebook"] = 5000, ["bottle"] = 5000, ["can"] = 5000, ["mic"] = 10000}
local plrColours = {["boy"] = "4E7FAF", ["girl"] = "C55252"}
local plrChar = "girl"
local fruitDisp = {}
local curFruit = "carrot"
local levelColour = "4d664d"
local lives = 5
local extraLifeGiven = false
local curLevel = 1
local pelletCount, maxPellets = 0, 0
local blinkVis = true
local score, highScore = 0, 0
local canUpdate = false
local baseMap = {--0 is for walls, 1 is for paths, 2 is for pellets, 3 is for energizers, 4 is for fruits, 5 is for ghost-only-- any collectable nums fall back to 1 when collected
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,2,2,2,2,2,3,0,0,2,2,2,2,2,2,2,2,2,2,0,0,3,2,2,2,2,2,0},
    {0,2,0,0,0,0,2,0,0,2,0,0,0,0,0,0,0,0,2,0,0,2,0,0,0,0,2,0},
    {0,2,0,0,0,0,2,0,0,2,0,0,0,0,0,0,0,0,2,0,0,2,0,0,0,0,2,0},
    {0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0},
    {0,2,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,2,0},
    {0,2,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,2,0},
    {0,2,2,2,2,2,2,0,0,2,2,2,2,0,0,2,2,2,2,0,0,2,2,2,2,2,2,0},
    {0,0,0,2,0,0,2,0,0,0,0,0,1,0,0,1,0,0,0,0,0,2,0,0,2,0,0,0},
    {0,0,0,2,0,0,2,0,0,0,0,0,1,0,0,1,0,0,0,0,0,2,0,0,2,0,0,0},
    {0,0,0,2,0,0,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,0,0,2,0,0,0},
    {0,0,0,2,0,0,2,0,0,1,0,0,0,5,5,0,0,0,1,0,0,2,0,0,2,0,0,0},
    {2,2,2,2,0,0,2,0,0,1,0,5,5,5,5,5,5,0,1,0,0,2,0,0,2,2,2,2},
    {0,0,0,0,0,0,2,0,0,1,0,5,5,5,5,5,5,0,1,0,0,2,0,0,0,0,0,0},
    {0,0,0,0,0,0,2,0,0,1,0,5,5,5,5,5,5,0,1,0,0,2,0,0,0,0,0,0},
    {2,2,2,2,0,0,2,0,0,1,0,5,5,5,5,5,5,0,1,0,0,2,0,0,2,2,2,2},
    {0,0,0,2,0,0,2,0,0,1,0,0,0,0,0,0,0,0,1,0,0,2,0,0,2,0,0,0},
    {0,0,0,2,0,0,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,0,0,2,0,0,0},
    {0,0,0,2,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,2,0,0,0},
    {0,0,0,2,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,2,0,0,0},
    {0,2,2,2,2,2,2,2,2,2,2,2,2,0,0,2,2,2,2,2,2,2,2,2,2,2,2,0},
    {0,2,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0},
    {0,2,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0},
    {0,2,2,2,2,2,0,0,2,2,2,2,2,1,1,2,2,2,2,2,0,0,2,2,2,2,2,0},
    {0,0,0,0,0,2,0,0,0,0,0,0,2,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0},
    {0,0,0,0,0,2,0,0,0,0,0,0,2,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0},
    {0,2,2,2,2,3,0,0,2,2,2,2,2,0,0,2,2,2,2,2,0,0,3,2,2,2,2,0},
    {0,2,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0},
    {0,2,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0},
    {0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
}
local map = {}

function startMinigame()
    utils:setWindowTitle("Friday Night Funkin': GARII'S ARCADE: Fuzzlings!")
    callOnLuas("toggleCursor", {false})
    setProperty("camHUD.zoom", 2)
    setVar("pacMapBase", baseMap)

    if (utils:getGariiData("fuzzlingsHighScore") == nil) then utils:setGariiData("fuzzlingsHighScore", 0) end
    highScore = utils:getGariiData("fuzzlingsHighScore")

    utils:makeBlankBG("blankBG", screenWidth,screenHeight, "111111", "hud")

    makeLuaSprite("fuzzMap", fldr.."map", gameOffsets.x, gameOffsets.y)
    setProperty("fuzzMap.antialiasing", false)
    setProperty("fuzzMap.color", getColorFromHex(levelColour))
    setObjectCamera("fuzzMap", "hud")
    addLuaSprite("fuzzMap")

    makeLuaSprite("ghostDoor", "", gameOffsets.x + 104, gameOffsets.y + 93)
    makeGraphic("ghostDoor", 16,2, "FFFFFF")
    setObjectCamera("ghostDoor", "hud")
    addLuaSprite("ghostDoor")

    makeAnimatedLuaSprite("truckPlayer", fldr..plrChar.."-mini", gameOffsets.x + 112, gameOffsets.y + 184)
    for i,anim in pairs({"left", "down", "up", "right"}) do
        addAnimationByPrefix("truckPlayer", "walk-"..anim, "walk "..anim, 12)
        addOffset("truckPlayer", "walk-"..anim, 4,4)
        addAnimationByPrefix("truckPlayer", "idle-"..anim, "idle "..anim)
        addOffset("truckPlayer", "idle-"..anim, 4,4)
    end
    addAnimationByPrefix("truckPlayer", "idle-down-start", "idle down")
    addOffset("truckPlayer", "idle-down-start", 8,4)
    setProperty("truckPlayer.antialiasing", false)
    setObjectCamera("truckPlayer", "hud")
    addLuaSprite("truckPlayer")

    makeAnimatedLuaSprite("andy", fldr.."fuzzling", gameOffsets.x + 112, gameOffsets.y + 80)
    for i,anim in pairs({"left", "down", "up", "right"}) do
        addAnimationByPrefix("andy", "andy-"..anim, "andy-"..anim, 8)
        addOffset("andy", "andy-"..anim, 4,4)
    end
    playAnim("andy", "andy-right")
    setProperty("andy.antialiasing", false)
    setObjectCamera("andy", "hud")
    addLuaSprite("andy")
    
    font:createNewText("levelTxt", gameOffsets.x + 24, gameOffsets.y - 24, "LEVEL "..curLevel, "left", "FFFFFF", "hud")
    font:createNewText("scoreTxt", gameOffsets.x + 32, gameOffsets.y - 16, score.."", "left", "FFFFFF", "hud")
    font:createNewText("highScore", gameOffsets.x + 120, gameOffsets.y - 24, "HI SCORE:SUX", "left", "FFFFFF", "hud")
    font:createNewText("hiScrTxt", gameOffsets.x + 192, gameOffsets.y - 16, highScore.."", "right", "FFFFFF", "hud")
    font:createNewText("readyUp", gameOffsets.x + 89, gameOffsets.y + 136, "READY!", "left", plrColours[plrChar], "hud")
    updateLives(false)
    
    makeLuaSprite("bnyuBorder", fldr.."border", 0, 0)
    setObjectCamera("bnyuBorder", "other")
    addLuaSprite("bnyuBorder", true)

    runTimer("blinkLoop", 0.2)
    reloadMap()
end

function reloadMap() --hopefully seperating this as its own function reduces a bit of lag and load on the pc
    map = getVar("pacMapBase")

    if (math.floor((curLevel/2)+0.5) > #levelFruits) then
        local trash = {"tire", "notebook", "bottle", "can"}
        curFruit = trash[getRandomInt(1,#trash)]
        if (curLevel % 10 == 0) then curFruit = "mic" end
    elseif (levelFruits[math.floor((curLevel/2)+0.5)] == "spirit") then
        curFruit = levelFruits[math.floor((curLevel/2)+0.5)].."-"..plrChar
    else
        curFruit = levelFruits[math.floor((curLevel/2)+0.5)]
    end
    table.insert(fruitDisp, curFruit)
    if (#fruitDisp>7) then table.remove(fruitDisp,1) end
    removeLuaSprite("picnicFruit")
    makeAnimatedLuaSprite("picnicFruit", fldr.."fruits", gameOffsets.x + 104, gameOffsets.y + 132)
    addAnimationByPrefix("picnicFruit", "idle", curFruit)
    setProperty("picnicFruit.antialiasing", false)
    setProperty("picnicFruit.visible", false)
    setObjectCamera("picnicFruit", "hud")
    addLuaSprite("picnicFruit")
    setObjectOrder("picnicFruit", getObjectOrder("truckPlayer"))
    updateFruitIndis()

    for i=1,#utils:numToStr(fruitPoints[curFruit]) do
        local lenOffs = {[3] = 4, [4] = 1, [5] = -1}
        local extraOff = 0
        if (#utils:numToStr(fruitPoints[curFruit]) % 2 == 0 and i > 1) then
            extraOff = 1
        end
        removeLuaSprite("fruitPoint"..i)
        makeAnimatedLuaSprite("fruitPoint"..i, fldr.."pointnums", gameOffsets.x + 96 + (5 * i) + lenOffs[#utils:numToStr(fruitPoints[curFruit])] + extraOff, gameOffsets.y + 136)
        addAnimationByPrefix("fruitPoint"..i, "idle", font:sheetName(utils:numToStr(fruitPoints[curFruit])[i]))
        setProperty("fruitPoint"..i..".antialiasing", false)
        setProperty("fruitPoint"..i..".visible", false)
        setObjectCamera("fruitPoint"..i, "hud")
        addLuaSprite("fruitPoint"..i)
        setObjectOrder("fruitPoint"..i, getObjectOrder("truckPlayer"))
    end

    maxPellets = 0
    pelletCount = 0
    for a,row in ipairs(map) do
        for b,squ in ipairs(row) do
            local y = a-1
            local x = b-1
            if (squ == 2) then
                removeLuaSprite("pellet"..x.." "..y)
                makeLuaSprite("pellet"..x.." "..y, "", gameOffsets.x + (x*8) + 3, gameOffsets.y + (y * 8) + 3)
                makeGraphic("pellet"..x.." "..y, 2, 2, "FFFFFF")
                setObjectCamera("pellet"..x.." "..y, "hud")
                addLuaSprite("pellet"..x.." "..y)
                setObjectOrder("pellet"..x.." "..y, getObjectOrder("truckPlayer"))
                maxPellets = maxPellets + 1
            elseif (squ == 3) then
                removeLuaSprite("energizer"..x.." "..y)
                makeLuaSprite("energizer"..x.." "..y, fldr.."energizer", gameOffsets.x + (x*8), gameOffsets.y + (y * 8))
                setObjectCamera("energizer"..x.." "..y, "hud")
                setProperty("energizer"..x.." "..y..".antialiasing", false)
                addLuaSprite("energizer"..x.." "..y)
                setObjectOrder("energizer"..x.." "..y, getObjectOrder("truckPlayer"))
                maxPellets = maxPellets + 1
            end
        end
    end

    trucker = {targetCoords = {x = 14, y = 23}, moveDir = {x = 0, y = 0}, queueDir = {x = 0, y = 0}, queueQueueDir = {x = 0, y = 0}}
    ghost = {targetCoords = {x = 14, y = 10}, moveDir = {x = 1, y = 0}, queueDir = {x = 1, y = 0}, queueQueueDir = {x = 0, y = 0}, lastMoveDir = {x = 0, y = 0}}
    setProperty("andy.x", gameOffsets.x + 112)
    setProperty("andy.y", gameOffsets.y + 80)
    setProperty("truckPlayer.x", gameOffsets.x + 112)
    setProperty("truckPlayer.y", gameOffsets.y + 184)
    playAnim("truckPlayer", "idle-down-start")

    font:setTextVisible("readyUp", true)
    font:setTextString("levelTxt", "LEVEL "..curLevel)
    setProperty("fuzzMap.color", getColorFromHex(levelColour))
    utils:makeBlankBG("blankFG", screenWidth,screenHeight, "111111", "other")
    setProperty("blankFG.visible", false)

    utils:playSound(fldr.."start", 1, "start")
end

function onUpdate(elp)
    if (not canUpdate) then return end

    if (keyJustPressed("back")) then
        callOnLuas("placeStickers")
        runTimer("destroyGame", 1)
        canUpdate = false
    end

    handlePellets()
    handleGhostMovement()
    handlePlayerMovement()
    font:setTextString("scoreTxt", score)
    if (score >= highScore) then 
        highScore = score
        utils:setGariiData("fuzzlingsHighScore", score)
        font:setTextString("hiScrTxt", highScore)
    end
end

function handlePellets()
    if (map[trucker.targetCoords.y+1][trucker.targetCoords.x+1] == 2) then
        utils:playSound(fldr.."eat_dot_"..(pelletCount%2))
        pelletCount = pelletCount + 1
        removeLuaSprite("pellet"..(trucker.targetCoords.x).." "..(trucker.targetCoords.y), true)
        map[trucker.targetCoords.y+1][trucker.targetCoords.x+1] = 1
        score = score + 10
    elseif (map[trucker.targetCoords.y+1][trucker.targetCoords.x+1] == 3) then
        utils:playSound(fldr.."fright", 1, "frightloop")
        runTimer("fright", 10)
        pelletCount = pelletCount + 1
        removeLuaSprite("energizer"..(trucker.targetCoords.x).." "..(trucker.targetCoords.y), true)
        map[trucker.targetCoords.y+1][trucker.targetCoords.x+1] = 1
        score = score + 50
    elseif (map[trucker.targetCoords.y+1][trucker.targetCoords.x+1] == 4) then
        utils:playSound(fldr.."eat_fruit")
        for y,row in ipairs(map) do for x,squ in ipairs(row) do
            if (squ == 4) then map[y][x] = 1 end
        end end
        setProperty("picnicFruit.visible", false)
        score = score + fruitPoints[curFruit]

        if (curLevel <= 16) then
            local fruitList = utils:getGariiData("FUZZfruits") or {}
            if (not utils:tableContains(fruitList, curFruit)) then
                table.insert(fruitList, curFruit)
                utils:setGariiData("FUZZfruits", fruitList)
                local achievementDone = true
                for _,fru in pairs(levelFruits) do
                    if (curLevel >= 15) then
                        if (not (utils:tableContains(fruitList, fru.."-boy") or utils:tableContains(fruitList, fru.."-girl"))) then --you have to get BOTH... mwahahaha
                            achievementDone = false
                        end
                    else
                        if (not utils:tableContains(fruitList, thing)) then
                            achievementDone = false
                        end
                    end
                end
                if (achievementDone) then
                    callOnLuas("unlockAchievement", {"fl-everyfruit"})
                end
            end
        else
            local trashList = utils:getGariiData("FUZZtrash") or {}
            if (not utils:tableContains(trashList, curFruit)) then
                table.insert(trashList, curFruit)
                utils:setGariiData("FUZZtrash", trashList)
                local achievementDone = true
                for _,tra in pairs({"tire", "notebook", "bottle", "can", "mic"}) do
                    if (not utils:tableContains(trashList, tra)) then
                        achievementDone = false
                    end
                end
                if (achievementDone) then
                    callOnLuas("unlockAchievement", {"fl-everytrash"})
                end
            end
        end
        
        for i=1,#utils:numToStr(fruitPoints[curFruit]) do
            setProperty("fruitPoint"..i..".visible", true)
        end
        cancelTimer("fruitDisappear")
        runTimer("fruitPointDisappear", 2)
    end
    for y,row in ipairs(map) do for x,squ in ipairs(row) do
        if (luaSpriteExists("energizer"..(x-1).." "..(y-1))) then 
            setProperty("energizer"..(x-1).." "..(y-1)..".visible", blinkVis) 
        end
    end end

    if (pelletCount >= maxPellets) then canUpdate = false
        runTimer("completedLevelI", 2)
        stopSound("frightloop")
    elseif (pelletCount == 70 or pelletCount == 170) then spawnFruit()
    end
    if (score >= 10000 and not extraLifeGiven) then
        extraLifeGiven = true
        utils:playSound(fldr.."extend")
        lives = lives + 1
        updateLives(true)
    end
end

function spawnFruit()
    map[18][14] = 4
    map[18][15] = 4
    setProperty("picnicFruit.visible", true)
    runTimer("fruitDisappear", 10)
end

function updateLives(extra)
    if (extra == nil) then extra = false end
    for i=1,6 do
        if ((not luaSpriteExists("life"..i)) and lives > i) then
            makeLuaSprite("life"..i, fldr..plrChar.."-life", gameOffsets.x + (i * 16), gameOffsets.y + (31*8))
            setProperty("life"..i..".antialiasing", false)
            setObjectCamera("life"..i, "hud")
            addLuaSprite("life"..i)
            if (extra) then runTimer("lifeFlash"..i, 0.25, 8) end
        elseif (luaSpriteExists("life"..i) and lives <= i) then 
            removeLuaSprite("life"..i, true)
        end
    end
end

function updateFruitIndis()
    for i=1,7 do
        if (i > #fruitDisp) then return end
        removeLuaSprite("fruitDisp"..i)
        makeAnimatedLuaSprite("fruitDisp"..i, fldr.."fruits", gameOffsets.x + (210 - (i*16)), gameOffsets.y + (31*8))
        addAnimationByPrefix("fruitDisp"..i, "idle", fruitDisp[i])
        setProperty("fruitDisp"..i..".antialiasing", false)
        setObjectCamera("fruitDisp"..i, "hud")
        addLuaSprite("fruitDisp"..i)
    end
end

function rerollGhostMove()
    local dirz = {{x = 1, y = 0}, {x = -1, y = 0}, {x = 0, y = -1}, {x = 0, y = 1}}
    local triedDirz = {}

    for _=1,4 do
        local theInt = getRandomInt(1,4, table.concat(triedDirz,","))
        local point = dirz[theInt]
        local fuckassMapPos = map[ghost.targetCoords.y+1+point.y][ghost.targetCoords.x+1+point.x]
        local yCheck = true
        local xCheck = true
        if (point.x ~= 0 and ghost.lastMoveDir.x ~= 0) then
            xCheck = (point.x ~= -ghost.lastMoveDir.x)
        end
        if (point.y ~= 0 and ghost.lastMoveDir.y ~= 0) then
            yCheck = (point.y ~= -ghost.lastMoveDir.y)
        end
        if (fuckassMapPos ~= 0 and fuckassMapPos ~= 5 and (ghost.targetCoords.x < 28 and ghost.targetCoords.x > 0) and xCheck and yCheck) then --lol?
            ghost.queueDir = point
            local animDirz = {"right", "left", "up", "down"}
            playAnim("andy", "andy-"..animDirz[theInt])
            return
        end
        table.insert(triedDirz, theInt)
    end
end

function handleGhostMovement()
    if (not luaSpriteExists("andy")) then return end

    if ((getProperty("andy.x")-gameOffsets.x)/8 == ghost.targetCoords.x and (getProperty("andy.y")-gameOffsets.y)/8 == ghost.targetCoords.y) then
        rerollGhostMove()
        if (ghost.queueDir.x ~= ghost.moveDir.x) then 
            ghost.moveDir.x = ghost.queueDir.x
        end
        if (ghost.queueDir.y ~= ghost.moveDir.y) then 
            ghost.moveDir.y = ghost.queueDir.y
        end

        if (map[ghost.targetCoords.y+1+ghost.queueDir.y][ghost.targetCoords.x+1+ghost.queueDir.x] ~= nil and map[ghost.targetCoords.y+1][ghost.targetCoords.x + ghost.moveDir.x+1] == 0) then 
            ghost.moveDir.x = 0
        end
        ghost.targetCoords.x = ghost.targetCoords.x + ghost.moveDir.x

        if (map[ghost.targetCoords.y+1+ghost.queueDir.y][ghost.targetCoords.x+1+ghost.queueDir.x] ~= nil and map[ghost.targetCoords.y + ghost.moveDir.y+1][ghost.targetCoords.x+1] == 0) then 
            ghost.moveDir.y = 0 
        end
        ghost.lastMoveDir.x = ghost.moveDir.x
        ghost.lastMoveDir.y = ghost.moveDir.y
        ghost.targetCoords.y = ghost.targetCoords.y + ghost.moveDir.y
    end

    if ((getProperty("andy.x")-gameOffsets.x)/8 ~= ghost.targetCoords.x and ghost.moveDir.x ~= 0) then
        setProperty("andy.x", getProperty("andy.x") + (ghost.moveDir.x))
    end

    if ((getProperty("andy.y")-gameOffsets.y)/8 ~= ghost.targetCoords.y and ghost.moveDir.y ~= 0) then
        setProperty("andy.y", getProperty("andy.y") + (ghost.moveDir.y))
    end
    
    if ((getProperty("andy.x")-gameOffsets.x)/8 < -1) then 
        ghost.targetCoords.x = 29
        setProperty("andy.x", gameOffsets.x+(ghost.targetCoords.x*8))
    elseif ((getProperty("andy.x")-gameOffsets.x)/8 > 29) then 
        ghost.targetCoords.x = -1
        setProperty("andy.x", gameOffsets.x+(ghost.targetCoords.x*8))
    end
end

function handlePlayerMovement()
    if (not luaSpriteExists("truckPlayer")) then return end

    for key,_ in pairs(dirIndex) do
        if (keyJustPressed("ui_"..key)) then 
            trucker.queueQueueDir = dirIndex[key] 
        end
    end

    if (trucker.targetCoords.x == ghost.targetCoords.x and trucker.targetCoords.y == ghost.targetCoords.y) then
        debugPrint("ass")
    end

    local fuckassMapPos = map[trucker.targetCoords.y+1+trucker.queueQueueDir.y][trucker.targetCoords.x+1+trucker.queueQueueDir.x]
    if (fuckassMapPos ~= 0 and fuckassMapPos ~= 5 and (trucker.targetCoords.x < 28 and trucker.targetCoords.x > 0)) then --lol?
        trucker.queueDir = trucker.queueQueueDir
    end

    if ((getProperty("truckPlayer.x")-gameOffsets.x)/8 == trucker.targetCoords.x and (getProperty("truckPlayer.y")-gameOffsets.y)/8 == trucker.targetCoords.y) then
        if (trucker.queueDir.x ~= trucker.moveDir.x) then 
            trucker.moveDir.x = trucker.queueDir.x
        end
        if (map[trucker.targetCoords.y+1+trucker.queueQueueDir.y][trucker.targetCoords.x+1+trucker.queueQueueDir.x] ~= nil and map[trucker.targetCoords.y+1][trucker.targetCoords.x + trucker.moveDir.x+1] == 0) then 
            if (trucker.moveDir.x < 1) then playAnim("truckPlayer", "idle-left")
            else playAnim("truckPlayer", "idle-right")
            end
            trucker.moveDir.x = 0
        end
        trucker.targetCoords.x = trucker.targetCoords.x + trucker.moveDir.x

        if (trucker.queueDir.y ~= trucker.moveDir.y) then 
            trucker.moveDir.y = trucker.queueDir.y 
        end
        if (map[trucker.targetCoords.y+1+trucker.queueQueueDir.y][trucker.targetCoords.x+1+trucker.queueQueueDir.x] ~= nil and map[trucker.targetCoords.y + trucker.moveDir.y+1][trucker.targetCoords.x+1] == 0) then 
            if (trucker.moveDir.y < 1) then playAnim("truckPlayer", "idle-up")
            else playAnim("truckPlayer", "idle-down")
            end
            trucker.moveDir.y = 0 
        end
        trucker.targetCoords.y = trucker.targetCoords.y + trucker.moveDir.y
    end

    if ((getProperty("truckPlayer.x")-gameOffsets.x)/8 ~= trucker.targetCoords.x and trucker.moveDir.x ~= 0) then
        setProperty("truckPlayer.x", getProperty("truckPlayer.x") + (trucker.moveDir.x))
        if (trucker.moveDir.x > 0) then playAnim("truckPlayer", "walk-right")
        else playAnim("truckPlayer", "walk-left")
        end
    end

    if ((getProperty("truckPlayer.y")-gameOffsets.y)/8 ~= trucker.targetCoords.y and trucker.moveDir.y ~= 0) then
        setProperty("truckPlayer.y", getProperty("truckPlayer.y") + (trucker.moveDir.y))
        if (trucker.moveDir.y > 0) then playAnim("truckPlayer", "walk-down")
        else playAnim("truckPlayer", "walk-up")
        end
    end

    if ((getProperty("truckPlayer.x")-gameOffsets.x)/8 < -1) then 
        trucker.targetCoords.x = 29
        setProperty("truckPlayer.x", gameOffsets.x+(trucker.targetCoords.x*8))
    elseif ((getProperty("truckPlayer.x")-gameOffsets.x)/8 > 29) then 
        trucker.targetCoords.x = -1
        setProperty("truckPlayer.x", gameOffsets.x+(trucker.targetCoords.x*8))
    end
end

function onSoundFinished(snd)
    if (snd == "frightloop") then utils:playSound(fldr.."fright", 1, "frightloop")
    elseif (snd == "start") then canUpdate = true
        font:setTextVisible("readyUp", false)
    end
end

function onTimerCompleted(tmr, _, loopsLeft)
    if (tmr == "fright") then stopSound("frightloop")
    elseif (tmr == "fruitPointDisappear") then
        for i=1,#utils:numToStr(fruitPoints[curFruit]) do
            setProperty("fruitPoint"..i..".visible", false)
        end
    elseif (stringStartsWith(tmr, "lifeFlash")) then
        local curLife = stringSplit(tmr, "lifeFlash")[2]
        setProperty("life"..curLife..".visible", not getProperty("life"..curLife..".visible"))
    elseif (tmr == "fruitDisappear") then 
        for y,row in ipairs(map) do for x,squ in ipairs(row) do
            if (squ == 4) then map[y][x] = 1 end
        end end
        setProperty("picnicFruit.visible", false)
    elseif (tmr == "completedLevelI") then runTimer("completedLevelII", 0.2, 9)
    elseif (tmr == "completedLevelII") then
        if (getProperty("fuzzMap.color") == getColorFromHex("FFFFFF")) then setProperty("fuzzMap.color", getColorFromHex(levelColour))
        else setProperty("fuzzMap.color", getColorFromHex("FFFFFF"))
        end
        if (loopsLeft < 1) then
            runTimer("completedLevelIII", 0.25)
            setProperty("blankFG.visible", true)
        end
    elseif (tmr == "completedLevelIII") then
        curLevel = curLevel+1
        if (curLevel >= 64) then callOnLuas("unlockAchievement", {"fl-64levels"})
        elseif (curLevel >= 16) then callOnLuas("unlockAchievement", {"fl-16levels"})
        end
        reloadMap()
    elseif (tmr == "blinkLoop") then 
        blinkVis = not blinkVis
        runTimer("blinkLoop", 0.2)
    elseif (tmr == "destroyGame") then destroyGame()
    end
end

function destroyGame()
    for i,spr in pairs({"truckPlayer", "blankBG", "blankFG", "fuzzMap", "picnicFruit", "ghostDoor", "bnyuBorder", "andy"}) do removeLuaSprite(spr, true) end
    for y,row in ipairs(map) do for x,squ in ipairs(row) do
        if (luaSpriteExists("pellet"..(x-1).." "..(y-1))) then removeLuaSprite("pellet"..(x-1).." "..(y-1), true) end
        if (luaSpriteExists("energizer"..(x-1).." "..(y-1))) then removeLuaSprite("energizer"..(x-1).." "..(y-1), true) end
    end end
    for i=1,7 do
        removeLuaSprite("fruitDisp"..i, true)
        removeLuaSprite("life"..i, true)
    end

    font:destroyAll()
    callOnLuas("toggleCursor", {true})
    setProperty("camHUD.zoom", 1)
    callOnLuas("backToMinigameHUB")
    close()
end