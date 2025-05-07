local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local pfFont = (require (getVar("folDir").."scripts.objects.fontHandler")):new("poker-freak")

local fold = "minigames/bushtrimmer/"
local sfld, mfld = fold.."skins/", fold.."menu/"
local skinList = {"tiles"}
local tileSkin, prevSkin = "", ""
local skinStats = {
    ["tiles"] = {title = "Hydrangea", colours = {x = "434253", [0] = "ffffff"; "a284b9","9ad6ff","8fc79b","f4f3ad","dbaf85","ea9fd0","c55252","7e464f","ffffff","c0c0c0","635245","000000","4e7faf"}},
    ["tiles-xp"] = {title = "Experience", colours = {x = "434253", [0] = "ffffff"; "4e7faf","4d664d","c55252","434253","7e464f","4e7faf","000000","333333"}},
    ["tiles-seven"] = {title = "Silver Seven", colours = {x = "FFFFFF", [0] = "ffffff"; "4e7faf","4d664d","c55252","434253","7e464f","4e7faf","c55252","c55252"}},
    ["tiles-lino"] = {title = "Fall Dolphin", colours = {x = "7e464f", [0] = "ffffff"; "a284b9","9ad6ff","8fc79b","f4f3ad","dbaf85","ea9fd0","c55252","4e7faf"}},
    ["tiles-wire"] = {title = "Evil Dark Mode", colours = {x = "FFFFFF", [0] = "ffffff"; "a284b9","9ad6ff","8fc79b","f4f3ad","dbaf85","ea9fd0","c55252","4e7faf"}},
    ["tiles-mboi"] = {title = "Navy Buoy", colours = {x = "434253", [0] = "ffffff"; "a284b9","9ad6ff","8fc79b","f4f3ad","dbaf85","ea9fd0","c55252","FFFFFF"}},
    ["tiles-faithful"] = {title = "Programmer Art", colours = {x = "434253", [0] = "ffffff"; "a284b9","9ad6ff","8fc79b","f4f3ad","dbaf85","ea9fd0","c55252","7e464f"}},
    ["tiles-xp-faithful"] = {title = "Windows XP", colours = {x = "808080", [0] = "ffffff"; "0000ff","008000","ff0000","000080","800000","008080","000000","808080"}},
    ["tiles-seven-faithful"] = {title = "Windows 7", colours = {x = "FFFFFF", [0] = "ffffff"; "0000ff","008000","ff0000","000080","800000","008080","ff0000","ff0000"}},
    ["tiles-lino-faithful"] = {title = "Dolphin Lino", colours = {x = "7e464f", [0] = "ffffff"; "a284b9","9ad6ff","8fc79b","f4f3ad","dbaf85","ea9fd0","c55252","4e7faf"}},
    ["unknown"] = {title = "Unknown Skin", colours = {x = "434253", [0] = "ffffff"; "a284b9","9ad6ff","8fc79b","f4f3ad","dbaf85","ea9fd0","c55252","7e464f"}}
}
local options = {"Beginner","Novice","Intermediate","Advanced","Expert","Custom","Style","Stats"}
local diffStats = {
    ["beginner"] = {width = 9, height = 9, mines = 10, flowers = 0},
    ["novice"] = {width = 16, height = 16, mines = 40, flowers = 0},
    ["intermediate"] = {width = 36, height = 18, mines = 99, flowers = 0},
    ["advanced"] = {width = 18, height = 18, mines = 60, flowers = 2},
    ["expert"] = {width = 30, height = 16, mines = 99, flowers = 4}
}
local curDiff, curSkin, curEnd = 1, 1, 1
local canPlay, canChoose, canSkin, canEnd = false, true, false, false
local nextGameDoesNotCount = false
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
local arrsine = 0

