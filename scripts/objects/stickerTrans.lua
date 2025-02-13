local utils = (require (getVar("folDir").."scripts.backend.utils")):new() 
local this = {}
local stkrGrp = {}
local stickers = {}
local rareStickers = {}
local sounds = {}
local toState = ""
local toFunc = ""

function onCreate()
    for _,stkr in pairs(utils:dirFileList('images/stickers/')) do
        if (stringEndsWith(stkr:lower(), ".png")) then 
            if (stringEndsWith(string.sub(stkr, 1, #stkr - 4):lower(), "rare")) then table.insert(rareStickers, string.sub(stkr, 1, #stkr - 4))
            else table.insert(stickers, string.sub(stkr, 1, #stkr - 4)) 
            end
        end
    end

    for _,snd in pairs(utils:dirFileList('sounds/stickers/')) do
        if (stringEndsWith(snd, ".ogg")) then table.insert(sounds, string.sub(snd, 1, #snd - 4)) end
    end
end

function onUpdatePost()
    for i,stkr in pairs(stkrGrp) do
        if (luaSpriteExists(stkr)) then
            setObjectOrder(stkr, getProperty("members.length"))
        end
    end
end

function placeStickers(openScript, callFunc)
    if (#stkrGrp > 0) then stkrGrp = {} 
        for _,stkr in pairs(stkrGrp) do removeLuaSprite(stkr) end
    end

    local xPos = -150
    local yPos = -150
    local inc = 1
    while (xPos <= screenWidth) do
        if (getRandomInt(1,100) == 1) then makeLuaSprite('sticker'..inc, 'stickers/'..rareStickers[getRandomInt(1, #rareStickers)], xPos, yPos)
        else makeLuaSprite('sticker'..inc, 'stickers/'..stickers[getRandomInt(1, #stickers)], xPos, yPos)
        end
        addLuaSprite('sticker'..inc, true)
        setObjectCamera("sticker"..inc, 'other')
        setProperty("sticker"..inc..".visible", false)
        setProperty("sticker"..inc..".active", false)

        xPos = xPos + (getProperty("sticker"..inc..".width")/2)
        if (xPos >= screenWidth and yPos <= screenHeight) then
            xPos = -150
            yPos = yPos + getRandomFloat(70,120)
        end
        setProperty("sticker"..inc..".angle", getRandomInt(-60,70))

        table.insert(stkrGrp, "sticker"..inc)
        inc = inc + 1
    end

    local start = getObjectOrder(stkrGrp[1])-1
    stkrGrp = utils:shuffle(stkrGrp)
    for i = 1,#stkrGrp do setObjectOrder(stkrGrp[i], start+i) end

    for i,stkr in pairs(stkrGrp) do
        local stkrTmng = utils:rmpToRng(i, 1, #stkrGrp, 0, 0.9)
        runTimer("stickerTrans"..i, stkrTmng)
    end

    toState = openScript
    toFunc = callFunc
    runTimer("openState", 1)
end

function removeStickers()
    for i,stkr in pairs(stkrGrp) do
        local stkrTmng = 0.9 - utils:rmpToRng(i, 1, #stkrGrp, 0, 0.9)
        runTimer("stickerUnTrans"..i, stkrTmng)
    end
end

function onTimerCompleted(tag)
    local j = tonumber(string.sub(tag, #tag-1, #tag))
    local stkr = stkrGrp[j]

    if (tag == "openState") then
        if (toState ~= nil) then addLuaScript('scripts/'..toState) end
        if (toFunc ~= nil) then callOnLuas(toFunc) end

        removeStickers()
    elseif (string.find(tag, "stickerTrans")) then
        setProperty(stkr..".visible", true)
        playSound('stickers/'..sounds[getRandomInt(1, #sounds)])

        local frtmr = getRandomInt(0,2)
        if (j == #stkrGrp) then frtmr = 2 
            screenCenter(stkr)
            setProperty(stkr..".angle", 0)
        end

        runTimer("stickerPop"..j, (1/24)*frtmr)
    elseif (string.find(tag, "stickerPop")) then
        setProperty(stkr..".scale.x", getRandomFloat(0.97, 1.02))
        setProperty(stkr..".scale.y", getProperty(stkr..".scale.x"))
    elseif (string.find(tag, "stickerUnTrans")) then
        setProperty(stkr..".scale.x", getRandomFloat(0.97, 1.02))
        setProperty(stkr..".scale.y", getProperty(stkr..".scale.x"))

        local frtmr = getRandomInt(0,2)
        runTimer("stickerUnPop"..j, (1/24)*frtmr)
    elseif (string.find(tag, "stickerUnPop")) then
        setProperty(stkr..".visible", false)
        playSound('stickers/'..sounds[getRandomInt(1, #sounds)])
    end
end


return this