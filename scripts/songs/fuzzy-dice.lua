
local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local notDoneScene = true
local doingScene = false
local curPanel = 0
local camYs = {[0] = -1350,-900,-900,-900,-900,-400,-400,485}

function onCreate()
    notDoneScene = not (utils:getGariiData("watchedCutscene"))
    addLuaScript("scripts/objects/extraCharacter")
    setProperty("skipCountdown", true)

    callOnLuas("addExtraSup", {"hunte", "hunte-support", defaultGirlfriendX,defaultGirlfriendY})
    callOnLuas("addExtraSup", {"carv", "carv-support", defaultGirlfriendX,defaultGirlfriendY})
    setProperty("carv.visible", false)
    setProperty("hunte.visible", false)

    utils:runHaxeCode([[
        import flixel.sprite.FlxSprite;
        var camAlt:FlxCamera;
        var camAltTwo:FlxCamera;
        camAlt = new FlxCamera(-640,0);
        camAltTwo = new FlxCamera(1280,0);
        FlxG.cameras.add(camAlt);
        FlxG.cameras.add(camAltTwo);
        FlxG.cameras.remove(camHUD, false); //yeah i had to do this cause of layering
        FlxG.cameras.remove(camOther, false);
        FlxG.cameras.add(camHUD, false);
        FlxG.cameras.add(camOther, false);
        camAlt.width = 640;
        camAltTwo.width = 640;
        camAlt.visible = false;
        camAltTwo.visible = false;
        var spr:FlxSprite = new FlxSprite(100,550);
        camAlt.follow(spr);
        var sprtwo:FlxSprite = new FlxSprite(1250,550);
        camAltTwo.follow(sprtwo);
    ]])
end

function onCreatePost()
    if (stringEndsWith(difficultyPath, "expert")) then
        callOnLuas("addExtraOpp", {"garii2", "garii-redeyes", -60,70, true})
        setProperty("garii2.alpha", 0)
        removeLuaSprite("iconTimegarii2")
    end
    if (not isStoryMode) or (not notDoneScene) then return end

    makeLuaSprite('tcbg','',0,-((590 * 1.75)*2))
    makeGraphic("tcbg", 1500, 1986, "FFFFFF")
	scaleObject('tcbg', 1.6, 1.6)
	setScrollFactor('tcbg', 0, 1)
	screenCenter("tcbg", "x")
	addLuaSprite('tcbg',true)

    local covers = {[0] = {-444,-1935}, {-425,-1141}, {61,-1198}, {372,-1157}, {959,-1196}, {-433,-686}, {1070,-662}, {-413,-73}}
    for i=0,7 do
        makeLuaSprite('tcpanel'..i,'comicpanels/'.."panel "..i.." gari page",0,0)
        setProperty("tcpanel"..i..".alpha", 1 - math.min(i,1))
        scaleObject("tcpanel"..i, 1.6, 1.6)
        setScrollFactor("tcpanel"..i, 0, 1)
        screenCenter("tcpanel"..i, "x")
        setProperty("tcpanel"..i..".x", covers[i][1])
        setProperty("tcpanel"..i..".y", covers[i][2])
        addLuaSprite("tcpanel"..i,true)
    end

    makeAnimatedLuaSprite('advancehint','comicpanels/advancehint',1150,-1000)
    addAnimationByPrefix("advancehint", "idle", "comic advance hint", 24, true)
	scaleObject('advancehint', 1.6, 1.6)
    setProperty("advancehint.alpha", 0)
	setScrollFactor('advancehint', 0, 1)
	addLuaSprite('advancehint',true)
    runTimer("advancehint", 3)
end

function onStartCountdown()
	if (notDoneScene and isStoryMode) then
		cutsceneShits()
		return Function_Stop;
	end
end

function onStepHit()
    if (curStep == 1 or (curStep % 4 == 0 and curBeat < 5)) then
        callOnScripts("onCountdownTick", {curBeat})
        utils:newCountdown(curBeat)
    end
