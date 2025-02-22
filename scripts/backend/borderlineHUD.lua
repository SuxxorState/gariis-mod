local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local font = (require (getVar("folDir").."scripts.objects.fontHandler")):new("lumeglyph")
local hudFold = "borderlineUI/"
local angerpoints = {}
local disableBar = (timeBarType == "Disabled")
local isHudVisible = true
local comboOff = {230, 96}
local timeIconLimits = {-1,0}
local ratingShits = { --rating image names, rating comments, icon progresses or regresses on low health
    ["truckgirl"] = {{"sick", "good", "bad", "ashit"}, {"Perfect!!", "Sick!!", "Great!", "Good!", "Meh", "Bruh", "Bad", "Shit", "You Suck!"}, {1,3}},
    ["carv"] = {{"shite", "okay", "subpar", "awful"}, {"I Love You.", "Shite!", "Aight", "Okay.", "Eh...", "Bogus", "Sub-Par", "Awful", "Fuck Outta Here"}, {0,-1}},
    ["truckboy"] = {{"sick", "good", "bad", "ashit"}, {"Killer!!", "Crazy!!", "Heat!", "Cool!", "Mid", "Dude", "Doodoo", "Terrible", "Not Cool!"}, {1,3}},
    ["def"] = {{"sick", "good", "bad", "ashit"}, {"Perfect!!", "Sick!!", "Great!", "Good!", "Meh", "Bruh", "Bad", "Shit", "You Suck!"}, {0,1}}
}
local curGFRead = "def"
local misscap = -1

function onCreatePost()
    setProperty('showComboNum', false)
    setProperty('showRating', false)

    precacheImage(hudFold.."grafix")

    makeAnimatedLuaSprite("border", hudFold.."bordertest",-495,-305)
    addAnimationByPrefix("border", "reg" ,"bordertest", 24, true)
    setScrollFactor("border",0,0)
    scaleObject('border', 1.67, 1.685)
    setObjectOrder("border", getObjectOrder('boyfriendGroup')+3)

    addAnimatedOneoff("hpBarPlanet", "hp bar base new", "planet bar", 1175,570, misscap ~= 0)
    addAnimatedOneoff("hpBarBackin", "hp bar base new", "hp bar back", 1196,140, misscap ~= 0)
    addAnimatedOneoff("hpBarActual", "hp bar base new", "bar fill dyeable", 1191,140, misscap ~= 0)
    addAnimatedOneoff("hpBarFrame", "hp bar base new", "bar base no planet", 1100,50, misscap ~= 0)

    if disableBar then addAnimatedOneoff("timerBar", "timebar", "no bar time bar", 75,screenHeight - 160)
    else addAnimatedOneoff("timerBar", "timebar", "bar bar time bar", 85,screenHeight - 140)
    end
    setObjectOrder('timerBar', getObjectOrder('timeBar') + 1)

    makeAnimatedLuaSprite('timBar', hudFold..'timebar', 90, screenHeight - 59.5)
    for i=25,100,25 do addAnimationByPrefix("timBar", 'fil'..i, "timebar"..i.."full", 24, true) end
    setProperty("timBar.color", utils:convColours(getProperty("dad.healthColorArray")))
    playAnim('timBar', 'fil100')
    setObjectCamera('timBar', 'hud')
	if not disableBar then setObjectOrder('timBar', getObjectOrder('timeBar') + 1) end

    addAnimatedOneoff("timerBarfbg", "timebar", "time bar fill bg", 0,0)
    if not disableBar then setObjectOrder('timerBarfbg', getObjectOrder('timBar')) end

    makeLuaText('scrTxt', "You NOT Rappin'", 220, 130, 50)
    utils:quickFormatTxt("scrTxt", "Lasting Sketch.ttf", 32, "000000", 0, "FFFFFF")
    utils:quickFormatTxt("timeTxt", "Lasting Sketch.ttf", 48, "000000", 1, "FFFFFF")
    utils:quickFormatTxt("botplayTxt", "Lasting Sketch.ttf", 48, "000000", 1, "FFFFFF")
    if disableBar then
	    setTextSize('scrTxt', 36)
        setTextWidth('scrTxt', 250)
        setProperty('scrTxt.x', 125)
        setProperty('scrTxt.y', 50)
    end
    setObjectCamera('scrTxt', 'hud')
	addLuaText('scrTxt')

    if (ratingShits[getProperty("gf.healthIcon")] ~= nil) then curGFRead = getProperty("gf.healthIcon") end
    replaceTimerIcon(ratingShits[curGFRead] == nil)
    replaceHealthIcon()

    if downscroll then
        if disableBar then setProperty('timerBar.y', 0)
        else
            setProperty("timeTxt.y", 4)
            setProperty('timBar.y', 20)
            setProperty('timerBar.y', 15)
            setProperty("timerBarfbg.y", getProperty("timerBar.y") + 7.5)
        end
    else
        comboOff = {230, screenHeight - 147}
        setProperty("scrTxt.y", screenHeight - 105)
        if not disableBar then
            setProperty('timBar.flipY', true)
            setProperty('timerBar.flipY', true)
            setProperty("timeTxt.y", screenHeight - 74)
            setProperty("timerBarfbg.flipY", true)
            setProperty("timerBarfbg.y", getProperty("timerBar.y") + 84)
        end
    end
    setProperty("timerBarfbg.x", getProperty("timerBar.x") + 7)

    utils:disableHUD({"healthBar", "scoreTxt", "timeBar", "iconP1", "iconP2"})
    setProperty("timeTxt.alpha", 1)
    setProperty("timeTxt.x", getProperty("timeTxt.x") - 350)

    addAnimatedOneoff("comboX", "grafix", "numX", comboOff[1],comboOff[2])
    scaleObject("comboX", 0.4, 0.4)
    setProperty('comboX.alpha', 0)

    --font:createNewText("testFont", 130, 60, "You NOT Rappin'", "left", "333333", "hud")
    --font:setTextScale("testFont", 0.9, 0.9)
