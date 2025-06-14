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
local plrList, curPlrSel = {"boy", "girl"}, 1
local plrData = {
    ["boy"] = {colour = "4E7FAF", icons = {0,2}, prefix = "", pinCond = "lostHat"}, 
    ["girl"] = {colour = "C55252", icons = {1,3}, prefix = "", pinCond = "lostSunnies"},
    ["garii"] = {colour = "F4F3AD", icons = {4}, prefix = "", pinCond = nil},
    ["hunte"] = {colour = "DBAF85", icons = {5}, prefix = "", pinCond = nil},
    ["carv"] = {colour = "4D664D", icons = {6}, prefix = "", pinCond = nil}
}
local plrChar = "boy"
local fruitDisp = {}
local curFruit = "carrot"
local levelColourList = {"4d664d", "8fc79b", "f4f3ad", "dbaf85", "c55252", "7e464f", "635245", "333333"}
local levelColour = "4d664d"
local lives = 5
local extraLivesGiven = 0
local curLevel = 1
local pelletCount, maxPellets = 0, 0
local blinkVis = true
local rebirths = 0
local score, highScore = 0, 0
local accX = 1 * getRandomInt(-1,1,"0")
local accY = -2
local attractMode, titleMode, canUpdate = false, false, false
local canTweenPlr = false
local ghostPointMult = 200
local charList, curChar = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}, 1
local placeholderLB = {{100, 0, "SUX"}, {90, 0, "XOR"}, {80, 0, "RAZ"}, {70, 0, "GAR"}, {60, 0, "LIN"}, {50, 0, "BKM"}, {40, 0, "PVG"}, {30, 0, "BEE"}, {20, 0, "AMO"}, {10, 0, "AST"}}
local playerName, hoveredChar, activatedName = "", "A", false
local noMorePlayerAnims = false
local zeroLoops = 0
local achData = {rounds = 0, ghosts = 0, current = ""}
local deadList = {
    ["boy"] = {}
}

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
    setProperty("bnyuBorderL.antialiasing", false)
    addLuaSprite("bnyuBorderL", true)
    if (utils:getGariiData("lostHat")) then makeLuaSprite("bnyuBorderR", fldr.."borderright-alt", 640, 0)
        plrData["boy"].prefix = "alt "
    else makeLuaSprite("bnyuBorderR", fldr.."borderright", 640, 0)
    end
    utils:setObjectCamera("bnyuBorderR", "other")
    setProperty("bnyuBorderR.antialiasing", false)
    addLuaSprite("bnyuBorderR", true)

    font:createNewText("levelTxt", gameOffsets.x + 24, gameOffsets.y - 24, "LEVEL ", "left", "FFFFFF", "hud")
    font:createNewText("scoreTxt", gameOffsets.x + 32, gameOffsets.y - 16, "0", "left", "FFFFFF", "hud")
    font:createNewText("highScore", gameOffsets.x + 120, gameOffsets.y - 24, "HI SCORE:"..(utils:getGariiData("fuzzLeaderboard")[1][3]), "left", "FFFFFF", "hud")
    font:createNewText("hiScrTxt", gameOffsets.x + 192, gameOffsets.y - 16, highScore.."", "right", "FFFFFF", "hud")

    runTimer("blinkLoop", 0.2)
    setupAttractMode()
end

