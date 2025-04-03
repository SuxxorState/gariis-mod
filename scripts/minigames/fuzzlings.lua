local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local font = (require (getVar("folDir").."scripts.objects.fontHandler")):new("rom-byte")
local fldr = "minigames/fuzzlings/"

local gameOffsets = {x = 528, y = 240}
local trucker = {}
local ghostList = {"andy", "mandy", "randy", "brandy"}
local ghosts = {}
local dirIndex = {["right"] = {x = 1, y = 0}, ["down"] = {x = 0, y = 1}, ["left"] = {x = -1, y = 0}, ["up"] = {x = 0, y = -1}}
local levelFruits = {"carrot", "grapes", "pineapple", "lemon", "cherries", "salad", "sandwich", "spirit"}
local fruitPoints = {["carrot"] = 100, ["grapes"] = 300, ["pineapple"] = 500, ["lemon"] = 700, ["cherries"] = 1000, ["salad"] = 2000, ["sandwich"] = 3000, ["spirit-boy"] = 4000, ["spirit-girl"] = 4000, ["tire"] = 5000, ["notebook"] = 5000, ["bottle"] = 5000, ["can"] = 5000, ["mic"] = 10000}
local plrData = {["boy"] = {colour = "4E7FAF", icons = {0,2}, prefix = ""}, ["girl"] = {colour = "C55252", icons = {1,3}, prefix = ""}}
local plrChar = "girl"
local fruitDisp = {}
local curFruit = "carrot"
local levelColour = "4d664d"
local lives = 5
local extraLifeGiven = false
local curLevel = 0
local pelletCount, maxPellets = 0, 0
local blinkVis = true
local rebirths = 0
local score, highScore = 0, 0
local accX = 1 * getRandomInt(-1,1,"0")
local accY = -2
local canUpdate = false
local canTweenPlr = false
local ghostPointMult = 200
local charList, curChar = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}, 1
local placeholderLB = {{100, 0, "SUX"}, {90, 0, "XOR"}, {80, 0, "RAZ"}, {70, 0, "GAR"}, {60, 0, "LIN"}, {50, 0, "BKM"}, {40, 0, "PVG"}, {30, 0, "BEE"}, {20, 0, "AMO"}, {10, 0, "AST"}}
local playerName, hoveredChar, activatedName = "", "A", false
local noMorePlayerAnims = false
local zeroLoops = 5

local behaviorList, curAction = { --mimic pacman behaviors please!
    {{"scatter", 7}, {"pursue", 20}, {"scatter", 7}, {"pursue", 20}, {"scatter", 5}, {"pursue", 20}, {"scatter", 5}, {"pursue"}},
    {{"scatter", 7}, {"pursue", 20}, {"scatter", 7}, {"pursue", 20}, {"scatter", 5}, {"pursue", (17*60) + 13 + (14/framerate)}, {"scatter", 1/framerate}, {"pursue"}},
    {{"scatter", 7}, {"pursue", 20}, {"scatter", 7}, {"pursue", 20}, {"scatter", 5}, {"pursue", (17*60) + 13 + (14/framerate)}, {"scatter", 1/framerate}, {"pursue"}},
    {{"scatter", 7}, {"pursue", 20}, {"scatter", 7}, {"pursue", 20}, {"scatter", 5}, {"pursue", (17*60) + 13 + (14/framerate)}, {"scatter", 1/framerate}, {"pursue"}},
    {{"scatter", 5}, {"pursue", 20}, {"scatter", 5}, {"pursue", 20}, {"scatter", 5}, {"pursue", (17*60) + 17 + (14/framerate)}, {"scatter", 1/framerate}, {"pursue"}}
}, 0
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
    {0,0,0,2,0,0,2,0,0,1,0,0,0,5,0,0,0,0,1,0,0,2,0,0,2,0,0,0},
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
local altMap = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
}
local alterMap = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
}
local map = {}

function startMinigame()
    utils:setWindowTitle("Friday Night Funkin': GARII'S ARCADE: Fuzzlings!")
    utils:setDiscord("In GARII'S ARCADE", "Fuzzlings!")
    callOnLuas("toggleCursor", {false})
    setProperty("camHUD.zoom", 2)
    setVar("pacMapBase", baseMap)

    if (utils:getGariiData("fuzzLeaderboard") == nil) then utils:setGariiData("fuzzLeaderboard", placeholderLB) end
    highScore = utils:getGariiData("fuzzLeaderboard")[1][1]

    utils:makeBlankBG("blankBG", screenWidth,screenHeight, "000000", "hud")
    utils:makeBlankBG("blankBG2", 28*8,36*8, "111111", "hud")
    setProperty("blankBG2.x", gameOffsets.x)
    setProperty("blankBG2.y", gameOffsets.y-24)
        
    if (utils:getGariiData("lostSunnies")) then makeLuaSprite("bnyuBorderL", fldr.."borderleft-alt", 0, 0)
        plrData["girl"].prefix = "alt "
    else makeLuaSprite("bnyuBorderL", fldr.."borderleft", 0, 0)
    end
    utils:setObjectCamera("bnyuBorderL", "other")
    addLuaSprite("bnyuBorderL", true)
    if (utils:getGariiData("lostHat")) then makeLuaSprite("bnyuBorderR", fldr.."borderright-alt", 640, 0)
        plrData["boy"].prefix = "alt "
    else makeLuaSprite("bnyuBorderR", fldr.."borderright", 640, 0)
    end
    utils:setObjectCamera("bnyuBorderR", "other")
    addLuaSprite("bnyuBorderR", true)

    makeLuaSprite("fuzzMap", fldr.."map", gameOffsets.x, gameOffsets.y)
    setProperty("fuzzMap.antialiasing", false)
    setProperty("fuzzMap.color", getColorFromHex(levelColour))
    utils:setObjectCamera("fuzzMap", "hud")
    addLuaSprite("fuzzMap")

    makeLuaSprite("ghostDoor", "", gameOffsets.x + 104, gameOffsets.y + 93)
    makeGraphic("ghostDoor", 16,2, "FFFFFF")
    utils:setObjectCamera("ghostDoor", "hud")
    addLuaSprite("ghostDoor")

    for _,fuzz in pairs(ghostList) do
        makeAnimatedLuaSprite(fuzz, fldr.."fuzzling", 0,0)
        for _,anim in pairs({"left", "down", "up", "right", "fright", "eatenleft", "eatendown", "eatenup", "eatenright"}) do
            addAnimationByPrefix(fuzz, fuzz.."-"..anim, fuzz.."-"..anim, 8)
            addOffset(fuzz, fuzz.."-"..anim, 4,4)
            addAnimationByPrefix(fuzz, "house-"..anim, fuzz.."-"..anim, 8)
            addOffset(fuzz, "house-"..anim, 0,0)
        end
        playAnim(fuzz, fuzz.."-right")
        setProperty(fuzz..".antialiasing", false)
        utils:setObjectCamera(fuzz, "hud")
        addLuaSprite(fuzz, true)
    end

    makeAnimatedLuaSprite("truckPlayer", fldr..plrChar.."-mini", gameOffsets.x + 112, gameOffsets.y + 184)
    for i,anim in pairs({"left", "down", "up", "right"}) do
        addAnimationByPrefix("truckPlayer", "walk-"..anim, (plrData[plrChar].prefix).."walk "..anim, 12)
        addOffset("truckPlayer", "walk-"..anim, 4,4)
        addAnimationByPrefix("truckPlayer", "idle-"..anim, (plrData[plrChar].prefix).."idle "..anim)
        addOffset("truckPlayer", "idle-"..anim, 4,4)
    end
    addAnimationByPrefix("truckPlayer", "die", (plrData[plrChar].prefix).."die", 6)
    addOffset("truckPlayer", "die", 4,4)
    addAnimationByPrefix("truckPlayer", "idle-down-start", (plrData[plrChar].prefix).."idle down")
    addOffset("truckPlayer", "idle-down-start", 8,4)
    setProperty("truckPlayer.antialiasing", false)
    utils:setObjectCamera("truckPlayer", "hud")
    addLuaSprite("truckPlayer", true)
    
    font:createNewText("levelTxt", gameOffsets.x + 24, gameOffsets.y - 24, "LEVEL "..curLevel, "left", "FFFFFF", "hud")
    font:createNewText("scoreTxt", gameOffsets.x + 32, gameOffsets.y - 16, score.."", "left", "FFFFFF", "hud")
    font:createNewText("highScore", gameOffsets.x + 120, gameOffsets.y - 24, "HI SCORE:"..(utils:getGariiData("fuzzLeaderboard")[1][3]), "left", "FFFFFF", "hud")
    font:createNewText("hiScrTxt", gameOffsets.x + 192, gameOffsets.y - 16, highScore.."", "right", "FFFFFF", "hud")
    utils:makeBlankBG("readyBG", 48,8, "111111", "hud")
    setProperty("readyBG.x", gameOffsets.x + 88)
    setProperty("readyBG.y", gameOffsets.y + 136)
    font:createNewText("readyUp", gameOffsets.x + 89, gameOffsets.y + 136, "READY!", "left", plrData[plrChar].colour, "hud")
    updateLives(false)

    runTimer("blinkLoop", 0.2)
    reloadMap()