end

function onCountdownTick(count)
    if (count == 0) then playAnim("gf", "count3", true)
        if (misscap > -1) then
            for i = 0, misscap-1 do
                local basex = 1150
                makeAnimatedLuaSprite("missMarker"..i, hudFold..'hp bar base new', basex + 80, 140 + ((450 / misscap) * i))
                addAnimationByPrefix("missMarker"..i, 'idle', "pin no ex", 24, true)
                addAnimationByPrefix("missMarker"..i, 'missing', "ex pin doing x", 24, false)
                addOffset("missMarker"..i, "missing", 12, 20)
                addAnimationByPrefix("missMarker"..i, 'missed', "ex pin done x", 24, true)
                addOffset("missMarker"..i, "missed", 8, 14)
                setObjectCamera("missMarker"..i, 'hud')
                setProperty('missMarker'..i..".alpha", 0)
                playAnim("missMarker"..i, "idle")
    
                addLuaSprite("missMarker"..i, true)
                setObjectOrder("missMarker"..i, getObjectOrder('hpBarActual') + 1)
    
                runTimer('missMarker'..i, ((60/curBpm)/misscap) * i) --it's a bit weird but it ensures every pin is placed before the countdown ends and the song starts
            end
        end
    elseif (count == 1) then playAnim("gf", "count2", true)
    elseif (count == 2) then playAnim("gf", "count1", true)
    elseif (count == 3) then playAnim("gf", "cheer", true)
    end
end

function onSongStart()
    if not disableBar then
        updateTimebar()

        for i = 1, #angerpoints do
            local basey = screenHeight - 65
            if downscroll then basey = 20 end
            makeAnimatedLuaSprite('marker'..i, hudFold..'timebar', 85, basey + 200)
            if not downscroll then setProperty('marker'..i..".flipY", true) end
            addAnimationByPrefix("marker"..i, 'def', "timebarmarker", 24 + (i-2), true)
            setProperty('marker'..i..".x", 85 + (420 * (angerpoints[i] / (songLength / (((60/bpm)*1000) / 4)))))
            setObjectCamera('marker'..i, 'hud')
            setProperty('marker'..i..".alpha", 0)
            addLuaSprite('marker'..i, true)
            setObjectOrder('marker'..i, getObjectOrder('timerBar') + 1)

            doTweenY('marker'..i.."yset", 'marker'..i, basey, 0.1 + (0.3 * i), 'elasticOut')
            doTweenAlpha('marker'..i.."alpha", 'marker'..i, 1, 0 + (0.2 * i), 'circIn')
        end
    end
end

