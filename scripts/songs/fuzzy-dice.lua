
local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local diif = "normal"

function onCreate()
    addLuaScript("scripts/objects/extraCharacter")
    setProperty("skipCountdown", true)

    callOnLuas("addExtraSup", {"hunte", "hunte-support", defaultGirlfriendX,defaultGirlfriendY, nil, false})
    callOnLuas("addExtraSup", {"carv", "carv-support", defaultGirlfriendX,defaultGirlfriendY})
    callOnLuas("addExtraSup", {"tg", "truckergirl", 1060,200})
    setObjectOrder('tg', getObjectOrder('boyfriendGroup')+1)
    setProperty("tg.visible", false)
    setProperty("carv.visible", false)
    setProperty("hunte.visible", false)
end

function onCreatePost() --660
    setProperty("iconTimecarv.visible", false)
    local cameraString = [[
        import flixel.sprite.FlxSprite;
        var camFourCrv:FlxCamera = new FlxCamera(520,725, 350,410, 0.75);
        var camFourHnt:FlxCamera = new FlxCamera(512,915, 575,399, 0.75);//+190
        var camFourOpp:FlxCamera = new FlxCamera(0,725, 410,315, 1.25);
        var camFourPlr:FlxCamera = new FlxCamera(790,725, 370,315, 1.25);

        camFourHnt.angle = -30;
        FlxG.cameras.add(camFourCrv, false);
        FlxG.cameras.add(camFourHnt, false);
        FlxG.cameras.add(camFourOpp, false);
        FlxG.cameras.add(camFourPlr, false);

        var camBustOpp:FlxCamera = new FlxCamera(0,1145, 640,350, 1.5);
        var camBustPlr:FlxCamera = new FlxCamera(640,1145, 410,350, 1.5);
        var camHeadOpp:FlxCamera = new FlxCamera(0,1135, 1280,390, 1);
        FlxG.cameras.add(camBustOpp, false);
        FlxG.cameras.add(camBustPlr, false);
        FlxG.cameras.add(camHeadOpp, false);

        FlxG.cameras.remove(camHUD, false); //yeah i had to do this cause of layering
        FlxG.cameras.remove(camOther, false);
        FlxG.cameras.add(camHUD, false);
        FlxG.cameras.add(camOther, false);
        for (i in 1...8) {
            FlxG.cameras.list[i].active = FlxG.cameras.list[i].visible = false;
            FlxG.cameras.list[i].bgColor = 0xFFFFFFFF;
        }
        camFourCrv.follow(new FlxSprite(850,510));
        camFourHnt.follow(new FlxSprite(480,470));
        camFourOpp.follow(new FlxSprite(100,450));
        camHeadOpp.follow(new FlxSprite(500,550));
        camBustOpp.follow(new FlxSprite(250,470));
        camFourPlr.follow(new FlxSprite(1250,460));
        camBustPlr.follow(new FlxSprite(1250,470));
        game.dad.cameras = [game.camGame, camFourOpp, camBustOpp, camHeadOpp];
        game.boyfriend.cameras = [game.camGame, camFourPlr, camBustPlr];
        game.getLuaObject("carv").cameras = [game.camGame, camFourCrv];
        game.gf.cameras = [game.camGame, camFourHnt];
    ]]

    runTimer("delayCreate", 0.1)
    utils:runHaxeCode(cameraString)
end

function onCreateDelay()
    makeAnimatedLuaSprite("borderfour", "borderlineUI/borderfour",0,720)
    addAnimationByPrefix("borderfour", "reg", "borderfour")
    utils:setObjectCamera("borderfour", "hud")
    setObjectOrder("borderfour", 0)

    makeAnimatedLuaSprite("borderhalf", "borderlineUI/borderhalf",0,1140)
    addAnimationByPrefix("borderhalf", "reg", "borderhalf")
    utils:setObjectCamera("borderhalf", "hud")
    setObjectOrder("borderhalf", 0)

    if (stringEndsWith(difficultyPath, "simple")) then diif = "simple"
    elseif (stringEndsWith(difficultyPath, "expert")) then diif = "expert"
        makeLuaSprite("screenie5", "comicpanels/middice5", 0,0)
        setProperty("screenie5.alpha", 0)
        utils:setObjectCamera("screenie5", "hud")
        setObjectOrder("screenie5", 0)
        makeLuaSprite("screeniegari", "comicpanels/gari", 0,0)
        setProperty("screeniegari.alpha", 0)
        utils:setObjectCamera("screeniegari", "hud")
        screenCenter("screeniegari")
        setObjectOrder("screeniegari", 1)
    else
        makeAnimatedLuaSprite("borderbottom", "borderlineUI/borderbottom",0,1130)
        addAnimationByPrefix("borderbottom", "reg", "borderbottom")
        utils:setObjectCamera("borderbottom", "hud")
        setObjectOrder("borderbottom", 0)

        makeAnimatedLuaSprite("watdafak", "bubbles/garicurse", 500,0)
        addAnimationByPrefix("watdafak", "reg", "watdagak", 24, false)
        setProperty("watdafak.alpha", 0)
        utils:setObjectCamera("watdafak", "hud")
        setObjectOrder("watdafak", 1)
        
        makeLuaSprite("screenie4", "comicpanels/middice4", 0,0)
        setProperty("screenie4.alpha", 0)
        utils:setObjectCamera("screenie4", "hud")
        setObjectOrder("screenie4", 0)
    end

    for i = 1,3 do
        makeLuaSprite("screenie"..i, "comicpanels/middice"..i, 0,0)
        setProperty("screenie"..i..".alpha", 0)
        utils:setObjectCamera("screenie"..i, "hud")
        setObjectOrder("screenie"..i, 0)
    end
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