end

function reloadMap() --hopefully seperating this as its own function reduces a bit of lag and load on the pc
    if (curLevel <= 0) then reloadSecretMap()
        return
    else setVar("pacMapBase", baseMap)
        ghostList = {"andy", "mandy", "randy", "brandy"}
    end
    map = getVar("pacMapBase")
    utils:setDiscord("In GARII'S ARCADE", "Fuzzlings! (Level "..curLevel..")")

    if (curLevel > 0) then
        if (math.floor((curLevel/2)+0.5) > #levelFruits) then
            local trash = {"tire", "notebook", "bottle", "can"}
            curFruit = trash[getRandomInt(1,#trash)]
            if (curLevel % 10 == 0) then curFruit = "mic" end
        elseif (levelFruits[math.floor((curLevel/2)+0.5)] == "spirit") then
            curFruit = levelFruits[math.floor((curLevel/2)+0.5)].."-"..plrChar
        else
            curFruit = levelFruits[math.floor((curLevel/2)+0.5)]
        end
    end
    table.insert(fruitDisp, curFruit)
    if (#fruitDisp>7) then table.remove(fruitDisp,1) end
    removeLuaSprite("picnicFruit")
    makeAnimatedLuaSprite("picnicFruit", fldr.."fruits", gameOffsets.x + 104, gameOffsets.y + 132)
    addAnimationByPrefix("picnicFruit", "idle", curFruit)
    setProperty("picnicFruit.antialiasing", false)
    setProperty("picnicFruit.visible", false)
    utils:setObjectCamera("picnicFruit", "hud")
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
        utils:setObjectCamera("fruitPoint"..i, "hud")
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
                utils:setObjectCamera("pellet"..x.." "..y, "hud")
                addLuaSprite("pellet"..x.." "..y)
                setObjectOrder("pellet"..x.." "..y, getObjectOrder("truckPlayer"))
                maxPellets = maxPellets + 1
            elseif (squ == 3) then
                removeLuaSprite("energizer"..x.." "..y)
                makeLuaSprite("energizer"..x.." "..y, fldr.."energizer", gameOffsets.x + (x*8), gameOffsets.y + (y * 8))
                utils:setObjectCamera("energizer"..x.." "..y, "hud")
                setProperty("energizer"..x.." "..y..".antialiasing", false)
                addLuaSprite("energizer"..x.." "..y)
                setObjectOrder("energizer"..x.." "..y, getObjectOrder("truckPlayer"))
                maxPellets = maxPellets + 1
            end
        end
    end

    trucker = {targetCoords = {x = 14, y = 23}, moveDir = {x = 0, y = 0}, queueDir = {x = 0, y = 0}, queueQueueDir = {x = 0, y = 0}, facing = {x = 0, y = 0}}
    local ghostCoords = {["andy"] = {x = 14, y = 10, tmr = 0.001}, ["mandy"] = {x = 11, y = 12, tmr = 1}, ["randy"] = {x = 11, y = 14, tmr = 8}, ["brandy"] = {x = 15, y = 12, tmr = 10}, ["sandy"] = {x = 13, y = 14}, ["paul"] = {x = 15, y = 14}}
    for _,name in pairs(ghostList) do
        ghosts[name] = {x = ghostCoords[name].x, y = ghostCoords[name].y, targetCoords = ghostCoords[name], moveDir = {x = 1, y = 0}, inHouse = (name ~= "andy"), active = (name == "andy"), frightened = false, eaten = false}
        runTimer("initLeave"..name, ghostCoords[name].tmr)
        setProperty(name..".x", gameOffsets.x + (ghosts[name].targetCoords.x * 8))
        setProperty(name..".y", gameOffsets.y + (ghosts[name].targetCoords.y * 8))
        if (name ~= "andy") then playAnim(name, "house-up")
        else playAnim(name, "andy-up")
        end
    end
    setProperty("truckPlayer.x", gameOffsets.x + 112)
    setProperty("truckPlayer.y", gameOffsets.y + 184)
    playAnim("truckPlayer", "idle-down-start")
    updateLives()
    noMorePlayerAnims = false
    canTweenPlr = false
    accX = 1 * getRandomInt(-1,1,"0")
    accY = -2

    font:setTextString("levelTxt", "LEVEL "..curLevel)
    setProperty("fuzzMap.color", getColorFromHex(levelColour))
    utils:makeBlankBG("blankFG", screenWidth,screenHeight, "111111", "other")
    setProperty("blankFG.visible", false)

    readyErUp(1)
end

function reloadSecretMap()
    if (zeroLoops > 3) then setVar("pacMapBase", alterMap)
        loadGraphic("fuzzMap", fldr.."mapalt2")
        if (not luaSoundExists("music")) then
            stopSound("rain")
            utils:playSound(fldr.."somewhere_else", 1, "music")
        end
        addOffset("truckPlayer", "idle-up", 4,4)
        addOffset("truckPlayer", "walk-up", 4,4)
        addOffset("truckPlayer", "idle-down", 4,4)
        addOffset("truckPlayer", "walk-down", 4,4)
    else setVar("pacMapBase", altMap)
        loadGraphic("fuzzMap", fldr.."mapalt1")
        addOffset("truckPlayer", "idle-up", 8,4)
        addOffset("truckPlayer", "walk-up", 8,4)
        addOffset("truckPlayer", "idle-down", 8,4)
        addOffset("truckPlayer", "walk-down", 8,4)
    end
    map = getVar("pacMapBase")
    lives = 2 + math.min(zeroLoops, 3)
    setProperty("ghostDoor.visible", false)
    ghostList = {}
    utils:setDiscord("In GARII'S ARCADE", "Fuzzlings! (Level NaN)")
    setProperty("bnyuBorderL.visible", false)
    setProperty("bnyuBorderR.visible", false)

    if (zeroLoops > 3) then
        removeLuaSprite("grave")
        makeAnimatedLuaSprite("grave", fldr.."grave", gameOffsets.x + 104, gameOffsets.y + 68)
        for _,anim in pairs({"init", "flowers-none", "flowers-boy", "flowers-girl", "flowers-couple"}) do
            addAnimationByPrefix("grave", anim, "grave"..anim)
        end
        if (zeroLoops == 4) then playAnim("grave", "init")
        else playAnim("grave", "flowers-none")
        end
        setProperty("grave.antialiasing", false)
        utils:setObjectCamera("grave", "hud")
        addLuaSprite("grave")
    end

    for i,char in pairs({"carv", "hunte", "garii"}) do
        removeLuaSprite(char)
        local loopFourOffsets = {{gameOffsets.x + 92},{gameOffsets.x + 124},{gameOffsets.x + 108}}
        local loopFiveOffsets = {{gameOffsets.x + 144, gameOffsets.y + 104},{gameOffsets.x + 128, gameOffsets.y + 72},{gameOffsets.x + 72, gameOffsets.y + 72}}
        if (zeroLoops > 4) then makeAnimatedLuaSprite(char, fldr..char.."-mini", loopFiveOffsets[i][1], loopFiveOffsets[i][2])
        elseif (zeroLoops > 3) then makeAnimatedLuaSprite(char, fldr..char.."-mini", loopFourOffsets[i][1], gameOffsets.y + 86 + (math.floor(i/3) * 80))
        else makeAnimatedLuaSprite(char, fldr..char.."-mini", gameOffsets.x + 108, (gameOffsets.y + (zeroLoops * 16) + 4) - (i * 16))
        end
        for _,anim in pairs({"left", "down", "up", "right"}) do
            addAnimationByPrefix(char, "walk-"..anim, "walk "..anim, 12)
            addOffset(char, "walk-"..anim, 4,4)
            addAnimationByPrefix(char, "idle-"..anim, "idle "..anim)
            addOffset(char, "idle-"..anim, 4,4)
        end
        local animList = {"idle-left", "idle-down", "idle-right"}
        if (zeroLoops > 4) then playAnim(char, animList[i])
        elseif (zeroLoops > 3 and char ~= "garii") then playAnim(char, "idle-up")
        else playAnim(char, "walk-up")
        end
        setProperty(char..".antialiasing", false)
        utils:setObjectCamera(char, "hud")
        addLuaSprite(char)
    end

    removeLuaSprite("visualBorder")
    makeLuaSprite("visualBorder", "", gameOffsets.x, gameOffsets.y-24)
    makeGraphic("visualBorder", 224,24, "111111")
    utils:setObjectCamera("visualBorder", "hud")
    addLuaSprite("visualBorder")

    if (zeroLoops == 4) then maxPellets = 0
    else maxPellets = 1
    end
    pelletCount = 0

    trucker = {targetCoords = {x = 14, y = 29}, moveDir = {x = 0, y = 0}, queueDir = {x = 0, y = 0}, queueQueueDir = {x = 0, y = 0}, facing = {x = 0, y = 0}}
    setProperty("truckPlayer.x", gameOffsets.x + 112)
    setProperty("truckPlayer.y", gameOffsets.y + 232)
    playAnim("truckPlayer", "idle-up")
    updateLives()
    local colours = {nil, "4d664d", "dbaf85", "f4f3ad"}
    for i=2,4 do
        addAnimation("life"..i, "reg", {8-i})
        setProperty("life"..i..".color", getColorFromHex(colours[i]))
    end
    noMorePlayerAnims = false
    canTweenPlr = false
    accX = 1 * getRandomInt(-1,1,"0")
    accY = -2

    font:setTextVisible("readyUp", zeroLoops ~= 4)
    font:setTextVisible("scoreTxt", false)
    font:setTextVisible("hiScrTxt", false)
    setProperty("fuzzMap.color", getColorFromHex(levelColour))
    utils:makeBlankBG("blankFG", screenWidth,screenHeight, "111111", "other")
    setProperty("blankFG.visible", false)
    if (zeroLoops >= 4) then font:createNewText("warningTxt", gameOffsets.x + 24, gameOffsets.y - 8, "(NOT QUITE READY YET.)", "left", plrData[plrChar].colour, "hud")
    else font:createNewText("warningTxt", gameOffsets.x + 32, gameOffsets.y - 24, "(NO NEED TO GO BACK.)", "left", plrData[plrChar].colour, "hud")
    end
    font:setTextVisible("warningTxt", false)

    readyErUp(0)
end

function readyErUp(volume)
    font:setTextVisible("readyUp", zeroLoops ~= 4 or curLevel > 0)
    setProperty("readyBG.visible", zeroLoops ~= 4 or curLevel > 0)
    utils:playSound(fldr.."eat_dot_0", volume, "start")
end

function advanceAction()
    curAction = curAction + 1
    ghosts.moveMode = behaviorList[math.min(curLevel, 5)][curAction][1]
    if (behaviorList[math.min(curLevel, 5)][curAction][2] == nil) then return end
    runTimer("advanceAction", behaviorList[math.min(curLevel, 5)][curAction][2])
end

function deathReset()
    setProperty("truckPlayer.x", gameOffsets.x + 112)
    setProperty("truckPlayer.y", gameOffsets.y + 184)
    trucker = {targetCoords = {x = 14, y = 23}, moveDir = {x = 0, y = 0}, queueDir = {x = 0, y = 0}, queueQueueDir = {x = 0, y = 0}, facing = {x = 0, y = 0}}
    playAnim("truckPlayer", "idle-down-start")
    updateLives()
    noMorePlayerAnims = false
    local ghostCoords = {["andy"] = {x = 14, y = 10, tmr = 0.001}, ["mandy"] = {x = 11, y = 12, tmr = 1}, ["randy"] = {x = 11, y = 14, tmr = 8}, ["brandy"] = {x = 15, y = 12, tmr = 10}, ["sandy"] = {x = 13, y = 14}, ["paul"] = {x = 15, y = 14}}
    for _,name in pairs(ghostList) do
        ghosts[name] = {x = ghostCoords[name].x, y = ghostCoords[name].y, targetCoords = ghostCoords[name], moveDir = {x = 1, y = 0}, inHouse = (name ~= "andy"), active = (name == "andy"), frightened = false, eaten = false}
        cancelTimer("initLeave"..name)
        runTimer("initLeave"..name, ghostCoords[name].tmr)
        setProperty(name..".x", gameOffsets.x + (ghosts[name].targetCoords.x * 8))
        setProperty(name..".y", gameOffsets.y + (ghosts[name].targetCoords.y * 8))
        setProperty(name..".visible", true)
        if (name ~= "andy") then playAnim(name, "house-up")
        else playAnim(name, "andy-up")
        end
    end

    canTweenPlr = false
    accX = 1 * getRandomInt(-1,1,"0")
    accY = -2

    readyErUp(0)
end

local textAdvance = {["garii"] = {1,1}, ["carv"] = {1,1}}
function onUpdate(elp)
    if (activatedName) then
        if (keyJustPressed("ui_up")) then scrollName(-1)
        elseif (keyJustPressed("ui_down")) then scrollName(1)
        elseif (keyJustPressed("ui_right") or keyJustPressed("accept")) then playerName = playerName..hoveredChar
            curChar = 1
            if (#utils:numToStr(playerName) >= 3) then activatedName = false
                finishLeaderboard()
            else scrollName(0)
            end
        elseif (keyJustPressed("ui_left") or keyJustPressed("back")) then
            local nameTable = utils:numToStr(playerName)
            playerName = ""
            if (#nameTable > 1) then for i=1,#nameTable-1 do
                playerName = playerName..nameTable[i]
            end end
            scrollName(0)
        end
    else
        if (keyJustPressed("back")) then
            callOnLuas("placeStickers")
            runTimer("destroyGame", 1)
            canUpdate = false
        end
    end

    if (luaSpriteExists("carv") and zeroLoops < 4) then
        for i,char in pairs({"carv", "hunte", "garii"}) do
            setProperty(char..".y", getProperty(char..".y") - 1)
            if (getProperty(char..".y") < gameOffsets.y-16) then
                removeLuaSprite(char)
                removeLuaSprite("life"..(i+1))
            end
        end
        if (keyJustPressed("ui_"..key)) then
            cancelTimer("warningDis")
            font:setTextVisible("warningTxt", false)
        end
    elseif (luaSpriteExists("garii") and zeroLoops == 4) then
        if (getProperty("garii.y") > gameOffsets.y + 86) then
            setProperty("garii.y", getProperty("garii.y") - 1)
            if (getProperty("garii.y") <= gameOffsets.y + 86) then
                playAnim("garii", "idle-up")
                runTimer("floweredGrave", 2.5)
            end
        end
    elseif (zeroLoops > 4) then
        if (keyJustPressed("accept")) then
            interactWithChar()
        end
        for key,_ in pairs(dirIndex) do
            if (keyJustPressed("ui_"..key)) then
                if (textAdvance["carv"][1] == 23 or textAdvance["carv"][1] == 24) then textAdvance["carv"][1] = 25 end
                cancelTimer("warningDis")
                font:setTextVisible("warningTxt", false)
                removeAllDatBabblin()
            end
        end
    end 
    if (canTweenPlr) then
        setProperty("truckPlayer.x", getProperty("truckPlayer.x") + accX)
        setProperty("truckPlayer.y", getProperty("truckPlayer.y") + accY)
        if (accX < 0) then accX = math.min(accX + 0.01, 0)
        else accX = math.max(accX - 0.01, 0)
        end
        accY = accY + math.min((0.1 * (math.abs(accY) + 0.1)), 0.25)
    end

    if (not canUpdate) then return end
    if (keyJustPressed("reset")) then
        lives = 0
        loseLife()
    end

    handlePellets()
    for _,ghst in pairs(ghostList) do
        handleGhostMovement(ghst)
        if (ghosts[ghst].eaten) then handleGhostMovement(ghst) end
    end
    handlePlayerMovement()
    font:setTextString("scoreTxt", score)
    if (score >= highScore) then
        highScore = score
        font:setTextString("highScore", "HI SCORE:YOU")
        font:setTextString("hiScrTxt", highScore)
    end
end

local textLines = {
    ["garii1"] = {{"...", "f4f3ad"}, {"(I SHOULD LEAVE HIM BE.)", plrData[plrChar].colour}},
    ["carv1"] = {
        {"HEY, CHUCK. COME TO PAY YOUR RESPECTS AS WELL?", "4d664d"}, {"that's awfully nice of  ya, especially since ya dont know 'em.", "4d664d"}, {"who died?", plrData[plrChar].colour},
        {"just a close friend of  ours.", "4d664d"}, {"their name's atlas, ringany bells?", "4d664d"}, {"not particularly, no.", plrData[plrChar].colour}, {"that's fine. da boss    told me yous aren't fromthese parts.", "4d664d"},
        {"atlas is someone who    always treated us nicelyeven when we's weren't  bein nice ourselves.", "4d664d"}, {"da boss in particular   had a soft spot for him.", "4d664d"}, {"...", "4d664d"}, {"garii?", plrData[plrChar].colour},
        {"we's don't have a motheror father like yous do. we's were made in a lab.", "4d664d"}, {"so atlas made you three?", plrData[plrChar].colour}, {"nah, just garii. garii  made us a bit after. he didn't want to be alone.", "4d664d"}, 
        {"da boss was in a bad    mindset back then. beingoutcast will do that to ya.", "4d664d"}, {"we's did a lot of       regrettable things back then.", "4d664d"}, {"...", "4d664d"},
        {"say, lemme give yous    some advice, chuck.", "4d664d"}, {"don't look back. keep   bettering yourself from what yous did in the    past.", "4d664d"}, {"if yous don't, yous willalways be the worst youscan be.", "4d664d"},
        {"im guessing you're      speaking from experience?", plrData[plrChar].colour}, {"yous could say that.", "4d664d"}, {"now gets on goin', i'm  tryin to enjoy the      silence here.", "4d664d"}, 
        {"", "FFFFFF"}, {"gets on outta here.", "4d664d"}
    }
}
function interactWithChar()
    if ((trucker.targetCoords.x + trucker.facing.x) >= 8 and (trucker.targetCoords.x + trucker.facing.x) <= 10 and (trucker.targetCoords.y + trucker.facing.y) >= 8 and (trucker.targetCoords.y + trucker.facing.y) <= 10) then
        talkToHim("garii")
    elseif ((trucker.targetCoords.x + trucker.facing.x) >= 17 and (trucker.targetCoords.x + trucker.facing.x) <= 19 and (trucker.targetCoords.y + trucker.facing.y) >= 12 and (trucker.targetCoords.y + trucker.facing.y) <= 14) then
        talkToHim("carv")
    else removeAllDatBabblin()
    end
end

local maxTextLength = 0
function talkToHim(char)
    local colour = textLines[char..textAdvance[char][2]][textAdvance[char][1]][2]
    local text = textLines[char..textAdvance[char][2]][textAdvance[char][1]][1]:upper()
    local splitText = {""}
    local utilsText = utils:numToStr(text)
    for i,chra in pairs(utilsText) do
        if (splitText[math.floor((i-1)/24)+1] == nil) then splitText[math.floor((i-1)/24)+1] = "" end
        splitText[math.floor((i-1)/24)+1] = splitText[math.floor((i-1)/24)+1]..chra
    end
    
    removeAllDatBabblin()
    for i,txt in pairs(splitText) do
        if (i > maxTextLength) then maxTextLength = i end
        font:createNewText("dialogue"..i, gameOffsets.x + 16, (gameOffsets.y - 24) + (16 * i), txt, "left", colour, "hud")
    end
    textAdvance[char][1] = math.min(textAdvance[char][1] + 1, #textLines[char..textAdvance[char][2]])
end

function removeAllDatBabblin()
    for i=1,maxTextLength do font:removeText("dialogue"..i) end
end

function scrollName(inc)
    curChar = curChar + inc
    if (curChar < 1) then curChar = #charList
    elseif (curChar > #charList) then curChar = 1 end

    hoveredChar = charList[curChar]
    font:setTextString("plrNameTxt", playerName..hoveredChar)
end

local nuhuh = false
function handlePellets()
    if (map[trucker.targetCoords.y+1][trucker.targetCoords.x+1] == 2) then
        utils:playSound(fldr.."eat_dot_"..(pelletCount%2))
        pelletCount = pelletCount + 1
        removeLuaSprite("pellet"..(trucker.targetCoords.x).." "..(trucker.targetCoords.y), true)
        map[trucker.targetCoords.y+1][trucker.targetCoords.x+1] = 1
        score = score + 10
    elseif (map[trucker.targetCoords.y+1][trucker.targetCoords.x+1] == 3) then
        utils:playSound(fldr.."fright", 1, "frightloop")
        for _,name in pairs(ghostList) do 
            if (not ghosts[name].inHouse) then
                if (dirIsOpen(ghosts[name], {x = ghosts[name].moveDir.x * -1, y = ghosts[name].moveDir.y * -1}) and not ghosts[name].frightened) then
                    ghosts[name].moveDir = {x = ghosts[name].moveDir.x * -1, y = ghosts[name].moveDir.y * -1}
                    ghosts[name].targetCoords.x = ghosts[name].targetCoords.x + ghosts[name].moveDir.x
                    ghosts[name].targetCoords.y = ghosts[name].targetCoords.y + ghosts[name].moveDir.y
                end
                ghosts[name].frightened = true
            end
        end
        cancelTimer("fright")
        ghostPointMult = 200
        runTimer("fright", 10)
        pelletCount = pelletCount + 1
        removeLuaSprite("energizer"..(trucker.targetCoords.x).." "..(trucker.targetCoords.y), true)
        map[trucker.targetCoords.y+1][trucker.targetCoords.x+1] = 1
        score = score + 50
    elseif (map[trucker.targetCoords.y+1][trucker.targetCoords.x+1] == 4 and not nuhuh) then
        nuhuh = true
        utils:playSound(fldr.."eat_fruit")
        map[18][14] = 1
        map[18][15] = 1
        setProperty("picnicFruit.visible", false)
        for i=1,#utils:numToStr(fruitPoints[curFruit]) do
            setProperty("fruitPoint"..i..".visible", true)
        end
        cancelTimer("fruitDisappear")
        runTimer("fruitPointDisappear", 2)
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
    nuhuh = false
    map[18][14] = 4
    map[18][15] = 4
    setProperty("picnicFruit.visible", true)
    runTimer("fruitDisappear", 10)
end

local maxLives = 0
function updateLives(extra)
    if (extra == nil) then extra = false end
    if (lives > maxLives) then maxLives = lives end
    for i=1,maxLives do
        if ((not luaSpriteExists("life"..i)) and lives > i) then
            local iconUsed = 1
            if (plrData[plrChar].prefix ~= "") then iconUsed = 2 end
            makeLuaSprite("life"..i, fldr.."life-icons", gameOffsets.x + (i * 16), gameOffsets.y + (31*8))
            loadGraphic("life"..i, fldr.."life-icons", 16, 16)
            addAnimation("life"..i, "reg", {plrData[plrChar].icons[iconUsed]})
            setProperty("life"..i..".color", getColorFromHex(plrData[plrChar].colour))
            setProperty("life"..i..".antialiasing", false)
            utils:setObjectCamera("life"..i, "hud")
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
        utils:setObjectCamera("fruitDisp"..i, "hud")
        addLuaSprite("fruitDisp"..i)
    end
end

function isPosGood(leX, leY, isGhost)
    if (isGhost) then return (map[math.floor(leY+1)][math.floor(leX+1)] ~= nil and map[math.floor(leY+1)][math.floor(leX+1)] ~= 0)
    else return (map[math.floor(leY+1)][math.floor(leX+1)] ~= nil and map[math.floor(leY+1)][math.floor(leX+1)] ~= 0 and map[math.floor(leY+1)][math.floor(leX+1)] ~= 5)
    end
end

function dirIsOpen(ghost, dir)
    if (dir == nil or ghost == nil) then return false end
    local new_x, new_y = ghost.x + dir.x, ghost.y + dir.y
    return isPosGood(new_x, new_y, ghost.eaten or ghost.inHouse)
end

function availableDirs(ghost)
    local slf = ghosts[ghost]
    local turns = {}
    if dirIsOpen(slf, slf.moveDir) then turns = {slf.moveDir} end
    for sign = -1, 1, 2 do
        local t = {x = slf.moveDir.y * sign, y = slf.moveDir.x * sign}
        if dirIsOpen(slf, t) then table.insert(turns, t) end
    end
    if #turns == 0 then table.insert(turns, {x = -slf.moveDir.x, y = -slf.moveDir.y}) end
    return turns
end

function ghostRegisterTurn(ghost)
    local key = utils:toStr({ghosts[ghost].x, ghosts[ghost].y})
    local value = ghosts[ghost].past_turns[key]
    if (value ~= nil and utils:toStr(value.dir) == utils:toStr(ghosts[ghost].moveDir)) then
        value.times = value.times + 1
    else
        ghosts[ghost].past_turns[key] = {dir = ghosts[ghost].moveDir, times = 1}
    end
end

function ghostTurnOpp(ghost, turn)
    if (ghostTurnScore(ghost, turn) > ghostTurnScore(ghost, ghosts[ghost].moveDir)) then
        ghosts[ghost].moveDir = turn
        ghosts[ghost].last_turn = {ghosts[ghost].x, ghosts[ghost].y}
    end
end

function ghostTurnScore(ghost, dir)
    local gstPos = ghosts[ghost]
    local target = getGhostTarget(ghost)
    local target_dir = {target.x - gstPos.x, target.y - gstPos.y}
    local score = (target_dir[1] * dir.x) + (target_dir[2] * dir.y)

    return score
end

function getGhostTarget(ghost)
    local ghostScatter = {["mandy"] = {x = 3, y = 1}, ["andy"] = {x = 26, y = 1}, ["brandy"] = {x = 1, y = 36}, ["randy"] = {x = 26, y = 36}}

    if (ghosts[ghost].inHouse) then return {x = 14, y = 10}
    elseif (ghosts[ghost].eaten) then return {x = 13, y = 13}
    elseif (ghosts[ghost].frightened) then
        local availableDis = availableDirs(ghost)
        return {x = ghosts[ghost].x + availableDis[1].x, y = ghosts[ghost].y + availableDis[1].y}
    elseif (ghosts.moveMode == "scatter") then
        local remainingDots = {20, 30, 40, 40, 40, 50, 50, 50, 60, 60, 60, 80, 80, 80, 100, 100, 100, 100, 120}
        if (ghost == "andy" and (maxPellets-pelletCount) <= remainingDots[math.min(curLevel, 19)]) then return {x = trucker.targetCoords.x, y = trucker.targetCoords.y} --andy ignores scatter when conditions are met
        else return ghostScatter[ghost]
        end
    elseif (ghosts.moveMode == "pursue") then
        local trkPos = trucker.targetCoords
        if (ghost == "andy") then return {x = trkPos.x, y = trkPos.y}
        elseif (ghost == "mandy") then return {x = trkPos.x + (trucker.moveDir.x * 2), y = trkPos.y + (trucker.moveDir.y * 2)}
        elseif (ghost == "randy") then
            local trkMove = {x = trkPos.x + trucker.moveDir.x, y = trkPos.y + trucker.moveDir.y}
            local redMove = {x = trkMove.x - ghosts["andy"].targetCoords.x, y = trkMove.y - ghosts["andy"].targetCoords.y}
            return {y = trkMove.x + redMove.x, x = trkMove.y + redMove.y}
        elseif (ghost == "brandy") then
            local dist_v = {ghosts["brandy"].x - ((getProperty("truckPlayer.x")-gameOffsets.x)/8), ghosts["brandy"].y - ((getProperty("truckPlayer.y")-gameOffsets.y)/8)}
            local dist_sq = (dist_v[1] * dist_v[1]) + (dist_v[2] * dist_v[2])
            if dist_sq > 16 then return {x = trkPos.x, y = trkPos.y}
            else return ghostScatter["brandy"]
            end
        end
    end
end

function handleGhostMovement(ghost)
    if (not (luaSpriteExists(ghost) and ghosts[ghost].active)) then return end

    if (ghosts[ghost].x == ghosts[ghost].targetCoords.x and ghosts[ghost].y == ghosts[ghost].targetCoords.y) then
        if (ghosts[ghost].inHouse and ghosts[ghost].targetCoords.x == 14 and ghosts[ghost].targetCoords.y == 10) then ghosts[ghost].inHouse = false
            ghosts[ghost].frightened = false
        elseif (ghosts[ghost].eaten and ghosts[ghost].targetCoords.x == 13 and ghosts[ghost].targetCoords.y == 13) then ghosts[ghost].inHouse = true
            ghosts[ghost].moveDir = {x = 0, y = -1}
            ghosts[ghost].eaten = false
            ghosts[ghost].frightened = false
        end
        if ((ghosts[ghost].x <= 2 or ghosts[ghost].x >= 27) and (ghosts[ghost].y == 12 or ghosts[ghost].y == 15)) then
        else
            local availableDis = availableDirs(ghost)
            ghosts[ghost].moveDir = availableDis[1]
            for _,dir in pairs(availableDis) do ghostTurnOpp(ghost, dir) end
        end
        ghosts[ghost].targetCoords.x = ghosts[ghost].targetCoords.x + ghosts[ghost].moveDir.x
        ghosts[ghost].targetCoords.y = ghosts[ghost].targetCoords.y + ghosts[ghost].moveDir.y
    end

    local animName = ghost
    if (ghosts[ghost].inHouse) then animName = "house" end
    if (ghosts[ghost].x ~= ghosts[ghost].targetCoords.x and ghosts[ghost].moveDir.x ~= 0) then
        setGhostX(ghost, ghosts[ghost].x + (ghosts[ghost].moveDir.x/8))
        if (ghosts[ghost].eaten) then
            if (ghosts[ghost].moveDir.x > 0) then playAnim(ghost, animName.."-eatenright")
            else playAnim(ghost, animName.."-eatenleft")
            end
        elseif (ghosts[ghost].frightened) then playAnim(ghost, animName.."-fright")
        elseif (ghosts[ghost].moveDir.x > 0) then playAnim(ghost, animName.."-right")
        else playAnim(ghost, animName.."-left")
        end
    end

    if (ghosts[ghost].y ~= ghosts[ghost].targetCoords.y and ghosts[ghost].moveDir.y ~= 0) then
        setGhostY(ghost, ghosts[ghost].y + (ghosts[ghost].moveDir.y/8))
        if (ghosts[ghost].eaten) then
            if (ghosts[ghost].moveDir.y > 0) then playAnim(ghost, animName.."-eatendown")
            else playAnim(ghost, animName.."-eatenup")
            end
        elseif (ghosts[ghost].frightened) then playAnim(ghost, animName.."-fright")
        elseif (ghosts[ghost].moveDir.y > 0) then playAnim(ghost, animName.."-down")
        else playAnim(ghost, animName.."-up")
        end
    end

    
    if (ghosts[ghost].x < -1) then
        ghosts[ghost].targetCoords.x = 29
        setGhostX(ghost, ghosts[ghost].targetCoords.x)
    elseif (ghosts[ghost].x > 29) then
        ghosts[ghost].targetCoords.x = -1
        setGhostX(ghost, ghosts[ghost].targetCoords.x)
    end
end

function setGhostX(ghost, newX)
    setProperty(ghost..".x", gameOffsets.x + (newX * 8))
    ghosts[ghost].x = newX
end

function setGhostY(ghost, newY)
    setProperty(ghost..".y", gameOffsets.y + (newY * 8))
    ghosts[ghost].y = newY
end

function handlePlayerMovement()
    if (not luaSpriteExists("truckPlayer")) then return end

    for key,_ in pairs(dirIndex) do
        if (keyJustPressed("ui_"..key)) then 
            trucker.queueQueueDir = dirIndex[key]
        end
    end

    local fuckassMapPos = map[trucker.targetCoords.y+1+trucker.queueQueueDir.y][trucker.targetCoords.x+1+trucker.queueQueueDir.x]
    if (fuckassMapPos ~= 0 and fuckassMapPos ~= 5 and (trucker.targetCoords.x < 28 and trucker.targetCoords.x > 0)) then --lol?
        trucker.queueDir = trucker.queueQueueDir
    end

    if ((getProperty("truckPlayer.x")-gameOffsets.x)/8 == trucker.targetCoords.x and (getProperty("truckPlayer.y")-gameOffsets.y)/8 == trucker.targetCoords.y) then
        if (trucker.queueDir.x ~= trucker.moveDir.x) then 
            trucker.moveDir.x = trucker.queueDir.x
            trucker.facing.x = trucker.moveDir.x
        end
        if (map[trucker.targetCoords.y+1+trucker.queueQueueDir.y][trucker.targetCoords.x+1+trucker.queueQueueDir.x] ~= nil and map[trucker.targetCoords.y+1][trucker.targetCoords.x + trucker.moveDir.x+1] == 0) then 
            if (not noMorePlayerAnims) then
                if (trucker.moveDir.x < 1) then playAnim("truckPlayer", "idle-left")
                else playAnim("truckPlayer", "idle-right")
                end
            end
            trucker.moveDir.x = 0
        end
        trucker.targetCoords.x = trucker.targetCoords.x + trucker.moveDir.x

        if (trucker.queueDir.y ~= trucker.moveDir.y) then 
            trucker.moveDir.y = trucker.queueDir.y 
            trucker.facing.y = trucker.moveDir.y
        end
        if (map[trucker.targetCoords.y+1+trucker.queueQueueDir.y][trucker.targetCoords.x+1+trucker.queueQueueDir.x] ~= nil and map[trucker.targetCoords.y + trucker.moveDir.y+1][trucker.targetCoords.x+1] == 0) then 
            if (not noMorePlayerAnims) then
                if (trucker.moveDir.y < 1) then playAnim("truckPlayer", "idle-up")
                else playAnim("truckPlayer", "idle-down")
                    if (curLevel == 0 and ((getProperty("truckPlayer.y")-gameOffsets.y)/8) > 28) then
                        font:setTextVisible("warningTxt", true)
                        runTimer("warningDis", 5)
                    end
                end
            end
            trucker.moveDir.y = 0 
        end
        trucker.targetCoords.y = trucker.targetCoords.y + trucker.moveDir.y
    end

    if ((getProperty("truckPlayer.x")-gameOffsets.x)/8 ~= trucker.targetCoords.x and trucker.moveDir.x ~= 0) then
        setProperty("truckPlayer.x", getProperty("truckPlayer.x") + (trucker.moveDir.x))
        if (not noMorePlayerAnims) then
            if (trucker.moveDir.x > 0) then playAnim("truckPlayer", "walk-right")
            else playAnim("truckPlayer", "walk-left")
            end
        end
    end

    if ((getProperty("truckPlayer.y")-gameOffsets.y)/8 ~= trucker.targetCoords.y and trucker.moveDir.y ~= 0) then
        setProperty("truckPlayer.y", getProperty("truckPlayer.y") + (trucker.moveDir.y))
        if (not noMorePlayerAnims) then
            if (trucker.moveDir.y > 0) then playAnim("truckPlayer", "walk-down")
            else playAnim("truckPlayer", "walk-up")
            end
        end
    end

    if ((getProperty("truckPlayer.x")-gameOffsets.x)/8 < -1) then 
        trucker.targetCoords.x = 29
        setProperty("truckPlayer.x", gameOffsets.x+(trucker.targetCoords.x*8))
    elseif ((getProperty("truckPlayer.x")-gameOffsets.x)/8 > 29) then 
        trucker.targetCoords.x = -1
        setProperty("truckPlayer.x", gameOffsets.x+(trucker.targetCoords.x*8))
    end
    
    for _,gst in pairs(ghostList) do
        if (dist_to_pt({x = (getProperty("truckPlayer.x")-gameOffsets.x)/8, y = (getProperty("truckPlayer.y")-gameOffsets.y)/8}, ghosts[gst]) < 1) then
            if (ghosts[gst].eaten) then
            elseif (ghosts[gst].frightened) then eatGhost(gst)
            else loseLife()
            end
        end
    end
end

function eatGhost(gst)
    ghosts[gst].eaten = true
    utils:playSound(fldr.."eat_ghost", 1)
    score = score + ghostPointMult
    ghostPointMult = ghostPointMult * 2
    canUpdate = false
    setProperty(gst..".visible", false)
    cancelTimer("unfreezeGame")
    runTimer("unfreezeGame", 0.75)
end

function loseLife()
    canUpdate = false
    utils:stopAllKnownSounds()
    runTimer("lifeFlash"..(lives-1), 0.25, 13)
    runTimer("removeLife"..(lives-1), 0.25*12)
    lives = lives - 1
    runTimer("fallChild", 0.5)
    utils:playSound(fldr.."die", 1, "deathSnd")
    noMorePlayerAnims = true
    playAnim("truckPlayer", "die", true)
end

local localLB = utils:getGariiData("fuzzLeaderboard")
local snapshotScr = {score, rebirths, "YOU"}
local rank = 0
function openLeaderboardEnter()
    for _,spr in pairs({"truckPlayer", "blankFG", "fuzzMap", "picnicFruit", "ghostDoor"}) do removeLuaSprite(spr, true) end
    for _,spr in pairs(ghostList) do removeLuaSprite(spr, true) end
    for y,row in ipairs(map) do for x,squ in ipairs(row) do
        if (luaSpriteExists("pellet"..(x-1).." "..(y-1))) then removeLuaSprite("pellet"..(x-1).." "..(y-1), true) end
        if (luaSpriteExists("energizer"..(x-1).." "..(y-1))) then removeLuaSprite("energizer"..(x-1).." "..(y-1), true) end
    end end
    for i=1,7 do
        removeLuaSprite("fruitDisp"..i, true)
        removeLuaSprite("life"..i, true)
    end
    font:removeText("readyUp")

    snapshotScr = {score, rebirths, "YOU"}
    if (localLB == nil) then localLB = placeholderLB end
    for i,scr in pairs(localLB) do
        if (snapshotScr[1] > scr[1]) then
            table.insert(localLB, i, snapshotScr)
            rank = i
            break
        end
    end
    if (rank == 0) then
        rank = #localLB+1
        localLB[rank] = snapshotScr
    end
    font:createNewText("enterInitTxt", gameOffsets.x + 24, gameOffsets.y + 24, "ENTER YOUR INITIALS !", "left", "9ad6ff", "hud")
    font:createNewText("scoreTitleTxt", gameOffsets.x + 56, gameOffsets.y + 44, "SCORE  REB  NAME", "left", "f4f3ad", "hud")
    local plrText = gimmeSpaces(10, #utils:numToStr(snapshotScr[1]))..snapshotScr[1]..gimmeSpaces(5, #utils:numToStr(snapshotScr[2]))..snapshotScr[2]
    font:createNewText("plrScoreTxt", gameOffsets.x + 16, gameOffsets.y + 56, plrText, "left", "ffffff", "hud")
    font:createNewText("plrNameTxt", gameOffsets.x + 160, gameOffsets.y + 56, "A", "left", "ffffff", "hud")
    font:createNewText("leaScoreTxt", gameOffsets.x + 88, gameOffsets.y + 80, "SCORE REB NAME", "left", "ffffff", "hud")
    activatedName = true

    for i=1,10 do
        local lbText = i..utils:numSuffix(i)
        if (i <= 9) then lbText = " "..lbText end

        local singleLB = localLB[i]
        if (singleLB == nil) then singleLB = placeholderLB[i] end
        lbText = lbText..gimmeSpaces(10, #utils:numToStr(singleLB[1]))..singleLB[1]..gimmeSpaces(4, #utils:numToStr(singleLB[2]))..singleLB[2].."  "..singleLB[3]

        local colourText = "FFFFFF"
        if (rank == i) then colourText = "f4f3ad"
            runTimer("placeFlicker"..i, 1)
        elseif (i == 10 and rank > 10) then colourText = "f4f3ad"
            runTimer("placeFlicker10", 1)
            lbText = rank..(utils:numSuffix(rank))..gimmeSpaces(10, #utils:numToStr(snapshotScr[1]))..snapshotScr[1]..gimmeSpaces(4, #utils:numToStr(snapshotScr[2]))..snapshotScr[2].."  "..snapshotScr[3]
        end

        font:createNewText("leaderboardRank"..i, gameOffsets.x + 16, gameOffsets.y + 96 + ((i-1)*16), lbText, "left", colourText, "hud")
    end
end

function finishLeaderboard()
    snapshotScr[3] = playerName
    localLB[rank] = snapshotScr
    cancelTimer("placeFlicker"..math.min(rank,10))
    font:setTextVisible("leaderboardRank"..math.min(rank,10), true)
    local lbNewTxt = rank..(utils:numSuffix(rank))..gimmeSpaces(10, #utils:numToStr(snapshotScr[1]))..snapshotScr[1]..gimmeSpaces(4, #utils:numToStr(snapshotScr[2]))..snapshotScr[2].."  "..snapshotScr[3]
    if (rank <= 9) then lbNewTxt = " "..lbNewTxt end
    font:setTextString("leaderboardRank"..math.min(rank,10), lbNewTxt)
    utils:setGariiData("fuzzLeaderboard", localLB)
end

function gimmeSpaces(compMax, varComp)
    local spaces = ""
    if (compMax-varComp > 0) then for _=1,(compMax-varComp) do
        spaces = spaces.." "
    end end
    return spaces
end

function onSoundFinished(snd)
    if (snd == "frightloop") then utils:playSound(fldr.."fright", 1, "frightloop")
    elseif (snd == "start") then canUpdate = true
        font:setTextVisible("readyUp", false)
        setProperty("readyBG.visible", false)
        curAction = 0
        cancelTimer("advanceAction")
        advanceAction()
    elseif (snd == "startkinda") then canUpdate = true
        font:setTextVisible("readyUp", false)
        setProperty("readyBG.visible", false)
    elseif (snd == "deathSnd") then runTimer("deathI", 0.1)
    elseif (snd == "music") then utils:playSound(fldr.."somewhere_else", 1, "music")
    end
end

function onTimerCompleted(tmr, _, loopsLeft)
    if (tmr == "fright") then stopSound("frightloop")
    elseif (tmr == "floweredGrave") then playAnim("grave", "flowers-none")
        for _,name in pairs(ghostList) do ghosts[name].frightened = false end
    elseif (tmr == "warningDis") then font:setTextVisible("warningTxt", false)
    elseif (tmr == "unfreezeGame") then canUpdate = true
    for _,gst in pairs(ghostList) do setProperty(gst..".visible", true) end
    elseif (tmr == "advanceAction") then advanceAction()
    elseif (tmr == "fallChild") then canTweenPlr = true
        for _,spr in pairs(ghostList) do setProperty(spr..".visible", false) end
    elseif (stringStartsWith(tmr, "initLeave")) then
        ghosts[stringSplit(tmr, "initLeave")[2]].active = true
    elseif (tmr == "fruitPointDisappear") then
        for i=1,#utils:numToStr(fruitPoints[curFruit]) do
            setProperty("fruitPoint"..i..".visible", false)
        end
    elseif (stringStartsWith(tmr, "lifeFlash")) then
        local curLife = stringSplit(tmr, "lifeFlash")[2]
        setProperty("life"..curLife..".visible", not getProperty("life"..curLife..".visible"))
    elseif (stringStartsWith(tmr, "removeLife")) then updateLives()
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
        if (curLevel > 0) then
            curLevel = (curLevel+1)%256
            if (curLevel == 0) then rebirths = rebirths + 1 end
            if (curLevel >= 64) then callOnLuas("unlockAchievement", {"fl-64levels"})
            elseif (curLevel >= 16) then callOnLuas("unlockAchievement", {"fl-16levels"})
            end
        else zeroLoops = zeroLoops + 1
        end
        reloadMap()
    elseif (tmr == "deathI") then
        if (lives > 0) then
            runTimer("deathII", 0.25)
            setProperty("blankFG.visible", true)
        else
            font:setTextX("readyUp", gameOffsets.x + 73)
            font:setTextString("readyUp", "GAME  OVER")
            font:setTextColour("readyUp", "C55252")
            font:setTextVisible("readyUp", true)
            runTimer("deathIII", 2)
        end
    elseif (tmr == "deathII") then
        deathReset()
        setProperty("blankFG.visible", false)
    elseif (tmr == "deathIII") then openLeaderboardEnter()
    elseif (tmr == "blinkLoop") then
        blinkVis = not blinkVis
        runTimer("blinkLoop", 0.2)
    elseif (stringStartsWith(tmr, "placeFlicker")) then
        local curPlace = stringSplit(tmr, "placeFlicker")[2]
        font:setTextVisible("leaderboardRank"..curPlace, not font:getTextVisible("leaderboardRank"..curPlace))
        runTimer("placeFlicker"..curPlace, 1)
    elseif (tmr == "destroyGame") then destroyGame()
    end
end

function destroyGame()
    for _,spr in pairs({"truckPlayer", "blankBG", "blankFG", "fuzzMap", "picnicFruit", "ghostDoor", "bnyuBorderL", "bnyuBorderR"}) do removeLuaSprite(spr, true) end
    for _,spr in pairs(ghostList) do removeLuaSprite(spr, true) end
    for y,row in ipairs(map) do for x,squ in ipairs(row) do
        if (luaSpriteExists("pellet"..(x-1).." "..(y-1))) then removeLuaSprite("pellet"..(x-1).." "..(y-1), true) end
        if (luaSpriteExists("energizer"..(x-1).." "..(y-1))) then removeLuaSprite("energizer"..(x-1).." "..(y-1), true) end
    end end
    for i=1,7 do
        removeLuaSprite("fruitDisp"..i, true)
        removeLuaSprite("life"..i, true)
    end
    for _,tmr in pairs({"blinkLoop", "destroyGame", "fright", "advanceAction", "fallChild", "fruitPointDisappear", "fruitDisappear", "completedLevelI", "completedLevelII", "completedLevelIII", "deathI", "deathII", "deathIII", "unfreezeGame"}) do
        cancelTimer(tmr)
    end

    font:destroyAll()
    utils:stopAllKnownSounds()
    callOnLuas("toggleCursor", {true})
    setProperty("camHUD.zoom", 1)
    callOnLuas("backToMinigameHUB")
    close()
end


function dist_to_pt(ptone, pttwo)
    local dist_v = {ptone.x - pttwo.x, ptone.y - pttwo.y}
    -- Using L1 makes it easier to survive close-pursuit turns.
    return math.abs(dist_v[1]) + math.abs(dist_v[2])
end