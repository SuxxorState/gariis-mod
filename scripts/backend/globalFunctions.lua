local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local alreadystarted = false
local gameovered = false
local arcadeKey = getModSetting('arcadeMenu')
local achievementKey = getModSetting('achievementsMenu')
local boomPerSect, bamIntensity = 4, 1
local unlockSecrets = (utils:lwrKebab(songName) == "gariis-arcade")

function initLuas()
    utils:setGariiData("test", true) --i dont remember why this is here however i dont feel like finding out if removing it breaks shit or not
    if not (getModSetting('gariiDebug')) then setPropertyFromClass("Main", "fpsVar.visible", false) end
    if (getPropertyFromClass('openfl.Lib', 'application.window.title') ~= "Friday Night Funkin': GARII'S MOD") then
        if (not getModSetting('sauceLock')) then utils:setGariiData("curSauce", nil) end
        utils:setGariiData("watchedCutscene", false)
        utils:setGariiData("cachedInMyStupidToken", false)
        utils:setGariiData("storyStats", nil)
        utils:setGariiData("deathCounter", 0)
        utils:setWindowTitle("Friday Night Funkin': GARII'S MOD")
    end
    --checkFreeplayIconCompatability()
    doubleCheckWeeks()
end

function onCreatePost()
    setProperty("camZooming", utils:lwrKebab(songName) ~= "gariis-arcade")
	setProperty("camZoomingMult", 0)
    setProperty("boyfriend.stunned", true)
end

function doubleCheckWeeks()
    if not isStoryMode then return end --these functions aren't needed for freeplay
    if (week == "garii" and utils.songNameFmt == "fuzzy-dice") then
        runHaxeCode([[
            PlayState.storyPlaylist = ["Fuzzy Dice", "Full House"];
        ]])
    end
end

function checkFreeplayIconCompatability() --1.0.x fucked up icons for some reason so there's alt icons in the files that are "fixed" for 1.0.x
    if (utils:getGariiData("freeIconsFixed") ~= nil) then return end
    utils:setGariiData("freeIconsFixed", true)
    if (not stringStartsWith(version, "1.0")) then return end
    for _,icn in pairs({"garfree-fake", "garfree", "goonsfree", "sixteenfree"}) do
        deleteFile('images/icons/'..icn..".png")
    end
end

local hpDrain = 0
local hpMultiplier = 1
function setupSpice(speed, hpamt, missamt, pushback, scrmult)
    if (speed ~= nil) then setProperty("songSpeed", speed) end
    if (hpamt ~= nil) then 
        for i = 0, getProperty('unspawnNotes.length')-1 do
            if (getPropertyFromGroup('unspawnNotes', i, 'noteType') ~= "Missed Opportunity") then
                setPropertyFromGroup('unspawnNotes', i, 'hitHealth', (0.023 / hpamt) / healthGainMult)
                setPropertyFromGroup('unspawnNotes', i, 'missHealth', (0.0475 / hpamt) / healthLossMult)
            end
        end
        hpMultiplier = hpamt
    end
    if (pushback ~= nil) then hpDrain = pushback / hpamt end
    unlockSecrets = true
    utils:setDiscord("Story Mode: "..utils.weekName, utils.songName.." ["..utils:getHeat(true).."]", getProperty("dad.healthIcon"))
end

function onCountdownTick(tick) fixTheDamnStrums() --for songs that keep the countdown
	if (tick == 2) then --this is simply so people dont miss when bf plays the animation
        setProperty("boyfriend.stunned", true)
        triggerEvent("Play Animation", "hey", "bf")
        playAnim("boyfriend", "hey", true)
    elseif (tick == 3) then
        setProperty("boyfriend.stunned", false)
    end
end
function onSongStart() fixTheDamnStrums() end--for songs that "skip" the countdown

function fixTheDamnStrums()
    if alreadystarted then return end
    alreadystarted = true
    for i = 0,7 do
        setPropertyFromGroup('strumLineNotes', i, 'alpha', 1)
        if (i <= 3) then setPropertyFromGroup('strumLineNotes', i, 'x', 1400)
        elseif (utils.hudType == "legacy") then
            if downscroll then setPropertyFromGroup('strumLineNotes', i, 'x', 110 + (((i-4) * 95) + 50) - 15)
                setPropertyFromGroup('strumLineNotes', i, 'y', screenHeight - 135)
            else setPropertyFromGroup('strumLineNotes', i, 'x', (screenWidth - 520) + (((i-4) * 95) + 50) - 15)
                setPropertyFromGroup('strumLineNotes', i, 'y', 85)
            end
        else
            setPropertyFromGroup('strumLineNotes', i, 'x', -254 + (((i-4) * 112) + 50) - 15 + (screenWidth / 2))
            if downscroll then setPropertyFromGroup('strumLineNotes', i, 'y', screenHeight)
                noteTweenY("noteIntro"..i, i, screenHeight - 120, 1 + (0.1 * (i%4)), "backOut")
            else setPropertyFromGroup('strumLineNotes', i, 'y', -100)
                noteTweenY("noteIntro"..i, i, 15, 1 + (0.1 * (i%4)), "backOut")
            end
        end
    end
    runHaxeCode([[
        for (note in game.unspawnNotes) {
            note.multAlpha = 1;
            if (note.noteType == "Pose Note" || note.noteType == "Pose Note Filler") {
                note.offset.x += 45;
                note.offset.y += 45;
            }
        }
    ]])