storedRanks = {}
susComTrkr = 0 -- so that it doesnt wipe during sustains
function goodNoteHit(id, dir, noteType, isSustainNote)
    if not isSustainNote then
        local rate = getPropertyFromGroup('notes', id, 'rating')
        local cool = 0
        if (rate == 'sick') then cool = 3
        elseif (rate == 'good') then cool = 2
        elseif (rate == 'bad') then cool = 1
        else cool = 0 end

        table.insert(storedRanks, cool)
        if (getPropertyFromGroup('notes', id, 'sustainLength') > 0) then
            susComTrkr = getPropertyFromGroup('notes', id, 'strumTime') + getPropertyFromGroup('notes', id, 'sustainLength')
        end
    end
end


local nearestNote = 0
local gfSwitchTo = ""
local gfIdleSuff = ""
local lastMHS = true
local canWipeCombo = false
function onBeatHit() --AWESOME accurate combo drop calculations.
    if (gfSwitchTo ~= "" and gfSwitchTo ~= nil) then 
        setProperty("gf.idleSuffix", gfSwitchTo) 
        gfSwitchTo = ""
    end

    if (canWipeCombo and (#storedRanks > 5)) or ((not lastMHS) and (#storedRanks) > 9 and (math.floor(curStep / 4) % 4 == 0 or math.floor(curStep / 4) % 6 == 0)) then
        local overall = 0
        for i, rate in pairs(storedRanks) do 
            overall = overall + rate end
        overall = utils:round(overall / (#storedRanks))
        if (overall < 0) then overall = 0 end

        makeAnimatedLuaSprite("comboRating", hudFold.."grafix", 0, 0)
        addAnimationByPrefix("comboRating", 'def', ratingShits[curGFRead][1][4-overall], 24, true)
        playAnim("comboRating", "def")
        setProperty("comboRating.visible", isHudVisible)
        screenCenter('comboRating')
        setProperty('comboRating.x', screenWidth * 0.55)
        setProperty('comboRating.y', getProperty('comboRating.y') - 100)
        addLuaSprite('comboRating', true)
    
        setProperty('comboRating.acceleration.y', 550)
        doTweenAngle("comboRatingAng", "comboRating", math.random(-150, 150), 2, "circIn")
        setProperty('comboRating.velocity.y', getProperty('comboRating.velocity.y') - math.random(140, 175))
        setProperty('comboRating.velocity.x', math.random(0, 10))
        runTimer('comboRating', crochet * 0.001)

        if (getProperty("gf.curCharacter") ~= nil) then
            if (ratingShits[curGFRead][1][4-overall] == ratingShits[curGFRead][1][1]) then playAnim("gf", "cheer", true)
            elseif (ratingShits[curGFRead][1][4-overall] == ratingShits[curGFRead][1][4]) then playAnim("gf", "sad", true) end
        end

        storedRanks = {}
        comboFall()
    end
end

function getNearestNoteTime()
    for i = 0, getProperty('notes.length') - 1 do -- checking if we already have one
        if getPropertyFromGroup('notes', i, 'mustPress') then
            return getPropertyFromGroup('notes', i, 'strumTime')
        end
    end
    for i = 0, getProperty('unspawnNotes.length') - 1 do
        if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
            return getPropertyFromGroup('unspawnNotes', i, 'strumTime')
        end
    end
end

function onUpdate()
    if lastMHS ~= mustHitSection then 
        if (callMethod("gf.animOffsets.exists", {"danceLeft"..gfIdleSuff.."-left"})) then --this system is a beat late but im too lazy to find a solution to it as it still works fine
            if mustHitSection then
                setProperty("gf.idleSuffix", gfIdleSuff.."-toright")
                gfSwitchTo = gfIdleSuff.."-right"
            else
                setProperty("gf.idleSuffix", gfIdleSuff.."-toleft")
                gfSwitchTo = gfIdleSuff.."-left"
            end
        else 
            setProperty("gf.idleSuffix", gfIdleSuff)
            utils:trc("borderlineHUD: No dynamic idle set found for gf, switching to default idle system", 2)
        end
        lastMHS = mustHitSection 
    end
end

function onUpdatePost()
    updateHealthbar()
    if not disableBar then
        updateTimebar()
    end
    playAnim('iconTime', 'stg'..lolthing)

    if (getNearestNoteTime() ~= nil) then
        local curNotePos = nearestNote - getSongPosition()
        local baseNoteTime = math.floor((curBpm/60) * 1000)
        if curNotePos < 1 then nearestNote = getNearestNoteTime() end
        if not (nearestNote - getSongPosition() < 2000) and (nearestNote - getSongPosition()) > baseNoteTime and curNotePos > (baseNoteTime/2) then
            if (not canWipeCombo) and (susComTrkr - getSongPosition() < -1000) then canWipeCombo = true end
        elseif canWipeCombo then
            canWipeCombo = false
        end
    else canWipeCombo = true
    end
end

angertracker = 1
function onEventPushed(name, value1, value2, strumTime)
    local event = name:lower()
    local val1 = value1:lower()
    local val2 = value2:lower()

	if (name == "Advance Anger") then
        if (val1 ~= "" and val1 ~= nil) then
            angerpoints[angertracker] = (strumTime / (((60/bpm)*1000) / 4))
            angertracker = angertracker + 1
        end
        if (tonumber(val2) ~= nil) then
            if (tonumber(val2) < timeIconLimits[1]) then timeIconLimits[1] = tonumber(val2) 
            elseif (tonumber(val2) > timeIconLimits[2]) then timeIconLimits[2] = tonumber(val2) 
            end
        end
    end
end

lolthing = 0
reduced = false
function onEvent(name, value1, value2, strumTime)
    local event = name:lower()
    local val1 = value1:lower()
    local val2 = value2:lower()

	if (event == "advance anger") and (tonumber(val2) ~= nil) and not disableBar then
        lolthing = tonumber(val2)
        reduced = false
        playAnim('iconTime', 'stg'..lolthing)
    elseif (event == "change character") then
        if (val1 == "gf" or val1 == "girlfriend" or val1 == "1") then
            if (ratingShits[getProperty("gf.healthIcon")] ~= nil) then curGFRead = getProperty("gf.healthIcon")
            else curGFRead = "def" end
            if disableBar then replaceTimerIcon() end
        elseif (val1 == "dad" or val1 == "opponent" or val1 == "0") then if not disableBar then replaceTimerIcon() end
        else replaceHealthIcon()
        end
        onRecalculateRating()
    elseif (event == "alt idle animation") then 
        if (val1 == "gf") then gfIdleSuff = value2 end
    elseif (event == "toggle borderline hud") then
        isHudVisible = not isHudVisible
        for _,spr in pairs({"hpBarPlanet", "hpBarBackin", "hpBarActual", "hpBarFrame", "iconHP"}) do
            setProperty(spr..'.visible', isHudVisible)
        end
        for i = 1, #angerpoints do
            setProperty('marker'..i..".visible", isHudVisible)
        end
        for _,spr in pairs({"timBar", "timerBar", "timeTxt", "timerBarfbg", "scrTxt", "iconTime"}) do
            setProperty(spr..'.visible', isHudVisible)
        end
    end
end

function replaceTimerIcon(nilgf)
    removeLuaSprite('iconTime')
    if not disableBar then
        setProperty("timBar.color", utils:convColours(getProperty("dad.healthColorArray")))
        makeAnimatedLuaSprite("iconTime", "icons/"..getProperty("dad.healthIcon").."-anim", 0, screenHeight - 135)
        for i=timeIconLimits[1],timeIconLimits[2] do  
            addAnimationByPrefix("iconTime", 'stg'..(i+lolthing), getProperty("dad.healthIcon").." stage "..i, 24, true) 
        end
    elseif not nilgf then
        makeAnimatedLuaSprite("iconTime", "icons/"..getProperty("gf.healthIcon").."-anim", 0, screenHeight - 135)
        addAnimationByPrefix("iconTime", 'stg0', getProperty("gf.healthIcon").." stage "..ratingShits[curGFRead][3][1], 24, true)
        addAnimationByPrefix("iconTime", 'stg1', getProperty("gf.healthIcon").." stage "..ratingShits[curGFRead][3][2], 24, true)
    end
    setObjectCamera('iconTime', 'hud')
    setProperty("iconTime.visible", isHudVisible)
    playAnim('iconTime', 'stg'..lolthing)
    if downscroll then setProperty('iconTime.y', 5) end
    addLuaSprite("iconTime", true)
end

function replaceHealthIcon()
    if (misscap == 0) then return end
    local hpAnims = {"sgfc", "fc", "miss1", "miss2", "miss3"}
    removeLuaSprite('iconHP')
    makeAnimatedLuaSprite("iconHP", "icons/"..getProperty("boyfriend.healthIcon").."-anim", screenWidth - 130, screenHeight - 160)
    for i,anim in pairs(hpAnims) do addAnimationByPrefix("iconHP", anim, getProperty("boyfriend.healthIcon").." stage "..(i-2), 24, true) end
    setObjectCamera('iconHP', 'hud')
    setProperty('iconHP.flipX', true)
    setProperty("iconHP.visible", isHudVisible)
    playAnim('iconHP', 'fc')
    addLuaSprite("iconHP", true)
    setProperty("hpBarActual.color", utils:convColours(getProperty("boyfriend.healthColorArray")))
end

function onSpawnNote(id, data, type, isSustainNote, strumTime)
	if (data < 4) then
        setPropertyFromGroup('notes', id, 'alpha', 0)
    end
end

rank = "You NOT Rappin'"
sepScr = {}
function onRecalculateRating() --so these functions arent constantly called. performance stuffs
    if (rating == 1)        then rank = ratingShits[curGFRead][2][1]
    elseif (rating >= 0.4) then rank = "You Rappin' "..ratingShits[curGFRead][2][11 - math.floor(rating*10)]
    elseif (rating >= 0.2) then rank = "You Rappin' "..ratingShits[curGFRead][2][10 - (math.floor(rating*10) + (math.floor(rating*10) % 2))] --bc ratings lower than 40% go by 20% instead of 10%... i dont know why it needs 10 instead of 11
    elseif (misses > 0)     then rank = ratingShits[curGFRead][2][9]
    end

    if (font:textExists("testFont")) then
        font:setTextString("testFont", rank)
        font:setTextScale("testFont", math.min(0.9 * (17/#rank), 0.9), 0.9)
    end
    setTextString("scrTxt", rank)--.." (x"..combo..")") --rating text

    if (misscap > -1 and misses > misscap) then setHealth(-2) end --miss cap

    for num,i in pairs(sepScr) do
        cancelTween("comboNum"..num.."Ang")
        removeLuaSprite("comboNum"..num, true)
    end

    sepScr = {}
    setProperty('comboX.alpha', 0)
    local combo = getProperty('combo')
    if combo > 5 then
        setProperty('comboX.alpha', 1)
        local comboStr = ""..getProperty('combo')
        local ten = 10

        while (ten <= combo) do
            if (combo >= ten) then table.insert(sepScr,1, math.floor(combo / ten) % 10) end
            ten = ten * 10
        end
        table.insert(sepScr, (combo % 10))

        setProperty("comboX.x", comboOff[1] + (30 - (10 * #comboStr)))
        setProperty("comboX.visible", isHudVisible)
        for num,i in pairs(sepScr) do
            addAnimatedOneoff("comboNum"..num, "grafix", "num"..i, comboOff[1] + (39 - (10 * #comboStr)) + (37 * num), 0)
            scaleObject("comboNum"..num, 0.4, 0.4)
            setProperty("comboNum"..num..".y", comboOff[2] + ((getProperty("comboX.height") - getProperty("comboNum"..num..".height")) / 2))
            setProperty("comboNum"..num..".visible", isHudVisible)
        end
    end
end

quart = 0
function updateTimebar()
    if not (math.ceil((getSongPosition() / songLength)*4) == quart) then
        quart = math.ceil((getSongPosition() / songLength)*4)
        playAnim('timBar', 'fil'..(quart*25))
    end
    scaleObject('timBar', getSongPosition() / (songLength*(quart/4)), 1)
end

nickel = 0
function updateHealthbar()
    for i = 0, misscap-1 do
        if (getProperty("missMarker"..i..".animation.curAnim.finished") and (getProperty("missMarker"..i..".animation.curAnim.name") ~= "missed")) then --kinda lag prevention ig
            playAnim("missMarker"..i, "missed")
        end
    end
    if (misscap <= -1) then
        if (getProperty("health")/2 <= 0.2) then
            playAnim('iconHP', 'miss3')
            if not reduced then 
                reduced = true
                if (disableBar) then lolthing = 1
                else lolthing = lolthing - 1
                end
            end
        elseif (getProperty("health")/2 <= 0.4) then
            playAnim('iconHP', 'miss2')
            if reduced then 
                reduced = false
                if (disableBar) then lolthing = 0
                else lolthing = lolthing + 1
                end
            end
        elseif (getProperty("health")/2 >= 0.8 and misses < 1) then
            if (ratingFC == "SFC" or ratingFC == "GFC") then playAnim('iconHP', 'sgfc')
            else playAnim('iconHP', 'fc') end
        else
            playAnim('iconHP', 'miss1')
        end
    else    
        setProperty("health", 2.08 - ((misses / misscap)*2))
        if (misses < 1) then
            if (ratingFC == "SFC" or ratingFC == "GFC") then playAnim('iconHP', 'sgfc')
            else playAnim('iconHP', 'fc')
            end
        else
            playAnim('iconHP', 'miss'..misses)
            if (misses >= misscap - 1) and not reduced then 
                lolthing = lolthing - 1
                reduced = true
            end
        end
    end
    if (misses <= misscap) or misscap <= -1 then
        scaleObject('hpBarActual', 1, 1 - (getProperty("health")/2))
        setProperty("hpBarActual.y", 140 + ((getProperty("health")/2) * 450))
        setProperty('iconHP.y', (140 + ((getProperty("health")/2) * 450)) - (getProperty("iconHP.height")/2))
    end
end

function noteMissPress(direction) --hate my life
    --table.insert(storedRanks, -1)
    if (misscap > -1) then fillHealth(misses) end
end

function noteMiss(id, direction, noteType, isSustainNote)
    table.insert(storedRanks, -2) --penalty is worse considering 3 miss limit
    if (misscap > -1) then fillHealth(misses) end
end

dummymiss = -1
plriconpos = {160, 340, 500, 650, 710}
function fillHealth(amt)
    markercall = (misscap - amt)
    playAnim('missMarker'..markercall, 'missing', true)
end

function comboFall()
    local lastcombo = getProperty('combo')

    setProperty('combo', 0)
    setProperty('comboX.acceleration.y', 550)
    setProperty('comboX.velocity.y', getProperty('comboX.velocity.y') - math.random(140, 175))
    setProperty('comboX.velocity.x', math.random(0, 10))
    runTimer('comboXFall', crochet * 0.001)

    local comboStr = ""..lastcombo
    for i=1,#comboStr do
        setProperty('comboNum'..i..'.acceleration.y', 550)
        doTweenAngle("comboNum"..i.."Ang", "comboNum"..i, math.random(-75,75), 1, "circIn")
        setProperty('comboNum'..i..'.velocity.y', getProperty('comboNum'..i..'.velocity.y') - math.random(140, 175))
        setProperty('comboNum'..i..'.velocity.x', math.random(0, 10))
        runTimer('comboNum'..i, crochet * 0.001)
    end
end

function setupSpice(speed, hpamt, missamt, pushback, scrmult)
    if (instakillOnMiss) then missamt = 0 end
    if (missamt ~= nil) then misscap = missamt end
end

function addAnimatedOneoff(tag, spr, anim, xPos, yPos, canAdd)
    if (canAdd == nil) then canAdd = true end
    if (canAdd == false) then return end
    
    makeAnimatedLuaSprite(tag, hudFold..spr, xPos, yPos)
    addAnimationByPrefix(tag, "reg" ,anim, 24, true)
	setObjectCamera(tag, 'hud')
    if (canAdd) then addLuaSprite(tag) end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if (tag == 'hpFill') then
        fillinghp = false
        dummymiss = misses
        playAnim('hpBar', 'miss'..misses, true)
    elseif (tag == "comboRating") then 
        doTweenAlpha(tag, tag, 0, 0.2, 'linear')
    elseif(tag == "comboXFall") then
        doTweenAlpha("comXAlpha", "comboX", 0, 0.2, 'linear')
    elseif (string.find(tag, "comboNum")) then
        doTweenAlpha(tag, tag, 0, 0.2, 'linear')
    elseif (string.find(tag, "missMarker")) then
        local basex = 1150
        doTweenX(tag.."xset", tag, basex, 0.3, 'elasticOut')
        doTweenAlpha(tag.."alpha", tag, 1, 0.2, 'circIn')
    end
end

function onTweenCompleted(tag)
    if (tag == "comboRatingAng") then
        removeLuaSprite("comboRating", true)
    elseif (string.find(tag, "comboNum") and string.find(tag, "Ang")) then
        removeLuaSprite(tag, true)
    elseif (tag == "comXAlpha") then
        setProperty("comboX.x", comboOff[1])
        setProperty("comboX.y", comboOff[2])
        setProperty('comboX.acceleration.y', 0)
        setProperty('comboX.velocity.y', 0)
        setProperty('comboX.velocity.x', 0)
        setProperty("comboX.angle", 0)
    end
end