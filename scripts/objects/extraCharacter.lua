local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local disableBar = (timeBarType == "Disabled")
local iconLimits = {-1,0}
local storedChrs = {}
local chrAmts = {["opp"] = 0, ["sup"] = 0}
local lastMHS = true
local lastcombo = 0

function addExtraOpp(varName, chName, xPos, yPos, def, hasIcon) makeNewCommon(varName, chName, xPos, yPos, getObjectOrder('dadGroup')+1, "opp", def, hasIcon) end
function addExtraSup(varName, chName, xPos, yPos, def, hasIcon) makeNewCommon(varName, chName, xPos, yPos, getObjectOrder('gfGroup')+1, "sup", def, hasIcon) end

function makeNewCommon(varName, chName, xPos, yPos, pos, tipe, def, hasIcn) --pretty barebones way of having another character; its WAY better than the old system i was using, though.
    if (def == nil) then def = false end
    if (hasIcn == nil) then hasIcn = true end
    chrAmts[tipe] = chrAmts[tipe] + 1
    storedChrs[varName] = {chrName = chName, x = xPos, y = yPos, reduced = false, lolthing = 0, index = chrAmts[tipe], chrType = tipe, idleSuffix = "", switchTo = "", poseSuffix = "", defaultNote = def, hasIcon = hasIcn}

    createInstance(varName, "objects.Character", {xPos, yPos, chName, false})
    setProperty(varName..".x", getProperty(varName..".x") + getProperty(varName..".positionArray")[1])
    setProperty(varName..".y", getProperty(varName..".y") + getProperty(varName..".positionArray")[2])
    callMethod("insert", {pos, instanceArg(varName)}) --what??
    if (hasIcn) then makeNewTimeIcon(varName, getProperty(varName..".healthIcon")) end

    local oppList = getVar("extraOppList") or {}
    table.insert(oppList, varName)
    setVar("extraOppList", oppList)
end

function onCreatePost()
    for chr,_ in pairs(storedChrs) do --bc layering shit
        callOnLuas("onRequestBubble", {utils:lwrKebab(chr)})
    end
end

function goodNoteHit() lastcombo = combo end
function noteMiss() noteMissCommon() end
function noteMissPress() noteMissCommon() end

function noteMissCommon()
    if (lastcombo <= 5) then return end

    lastcombo = 0
    for chr,_ in pairs(storedChrs) do
        if storedChrs[chr].chrType == "sup" and callMethod(chr..".animOffsets.exists", {"sad"}) then
            callMethod(chr..".playAnim", {"sad", true})
            setProperty(chr..".specialAnim", true)
        end
    end
end

function onUpdate(elp)
    if lastMHS ~= mustHitSection then 
        for chr,vals in pairs(storedChrs) do
            if (stringStartsWith(getProperty(chr..".animation.curAnim.name"), "sing")) then
                setProperty(chr..".holdTimer", {getProperty(chr..".holdTimer") + elp})
            end
            if (vals.chrType == "sup") then
                if (callMethod(chr..".animOffsets.exists", {"danceLeft"..vals.idleSuffix.."-left"})) then --this system is a beat late but im too lazy to find a solution to it as it still works fine
                    if mustHitSection then
                        setProperty(chr..".idleSuffix", vals.idleSuffix.."-toright")
                        vals.switchTo = vals.idleSuffix.."-right"
                    else
                        setProperty(chr..".idleSuffix", vals.idleSuffix.."-toleft")
                        vals.switchTo = vals.idleSuffix.."-left"
                    end
                else 
                    setProperty(chr..".idleSuffix", vals.idleSuffix)
                    utils:trc("extraCharacter: No dynamic idle set found for "..chr..", switching to default idle system", 2)
                end
            end
        end
        lastMHS = mustHitSection 
    end
end

function onUpdatePost()
    for chr,vals in pairs(storedChrs) do
        if (getProperty("health")/2 <= 0.2) then
            if not vals.reduced then
                vals.reduced = true
                if (disableBar) then vals.lolthing = 1
                else vals.lolthing = vals.lolthing - 1
                end
            end
        elseif (getProperty("health")/2 <= 0.4) then
            if vals.reduced then
                vals.reduced = false
                if (disableBar) then vals.lolthing = 0
                else vals.lolthing = vals.lolthing + 1
                end
            end
        end
        if (luaSpriteExists('iconTime'..chr)) then playAnim('iconTime'..chr, 'stg'..vals.lolthing) end
    end
end

function onBeatHit()
    charDance(curBeat)
end

function onCountdownTick(count)
    if getProperty("skipCountdown") then return end
    charDance(count)
end

function opponentNoteHit(index, dir, noteType, sustain) 
    local dirs = {"left", "down", "up", "right"}
    for chr,vr in pairs(storedChrs) do
        if (utils:lwrKebab(noteType) == chr..'-note' or (vr.defaultNote and noteType == "")) and storedChrs[chr].chrType == "opp" then
            callMethod(chr..".playAnim", {"sing"..(dirs[dir+1]:upper())..storedChrs[chr].poseSuffix, true})
            setProperty(chr..".holdTimer", 0)
            setObjectOrder("iconTime"..chr, getObjectOrder("iconTime") + 1)
            setProperty("timBar.color", utils:convColours(getProperty(chr..".healthColorArray")))
        end
    end