local shit = 0
local lolfall = false
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
    elseif (event == "advance close-up cams") then
        shit = shit + 1
        if (shit == 1) then
            doTweenAlpha("screenie1", "screenie1", 1, 0.5)
            runTimer("togel1", 0.5)
        elseif (shit == 2) then
            doTweenAlpha("screenie2", "screenie2", 1, 0.25)
            doTweenY("screenieone", "screenie1", -1060, 0.5, "sineOut")
            doTweenY("borderfour", "borderfour", -340, 0.5, "sineOut")
            doTweenY("borderhalf", "borderhalf", 80, 0.5, "sineOut")
            utils:runHaxeCode([[
                for (i in 1...7) {
                    if (i == 2) {
                        FlxTween.tween(FlxG.cameras.list[i], {y:-145}, 0.5, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween) {
                            FlxG.cameras.list[i].visible = FlxG.cameras.list[i].active = false;
                        }});
                    } else if (i <= 4) {
                        FlxTween.tween(FlxG.cameras.list[i], {y:-335}, 0.5, {ease: FlxEase.sineOut});
                    } else {
                        FlxTween.tween(FlxG.cameras.list[i], {y:85}, 0.5, {ease: FlxEase.sineOut});
                    }
                }
            ]])
            if (luaSpriteExists("borderbottom")) then doTweenY("borderbottom", "borderbottom", 640, 0.5, "sineOut")
                utils:runHaxeCode([[
                    FlxTween.tween(FlxG.cameras.list[7], {y:645}, 0.5, {ease: FlxEase.sineOut});
                    FlxG.cameras.list[7].active = FlxG.cameras.list[7].visible = true;
                ]])
            else
                runTimer("quickfade", 8)
                utils:runHaxeCode([[
                    game.camGame.y = 1210;
                    FlxTween.tween(game.camGame, {y:640}, 0.5, {ease: FlxEase.sineOut});
                ]])
            end
        elseif (shit == 3 and luaSpriteExists("borderbottom")) then
            runTimer("quickfade", 0.5)
            doTweenAlpha("screenie3", "screenie3", 1, 0.25)
            setProperty("watdafak.alpha", 1)
            playAnim("watdafak", "reg")
            
            doTweenY("borderhalf", "borderhalf", -410, 0.5, "sineOut")
            doTweenY("borderfour", "borderfour", -830, 0.5, "sineOut")
            doTweenY("borderbottom", "borderbottom", 150, 0.5, "sineOut")
    
            utils:runHaxeCode([[
                for (i in 1...7) {
                    if (i > 4) {
                        FlxTween.tween(FlxG.cameras.list[i], {y:-405}, 0.5, {ease: FlxEase.sineOut});
                    } else {
                        FlxTween.tween(FlxG.cameras.list[i], {y:-825}, 0.5, {ease: FlxEase.sineOut});
                    }
                }
                FlxG.cameras.list[7].visible = true;
                FlxTween.tween(FlxG.cameras.list[7], {y:155}, 0.5, {ease: FlxEase.sineOut});

                game.camGame.y = 1060;
                FlxTween.tween(game.camGame, {y:570}, 0.5, {ease: FlxEase.sineOut});
            ]])
        else 
            setProperty("gf.angle", 0)
            if (luaSpriteExists("borderbottom")) then doTweenY("borderbottom", "borderbottom", -419, 0.5, "sineOut")

                doTweenY("borderhalf", "borderhalf", -1119, 0.5, "sineOut")
                utils:runHaxeCode([[
                    for (i in 5...7) {
                        FlxG.cameras.list[i].visible = true;
                        FlxTween.tween(FlxG.cameras.list[i], {y:-1114}, 0.5, {ease: FlxEase.sineOut});
                    }
                    FlxTween.tween(game.camGame, {y:0}, 0.5, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween) {
                        for (i in 1...8) {
                            FlxG.cameras.list[i].visible = FlxG.cameras.list[i].active = false;
                        }
                    }});
                    FlxTween.tween(FlxG.cameras.list[7], {y:-394}, 0.5, {ease: FlxEase.sineOut});
                ]])
            else doTweenY("borderfour", "borderfour", -980, 0.5, "sineOut")
                doTweenY("borderhalf", "borderhalf", -560, 0.5, "sineOut")
                
                utils:runHaxeCode([[
                    for (i in 1...7) {
                        FlxTween.tween(FlxG.cameras.list[i], {y:-555}, 0.5, {ease: FlxEase.sineOut});
                    }
                    FlxTween.tween(game.camGame, {y:0}, 0.5, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween) {
                        for (i in 1...8) {
                            FlxG.cameras.list[i].visible = FlxG.cameras.list[i].active = false;
                        }
                    }});
                ]])
            end
            --doTweenY("screenie21", "screenie2", -1119, 0.5, "sineOut")
        end
    elseif (event == "change character") then
        local valExc = {["gf"] = "gf", ["girlfriend"] = "gf", ["1"] = "gf", ["dad"] = "dad", ["opponent"] = "dad", ["0"] = "dad"}
        local chngChr = valExc[val1] or "boyfriend"

        if (chngChr == "boyfriend") then --hackjob solution to fix a bullshit problem
            utils:runHaxeCode("game.boyfriend.cameras = [game.camGame, FlxG.cameras.list[4], FlxG.cameras.list[6]];")
        elseif (chngChr == "dad") then
            utils:runHaxeCode("game.dad.cameras = [game.camGame, FlxG.cameras.list[3], FlxG.cameras.list[5], FlxG.cameras.list[7]];")
        elseif (chngChr == "gf") then
            utils:runHaxeCode("game.gf.cameras = [game.camGame, FlxG.cameras.list[2]];")
        end
    elseif (event == "panel please") then
        setProperty("screenie5.alpha", 1)
        runTimer("scren", 0.75)
        runTimer("screm", 0.25)
    end