end

function advancePanel()
    curPanel = curPanel + 1
    local sounds = {{"fuzzyloopstart", 0.8}, {"mmm_chicen", 0.75}, {"le_bubel_pop", 0.75}, {"boybeep",0.8}, {"boydah",0.75}}
    if (sounds[curPanel] ~= nil) then utils:playSound("cutscene/"..sounds[curPanel][1], sounds[curPanel][2], sounds[curPanel][1]) end
    doTweenAlpha("tcpanel"..curPanel, "tcpanel"..curPanel, 1, 0.5)
    setProperty("camFollow.y", camYs[curPanel])
    setProperty("advancehint.visible", curPanel < 1)

    if (curPanel == 3) then runTimer("advanceComic", 0.25)
    else stopTimer("advanceComic")
    end
end

function onUpdate()
    if (not doingScene) then return end

    if (keyJustPressed("accept")) then
        advancePanel()
    end
    if (luaSoundExists("fuzzyloop") and getSoundTime("fuzzyloop") < 2140 and curPanel >= 7) then
        setSoundVolume("fuzzyloopcoverend", 0.8)
        stopSound("fuzzyloop")
    end
    if (curPanel > 7) then
        doingScene = false
        notDoneScene = false
        utils:setGariiData("watchedCutscene", true)
        stopSound("fuzzyloopstart")
        stopSound("fuzzyloop")
        stopSound("fuzzyloopend")
        stopSound("fuzzyloopcoverend")
        callOnLuas("cutsceneOver", {})
        doTweenAlpha("tcbg", "tcbg", 0, 1)
        doTweenAlpha("tcpanel7", "tcpanel7", 0, 1)
		setProperty("cameraSpeed", 1)
		runTimer("hudTwn", 0.5)
		triggerEvent("Camera Follow Pos", nil, nil)
		startCountdown()
    end
end

function cutsceneShits()
    doingScene = true
    callOnLuas("disablePause", {})
    setProperty("isCameraOnForcedPos", true)
    setProperty("camFollow.x", 366)    
    setProperty("camFollow.y", camYs[0])
	setProperty("cameraSpeed", 10)
	setProperty("camHUD.alpha", 0)
end

function onEventPushed(name, value1, value2, strumTime)
    local event = name:lower()
    if (event == "goons fall") then
        makeAnimatedLuaSprite("truckergf-looney", "characters/truckergirl-support", defaultGirlfriendX, defaultGirlfriendY)
        addAnimationByPrefix("truckergf-looney", "looney", "girl mario ahahahaha", 24, true)
        addOffset("truckergf-looney", "looney", -150,-100)
        setProperty("truckergf-looney.scrollFactor.x", 0.95)
        setProperty("truckergf-looney.scrollFactor.y", 0.95)
        setProperty("truckergf-looney.alpha", 0)
        addLuaSprite("truckergf-looney", true)
    end
end

