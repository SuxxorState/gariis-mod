
local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local doneScene, doingScene, pressedAcc = false, false, false
local cur = {panel = -1, comic = "", diff = "", length = 0}
local comicInfo = {
    ["fuzzy-dice"] = {
        img = "gari", bgm = "fuzzyloop", bgmLoopEnd = 2140,
        ["normal"] = {
            [0] = {x = -444,y = -1935, camY = -1350},
            {x = -425,y = -1141, camY = -900, snd = "fuzzyloopstart",vol = 0.8},
            {x = 61,y = -1198, camY = -900, snd = "mmm_chicen",vol = 0.75},
            {x = 372,y = -1157, camY = -900, snd = "le_bubel_pop",vol = 0.75, autoAdv = 0.25},
            {x = 959,y = -1196, camY = -900, snd = "boybeep",vol = 0.8},
            {x = -433,y = -686, camY = -400, snd = "boydah",vol = 0.75},
            {x = 1070,y = -662, camY = -400},
            {x = -413,y = -73, camY = 485}
        }
    },
    ["full-house"] = {
        img = "goon", bgm = "fullhouseloop", bgmLoopEnd = 9999,
        ["normal"] = {
            [0] = {camY = -1900, snd = "fuzzyloopend",vol = 0.8, autoAdv = 3},
            {x = -440,y = -2510, camY = -1900, snd = "micdrop_quick",vol = 0.8},
            {x = 540,y = -2360, camY = -1900, snd = "garimad",vol = 0.6},
            {x = 1060,y = -2360, camY = -1900, snd = "boyyeah",vol = 0.8},
            {x = -440,y = -1700, camY = -1200, snd = "blink",vol = 0.6},
            {x = -435,y = -1345, camY = -1200, snd = "boythink",vol = 0.8},
            {x = 370,y = -1770, camY = -1200, snd = "boyah",vol = 0.8},
            {x = 635,y = -1745, camY = -1200, snd = "boybooh",vol = 0.8},
            {x = -450,y = -975, camY = -400},
            {x = 195,y = -970, camY = -400, snd = "goonshuh",vol = 0.8},
            {x = 700,y = -1020, camY = -400, snd = "boyyeah2",vol = 0.7},
            {x = 1320,y = -980, camY = -400, snd = "stolencarvlaugh",vol = 0.7},
            {x = -410,y = -425, camY = 160, snd = "fullhouseloopstart",vol = 0.8},
            {x = 655,y = -425, camY = 160},
            {x = 1175,y = -430, camY = 160, snd = "carvheh",vol = 0.9},
            {x = -445,y = -85, camY = 485}
        }
    },
}

