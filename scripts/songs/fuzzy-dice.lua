
local utils = (require (getVar("folDir").."scripts.backend.utils")):new()

function onCreate()
    addLuaScript("scripts/objects/extraCharacter")
    setProperty("skipCountdown", true)

    callOnLuas("addExtraSup", {"hunte", "hunte-support", defaultGirlfriendX,defaultGirlfriendY})
    callOnLuas("addExtraSup", {"carv", "carv-support", defaultGirlfriendX,defaultGirlfriendY})
    setProperty("carv.visible", false)
    setProperty("hunte.visible", false)
end

function onCreatePost()
    if (stringEndsWith(difficultyPath, "expert")) then
        callOnLuas("addExtraOpp", {"garii2", "garii-redeyes", -60,70, true})
        setProperty("garii2.alpha", 0)
        removeLuaSprite("iconTimegarii2")
    end
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
        game.boyfriend.cameras = [game.camGame, camAltTwo];
    ]])
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