end

function charDance(dncbeat)
    for chr,vals in pairs(storedChrs) do
        local isSinging = (stringStartsWith(getProperty(chr..".animation.curAnim.name"), "sing") or stringStartsWith(getProperty(chr..".atlas.anim.lastPlayedAnim"), "sing"))
        if (stringStartsWith(version, "1.0")) then isSinging = (stringStartsWith(callMethod(chr..".getAnimationName"), "sing")) end
        if (dncbeat % getProperty(chr..".danceEveryNumBeats") == 0 and (getProperty(chr..".holdTimer") <= 0) and (not isSinging) and (not getProperty(chr..".stunned")) and (not getProperty(chr..".specialAnim"))) then
            if (callMethod(chr..".animOffsets.exists", {"danceLeft"})) then
                if (getProperty(chr..".danced")) then callMethod(chr..".playAnim", {"danceRight"..getProperty(chr..".idleSuffix")})
                else callMethod(chr..".playAnim", {"danceLeft"..getProperty(chr..".idleSuffix")})
                end
                setProperty(chr..".danced", not getProperty(chr..".danced"))
            else
                callMethod(chr..".playAnim", {"idle"..getProperty(chr..".idleSuffix")})
            end
            setProperty(chr..".holdTimer", {0})
            if (vals.switchTo ~= "" and vals.switchTo ~= nil) then 
                setProperty(chr..".idleSuffix", vals.switchTo) 
                vals.switchTo = ""
            end
            setObjectOrder("iconTime"..chr, getObjectOrder("iconTime") - 1)
            setProperty("timBar.color", utils:convColours(getProperty("dad.healthColorArray")))
        end
    end
end

function makeNewTimeIcon(chrName, iconName)
    local vars = storedChrs[chrName]
    if (disableBar and (vars.chrType == "opp")) or ((not disableBar) and (vars.chrType == "sup") or (not vars.hasIcon)) then return end

    removeLuaSprite('iconTime'..chrName)

    makeAnimatedLuaSprite("iconTime"..chrName, "icons/"..iconName.."-anim", ((vars.index-1) % 2) * 45, screenHeight - (205 * vars.index))
    for i=iconLimits[1],iconLimits[2] do  
        addAnimationByPrefix("iconTime"..chrName, 'stg'..i, iconName.." stage "..i, 24, true) 
    end

    utils:setObjectCamera('iconTime'..chrName, 'hud')
    playAnim('iconTime'..chrName, 'stg'..vars.lolthing)
    
    if downscroll then setProperty('iconTime'..chrName..'.y', 0 + (45 * vars.index)) end
    addLuaSprite("iconTime"..chrName, true)
end

function removeExtraChar(varName, destroy)
    destroy = destroy or true
    chrAmts[storedChrs[varName].chrType] = chrAmts[storedChrs[varName].chrType] - 1
    storedChrs[varName] = nil
    callOnLuas("onDeleteBubble", {utils:lwrKebab(varName)})
    callMethod("remove", {instanceArg(varName), true})
    if destroy then callMethod(varName..".destroy") end
end


function onEventPushed(name, value1, value2, strumTime)
    local event = utils:lwrKebab(name)
    local val1 = utils:lwrKebab(value1)
    local val2 = utils:lwrKebab(value2)

	if (event == "advance-anger") then
        if (tonumber(val2) ~= nil) then
            if (tonumber(val2) < iconLimits[1]) then iconLimits[1] = tonumber(val2) 
            elseif (tonumber(val2) > iconLimits[2]) then iconLimits[2] = tonumber(val2) 
            end
            if (disableBar) then iconLimits = {0,1} end
            for chr,vars in pairs(storedChrs) do
                if (vars.hasIcon) then makeNewTimeIcon(chr, getProperty(chr..".healthIcon")) end
            end
        end
    end
end

function onEvent(name, value1, value2, strumTime)
    local event = utils:lwrKebab(name)
    local val1 = utils:lwrKebab(value1)
    local val2 = utils:lwrKebab(value2)

    if (event == "extra-char-alt-idle") then
        setProperty(val1..".idleSuffix", value2)
        callMethod(val1..".recalculateDanceIdle")
    elseif (event == "extra-char-alt-anims") then
        storedChrs[val1].poseSuffix = value2
    elseif (event == "extra-char-play-anim") then
        callMethod(val2..".playAnim", {value1})
        setProperty(val2..".holdTimer", 0) --how did i catch this so late in development
        setProperty(val2..".specialAnim", true)
	elseif (event == "advance-anger") and (tonumber(val2) ~= nil) and not disableBar then
        for chr,vars in pairs(storedChrs) do
            storedChrs[chr].lolthing = tonumber(val2)
            storedChrs[chr].reduced = false
            if (luaSpriteExists('iconTime'..chr) and vars.chrType == "opp") then
                playAnim('iconTime'..chr, 'stg'..vars.lolthing)
            end
        end
    elseif (event == "toggle-borderline-hud") then
        for chr,_ in pairs(storedChrs) do
            if (luaSpriteExists('iconTime'..chr)) then
                setProperty('iconTime'..chr..'.visible', not getProperty('iconTime'..chr..'.visible'))
            end
        end
    end
end