end

local usedPoses = {}
local maxPoses = 5
function opponentNoteHit(id, dir, ntype)
    if (ntype == "Missed Note") then
        setProperty("health", getProperty("health") + (0.0475 / hpMultiplier) / healthLossMult)
        utils:playSound("missnote"..getRandomInt(1,3), getRandomFloat(0.1,0.2))
    elseif (getProperty("health") > (hpDrain + 0.025)) then --adding the hp drain ensures that the health cant accidentally overlook it and kill the player for being too small
        setProperty("health", getProperty("health") - hpDrain)
    end
    if (ntype == "Pose Note") then
        local rngNum = getRandomInt(1,maxPoses, table.concat(usedPoses, ","))

        triggerEvent("Play Animation", "pose"..rngNum, "dad") --this triggers any effects that the scripts have on play anims, like the speech bubbles hiding themselves
        playAnim("dad", "pose"..rngNum, true)
        for _,chr in pairs(getVar("extraOppList")) do
            triggerEvent("Extra Char Play Anim", "pose"..rngNum, chr)
            playAnim(chr, "pose"..rngNum, true)
        end
        if (#usedPoses >= maxPoses-1) then usedPoses = {} end
        table.insert(usedPoses, rngNum)
    end
end

function restartCountdown(delay)
    if delay == nil then delay = 0 end

    runTimer("restartCountdown", delay)
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == "restartCountdown" then
        startCountdown()
    elseif tag == "exitSong" then
        exitSong()
    end
end

function onUpdate(elapsed)
    if ((not paused) and (not utils.songNameFmt == "gariis-arcade")) then --weird bug... guess its for the best it ignores gariis arcade tho
        if not gameovered then
            local timeLeft = nil
            if (getPropertyFromClass("backend.Conductor", "songPosition") >= 0) then timeLeft = songLength - getPropertyFromClass("backend.Conductor", "songPosition") end
            if (isStoryMode) then utils:setDiscord("Story Mode: "..utils.weekName, utils.songName.." ["..utils:getHeat(true).."]", getProperty("dad.healthIcon"), timeLeft ~= nil, timeLeft)
            else utils:setDiscord("Freeplay", utils.songName.." ["..utils:getHeat(true).."]", getProperty("dad.healthIcon"), timeLeft ~= nil, timeLeft)
            end
        else
            if (isStoryMode) then utils:setDiscord("Story Mode (Game Over)", utils.songName.." ["..utils:getHeat(true).."]", getProperty("dad.healthIcon"))
            else utils:setDiscord("Freeplay (Game Over)", utils.songName.." ["..utils:getHeat(true).."]", getProperty("dad.healthIcon"))
            end
        end
    end
    if (not stringStartsWith(getPropertyFromClass('openfl.Lib', 'application.window.title'), "Friday Night Funkin': GARII'S MOD") and not getVar("tryingtoexit") == nil) then
        setProperty('inCutscene', true)
        openCustomSubstate("error", true)
    end

    if (not unlockSecrets) then return end

    if (getModSetting('gariiDebug')) then
        if (keyboardJustPressed("F5")) then 
            setPropertyFromClass("states.PlayState", "nextReloadAll", true)
            restartSong()
        end
        if (keyboardJustPressed("F6")) then callMethod("setSongTime", {getPropertyFromClass("backend.Conductor", "songPosition") + 5000}) --this debug function is held together by like thin ass string, the fact that it even works is insane
            callMethod("clearNotesBefore", {getPropertyFromClass("backend.Conductor", "songPosition")}) 
        end
        if (keyboardJustPressed("F7")) then callMethod("setSongTime", {getPropertyFromClass("backend.Conductor", "songPosition") + 10000})
            callMethod("clearNotesBefore", {getPropertyFromClass("backend.Conductor", "songPosition")}) 
        end
        if (keyboardJustPressed("F8")) then endSong() end
        if (keyboardJustPressed("F9")) then exitSong() end --anti softlock
        if (keyboardJustPressed("F10")) then callMethod("setSongTime", {136000}) --fullhouse blackout
            callMethod("clearNotesBefore", {getPropertyFromClass("backend.Conductor", "songPosition")}) 
        end
        if (keyboardJustPressed("F11")) then callMethod("setSongTime", {58000}) --fullhouse taunt test
            callMethod("clearNotesBefore", {getPropertyFromClass("backend.Conductor", "songPosition")}) 
        end
    else
        if keyJustPressed('debug_1') or keyJustPressed('debug_2') then
            setProperty("inCutscene", true)
            if (utils.songNameFmt == "twenty-sixteen") then
                os.execute("start https://drive.google.com/drive/folders/1HmqI39zEi19OY3gh6a1BWcfmYIm7SXrQ?usp=sharing")
                exitSong()
            else
                runHaxeCode([[
                    import backend.Highscore;
                    import backend.Song;
                    PlayState.isStoryMode = false;
                    PlayState.SONG = Song.loadFromJson(Highscore.formatSong("twenty-sixteen", 0), "twenty-sixteen");
                ]])
                restartSong()
            end
        end
    end

    if (keyboardJustPressed(arcadeKey.keyboard) or anyGamepadJustPressed(arcadeKey.gamepad)) then
        loadSong("gariis-arcade", 0)
    elseif (keyboardJustPressed(achievementKey.keyboard) or anyGamepadJustPressed(achievementKey.gamepad)) then
        addLuaScript('scripts/menus/achievements')
        callOnLuas("openAchievementsMenu") 
    end
end

function onBeatHit()
	if (curBeat % boomPerSect ~= 0) then return end

	triggerEvent("Add Camera Zoom",0.015*bamIntensity,0.03*bamIntensity)
end

local curTexture = ""
function onEvent(name, value1, value2, strumTime)
    local event = utils:lwrKebab(name)
    local val1 = utils:lwrKebab(value1)
    local val2 = utils:lwrKebab(value2)

    if (event == "play-animation") then
        if (val2 == "bf") then val2 = "boyfriend" end
        if (val2 == "girlfriend") then val2 = "gf" end
        setProperty(val2..".specialAnim", true)
    elseif (event == "play-diff-dependent-anim") then
        if (val2 == "bf") then val2 = "boyfriend" end
        if (val2 == "girlfriend") then val2 = "gf" end
        setProperty(val2..".specialAnim", true)
        local anims = stringSplit(value1, ",,")
        local lelAnim = anims[2]
        if (difficultyPath == "simple") then lelAnim = anims[1]
        elseif (difficultyPath == "expert") then lelAnim = anims[3] end

        triggerEvent("Play Animation", lelAnim, val2)
    elseif (event == "cam-boom-speed") then
        boomPerSect = tonumber(val1) or 4
        bamIntensity = tonumber(val2) or 1
    elseif (event == "set-cam-zoom") then
        if val2 == '' then setProperty("defaultCamZoom",val1)
        else doTweenZoom('camPermaZoom','camGame',tonumber(val1),tonumber(val2),'sineInOut')
        end 
    elseif (event == 'change-note-skin') then
        if (val1 ~= '') then
            for i = 0,3 do
                setPropertyFromGroup('opponentStrums', i, 'texture', value1)
                setPropertyFromGroup('playerStrums', i, 'texture', value1)
            end
            for i = 0, getProperty('unspawnNotes.length')-1 do
                local customNotes = {"pose-note", "pose-note-filler", "interrupted-note"} --list of notes that have custom textures that probably shouldnt be overridden
                if (not utils:tableContains(customNotes, utils:lwrKebab(getPropertyFromGroup('unspawnNotes', i, 'noteType')))) then
                    setPropertyFromGroup('unspawnNotes', i, 'texture', value1)
                end
            end
        end
   
        if (val2 ~= '') then
            for i = 0, getProperty('unspawnNotes.length')-1 do
                setPropertyFromGroup('unspawnNotes', i, 'noteSplashData.texture', value2);
            end
        end
    end
end

function goodNoteHit() --this detects when bf SHOULD be dancing but isnt (due to gf singing whilst he was singing) and forces him to do so when he's stuck in a pose
    if curBeat % 2 == 0 then
        runHaxeCode([[
            import psychlua.LuaUtils;
            if (boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 #if FLX_PITCH / FlxG.sound.music.pitch #end) * boyfriend.singDuration) {
                boyfriend.dance();
            }
        ]])
    end
end

function onTweenCompleted(name)
	if (name == 'camPermaZoom') then setProperty("defaultCamZoom",getProperty('camGame.zoom')) 
	end
end


function onCustomSubstateCreate(tag)
    if tag == "error" then
        utils:playSound("errorjingle", 1)

        makeLuaSprite('garError','error',0,0)
        addLuaSprite('garError', true)
        setObjectCamera('garError', 'other')

        makeLuaText('errorTxt', "You have a script that's messing with our scripts!\nWe recommend turning off any mod scripts that edit the window text before resuming.", 1000, 12, 600)
        setTextFont('errorTxt', "Lasting Sketch.ttf")
		setTextBorder('errorTxt', 1, '000000')
		addLuaText('errorTxt')
		setTextSize('errorTxt', 32)
		setObjectCamera('errorTxt', 'other')
		screenCenter('errorTxt', 'x')
    elseif tag == "gameover" then
        gameovered = true
    end
end

function onCustomSubstateUpdate(tag)
    if tag == "error" then
        if keyJustPressed('accept') then
            utils:exitToMenu()
        end
    end
end

function onDestroy()
    runHaxeCode([[
        import Main;
        import backend.ClientPrefs;
        Main.fpsVar.visible = ClientPrefs.data.showFPS;
    ]])
end