function startMinigame()
    utils:setWindowTitle("Friday Night Funkin': GARII'S ARCADE: Bushtrimmer")
    utils:setDiscord("In GARII'S ARCADE", "Bushtrimmer")
    setProperty("camHUD.zoom", 2)
    callOnScripts("initCursor")

    tileSkin = utils:getGariiData("btSkin")
    if (tileSkin == nil) then tileSkin = "tiles" end
    if (getModSetting('faithfulMode')) then skinList[1] = "tiles-faithful"
        if (not stringEndsWith(utils:lwrKebab(tileSkin), "-faithful")) then tileSkin = tileSkin.."-faithful" end
    elseif (stringEndsWith(utils:lwrKebab(tileSkin), "-faithful")) then
        tileSkin = stringSplit(tileSkin, "-faithful")[1]
    end
    utils:setGariiData("btSkin", tileSkin)
    for _,file in pairs(utils:dirFileList('images/'..sfld)) do
        if (stringEndsWith(file, ".png")) then
            local clippedFile = string.sub(file, 1, #file - 4)
            if (not (stringEndsWith(utils:lwrKebab(clippedFile), "-faithful") or utils:tableContains(skinList, clippedFile) or utils:tableContains(skinList, clippedFile.."-faithful"))) then
                if (getModSetting('faithfulMode') and checkFileExists("images/"..sfld..clippedFile.."-faithful.png")) then table.insert(skinList, clippedFile.."-faithful")
                else table.insert(skinList, clippedFile)
                end
                if (skinStats[clippedFile] == nil) then skinStats[clippedFile] = skinStats["unknown"] end
            end
        end
    end
    curSkin = utils:indexOf(skinList, tileSkin)

    makeLuaSprite('grass',fold..'grass',320,180)
    quickAddSprite("grass")

    for i,dif in pairs(options) do
        makeLuaSprite(dif:lower(),mfld..dif:lower(),359 + (200 * ((i-1)%3)),186 + (180 * math.floor((i-1) /3)))
        quickAddSprite(dif:lower())
    end

    makeLuaSprite("style",mfld.."style",359 + (400) + 4,186 + (180) + 68)
    quickAddSprite("style")
    makeLuaSprite("stats",mfld.."stats",359 + (400) + 86,186 + (180) + 68)
    quickAddSprite("stats")
    skinSel(0)
end

function firstTimeSetup()
    width = math.min(diffStats[utils:lwrKebab(options[curDiff])].width, 36)
    height = math.min(diffStats[utils:lwrKebab(options[curDiff])].height, 18)
    x = (screenWidth - (width * 16)) / 2
    y = ((screenHeight - (height * 16)) / 2) + 16
    mines = math.min(diffStats[utils:lwrKebab(options[curDiff])].mines, math.floor((width * height) * 0.85))
    flowers = math.min(diffStats[utils:lwrKebab(options[curDiff])].flowers, 5)
    if (mines >= 99) then diff = "exp" end

    for i,s in pairs({{24, "000000"}, {20, "7e464f"}, {4, "000000"}}) do
        makeLuaSprite('minebg'..i,'',x - (s[1] / 2),y - (s[1] / 2))
        makeGraphic('minebg'..i, (width * 16) + s[1], (height * 16) + s[1], s[2])
        quickAddSprite('minebg'..i)
    end
    
    makeAnimatedLuaSprite("smileyicon", fold.."smallsmiles", 600,184)
    for _,anim in pairs{"reg-idle","reg-click","reg-dead","reg-win","exp-idle","exp-click","exp-dead","exp-win"} do
        addAnimationByPrefix("smileyicon", anim, anim, 6)
    end
    playAnim("smileyicon", diff.."-idle")
    screenCenter("smileyicon", "x")
    quickAddSprite("smileyicon")
    setProperty("smileyicon.active", true)

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

function setupGame(resetData)
    removeWin()
    if (resetData == nil) then resetData = true end
    time = 0
    if (resetData) then
        data = {mines = {}, flowers = {}, opentiles = {}, flaggedtiles = {}, markedtiles = {}}

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
    else data.opentiles = {}
        data.markedtiles = {}
        data.flaggedtiles = {}
    end

    for i = 1,height do
        for j=1,width do
            removeLuaSprite("tile"..i.."-"..j)
            makeLuaSprite("tile"..i.."-"..j, nil, x + ((j-1) * 16), y + ((i-1) * 16))
            addGridAnims("tile"..i.."-"..j, sfld..tileSkin, 16, 16, {{"reg", 0}, {"open", 1}, {"dead", 2}})
            quickAddSprite("tile"..i.."-"..j)

            if (compareIndexTables(data.mines, {j,i})) then
                local curMine = bigIndexOf(data.mines, {j,i}) --prevents desync because a simple counter can sometimes... be wrong
                removeLuaSprite("mine"..curMine)
                makeLuaSprite("mine"..curMine, nil, x + ((j-1) * 16), y + ((i-1) * 16))
                addGridAnims("mine"..curMine, sfld..tileSkin, 16, 16, {{"reg", 3}})
                quickAddSprite("mine"..curMine, false)
            elseif (compareIndexTables(data.flowers, {j,i})) then
                local curFlwr = bigIndexOf(data.flowers, {j,i})
                removeLuaSprite("flower"..curFlwr)
                makeLuaSprite("flower"..curFlwr, nil, x + ((j-1) * 16), y + ((i-1) * 16))
                addGridAnims("flower"..curFlwr, sfld..tileSkin, 16, 16, {{"reg", 6}, {"open", 7}})
                quickAddSprite("flower"..curFlwr, false)
            end
            removeLuaSprite("flag"..i.."-"..j)
            makeLuaSprite("flag"..i.."-"..j, nil, x + ((j-1) * 16), y + ((i-1) * 16))
            addGridAnims("flag"..i.."-"..j, sfld..tileSkin, 16, 16, {{"flag", 4}, {"mark", 5}})
            quickAddSprite("flag"..i.."-"..j, false)

            removeLuaSprite("data"..i.."-"..j)
            makeAnimatedLuaSprite("data"..i.."-"..j, fold.."infostuff", x + ((j-1) * 16), y + ((i-1) * 16))
            local adjcount = countAdjacentMines(j, i)
            setProperty("data"..i.."-"..j..".color", getColorFromHex(skinStats[tileSkin].colours[adjcount.mines]))
            if (adjcount.mines >= 1 and adjcount.flowers <= 0) then addAnimationByPrefix("data"..i.."-"..j, "num", (adjcount.mines).."num", 24, true)
            elseif (adjcount.flowers >= 1) then addAnimationByPrefix("data"..i.."-"..j, "num", (adjcount.mines + adjcount.flowers).."fakenum", 24, true)
            else setProperty("data"..i.."-"..j..".color", getColorFromHex(skinStats[tileSkin].colours.x))
            end
            addAnimationByPrefix("data"..i.."-"..j, "x", "x", 24, true)
            playAnim("data"..i.."-"..j, "num")
            quickAddSprite("data"..i.."-"..j, false)
        end
    end

    checkForOptimalStartPos()
    utils:playSound(fold.."start")
    runTimer("timerup",0.0000001)

    playAnim("smileyicon", diff.."-idle", nil,nil, (getProperty("smileyicon.animation.curAnim.curFrame")+1)%2)
    pfFont:setTextString("mineTxt", ""..(mines-(#data.flaggedtiles)))
    pfFont:screenCenter("mineTxt", "X")
    pfFont:setTextX("mineTxt", pfFont:getTextX("mineTxt") + 120)
    setProperty("mineicon.x", pfFont:getTextX("mineTxt") - 24)
    canPlay, canEnd = true, false
end

function addGridAnims(spr, texture, wid, hei, anims) --added for convenience
    loadGraphic(spr, texture, wid, hei)
    for _,v in ipairs(anims) do
        addAnimation(spr, v[1], {v[2]})
        playAnim(spr, "reg") --default anim basically
    end
end

function quickAddSprite(spr, visible, cam)
    setProperty(spr..".visible", visible == nil or visible == true)
    setProperty(spr..".antialiasing", false)
    setProperty(spr..".active", false) --optimization
    if (cam == nil) then cam = "hud" end
    utils:setObjectCamera(spr, cam)
    addLuaSprite(spr)
end

local tester = {x = 732, y = 302, width = 8, height = 8, mine = {x = 3, y = 2}}
function openSkinMenu()
    canSkin = true
    prevSkin = tileSkin
    curSkin = utils:indexOf(skinList, tileSkin)

    utils:makeBlankBG("blackout", screenWidth,screenHeight, "000000", "hud")
    setProperty("blackout.alpha", 0)
    doTweenAlpha("blackout", "blackout", 0.5, 0.5, "circOut")
    for i=1,5 do
        pfFont:createNewText("skin"..i.."Txt", 250, 250 + ((i-1) * 50), " ")
        if (i == 3) then pfFont:setTextX("skin"..i.."Txt", 275) end
        pfFont:setTextAlpha("skin"..i.."Txt", 0)
        pfFont:setTextCamera("skin"..i.."Txt", "hud")
    end
    
    makeLuaSprite('arrowSkin',"minigames/arrow",233,343)
    setProperty('arrowSkin.alpha', 0)
    setProperty('arrowSkin.angle', 270)
    quickAddSprite("arrowSkin")

    for i,s in pairs({{24, "000000"}, {20, "7e464f"}, {4, "000000"}}) do
        makeLuaSprite('skinminebg'..i,'',tester.x - (s[1] / 2),tester.y - (s[1] / 2))
        makeGraphic('skinminebg'..i, (tester.width * 16) + s[1], (tester.height * 16) + s[1], s[2])
        quickAddSprite('skinminebg'..i)
    end

    for i = 1,tester.height do
        for j=1,tester.width do
            removeLuaSprite("testtile"..i.."-"..j)
            makeLuaSprite("testtile"..i.."-"..j, nil, tester.x + ((j-1) * 16), tester.y + ((i-1) * 16))
            quickAddSprite("testtile"..i.."-"..j)
        end
    end

    for _,v in pairs({{name = "flag", x=4,y=7}, {name = "mark", x=1,y=6}, {name = "mine", x=tester.mine.x,y=tester.mine.y}, {name = "flower1", x=7,y=1}, {name = "flower2", x=8,y=7}}) do
        removeLuaSprite("test"..v.name)
        makeLuaSprite("test"..v.name, nil, tester.x + ((v.x-1) * 16), tester.y + ((v.y-1) * 16))
        quickAddSprite("test"..v.name)
    end

    for i,v in pairs({{x = 8, y = 4}, {x = 7, y = 4}, {x = 6, y = 4}, {x = 5, y = 4}, {x = 5, y = 5}, {x = 5, y = 6}, {x = 5, y = 7}, {x = 5, y = 8}}) do
        removeLuaSprite("testdata"..i)
        makeAnimatedLuaSprite("testdata"..i, fold.."infostuff", tester.x + ((v.x-1) * 16), tester.y + ((v.y-1) * 16))
        addAnimationByPrefix("testdata"..i, "reg", i.."num", 24, true)
        quickAddSprite("testdata"..i)
    end

    removeLuaSprite("testdatax")
    makeAnimatedLuaSprite("testdatax", fold.."infostuff", tester.x + ((2-1) * 16), tester.y + ((4-1) * 16))
    addAnimationByPrefix("testdatax", "reg", "x", 24, true)
    quickAddSprite("testdatax")

    skinSel(0)

    doTweenX("arrowSkinInX", "arrowSkin", getProperty("arrowSkin.x") + 100, 0.7, "circOut")
    doTweenAlpha("arrowSkinInAlpha", "arrowSkin", 1, 0.5, "circOut")
    for i=1,5 do
        pfFont:tweenTextX("skin"..i.."Txt", pfFont:getTextX("skin"..i.."Txt") + 100, 0.5 + (0.1 * (i-1)), "circOut")
        if (i == 3) then pfFont:tweenTextAlpha("skin"..i.."Txt", 1, 0.5, "circOut")
        else pfFont:tweenTextAlpha("skin"..i.."Txt", 0.5, 0.5, "circOut")
        end
    end
end

function closeSkinMenu(saveSkin)
    canSkin = false
    if (saveSkin) then utils:setGariiData("btSkin", tileSkin)
        utils:playSound(fold.."click")
    else tileSkin = prevSkin
        utils:playSound(fold.."Windows Recycle")
    end
    doTweenAlpha("blackout", "blackout", 0, 0.5, "circOut")
    pfFont:destroyAll()

    for i = 1,tester.height do
        for j=1,tester.width do
            removeLuaSprite("testtile"..i.."-"..j)
        end
    end

    for _,v in pairs({"flag", "mark", "mine", "flower1", "flower2"}) do
        removeLuaSprite("test"..v)
    end

    for i=1,8 do
        removeLuaSprite('skinminebg'..i)
        removeLuaSprite("testdata"..i)
    end
    removeLuaSprite("arrowSkin")
    removeLuaSprite("testdatax")
end

function skinSel(move)
    curSkin = (((curSkin-1) + move) % #skinList)+1
    if (move ~= 0) then utils:playSound(fold.."Windows Restore") end

    tileSkin = skinList[curSkin]
    for i=1,5 do
        pfFont:setTextVisible("skin"..i.."Txt", skinList[curSkin + (i-3)] ~= nil)
        if (skinList[curSkin + (i-3)] ~= nil) then
            pfFont:setTextString("skin"..i.."Txt", skinStats[skinList[curSkin + (i-3)]].title)
        end
    end
    
    for i = 1,tester.height do
        for j=1,tester.width do
            addGridAnims("testtile"..i.."-"..j, sfld..tileSkin, 16, 16, {{"reg", 0}, {"open", 1}, {"dead", 2}})
            if (i == tester.mine.y and j == tester.mine.x) then playAnim("testtile"..i.."-"..j, "dead")
            elseif (i == 8 and j == 9) then playAnim("testtile"..i.."-"..j, "open")
            elseif (i >= 4 and j >= 5) then playAnim("testtile"..i.."-"..j, "open")
            end
        end
    end
    for _,v in pairs({{name = "flag", tile = 4}, {name = "mark", tile = 5}, {name = "mine", tile = 3}, {name = "flower1", tile = 6}, {name = "flower2", tile = 7}}) do
        addGridAnims("test"..v.name, sfld..tileSkin, 16, 16, {{"reg", v.tile}})
    end

    for i=1,8 do
        setProperty("testdata"..i..".color", getColorFromHex(skinStats[tileSkin].colours[i]))
    end
    setProperty("testdatax.color", getColorFromHex(skinStats[tileSkin].colours.x))
end

function endSel(move)
    curEnd = (((curEnd-1) + move)%3)+1
    if (move ~= 0) then utils:playSound(fold.."Windows Restore") end

    for i=1,3 do
        if (i==curEnd) then pfFont:setTextAlpha("restultOption"..i, 1)
        else pfFont:setTextAlpha("restultOption"..i, 0.5)
        end
    end
    setProperty('arrowEnd.y', 313 + (curEnd*50))
end

function onUpdate(elp)
    if (luaSpriteExists("smileyicon") and (not canEnd)) then
        if ((mouseReleased() or mouseReleased("right")) and utils:mouseWithinBounds({getProperty("smileyicon.x"),getProperty("smileyicon.y"), getProperty("smileyicon.x")+getProperty("smileyicon.width"),getProperty("smileyicon.y")+getProperty("smileyicon.height")}, "hud")) then
            winStuff()
            cancelTimer("delayboom")
            stopSound("winmusic")
            local curStreak = utils:getGariiData("btStreak") or {0,0,0,0,0}
            curStreak[curDiff] = 0
            utils:setGariiData("btStreak", curStreak)
            setupGame()
        end
        if (keyJustPressed("back")) then 
            canChoose = true
            onDestroy()
            startMinigame()
        end
    end
    if (canPlay) then
        if (mousePressed() and utils:mouseWithinBounds({x,y, x + (16 * width),y + (16 * height)}, "hud")) then
            playAnim("smileyicon", diff.."-click", nil,nil, (getProperty("smileyicon.animation.curAnim.curFrame")+1)%2)
        end

        if (mouseReleased() or mouseReleased("right")) then
            playAnim("smileyicon", diff.."-idle", nil,nil, (getProperty("smileyicon.animation.curAnim.curFrame")+1)%2)
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
    elseif (canSkin) then
        if (luaSpriteExists("arrowSkin") and getProperty('arrowSkin.alpha') == 1) then
            arrsine = arrsine + (180 * (elp/2))
            if (arrsine >= 360) then arrsine = 0 end --overflow prevention
            setProperty('arrowSkin.x', 333 - math.floor(math.sin((math.pi * arrsine) / 180) * 4))
        end
        if (keyJustPressed("ui_up")) then skinSel(-1)
        elseif (keyJustPressed("ui_down")) then skinSel(1)
        elseif (keyJustPressed("back") or keyJustPressed("ui_right") or keyJustPressed("accept")) then closeSkinMenu(not keyJustPressed("back"))
        end
    elseif (canChoose) then
        local curChoice = 0
        for i,spr in pairs(options) do
            local dif = utils:lwrKebab(spr)
            if (utils:mouseWithinBounds({getProperty(dif..".x"), getProperty(dif..".y"), getProperty(dif..".x")+getProperty(dif..".width"), getProperty(dif..".y")+getProperty(dif..".height")}, "hud")) then
                curChoice = i
            end
        end
        if (curChoice ~= 0) then callOnLuas("cursorPlayAnim", {"enter"})
            if ((mouseReleased() or mouseReleased("right"))) then
                if (curChoice == 6) then
                    
                elseif (curChoice == 7) then openSkinMenu()
                elseif (curChoice == 8) then
                else
                    canChoose = false
                    curDiff = curChoice
                    for _,jif in pairs(options) do
                        removeLuaSprite(utils:lwrKebab(jif))
                    end
                    removeLuaSprite("style")
                    removeLuaSprite("stats")
                    firstTimeSetup()
                    canPlay = true
                end
                callOnLuas("cursorPlayAnim")
                local rpc = options[curChoice]
                if (curChoice >= 7) then rpc = rpc.." Menu" end
                utils:setDiscord("In GARII'S ARCADE", "Bushtrimmer: "..rpc)
            end
        else callOnLuas("cursorPlayAnim")
            utils:setDiscord("In GARII'S ARCADE", "Bushtrimmer")
        end
        if (keyJustPressed("back")) then
            callOnLuas("placeStickers")
            runTimer("destroy", 1)
            canPlay = false
        end
    elseif (canEnd) then
        if (luaSpriteExists("arrowEnd") and getProperty('arrowEnd.alpha') == 1) then
            arrsine = arrsine + (180 * (elp/2))
            if (arrsine >= 360) then arrsine = 0 end --overflow prevention
            setProperty('arrowEnd.x', 488 - math.floor(math.sin((math.pi * arrsine) / 180) * 4))
        end
        if (keyJustPressed("ui_up")) then endSel(-1)
        elseif (keyJustPressed("ui_down")) then endSel(1)
        elseif (keyJustPressed("ui_right") or keyJustPressed("accept")) then 
            cancelTimer("delayboom")
            stopSound("winmusic")
            canEnd = false
            if (curEnd == 1 or curEnd == 2) then
                setupGame(curEnd == 1)
                nextGameDoesNotCount = (curEnd == 2)
            else
                canChoose = true
                onDestroy()
                startMinigame()
            end
        elseif (keyJustPressed("ui_back")) then
            canChoose = true
            onDestroy()
            startMinigame()
        end
    end
end

function interactWithTile(tilex, tiley, flag, massopen)
    if (tilex < 1 or tiley < 1) then return end
    flag = flag or false
    massopen = massopen or false
    playAnim("smileyicon", diff.."-idle", nil,nil, (getProperty("smileyicon.animation.curAnim.curFrame")+1)%2)
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
                    utils:playSound(fold.."fuckedup")
                    runTimer("delayboom", 2)
                else loseStuff()
                    playAnim("tile"..tiley.."-"..tilex, "dead")
                end
            else
                table.insert(data.opentiles, {tilex, tiley})
                local adjtiles = countAdjacentMines(tilex, tiley)
                if compareIndexTables(data.flowers, {tilex, tiley}) then
                    playAnim("flower"..(bigIndexOf(data.flowers, {tilex, tiley})), "open")
                    setProperty("flower"..(bigIndexOf(data.flowers, {tilex, tiley}))..".visible", true)
                else setProperty("data"..tiley.."-"..tilex..".visible", (adjtiles.mines + adjtiles.flowers) >= 1)
                end
                playAnim("tile"..tiley.."-"..tilex, "open")
                if ((adjtiles.mines + adjtiles.flowers) < 1 and (not compareIndexTables(data.flowers, {tilex, tiley}))) then
                    if (not luaSoundExists("bigclick")) and (not massopen) then utils:playSound(fold.."click", 1, "bigclick") end
                    intWithAdjTiles(tilex, tiley)
                end
            end
        end
    end
end

function loseStuff()
    canPlay = false
    local curStreak = utils:getGariiData("btStreak") or {0,0,0,0,0}
    curStreak[curDiff] = 0
    utils:setGariiData("btStreak", curStreak)
    playAnim("smileyicon", diff.."-dead", nil,nil, (getProperty("smileyicon.animation.curAnim.curFrame")+1)%2)
    revealMines(true)
end

function revealMines(bad)
    bad = bad or false
    for i = 1,#data.mines do
        if (bad) then utils:playSound(fold.."lose_minesweeper", 1, "losemine") end
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
    canPlay, canEnd = false, true
    curEnd = 1
    cancelTimer("timerup")
    playAnim("smileyicon", diff.."-win", nil,nil, (getProperty("smileyicon.animation.curAnim.curFrame")+1)%2)
    utils:playSound("results/resultsEXCELLENT", 1, "winmusic")
    revealMines()

    if (curDiff > 5) then return --no achievements for custom diff
    elseif (not nextGameDoesNotCount) then
        local saveStreak = utils:getGariiData("btStreak") or {0,0,0,0,0}
        local saveScores = utils:getGariiData("btBestScores") or {{}}
        saveStreak[curDiff] = saveStreak[curDiff] + 1
        if (saveScores[curDiff] == nil or saveScores[curDiff] == {}) then saveScores[curDiff] = {time = math.huge, streak = 0} end
        saveScores[curDiff] = {time = math.min(saveScores[curDiff].time, time), streak = math.max(saveScores[curDiff].streak, saveStreak[curDiff])}
        utils:setGariiData("btStreak", saveStreak)
        utils:setGariiData("btBestScores", saveScores)
        handleAchievementChecks()
    end
    nextGameDoesNotCount = false

    winScreen()
    endSel(0)
end

function handleAchievementChecks()
    callOnLuas("unlockAchievement", {"bt-simple"})
    if (curDiff == 5) then callOnLuas("unlockAchievement", {"bt-expert"}) end
    if (utils:getGariiData("btStreak")[curDiff] >= 5) then
        callOnLuas("unlockAchievement", {"bt-5simple"})
        if (curDiff == 5) then callOnLuas("unlockAchievement", {"bt-5expert"}) end
    end
    if (time <= 60) then callOnLuas("unlockAchievement", {"bt-speedy"}) end
    if (time <= 300 and curDiff == 5) then callOnLuas("unlockAchievement", {"bt-exp-speed"}) end
end

function winScreen()
    utils:makeBlankBG("winbg", 1280, 720, "000000", "hud")
    setProperty("winbg.alpha", 0)
    doTweenAlpha("wibg", "winbg", 0.6, 0.5)

    makeAnimatedLuaSprite("smileybig", fold.."mrsmiles", 350,500)
    addAnimationByPrefix("smileybig", "reg", "reg", 6)
    playAnim("smileybig", "reg")
    quickAddSprite("smileybig", nil, "hud")
    setProperty("smileybig.active", true)
    setProperty("smileybig.alpha", 0)
    runTimer("smiley", 1.5)
    
    for i,spr in pairs({{"Diff", "meter"}, {"Time", "timething"}, {"Streak", "fire"}}) do
        makeLuaSprite("result"..spr[1].."Icon", fold..spr[2], 700,314+(i*50))
        quickAddSprite("result"..spr[1].."Icon")
        setProperty("result"..spr[1].."Icon.alpha", 0)
    end

    pfFont:createNewText("resultDiffTxt", 725, 370, options[math.max(curDiff,1)], nil,nil, "hud")
    pfFont:createNewText("resultTimeTxt", 725, 420, math.floor(math.max(time,0)/60)..":"..utils:formatDigit(math.floor(math.max(time,0)%60)), nil,nil, "hud")
    pfFont:createNewText("resultStreakTxt", 725, 470, math.max(utils:getGariiData("btStreak")[math.max(curDiff,1)],1).." Streak", nil,nil, "hud")
    pfFont:setTextAlpha("resultDiffTxt", 0)
    pfFont:setTextAlpha("resultTimeTxt", 0)
    pfFont:setTextAlpha("resultStreakTxt", 0)

    for i=1,3 do
        local shit = {"New Game", "Play Again", "Back to Menu"}
        pfFont:createNewText("restultOption"..i, 525, 320 + (i*50), shit[i], nil,nil, "hud")
    end
        
    makeLuaSprite('arrowEnd',"minigames/arrow",508,353)--250,350
    setProperty('arrowEnd.angle', 270)
    quickAddSprite("arrowEnd")

    makeLuaSprite("wintxt", fold.."nicework", 560,90)
    quickAddSprite("wintxt")
    setProperty("wintxt.alpha", 0)
    runTimer("wintxt", 0.25)
end

function removeWin()
    for _,spr in pairs({"winbg", "smileybig", "wintxt", "resultDiffIcon", "resultTimeIcon", "resultStreakIcon", "arrowEnd"}) do removeLuaSprite(spr) end
    for _,txt in pairs({"resultDiffTxt", "resultTimeTxt", "resultStreakTxt", "restultOption1", "restultOption2", "restultOption3"}) do pfFont:removeText(txt) end
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

function onTimerCompleted(tmr, loops, left)
    if (tmr == "delayboom") then loseStuff()
    elseif (tmr == "timerup") then time = time + 1
        pfFont:setTextString("timeTxt", math.floor(time/60)..":"..utils:formatDigit(math.floor(time%60)))
        pfFont:screenCenter("timeTxt", "X")
        pfFont:setTextX("timeTxt", pfFont:getTextX("timeTxt") - 100)
        setProperty("timeicon.x", pfFont:getTextX("timeTxt") - 25)
        runTimer("timerup", 1)
    elseif (tmr == "destroy") then onDestroy()
        close()
        callOnLuas("backToMinigameHUB")
    elseif (tmr == "smiley") then 
        doTweenY("smileybig", "smileybig", 200, 1, "backOut")
        doTweenAlpha("smileybig2", "smileybig", 1, 1, "backOut")
    elseif (tmr == "wintxt") then
        doTweenY("wintxt", "wintxt", 190, 1, "backOut")
        doTweenAlpha("wintxt2", "wintxt", 1, 1, "backOut")
        runTimer("stata", 0.1, 3)
    elseif (tmr == "stata") then
        local spr = {"Diff", "Time", "Streak"}
        doTweenX("result"..spr[loops-left].."Icon", "result"..spr[loops-left].."Icon", 725, 0.5, "backOut")
        doTweenAlpha("result"..spr[loops-left].."Icon2", "result"..spr[loops-left].."Icon", 1, 0.5, "backOut")
        pfFont:tweenTextX("result"..spr[loops-left].."Txt", 750, 0.5, "backOut")
        pfFont:tweenTextAlpha("result"..spr[loops-left].."Txt", 1, 0.5, "backOut")
    end
end

function onDestroy()
    canPlay = false
    setProperty("camHUD.zoom", 1)
    stopSound("winmusic")
    closeSkinMenu()
    removeWin()
    for _,tmr in pairs({"delayboom", "timerup", "destroy", "smiley", "wintxt", "stata"}) do cancelTimer(tmr) end
    for _,spr in pairs({"blankBG", "minebg3", "minebg1", "minebg2", "timeicon", "mineicon", "smileyicon", "grass", "blackout", "winbg", "smileybig", "wintxt", "resultDiffIcon", "resultTimeIcon", "resultStreakIcon"}) do removeLuaSprite(spr) end
    for i = 1,height do
        for j=1,width do 
            removeLuaSprite("tile"..i.."-"..j)
            removeLuaSprite("flag"..i.."-"..j)
            removeLuaSprite("data"..i.."-"..j)
        end
    end
    removeLuaSprite("style")
    removeLuaSprite("stats")
    for i = 1,mines do removeLuaSprite("mine"..i) end
    for i = 1,flowers do removeLuaSprite("flower"..i) end
    for _,jif in pairs(options) do
        removeLuaSprite(utils:lwrKebab(jif))
    end
    pfFont:destroyAll()
end