end

function toggleShits()
    if (shit ~= 1) then return end
    doTweenY("screenieone", "screenie1", -570, 0.5, "sineOut")
    doTweenY("borderfour", "borderfour", 150, 0.5, "sineOut")
    doTweenY("borderhalf", "borderhalf", 570, 0.5, "sineOut")
    utils:runHaxeCode([[
        for (i in 1...7) {
            FlxG.cameras.list[i].active = FlxG.cameras.list[i].visible = true;
            if (i == 2) {
                FlxTween.tween(FlxG.cameras.list[i], {y:345}, 0.5, {ease: FlxEase.sineOut});
            } else if (i > 4) {
                FlxTween.tween(FlxG.cameras.list[i], {y:575}, 0.5, {ease: FlxEase.sineOut});
            } else {
                FlxTween.tween(FlxG.cameras.list[i], {y:155}, 0.5, {ease: FlxEase.sineOut});
            }
        }
        FlxTween.tween(game.camGame, {y:-570}, 0.5, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween) {
            game.camGame.y = 720;
        }});
    ]])
end

canShit = false
doGFChecks = false
function onTimerCompleted(tmr)
    if (tmr == "quickfade") then
        if (luaSpriteExists("borderbottom")) then 
            doTweenAlpha("screenie4", "screenie4", 1, 0.25)
        else
            doTweenAlpha("screenie3", "screenie3", 1, 0.25)
        end
    elseif (tmr == "scren") then setProperty("screenie5.alpha", 0)
            setProperty("screeniegari.alpha", 0)
        lolfall = false
    elseif (tmr == "screm") then        setProperty("screeniegari.alpha", 1)
        lolfall = true
	elseif (tmr == 'fly gf fly') then
        utils:playSound("badexplosion", 0.25)
        setProperty("gf.alpha", 0)
        doGFChecks = true
        playAnim("truckergf-looney", "looney")
        setProperty("truckergf-looney.alpha", 1)
        triggerEvent("Change Character", "gf", "hunte-support")
        setProperty("iconTimecarv.visible", true)
        canShit = true
    elseif (tmr == "startle bf") then triggerEvent("Play Animation", "startled", "bf")
        --runTimer("startle bf end", 58/24)
        --setProperty("boyfriend.stunned", true)
        setProperty("boyfriendBubbles.alpha", 0)
    --elseif (tag == "startle bf end") then setProperty("boyfriend.stunned", false)
    elseif (tmr == "die goons") then
        setProperty("gf.alpha", 1)
        callOnLuas("removeExtraChar", {"hunte", true})
    elseif (tmr == "delayCreate") then onCreateDelay()
    elseif (tmr == "togel1") then toggleShits()
        setProperty("gf.angle", 30)
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
    if (luaSpriteExists("borderbottom")) then
        setProperty("watdafak.y", getProperty("borderbottom.y") + 40)
        setProperty("screenie4.y", getProperty("borderbottom.y"))
    end
    setProperty("screenie2.y", getProperty("borderfour.y"))
    setProperty("screenie3.y", getProperty("borderhalf.y"))
    if (curStep == 508 and stringEndsWith(difficultyPath, "expert")) then
        setProperty("tg.visible", true)
    end
    if (getProperty("camFollow.x") >= 700) then
        setProperty("tg.idleSuffix", "-alt")
    else
        setProperty("tg.idleSuffix", "")
    end
    if (lolfall) then
        setProperty("screeniegari.scale.x", getProperty("screeniegari.scale.x") - (0.025 * (60/framerate)))
        setProperty("screeniegari.scale.y", getProperty("screeniegari.scale.y") - (0.025 * (60/framerate)))
        screenCenter("screeniegari")
    end
end