
local utils = (require (getVar("folDir").."scripts.backend.utils")):new()

function onCreate()
    addLuaScript("scripts/objects/extraCharacter")
    setProperty("skipCountdown", true)

    callOnLuas("addExtraSup", {"hunte", "hunte-support", defaultGirlfriendX,defaultGirlfriendY})
    callOnLuas("addExtraSup", {"carv", "carv-support", defaultGirlfriendX,defaultGirlfriendY})
    setProperty("carv.visible", false)
    setProperty("hunte.visible", false)
end

function onCreatePost() --660
    callOnLuas("addExtraOpp", {"gariiANGERY", "garii", -60,70, true})
    setProperty("gariiANGERY.visible", false)
    setProperty('gariiANGERY.idleSuffix', '-shaking')
    playAnim("gariiANGERY", "idle-shaking", true)
    removeLuaSprite("iconTimegariiANGERY")
    if (stringEndsWith(difficultyPath, "expert")) then
        callOnLuas("addExtraOpp", {"garii2", "garii-redeyes", -60,70, true})
        setProperty("garii2.alpha", 0)
        removeLuaSprite("iconTimegarii2")
    end

    runTimer("delayCreate", 0.1)
    utils:runHaxeCode([[
        import flixel.sprite.FlxSprite;
        var camBustOpp:FlxCamera = new FlxCamera(0,720, 640,470, 1.5);
        var camBustPlr:FlxCamera = new FlxCamera(640,720, 640,470, 1.5);
        var camHeadOpp:FlxCamera = new FlxCamera(0,720, 1280,399, 1);
        camBustOpp.bgColor = 0xFFFFFFFF;
        camBustPlr.bgColor = 0xFFFFFFFF;
        camHeadOpp.bgColor = 0xFFFFFFFF;
        FlxG.cameras.add(camBustOpp, false);
        FlxG.cameras.add(camBustPlr, false);
        FlxG.cameras.add(camHeadOpp, false);
        FlxG.cameras.remove(camHUD, false); //yeah i had to do this cause of layering
        FlxG.cameras.remove(camOther, false);
        FlxG.cameras.add(camHUD, false);
        FlxG.cameras.add(camOther, false);
        camBustOpp.visible = false;
        camBustPlr.visible = false;
        camHeadOpp.visible = false;
        var spr:FlxSprite = new FlxSprite(500,550);
        camHeadOpp.follow(spr);
        var spr:FlxSprite = new FlxSprite(250,470);
        camBustOpp.follow(spr);
        var sprtwo:FlxSprite = new FlxSprite(1350,470);
        camBustPlr.follow(sprtwo);
        game.dad.cameras = [game.camGame, camBustOpp, camHeadOpp];
        game.getLuaObject("gariiANGERY").cameras = [camBustOpp];
        game.boyfriend.cameras = [game.camGame, camBustPlr];
        game.getLuaObject("garii2").cameras = [game.camGame, camBustOpp, camHeadOpp];
    ]])
end

function onCreateDelay()
    makeAnimatedLuaSprite("borderhalf", "borderlineUI/borderhalf",0,720)
    addAnimationByPrefix("borderhalf", "reg", "bordersplit")
    utils:setObjectCamera("borderhalf", "hud")
    setObjectOrder("borderhalf", 0)
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
            doTweenY("borderleft", "borderhalf", 0, 0.5, "sineOut")
        else
            doTweenY("borderleft", "borderhalf", -1119, 0.5, "sineOut")
        end
        utils:runHaxeCode([[
            var fuckass:Bool = true;
            for (i in 1...3) {
                FlxG.cameras.list[i].visible = !FlxG.cameras.list[i].visible;
                fuckass = FlxG.cameras.list[i].visible;
                if (FlxG.cameras.list[i].visible) {
                    FlxTween.tween(FlxG.cameras.list[i], {y:0}, 0.5, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween) {
                        FlxTween.tween(FlxG.cameras.list[i], {zoom:1.75}, 20);
                    }});
                } else {
                    FlxG.cameras.list[i].visible = true;
                    FlxTween.tween(FlxG.cameras.list[i], {y:-1119}, 0.5, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween) {
                        FlxG.cameras.list[i].visible = false;
                    }});
                }
            }
            if (fuckass) {
                FlxTween.tween(game.camGame, {y:-720}, 0.5, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween) {
                    game.camGame.y = 720;
                }});
            } else {
                FlxTween.tween(game.camGame, {y:0}, 0.5, {ease: FlxEase.sineOut});
                FlxTween.tween(FlxG.cameras.list[3], {y:-399}, 0.5, {ease: FlxEase.sineOut});
            }
        ]])
    elseif (event == "advance close-up cams") then
        setProperty("gariiANGERY.visible", true)
        triggerEvent("extra-char-play-anim", "gariiANGERY", "idle-shaking")

        doTweenY("borderleft", "borderhalf", -399, 0.5, "sineOut")

        utils:runHaxeCode([[
            for (i in 1...3) {
                FlxTween.tween(FlxG.cameras.list[i], {y:-399}, 0.5, {ease: FlxEase.sineOut});
            }
            FlxG.cameras.list[3].visible = true;
            FlxTween.tween(FlxG.cameras.list[3], {y:321}, 0.5, {ease: FlxEase.sineOut});
            
            game.dad.cameras = [game.camGame, FlxG.cameras.list[3] ];
        ]])
    elseif (event == "change character") then
        local valExc = {["gf"] = "gf", ["girlfriend"] = "gf", ["1"] = "gf", ["dad"] = "dad", ["opponent"] = "dad", ["0"] = "dad"}
        local chngChr = valExc[val1] or "boyfriend"

        if (chngChr == "boyfriend") then --hackjob solution to fix a bullshit problem
            utils:runHaxeCode("game.boyfriend.cameras = [game.camGame, FlxG.cameras.list[2]];")
        end
    end
end

canShit = false
doGFChecks = false
function onTimerCompleted(tmr)
	if (tmr == 'fly gf fly') then
        utils:playSound("badexplosion", 0.25)
        setProperty("gf.alpha", 0)
        doGFChecks = true
        playAnim("truckergf-looney", "looney")
        setProperty("truckergf-looney.alpha", 1)
        triggerEvent("Change Character", "gf", "hunte-support")
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