local shit = false
function onEvent(name, value1, value2, strumTime)
    local event = name:lower()
    local val1 = value1:lower()
    local val2 = value2:lower()

    if (event == "goons fall") then
        callMethod("carv.playAnim", {"fall"})
        callMethod("hunte.playAnim", {"fall"})
        setProperty("carv.specialAnim", true)
        setProperty("hunte.specialAnim", true)
        setProperty("carv.visible", true)
        setProperty("hunte.visible", true)
        runTimer("fly gf fly", 4/24)
        runTimer("startle bf", 6/24)
        runTimer("die goons", 30/24)
    elseif (event == "kill extra garii") then 
        setProperty("garii2.alpha", 0)
        callOnLuas("removeExtraChar", {"garii2"})
    elseif (event == "toggle close-up cams") then
        shit = not shit
        if (shit) then doTweenAlpha("garii2", "garii2", 1, 5)
        end
        utils:runHaxeCode([[
            FlxG.cameras.list[1].visible = !FlxG.cameras.list[1].visible;
            FlxG.cameras.list[2].visible = !FlxG.cameras.list[2].visible;

            if (FlxG.cameras.list[1].visible) {
                FlxTween.tween(FlxG.cameras.list[1], {x:0}, 0.75, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween) {
                    FlxTween.tween(FlxG.cameras.list[1], {zoom:1.5}, 20);
                }});
            } else {
                FlxG.cameras.list[1].visible = true;
                FlxTween.tween(FlxG.cameras.list[1], {x:-640}, 0.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween) {
                    FlxG.cameras.list[1].visible = false;
                }});
            }

            if (FlxG.cameras.list[2].visible) {
                FlxTween.tween(FlxG.cameras.list[2], {x:640}, 0.75, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween) {
                    FlxTween.tween(FlxG.cameras.list[2], {zoom:1.5}, 20);
                }});
            } else {
                FlxG.cameras.list[2].visible = true;
                FlxTween.tween(FlxG.cameras.list[2], {x:1280}, 0.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween) {
                    FlxG.cameras.list[2].visible = false;
                }});
            }
        ]])
    end
end

canShit = false
doGFChecks = false
function onTimerCompleted(tag, loops, loopsLeft)
	if (tag == 'fly gf fly') then
        utils:playSound("badexplosion", 0.25)
        setProperty("gf.alpha", 0)
        doGFChecks = true
        playAnim("truckergf-looney", "looney")
        setProperty("truckergf-looney.alpha", 1)
        triggerEvent("Change Character", "gf", "hunte-support")
        canShit = true
    elseif (tag == "startle bf") then triggerEvent("Play Animation", "startled", "bf")
        --runTimer("startle bf end", 58/24)
        --setProperty("boyfriend.stunned", true)
        setProperty("boyfriendBubbles.alpha", 0)
    --elseif (tag == "startle bf end") then setProperty("boyfriend.stunned", false)
    elseif (tag == "die goons") then
        setProperty("gf.alpha", 1)
        callOnLuas("removeExtraChar", {"hunte", true})
    elseif (tag == "cutsceneCuntdown") then
		notDoneScene = false
		setProperty("cameraSpeed", 1)
		runTimer("hudTwn", 0.55)
		triggerEvent("Camera Follow Pos", nil, nil)
		startCountdown()
	elseif (tag == "hudTwn") then doTweenAlpha("hudtween", "camHUD", 1, 0.5)
        callOnLuas("enablePause", {})
    elseif (tag == "advanceComic") then advancePanel()
    elseif (tag == "advancehint") then doTweenAlpha("advancehint", "advancehint", 1, 0.5)
	end
end

function onSoundFinished(tag)
    if tag == 'fuzzyloop' or tag == 'fuzzyloopstart' then 
        if (curPanel >= 6) then utils:playSound("cutscene/fuzzyloopend", 0.8, "fuzzyloopend")
        else utils:playSound("cutscene/fuzzyloop", 0.8, "fuzzyloop") 
            utils:playSound("cutscene/fuzzyloopend", 0, "fuzzyloopcoverend") 
        end
    elseif (tag == 'fuzzyloopend' or (tag == 'fuzzyloopcoverend' and curPanel >= 7)) and doingScene then 
        if (tag == "fuzzyloopcoverend" and luaSoundExists("fuzzyloop")) then return end
        advancePanel()
    end
end

function onUpdatePost(elp)
    if (canShit) then
        local shats = {"truckergf-looney", "spkr1", "spkr2"}
        for i,spr in pairs(shats) do
            if luaSpriteExists(spr) then
                if (getProperty(spr..".y") > -1000) then setProperty(spr..".y", getProperty(spr..".y") - (180 * (60/framerate)))
                else removeLuaSprite(spr, true)
                end
            end
        end
    end
end