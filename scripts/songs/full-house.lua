
local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local closeMode = false
local canIcon, didIcon = false, false
function onCreate()
    addLuaScript("scripts/objects/extraCharacter")
    setProperty("skipCountdown", true)

    makeLuaSprite('blackin','gameOver/black-paper',450,116)
    setGraphicSize("blackin", 1300, 740)
    addLuaSprite('blackin')
    setObjectOrder("blackin", getObjectOrder('gfGroup'))
    setProperty("blackin.visible", false)
    
    makeLuaSprite('blackoutSpr','gameOver/black-paper',-10,-10)
    setGraphicSize("blackoutSpr", 1300, 740)
    setObjectCamera('blackoutSpr','other')
    setProperty('blackoutSpr.visible', false)
    addLuaSprite('blackoutSpr')

    makeLuaSprite('over','gameOver/not-black-paper',-10,-10)
    setGraphicSize("over", 1300, 740)
	setBlendMode('over', "multiply")
    setObjectCamera('over','other')
    setProperty('over.visible', false)
    addLuaSprite('over')
end

function onCreatePost()
    setProperty("dad.x", getProperty("dad.x") - 100)
    setProperty("spkr2.visible", false)

    callOnLuas("addExtraOpp", {"hunte", "hunte", -310,150})
    setProperty("hunte.visible", stringEndsWith(difficultyPath, "expert"))
    triggerEvent("Extra Char Alt Anims", "hunte", "-nomic")
    triggerEvent("Extra Char Alt Idle", "hunte", "-nomic")
    playAnim("hunte", "idle-nomic", true)
    if (stringEndsWith(difficultyPath, "expert")) then
        updateGF()
    end
    if (timeBarType ~= "Disabled" and (not stringEndsWith(difficultyPath, "expert"))) then setProperty("iconTimehunte.x", -150) end
end


function onStepHit()
    if (curStep == 1 or (curStep % 4 == 0 and curBeat < 5)) then
        callOnScripts("onCountdownTick", {curBeat})
        utils:newCountdown(curBeat)
    end
    if (curStep == 144) then setProperty("hunte.visible", true)
    elseif (curStep >= 208 and not didIcon) then canIcon = true
    end
end

function updateGF()
    setProperty("spkr2.visible", true)
    setProperty("gf.scrollFactor.x", 1)
    setProperty("gf.scrollFactor.y", 1)
    setObjectOrder('gfGroup', getObjectOrder('boyfriendGroup')+1)
    setProperty("gf.flipX", false)
    setProperty("gf.x", 1060 + getProperty("gf.positionArray")[1])
    setProperty("gf.y", 200 + getProperty("gf.positionArray")[2])
end

function onUpdate()
    if (canIcon) then
        setProperty("iconTimehunte.x", utils:lerp(getProperty("iconTimehunte.x"), 0, 0.1))
        if (getProperty("iconTimehunte.x") > -1) then canIcon = false
            didIcon = true
            setProperty("iconTimehunte.x", 0)
        end
    end
end

function opponentNoteHit()
    if (closeMode) then
        local defOppX = defaultOpponentX
        if (stringStartsWith(dadName, "hunte")) then defOppX = defOppX + 90 end

        cancelTween("oppAlphaTween")
        cancelTween("oppXTween")
        cancelTimer("oppCloseTween")
        setProperty("dad.alpha", 1)
        setProperty("dad.x", defOppX + 300)
        runTimer("oppCloseTween", 0.25)
    end
end


function goodNoteHit() playerAlpha() end
function noteMiss() playerAlpha() end

function playerAlpha()
    if (not closeMode) then return end
    local defPlrX = defaultBoyfriendX
    if (stringStartsWith(boyfriendName, "truckergirl")) then defPlrX = defPlrX - 50 end
    cancelTween("plrAlphaTween")
    cancelTween("plrXTween")
    cancelTimer("plrCloseTween")
    setProperty("boyfriend.alpha", 1)
    setProperty("boyfriend.x", defPlrX + 300)
    runTimer("plrCloseTween", 0.25)
end

function onTweenCompleted(twn)
    if (stringStartsWith(twn, "count")) then removeLuaSprite(twn, true) end
end

function onTimerCompleted(tmr)
    if (tmr == "oppCloseTween") then
        local defOppX = defaultOpponentX
        if (stringStartsWith(dadName, "hunte")) then defOppX = defOppX + 90 end
        doTweenX("oppXTween", "dad", defOppX - 200, 0.75, "circIn")
        doTweenAlpha("oppAlphaTween", "dad", 0, 0.25, "circIn")
    elseif (tmr == "plrCloseTween") then
        doTweenX("plrXTween", "boyfriend", defaultBoyfriendX + 800, 0.75, "circIn")
        doTweenAlpha("plrAlphaTween", "boyfriend", 0, 0.25, "circIn")
    end
end

function onEvent(name, value1, value2, strumTime)
    local event = utils:lwrKebab(name)
    local val1 = value1:lower()
    local val2 = value2:lower()

	if (event == "change-character") and (val1 == "gf" or val1 == "girlfriend" or val1 == "1") then updateGF()
    elseif (event == "hunte-be-evil") then
    elseif (event == "toggle-blackout") then
        setProperty("blackoutSpr.visible", not getProperty("blackoutSpr.visible"))
    elseif (event == "set-char-colour") then
        setProperty(val1..".color", getColorFromHex(val2))
    elseif (event == "setup-close-shit") then
        setProperty("blackin.visible", val1 == "")
        setProperty("bg.visible", val1 ~= "")
        setProperty("gf.visible", val1 ~= "")
        setProperty('over.visible', val1 == "")
        closeMode = (val1 == "")
        if (val1 == "") then
            for chr,var in pairs({["dad"] = {x = defaultOpponentX, y = defaultOpponentY, clr = "4D664D"}, ["boyfriend"] = {x = defaultBoyfriendX, y = defaultBoyfriendY, clr = "C55252"}}) do
                setProperty(chr..".color", getColorFromHex(var.clr))
                setProperty(chr..".x", var.x + 300)
                setProperty(chr..".y", var.y + 150)
                setProperty(chr..".alpha", 0)
            end
            for i=0,2 do setProperty('cr'..i..'.alpha', 0) end
            setProperty("cameraSpeed", 16)
        else
            setProperty("cameraSpeed", 1)
            for i=0,2 do setProperty('cr'..i..'.alpha', 1) end
            setProperty("dad.alpha", 1)
            setProperty("boyfriend.alpha", 1)
            for _,tag in pairs({"oppAlphaTween", "oppXTween", "oppCloseTween", "plrAlphaTween", "plrXTween", "plrCloseTween"}) do
                cancelTween(tag)
                cancelTimer(tag)
            end
        end
    end
end