function onCreateComic(comicName)
    doneScene = (utils:getGariiData("watchedCutscene") == utils.songNameFmt)
    if ((not isStoryMode) or doneScene or comicInfo[utils:lwrKebab(comicName)] == nil) then
        utils:trc("comicHandler: NO COMIC FOUND, SKIPPING COMIC", 2)
        endComic()
        return
    end

    cur.comic, cur.diff = utils:lwrKebab(comicName), stringSplit(difficultyPath,"-")[#stringSplit(difficultyPath,"-")]
    if (comicInfo[cur.comic][cur.diff] == nil or comicInfo[cur.comic][cur.diff] == {}) then cur.diff = "normal" end
    cur.length = #comicInfo[cur.comic][cur.diff]

    makeLuaSprite('tcbg','',0,-((740 * 1.75)*2))
    makeGraphic("tcbg", 1500, 2386, "FFFFFF")
	scaleObject('tcbg', 1.6, 1.6)
	setScrollFactor('tcbg', 0, 1)
	screenCenter("tcbg", "x")
	addLuaSprite('tcbg',true)

    makeLuaSprite('tcpanel','goon page',-445,-2510)
    setProperty("tcpanel.alpha", 0.5)
    scaleObject("tcpanel", 1.6, 1.6)
    setScrollFactor("tcpanel", 0, 1)
    --addLuaSprite("tcpanel",true)

    for i=0,cur.length do
        if (checkFileExists("images/comicpanels/"..comicInfo[cur.comic].img..i..cur.diff..".png")) then
            makeLuaSprite('tcpanel'..i,'comicpanels/'..comicInfo[cur.comic].img..i..cur.diff,0,0)
            setProperty("tcpanel"..i..".alpha", 1 - math.min(i,1))
            scaleObject("tcpanel"..i, 1.6, 1.6)
            setScrollFactor("tcpanel"..i, 0, 1)
            setProperty("tcpanel"..i..".x", comicInfo[cur.comic][cur.diff][i].x)
            setProperty("tcpanel"..i..".y", comicInfo[cur.comic][cur.diff][i].y)
            addLuaSprite("tcpanel"..i,true)
        end
    end

    makeAnimatedLuaSprite('advancehint','comicpanels/advancehint',990,580)
    addAnimationByPrefix("advancehint", "idle", "comic advance hint", 24, true)
    scaleObject("advancehint", 0.75, 0.75)
    setProperty("advancehint.alpha", 0)
	addLuaSprite('advancehint')
    utils:setObjectCamera('advancehint', 'other')
    runTimer("advancehint", 5)

    callOnLuas("disablePause")
    setProperty("isCameraOnForcedPos", true)
    setProperty("camFollow.x", 366)
    advancePanel()
	setProperty("cameraSpeed", 10)
	setProperty("camHUD.alpha", 0)
    doingScene = true
end

function advancePanel()
    cur.panel = cur.panel + 1
    if (cur.panel > 0) then utils:playSound('pause/scribble'..getRandomInt(1,3), getRandomFloat(0.3,0.5)) end
    if (comicInfo[cur.comic][cur.diff][cur.panel].snd ~= nil and comicInfo[cur.comic][cur.diff][cur.panel].snd ~= "") then 
        utils:playSound("cutscene/"..comicInfo[cur.comic][cur.diff][cur.panel].snd, comicInfo[cur.comic][cur.diff][cur.panel].vol, comicInfo[cur.comic][cur.diff][cur.panel].snd) 
    end
    if (luaSpriteExists("tcpanel"..cur.panel)) then doTweenAlpha("tcpanel"..cur.panel, "tcpanel"..cur.panel, 1, 0.5) end
    setProperty("camFollow.y", comicInfo[cur.comic][cur.diff][cur.panel].camY)
    setProperty("advancehint.visible", not pressedAcc)

    cancelTimer("advanceComic")
    if (comicInfo[cur.comic][cur.diff][cur.panel].autoAdv ~= nil) then runTimer("advanceComic", comicInfo[cur.comic][cur.diff][cur.panel].autoAdv) end
end

function onUpdate()
    if (not doingScene) then return end

    if (keyJustPressed("accept")) then 
        pressedAcc = true
        advancePanel()
    end
    if (luaSoundExists(comicInfo[cur.comic].bgm) and getSoundTime(comicInfo[cur.comic].bgm) < comicInfo[cur.comic].bgmLoopEnd and cur.panel >= cur.length) then
        setSoundVolume(comicInfo[cur.comic].bgm.."coverend", 0.8)
        stopSound(comicInfo[cur.comic].bgm)
    end
    if (cur.panel > cur.length) then
        endComic()
    end
end

function endComic()
    doingScene = false
    doneScene = true
    utils:setGariiData("watchedCutscene", utils.songNameFmt)
    utils:stopAllKnownSounds()
    callOnLuas("cutsceneOver")
    doTweenAlpha("tcbg", "tcbg", 0, 1)
    if (luaSpriteExists("tcpanel"..cur.length)) then doTweenAlpha("tcpanel"..cur.length, "tcpanel"..cur.length, 0, 1) end
    setProperty("cameraSpeed", 1)
    runTimer("hudTwn", 0.5)
    triggerEvent("Camera Follow Pos", nil, nil)
    startCountdown()
end

function onTimerCompleted(tmr)
	if (tmr == "hudTwn") then
        doTweenAlpha("hudtween", "camHUD", 1, 0.5)
        callOnLuas("enablePause")
        close()
    elseif (tmr == "advanceComic") then advancePanel()
    elseif (tmr == "advancehint") then doTweenAlpha("advancehint", "advancehint", 1, 0.5)
	end
end

function onSoundFinished(snd)
    if (snd == comicInfo[cur.comic].bgm or snd == (comicInfo[cur.comic].bgm.."start")) then
        if (cur.panel >= (cur.length-1)) then utils:playSound("cutscene/"..comicInfo[cur.comic].bgm.."end", 0.8, comicInfo[cur.comic].bgm.."end")
        else utils:playSound("cutscene/"..comicInfo[cur.comic].bgm, 0.8, comicInfo[cur.comic].bgm)
            utils:playSound("cutscene/"..comicInfo[cur.comic].bgm.."end", 0, comicInfo[cur.comic].bgm.."coverend")
        end
    elseif ((snd == (comicInfo[cur.comic].bgm..'end') or (snd == (comicInfo[cur.comic].bgm..'coverend') and cur.panel >= cur.length)) and doingScene) then
        if (snd == (comicInfo[cur.comic].bgm.."coverend") and luaSoundExists(comicInfo[cur.comic].bgm)) then return end
        advancePanel()
        runTimer("advanceComic", 1)
    end
end