function setupAttractMode()
    font:createNewText("charTitleTxt", gameOffsets.x + 56, gameOffsets.y + 16, "CHARACTER / NICKNAME", "left", "FFFFFF", "hud")
    local charListList = {{'CHARLIE-----"ANDY"', "c55252"}, {'NAVI-------"MANDY"', "ea9fd0"}, {'BOLAVARD---"RANDY"', "9ad6ff"}, {'HAROLD----"BRANDY"', "dbaf85"}, {'KIM--------"SANDY"', "f4f3ad"}, {'PABLO-------"PAUL"', "8fc79b"}}
    for i,name in pairs(charListList) do
        if (i > #ghostList) then break end
        font:createNewText(ghostList[i].."TitleTxt", gameOffsets.x + 64, gameOffsets.y + 8 + (24 * i), name[1], "left", name[2], "hud")
        makeAnimatedLuaSprite(ghostList[i].."attract", fldr.."fuzzling", gameOffsets.x + 32,(gameOffsets.y+4) + (24 * i))
        addAnimationByPrefix(ghostList[i].."attract", "reg", ghostList[i].."-right", 8, false)
        playAnim(ghostList[i].."attract", "reg")
        setProperty(ghostList[i].."attract"..".antialiasing", false)
        utils:setObjectCamera(ghostList[i].."attract", "hud")
        addLuaSprite(ghostList[i].."attract", true)
    end

    font:createNewText("pelletPTAmt", gameOffsets.x + (8*12), gameOffsets.y + (8*21), "10", "left", "FFFFFF", "hud")
    font:createNewText("energizerPTAmt", gameOffsets.x + (8*12), gameOffsets.y + (8*23), "50", "left", "FFFFFF", "hud")
    font:createNewText("attractEnter", gameOffsets.x + 16, gameOffsets.y + (8*32), "PRESS "..((utils:getKeyFromBind("accept")):upper()), "left", "FFFFFF", "hud")

    for i=1,2 do
        makeAnimatedLuaSprite("pts"..i, fldr.."pointnums", gameOffsets.x + (8*15), gameOffsets.y + (8*(21 + ((i-1)*2)))+1)
        addAnimationByPrefix("pts"..i, "reg", "points ")
        playAnim("pts"..i, "reg")
        utils:setObjectCamera("pts"..i, "hud")
        setProperty("pts"..i..".antialiasing", false)
        addLuaSprite("pts"..i)
    end

    makeLuaSprite("pelletAttract", "", gameOffsets.x + (10*8) + 3, gameOffsets.y + (21 * 8) + 3)
    makeGraphic("pelletAttract", 2, 2, "FFFFFF")
    utils:setObjectCamera("pelletAttract", "hud")
    addLuaSprite("pelletAttract")

    makeLuaSprite("energizerAttract", fldr.."energizer", gameOffsets.x + (10*8), gameOffsets.y + (23 * 8))
    utils:setObjectCamera("energizerAttract", "hud")
    setProperty("energizerAttract.antialiasing", false)
    addLuaSprite("energizerAttract")

    makeLuaSprite("gariiMark", fldr.."gariiwatermark", gameOffsets.x + (8*8), gameOffsets.y + (8*28))
    utils:setObjectCamera("gariiMark", "hud")
    setProperty("gariiMark.color", getColorFromHex("f4f3ad"))
    setProperty("gariiMark.antialiasing", false)
    addLuaSprite("gariiMark")
    attractMode = true
end

function removeAttractScr()
    for i,fuzz in pairs(ghostList) do
        font:removeText(fuzz.."TitleTxt")
        removeLuaSprite(fuzz.."attract")
        removeLuaSprite("pts"..i)
    end
    for _,txt in pairs({"pelletPTAmt", "energizerPTAmt", "attractEnter", "charTitleTxt"}) do font:removeText(txt) end
    
    removeLuaSprite("pelletAttract")
    removeLuaSprite("energizerAttract")
    removeLuaSprite("gariiMark")

end

function setupTitleScreen()
    makeLuaSprite("logo", fldr.."logo", gameOffsets.x + (8*2.5), gameOffsets.y + 8)
    utils:setObjectCamera("logo", "hud")
    setProperty("logo.antialiasing", false)
    addLuaSprite("logo")

    for i,chr in pairs(plrList) do
        makeAnimatedLuaSprite(chr.."title", fldr..chr.."-mini", gameOffsets.x + 24, gameOffsets.y + (8*(10+((i-1)*3)))-4)
        addAnimationByPrefix(chr.."title", "reg", (plrData[chr].prefix).."walk right", 12)
        playAnim(chr.."title", "reg")
        setProperty(chr.."title.antialiasing", false)
        setProperty(chr.."title.visible", i == curPlrSel)
        utils:setObjectCamera(chr.."title", "hud")
        addLuaSprite(chr.."title", true)

        if (utils:getGariiData(plrData[chr].pinCond) ~= nil and utils:getGariiData(plrData[chr].pinCond)) then
            makeLuaSprite("pin"..chr, fldr.."pin", gameOffsets.x + (8*(12 + #chr)), gameOffsets.y + (8*(10+((i-1)*3))))
            utils:setObjectCamera("pin"..chr, "hud")
            setProperty("pin"..chr..".antialiasing", false)
            addLuaSprite("pin"..chr)
        end
        font:createNewText(chr.."titleTxt", gameOffsets.x + (8*6), gameOffsets.y + (8*(10+((i-1)*3))), (chr:upper()).." GAME", "left", plrData[chr].colour, "hud")
    end

    local plrOffset = 12+((#plrList-1)*3)
    font:createNewText("bonusLifeTxt", gameOffsets.x + (8*7), gameOffsets.y + (8*(plrOffset + 2)), "BONUS LIFE FOR", "left", "ffffff", "hud")
    for i,num in pairs({"10000", "25000", "50000", "100000"}) do
        font:createNewText(i.."LifeTxt", gameOffsets.x + (8*2), gameOffsets.y + (8*(plrOffset + (2*(i+1)))), gimmeSpaces(11, math.floor((#num+3)/2))..num.." PTS", "left", "ffffff", "hud")
    end
    font:createNewText("gModSlogan", gameOffsets.x + (8*3), gameOffsets.y + (8*30), "© CAT GOT YOUR TOUNGE?", "left", "f4f3ad", "hud")
    titleMode = true
end

function removeTitleScreen()
    removeLuaSprite("logo")
    for i=1,4 do font:removeText(i.."LifeTxt") end

    for _,chr in pairs(plrList) do
        removeLuaSprite(chr.."title")
        removeLuaSprite("pin"..chr)
        font:removeText(chr.."titleTxt")
    end

    font:removeText("bonusLifeTxt")
    font:removeText("gModSlogan")
end

function firstTimeSetup()
    pelletCount, maxPellets, rebirths, score, zeroLoops, extraLivesGiven = 0, 0, 0, 0, 0, 0
    lives, curLevel, ghostPointMult = 5, 1, 200
    fruitDisp = {}

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
        for _,anim in pairs({"left", "down", "up", "right", "fright", "eatenleft", "eatendown", "eatenup", "eatenright", "flashfright"}) do
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
    
    utils:makeBlankBG("readyBG", 48,8, "111111", "hud")
    setProperty("readyBG.x", gameOffsets.x + 88)
    setProperty("readyBG.y", gameOffsets.y + 136)
    font:createNewText("readyUp", gameOffsets.x + 89, gameOffsets.y + 136, "READY!", "left", plrData[plrChar].colour, "hud")
    updateLives(false)
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
    setObjectOrder("picnicFruit", getObjectOrder(ghostList[1])-1)
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
                setObjectOrder("pellet"..x.." "..y, getObjectOrder(ghostList[1])-1)
                maxPellets = maxPellets + 1
            elseif (squ == 3) then
                removeLuaSprite("energizer"..x.." "..y)
                makeLuaSprite("energizer"..x.." "..y, fldr.."energizer", gameOffsets.x + (x*8), gameOffsets.y + (y * 8))
                utils:setObjectCamera("energizer"..x.." "..y, "hud")
                setProperty("energizer"..x.." "..y..".antialiasing", false)
                addLuaSprite("energizer"..x.." "..y)
                setObjectOrder("energizer"..x.." "..y, getObjectOrder(ghostList[1])-1)
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
    levelColour = levelColourList[(math.floor((curLevel+1)/8) % #levelColourList) + 1]
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
        else 
            local thinger = "none"
            if (utils:getGariiData("lostHat") and utils:getGariiData("lostSunnies")) then thinger = "couple"
            elseif (utils:getGariiData("lostSunnies")) then thinger = "girl"
            elseif (utils:getGariiData("lostHat")) then thinger = "boy"
            end
            playAnim("grave", "flowers-"..thinger)
        end
        setProperty("grave.antialiasing", false)
        utils:setObjectCamera("grave", "hud")
        addLuaSprite("grave")
    end

    trucker = {targetCoords = {x = 14, y = 29}, moveDir = {x = 0, y = 0}, queueDir = {x = 0, y = 0}, queueQueueDir = {x = 0, y = 0}, facing = {x = 0, y = 0}}
    setProperty("truckPlayer.x", gameOffsets.x + 112)
    setProperty("truckPlayer.y", gameOffsets.y + 232)
    playAnim("truckPlayer", "idle-up")
    updateLives()
    noMorePlayerAnims = false
    canTweenPlr = false
    accX = 1 * getRandomInt(-1,1,"0")
    accY = -2

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
        if (luaSpriteExists("life"..(i+1))) then
            addAnimation("life"..(i+1), "r", {plrData[char].icons[1]})
            playAnim("life"..(i+1), "r")
            setProperty("life"..(i+1)..".color", getColorFromHex(plrData[char].colour))
        end
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
    utils:playSound(fldr.."start", volume, "start")
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
    currentXTWO = 0
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

function updateAttract()
    if (luaSpriteExists("energizerAttract")) then setProperty("energizerAttract.visible", blinkVis) end
end

local turnIndi = 0
local fruitElp, frightElp = -1, -1
local textAdvance = {["garii"] = {1,1}, ["carv"] = {1,1}, ["grave"] = {1,1}, ["garLeave"] = {1,1}, ["graveAfter"] = {1,1}}
local whatToDo = true
local gariisHappy = false
local heShallTalk = false
function onUpdate(elp)
    local achieved = true
    for _,gst in pairs(ghostList) do
        if (not (utils:tableContains(deadList["boy"], gst) and utils:tableContains(deadList["girl"], gst))) then
            achieved = false     
        end
    end
    if (achieved) then
        callOnLuas("unlockAchievement", {"fl-deaths"})
    end
    if (attractMode) then
        updateAttract()
        if (keyJustPressed("accept")) then
            attractMode = false
            utils:playSound(fldr.."credit")
            removeAttractScr()
            runTimer("delayTitle", 0.25)
        elseif (keyJustPressed("back")) then
            attractMode = false
            callOnLuas("placeStickers")
            runTimer("destroyGame", 1)
        end
    elseif (titleMode) then
        if (keyJustPressed("ui_up")) then scrollPlr(-1)
        elseif (keyJustPressed("ui_down")) then scrollPlr(1)
        elseif (keyJustPressed("accept")) then
            titleMode = false
            plrChar = plrList[curPlrSel]
            removeTitleScreen()
            runTimer("delayStart", 0.25)
        elseif (keyJustPressed("back")) then
            titleMode = false
            removeTitleScreen()
            runTimer("goBackToAttract", 0.25)
        end
    end

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
        if (heShallTalk) then
            if (keyJustPressed("accept") and not gariisHappy) then
                talkToHim("garLeave")
            end
            return 
        end
        if (theChoice) then 
            if (keyJustPressed("ui_left") or keyJustPressed("ui_right")) then whatToDo = not whatToDo 
                if (whatToDo) then font:setTextString("dialogue3", "   >YES        NO")
                else font:setTextString("dialogue3", "    YES       >NO")
                end
            end
            if (keyJustPressed("accept")) then
                if (not whatToDo) then
                    theChoice = false
                    removeAllDatBabblin()
                else theChosen()
                end
            end
            return 
        end
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

    if (keyJustPressed("back")) then
        canUpdate = false
        removeGameplay()
        runTimer("goBackToAttract", 0.25)
    end

    if (fruitElp >= 0) then
        fruitElp = fruitElp + elp
        if (fruitElp >= 10) then
            fruitElp = -1
            onTimerCompleted("fruitDisappear")
        end
    end
    if (frightElp >= 0) then
        frightElp = frightElp + elp
        if (frightElp >= (11 - (curLevel/2)) or not (ghosts["andy"].frightened or ghosts["mandy"].frightened or ghosts["randy"].frightened or ghosts["brandy"].frightened)) then
            frightElp = -1
            onTimerCompleted("fright")
        end
    end
    if (false) then
        if (keyJustPressed("reset")) then
            loseLife()
        elseif (keyJustPressed("accept")) then
            pelletCount = 1000
            curLevel = curLevel+7
        elseif (keyboardJustPressed("F2")) then
            lives = lives+1
            updateLives()
        end
    end

    handlePellets()
    if (curLevel > 0) then
        for _,ghst in pairs(ghostList) do
            if ((ghosts[ghst].frightened and (not ghosts[ghst].eaten) and (turnIndi ~= 0)) or (not ghosts[ghst].frightened) or ghosts[ghst].eaten) then handleGhostMovement(ghst) end
            if (ghosts[ghst].eaten) then handleGhostMovement(ghst) end
        end
    end
    turnIndi = (turnIndi + 1) % 4
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
    ["grave1"] = {{"HERE LIES ATLAS.        FRIEND OF MANY.", "ffffff"}, {"Should I leave an       offering?                  >YES        NO", plrData[plrChar].colour}},
    ["graveAfter1"] = {{"HERE LIES ATLAS.        FRIEND OF MANY.", "ffffff"}, {"take good care of this  for me.", plrData[plrChar].colour}},
    ["garLeave1"] = {
        {"Hey. I wanted to say.", "f4f3ad"},
        {"You're not that bad, kid", "f4f3ad"},
        {"I know I play the bad   guy but i don't hate you", "f4f3ad"},
        {"Atlas meant a lot to me.", "f4f3ad"},
        {"I know you and your     partner are a long way  from home.", "f4f3ad"},
        {"Now get outta here.     Find your way home.", "f4f3ad"},
        {"I wish you the best of  luck.I mean it.", "f4f3ad"},
        {" ", "f4f3ad"},
    },
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
    utils:trc((trucker.targetCoords.x + trucker.facing.x).." "..(trucker.targetCoords.y + trucker.facing.y))
    if ((trucker.targetCoords.x + trucker.facing.x) >= 8 and (trucker.targetCoords.x + trucker.facing.x) <= 10 and (trucker.targetCoords.y + trucker.facing.y) >= 8 and (trucker.targetCoords.y + trucker.facing.y) <= 10) then
        talkToHim("garii")
    elseif ((trucker.targetCoords.x + trucker.facing.x) >= 12 and (trucker.targetCoords.x + trucker.facing.x) <= 14 and (trucker.targetCoords.y + trucker.facing.y) >= 8 and (trucker.targetCoords.y + trucker.facing.y) <= 10) then
        if (utils:getGariiData(plrData[plrChar].pinCond.."")) then talkToHim("graveAfter")
        else talkToHim("grave")
        end
    elseif ((trucker.targetCoords.x + trucker.facing.x) >= 17 and (trucker.targetCoords.x + trucker.facing.x) <= 19 and (trucker.targetCoords.y + trucker.facing.y) >= 12 and (trucker.targetCoords.y + trucker.facing.y) <= 14) then
        talkToHim("carv")
    else removeAllDatBabblin()
    end
end

function presentOption()
    theChoice = true
    whatToDo = true
end

function initiateGariiBabble()
    heShallTalk = true
    talkToHim("garLeave")
end

function theChosen()
    theChoice = false
    utils:setGariiData(plrData[plrChar].pinCond.."", true)
    local thinger = "none"
    if (utils:getGariiData("lostHat") and utils:getGariiData("lostSunnies")) then thinger = "couple"
    elseif (utils:getGariiData("lostSunnies")) then thinger = "girl"
    elseif (utils:getGariiData("lostHat")) then thinger = "boy"
    end
    playAnim("grave", "flowers-"..thinger)
    plrData[plrChar].prefix = "alt "
    for i,anim in pairs({"left", "down", "up", "right"}) do
        addAnimationByPrefix("truckPlayer", "walk-"..anim, (plrData[plrChar].prefix).."walk "..anim, 12)
        addOffset("truckPlayer", "walk-"..anim, 4,4)
        addAnimationByPrefix("truckPlayer", "idle-"..anim, (plrData[plrChar].prefix).."idle "..anim)
        addOffset("truckPlayer", "idle-"..anim, 4,4)
    end

    removeAllDatBabblin()
    font:setTextString("warningTxt", "(They all liked that.)")
    font:setTextVisible("warningTxt", true)
    runTimer("warningDis", 5)
    handlePlayerMovement()
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
    if (char == "grave" and textAdvance[char][1] >= 2) then
        presentOption()
    elseif (char == "garLeave" and textAdvance[char][1] > 7) then
        gariisHappy = true
        heShallTalk = false
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

function scrollPlr(inc)
    curPlrSel = curPlrSel + inc
    if (curPlrSel < 1) then curPlrSel = #plrList
    elseif (curPlrSel > #plrList) then curPlrSel = 1 end

    for i,chr in pairs(plrList) do
        setProperty(chr.."title.visible", i == curPlrSel)
    end
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
                ghosts[name].frightened = (curLevel <= 21)
            end
        end
        frightElp = -1
        ghostPointMult = 200
        if (curLevel <= 21) then frightElp = 0 end
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
        fruitElp = -1
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
    if ((score >= 10000 and extraLivesGiven <= 0) or (score >= 25000 and extraLivesGiven <= 1) or (score >= 50000 and extraLivesGiven <= 2) or (score >= 100000 and extraLivesGiven <= 3)) then
        extraLivesGiven = extraLivesGiven + 1
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
    fruitElp = 0
end

local maxLives, currentXTWO = 0, 0
function updateLives(extra)
    if (extra == nil) then extra = false end
    lives = math.min(lives, 9)
    if (lives > maxLives) then maxLives = lives end
    local iconUsed = 1
    if (plrData[plrChar].prefix ~= "") then iconUsed = 2 end
    for i=1,5 do
        if ((not luaSpriteExists("life"..i)) and lives > i) then
            makeLuaSprite("life"..i, fldr.."life-icons", gameOffsets.x + (i * 16), gameOffsets.y + (31*8))
            loadGraphic("life"..i, fldr.."life-icons", 16, 16)
            addAnimation("life"..i, "reg", {plrData[plrChar].icons[iconUsed]})
            setProperty("life"..i..".color", getColorFromHex(plrData[plrChar].colour))
            setProperty("life"..i..".antialiasing", false)
            utils:setObjectCamera("life"..i, "hud")
            addLuaSprite("life"..i)
            if (extra) then runTimer("lifeFlash"..i, 0.25, 8) end
        elseif (luaSpriteExists("life"..i)) then 
            if (lives <= i) then removeLuaSprite("life"..i, true)
            elseif (math.floor((lives+1)/2) ~= i) then
                addAnimation("life"..i, "reg", {plrData[plrChar].icons[iconUsed]})
                playAnim("life"..i, "reg")
                setProperty("life"..i..".visible", true)
            end
        end
    end
    if (lives == 7) then removeLuaSprite("life5") end
    if (lives > 6 and currentXTWO ~= math.floor((lives+1)/2)) then
        setProperty("life"..math.floor((lives+1)/2)..".visible", true)
        addAnimation("life"..math.floor((lives+1)/2), "reg", {7})
        playAnim("life"..math.floor((lives+1)/2), "reg")
        if (extra) then runTimer("lifeFlash"..math.floor((lives+1)/2), 0.25, 8) end
    end
    currentXTWO = math.floor((lives+1)/2)
end

function updateFruitIndis()
    for i=1,7 do
        if (i > #fruitDisp) then return end
        removeLuaSprite("fruitDisp"..i)
        makeAnimatedLuaSprite("fruitDisp"..i, fldr.."fruits", gameOffsets.x + (209 - (i*16)), gameOffsets.y + (31*8))
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
        local dirChosen = getRandomInt(1,#availableDis)
        return {x = ghosts[ghost].x + availableDis[dirChosen].x, y = ghosts[ghost].y + availableDis[dirChosen].y}
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
        setGhostX(ghost, ghosts[ghost].x + ((ghosts[ghost].moveDir.x/8)*(60/framerate)))
        if (ghosts[ghost].eaten) then
            if (ghosts[ghost].moveDir.x > 0) then playAnim(ghost, animName.."-eatenright")
            else playAnim(ghost, animName.."-eatenleft")
            end
        elseif (ghosts[ghost].frightened) then  
            if (frightElp >= (9.5 - (curLevel/2))) then playAnim(ghost, animName.."-flashfright")
            else playAnim(ghost, animName.."-fright")
            end
        elseif (ghosts[ghost].moveDir.x > 0) then playAnim(ghost, animName.."-right")
        else playAnim(ghost, animName.."-left")
        end
    end

    if (ghosts[ghost].y ~= ghosts[ghost].targetCoords.y and ghosts[ghost].moveDir.y ~= 0) then
        setGhostY(ghost, ghosts[ghost].y + ((ghosts[ghost].moveDir.y/8)*(60/framerate)))
        if (ghosts[ghost].eaten) then
            if (ghosts[ghost].moveDir.y > 0) then playAnim(ghost, animName.."-eatendown")
            else playAnim(ghost, animName.."-eatenup")
            end
        elseif (ghosts[ghost].frightened) then
            if (frightElp >= (9.5 - (curLevel/2))) then playAnim(ghost, animName.."-flashfright")
            else playAnim(ghost, animName.."-fright")
            end
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
                        if (((not utils:getGariiData(plrData[plrChar].pinCond)) and textAdvance["carv"][1] >= 24) or gariisHappy) then
                            canUpdate = false
                            ghostList = {"andy", "mandy", "randy", "brandy"}
                            removeGameplay()
                            runTimer("goBackToAttract", 0.25)
                        elseif (utils:getGariiData(plrData[plrChar].pinCond) and textAdvance["carv"][1] >= 24) then
                            initiateGariiBabble()
                        else
                            font:setTextVisible("warningTxt", true)
                            runTimer("warningDis", 5)
                        end
                    end
                end
            end
            trucker.moveDir.y = 0 
        end
        trucker.targetCoords.y = trucker.targetCoords.y + trucker.moveDir.y
    end

    if ((getProperty("truckPlayer.x")-gameOffsets.x)/8 ~= trucker.targetCoords.x and trucker.moveDir.x ~= 0) then
        setProperty("truckPlayer.x", getProperty("truckPlayer.x") + ((trucker.moveDir.x)*(60/framerate)))
        if (not noMorePlayerAnims) then
            if (trucker.moveDir.x > 0) then playAnim("truckPlayer", "walk-right")
            else playAnim("truckPlayer", "walk-left")
            end
        end
    end

    if ((getProperty("truckPlayer.y")-gameOffsets.y)/8 ~= trucker.targetCoords.y and trucker.moveDir.y ~= 0) then
        setProperty("truckPlayer.y", getProperty("truckPlayer.y") + ((trucker.moveDir.y)*(60/framerate)))
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
            else loseLife(gst)
            end
        end
    end
end

function eatGhost(gst)
    ghosts[gst].eaten = true
    utils:playSound(fldr.."eat_ghost", 1)
    achData.ghosts = achData.ghosts + 1
    achData.current = "all"
    score = score + ghostPointMult
    ghostPointMult = ghostPointMult * 2
    canUpdate = false
    setProperty(gst..".visible", false)
    cancelTimer("unfreezeGame")
    runTimer("unfreezeGame", 0.75)
end

function loseLife(gst)
    canUpdate = false
    if (deadList[plrChar] == nil) then deadList[plrChar] = {} end
    if (not utils:tableContains(deadList[plrChar], gst)) then
        table.insert(deadList[plrChar], gst)
    end
    utils:stopAllKnownSounds()
    if (lives <= 6) then
        runTimer("lifeFlash"..(lives-1), 0.25, 13)
    else
        runTimer("lifeFlash"..(math.floor((lives+2)/2)), 0.25, 13)
    end
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
    removeGameplay()

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

    runTimer("killLeaderboard", 3)
end

function killLeaderboard()
    for _,txt in pairs({"enterInitTxt", "scoreTitleTxt", "plrScoreTxt", "plrNameTxt", "leaScoreTxt"}) do font:removeText(txt) end
    for i=1,10 do font:removeText("leaderboardRank"..i) end

    runTimer("goBackToAttract", 0.25)
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
        for _,name in pairs(ghostList) do ghosts[name].frightened = false end
    elseif (tmr == "killLeaderboard") then killLeaderboard()
    elseif (tmr == "goBackToAttract") then setupAttractMode()
    elseif (tmr == "delayTitle") then setupTitleScreen()
    elseif (tmr == "delayStart") then firstTimeSetup()
    elseif (tmr == "floweredGrave") then playAnim("grave", "flowers-none")
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
        if (curLevel > 0 or zeroLoops > 4) then
            zeroLoops = 0
            loadGraphic("fuzzMap", fldr.."map")
            curLevel = (curLevel+1)%256
            if (curLevel == 0) then rebirths = rebirths + 1 end
            if (curLevel == 0 and utils:getGariiData(plrData[plrChar].pinCond)) then
                curLevel = (curLevel+1)%256
            end
            if (curLevel >= 64) then callOnLuas("unlockAchievement", {"fl-64levels"})
            elseif (curLevel >= 16) then callOnLuas("unlockAchievement", {"fl-16levels"})
            end
            if (achData.ghosts < 16 and achData.current == "all") then
                achData.rounds = 0
                achData.current = "none"
            elseif (achData.ghosts > 0 and achData.current == "none") then
                achData.rounds = 0
                achData.current = "all"
            end
            achData.rounds = achData.rounds + 1
            achData.ghosts = 0
            if (achData.rounds >= 4 and achData.current == "all") then callOnLuas("unlockAchievement", {"fl-sadist"})
            elseif (achData.rounds >= 16 and achData.current == "none") then callOnLuas("unlockAchievement", {"fl-pacifist"})
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

function removeGameplay()
    for _,spr in pairs({"truckPlayer", "blankFG", "fuzzMap", "picnicFruit", "ghostDoor", "carv", "hunte", "garii", "grave", "visualBorder", "readyBG"}) do removeLuaSprite(spr) end
    font:removeText("readyUp")
    for _,spr in pairs(ghostList) do removeLuaSprite(spr, true) end
    for y,row in ipairs(map) do for x,squ in ipairs(row) do
        if (luaSpriteExists("pellet"..(x-1).." "..(y-1))) then removeLuaSprite("pellet"..(x-1).." "..(y-1), true) end
        if (luaSpriteExists("energizer"..(x-1).." "..(y-1))) then removeLuaSprite("energizer"..(x-1).." "..(y-1), true) end
    end end
    for i=1,7 do
        removeLuaSprite("fruitDisp"..i, true)
        removeLuaSprite("life"..i, true)
    end
    for _,tmr in pairs({"fright", "advanceAction", "fallChild", "fruitDisappear", "fruitPointDisappear", "completedLevelI", "completedLevelII", "completedLevelIII", "deathI", "deathII", "deathIII", "unfreezeGame", "floweredGrave", "warningDis"}) do
        cancelTimer(tmr)
    end
    utils:stopAllKnownSounds()
end

function destroyGame()
    for _,spr in pairs({"blankBG", "bnyuBorderL", "bnyuBorderR", "blankBG2"}) do removeLuaSprite(spr, true) end
    for _,tmr in pairs({"blinkLoop", "destroyGame", "killLeaderboard", "goBackToAttract", "delayTitle", "delayStart"}) do
        cancelTimer(tmr)
    end

    removeAttractScr()
    removeTitleScreen()
    removeGameplay()
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