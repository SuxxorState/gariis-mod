local utils = (require (getVar("folDir").."scripts.backend.utils")):new() 
local fldr = "gameOver/"
local gameOvered = false
local gameOverMusic = "high-cholesterol"
local gameOverChar = "truckerboy"
local oppGenName = ""
local gameOverTaunts = {
    ["garii"] = {{"F4F3AD"}, --provide text colour as index 1 then the quotes after
        {"You either are trying too hard, or aren't trying hard enough...Funny, both mean you're ass."}, {"Stupid boy, you make me look bad!"}, {"You dont know the beginning of godhood, boy."}, {"Give it up to this guy, everybody! You fucking suck!"}, 
        {"Does baby want something easier?\nTOO BAD! I HATE CHILDREN!!"}, {"Damn. For how much you were bragging,\nyou sure did disappoint!"}, {"You know how to tie knots? Oh, wait, you have velcro shoes. Nevermind."}, {"I'm guessing she has the cock?"},
        {"Yes, yes, reset time, like you always do.\nFuckin'...sore loser ass power."}, {"I would call you a pansy! But that would be an insult to Atlas's craft."}, {"Here's a lore dump for you: YOU SUCK... A LOT."},
        {"If you can't handle the heat, then GET OUT OF MY GODDAMN WAY!!"}, {"Hey. You, pressing the keys. I know a good mod for you. https://gamebanana.com/mods/44238"}, {"This is for big boys, go get ready for kindergarten."}, {"Imma get some Wendy's"},
        {"I'm not mad, I'm just disappointed. I'm mad too, I lied."}, {"Aww, why dont you just beat me with the\ntalent you have-OH WAIT YOU DONT HAVE ANY TALENT!!!"}, {"Alright, cool. That was lame. I'm going home."}, {"Tempted to make things harder just for you.\nYou know what? I will. Have fun."}
    }, 
    ["carv"] = {{"4D664D", "DBAF85"},
        {"What? Expecting us to\nplay fair wit'cha?", "I'd recommend\nyou play fair first."}, {"Well, that was sad.", "My ears are bleeding...\nMetaphorically, I mean."}, {"Into the pit of lava they go.", "Well, toodles!"},
        {"You guys stink.", "A FOUL stench too, peeyew!"}, {"Y'know, me and my band made this song.", "I'm sorry to hear that."}, {"This was easier\nthan I thought.", "I owe Garii 20 dollars..."},
        {"You two made this\nlook hard with Garii.", "I'm sensing foul play afoot..."}, {"There's no way you\ntwo lost THAT easily.", "One might call it purposeful... Hmm..."}, {"Alright, uhh. What now?", "You're asking me?"}
    },
    ["foxy"] = {{"8FC79B"},
        {"What? Was I supposed to go easy or somn'?\nAtlas, was I supposed to go easy on him?"}, {"F16 to F24, the cup has been eradicated.\nI repeat, the cup has been eradicated."}, {"Uh, awkward."}, {"16 OC is your limit, cup."}, {"I wonder y u suk"},
        {"Didn't even need to call LL for this."}, {"On days like these, drinks like you...\nEven heck is too good for you."}, {"What? I ain't gonna get shot."}, {"Were the fish bones too much for you?"}, {"Catster blaster BLAST!"}, {"ez"}, {"Eat it, hollowhead!"}
    }
}

function onCreate() --buhhh
    for _,img in pairs({"silhouette", "chars/spritemap1", "black-paper", "not-black-paper", "gameOverTxt"}) do
        precacheImage(fldr..img)
    end

    precacheSound(fldr.."jingles/"..((songName:lower()):gsub(" ", "-")))
    precacheMusic(gameOverMusic.."-intro")
    precacheMusic(gameOverMusic.."-vox")
    precacheMusic(gameOverMusic)
end

function onGameOver()
    if (gameOvered) then return Function_Stop; end
    gameOvered = true
    utils:setGariiData("deathCounter", utils:getGariiData("deathCounter") + 1)

    if (utils:lwrKebab(songName) == "full-house") or (utils:lwrKebab(songName) == "fuzzy-dice" and getSongPosition() >= 67500) then gameOverChar = "truckercouple"
    elseif (utils:lwrKebab(songName) == "twenty-sixteen") then gameOverChar = "cup" 
    end

    makeLuaSprite('circleGameOver', fldr..'silhouette', 620-1450, 320-900)
    setObjectCamera('circleGameOver', 'other')
    addLuaSprite('circleGameOver')
    setProperty("circleGameOver.alpha", 0.5)
    setProperty("circleGameOver.scale.x", 12)
    setProperty("circleGameOver.scale.y", 12)
    doTweenX("circleX", "circleGameOver.scale", 3, 1)
    doTweenY("circleY", "circleGameOver.scale", 3, 1)

    makeLuaSprite('bgGameOver',fldr..'black-paper',0,0)
    setProperty("bgGameOver.alpha", 0)
	setObjectCamera('bgGameOver','other')
	addLuaSprite('bgGameOver')

    setProperty("inCutscene", true)
    setProperty("boyfriend.visible", false)
    setProperty("boyfriend.stunned", true)
    callOnScripts("disablePause")
    doTweenAlpha("lole", "camHUD", 0, 0.5)
    playSound(fldr.."fallin", 0.5, 'gofall')

    setProperty("generatedMusic", false) --disables shit like events... mainly cause of sfx playing
    callMethod("vocals.stop")
    callMethod("opponentVocals.stop")
    soundFadeOut(_, 0.5, 0)

    createInstance("bfDead", "objects.Character", {getProperty("boyfriend.x"), getProperty("boyfriend.y"), "truckerboy-deaths", true})
    setProperty("bfDead.x", (getProperty("bfDead.x") + getProperty("bfDead.positionArray")[1]) - getProperty("boyfriend.positionArray")[1])
    setProperty("bfDead.y", (getProperty("bfDead.y") + getProperty("bfDead.positionArray")[2]) - getProperty("boyfriend.positionArray")[2])
    addInstance("bfDead") --actually simpler code via lua???

    anvilDeath()

    runTimer("jingle", 0.075)
    return Function_Stop;
end

function anvilDeath() --many different death anims so just handle them all within a function
    playAnim("bfDead", "death-anvil")
    runTimer("anvilsound", 36/24)
end

function onCustomSubstateCreate(css)
    if (css ~= "GameOver") then return end

    removeLuaSprite("circleGameOver", true)
    playMusic(gameOverMusic.."-intro", 1)
    runTimer("stupidFuckinMusicTimerCausePsychEngineDoesntHaveAnOnMusicEndFunction", 6)
    
    makeAnimatedLuaSprite('textGameOver', fldr..'gameOverTxt', 0, 20)
    addAnimationByPrefix("textGameOver", "reg" , "game over text", 24, true)
    screenCenter("textGameOver", "x")
    insertToCustomSubstate('textGameOver')
    setProperty('textGameOver.y', -220)
    doTweenY('awesome', "textGameOver", 20, 1, "circOut")
    
    makeFlxAnimateSprite('charGameOver', 0,0, fldr..'chars')
    addAnimationBySymbol("charGameOver", "firstDeath" , "-deaths/"..gameOverChar.." death", 24, false)
    addAnimationBySymbol("charGameOver", "deathLoop" , "-deaths/"..gameOverChar.." loopdeath", 24, true)
    insertToCustomSubstate("charGameOver")
    runTimer('playDeath', 0.5)
    setProperty("charGameOver.alpha", 0.01) -- i dont???? huh???? 1.0 weirddd
    runTimer("setCharPosLol", 0.01)

    oppGenName = stringSplit(dadName, "-")[1] --there's a reason why i word my character files the way i do, makes finding out what character they are a lot easier without shemantics
    randomquote = getRandomInt(2, #gameOverTaunts[oppGenName])
    
    for i = 1, #gameOverTaunts[oppGenName][1] do
        makeLuaText('tauntTxtGameOver'..i, gameOverTaunts[oppGenName][randomquote][i], 900 / #gameOverTaunts[oppGenName][1], 0, 0)
        utils:quickFormatTxt('tauntTxtGameOver'..i, "Lasting Sketch.ttf", 48, gameOverTaunts[oppGenName][1][i])
        if (stringStartsWith(gameOverTaunts[oppGenName][randomquote][i], "Tempted to make things harder just for you.") and (not utils:getGariiData("cachedInMyStupidToken"))) then
            utils:setGariiData("cachedInMyStupidToken", true)
            utils:setGariiData("curSauce", math.min(utils:getGariiData("curSauce") + 1, 6))
        elseif (utils:getGariiData("deathCounter") > 5 and oppGenName == "garii") then
            setTextString('tauntTxtGameOver'..i, "Don't you have anything better to do?")
        end
        screenCenter('tauntTxtGameOver'..i, 'x')
        if (#gameOverTaunts[oppGenName][1] > 1) then
            if (i > #gameOverTaunts[oppGenName][1] / 2) then 
                setProperty('tauntTxtGameOver'..i..'.x', getProperty("tauntTxtGameOver"..i..".x") + ((getProperty('tauntTxtGameOver'..i..'.fieldWidth')-150) * (i-(#gameOverTaunts[oppGenName][1]/2))))
            elseif (i < #gameOverTaunts[oppGenName][1] / 2 or (#gameOverTaunts[oppGenName][1] % 2 == 0 and i <= #gameOverTaunts[oppGenName][1] / 2)) then 
                setProperty('tauntTxtGameOver'..i..'.x', getProperty("tauntTxtGameOver"..i..".x") - ((getProperty('tauntTxtGameOver'..i..'.fieldWidth')-150) * i))
            end
        end
        if (getProperty("tauntTxtGameOver"..i..".height") < 60) then setProperty('tauntTxtGameOver'..i..'.y', screenHeight - (getProperty("tauntTxtGameOver"..i..".height") + 35))
        else setProperty('tauntTxtGameOver'..i..'.y', screenHeight - (getProperty("tauntTxtGameOver"..i..".height") + 10))
        end

        setProperty('tauntTxtGameOver'..i..'.alpha', 0)
        setObjectCamera('tauntTxtGameOver'..i, 'other')
        insertToCustomSubstate('tauntTxtGameOver'..i)
    end
    
    makeLuaSprite('fgGameOver',fldr..'not-black-paper',0,0)
    setBlendMode('fgGameOver', "multiply")
    setProperty("fgGameOver.alpha", 0.75)
	insertToCustomSubstate('fgGameOver')

    runTimer('textappear', 3)
    runTimer('playDeath', 0.5)
end

function onCustomSubstateUpdate(css)
    if (css ~= "GameOver" or (not gameOvered)) then return end

    if (getProperty("charGameOver.anim.finished")) and getProperty("charGameOver.anim.lastPlayedAnim") ~= "deathLoop" then
        playAnim("charGameOver", "deathLoop")
    end
    if keyJustPressed('back') then
        utils:exitToMenu()
        soundFadeOut('gomusic', 1, 0)
    elseif keyJustPressed('accept') then
        utils:makeBlankBG("fadeOut", screenWidth,screenHeight, "000000", "other")
        setProperty("fadeOut.alpha", 0)
        insertToCustomSubstate('fadeOut')
        callMethod("camOther.fade", {nil, 0.25})
        doTweenAlpha("fadeOut", "fadeOut", 1, 0.25)
        gameOvered = false
        soundFadeOut('gomusic', 0.25, 0)
    end
end

function onTweenCompleted(twn)
    if (twn == "fadeOut") then
        restartSong()
    end
end

function onTimerCompleted(tmr)
	if (tmr == 'playDeath') then 
        playAnim("charGameOver", "firstDeath")
    elseif (tmr == "setCharPosLol") then
        setProperty("charGameOver.alpha", 1)
        screenCenter("charGameOver", "x")
        setProperty('charGameOver.x', getProperty('charGameOver.x') + 30) 
        setProperty('charGameOver.y', (screenHeight - getProperty("charGameOver.height")) - 230)
        playAnim("charGameOver", "firstDeath")
    elseif (tmr == "textappear") then
        if (gameOverChar ~= "cup") then doTweenY('charDeathTwn', "charGameOver", (screenHeight - getProperty("charGameOver.height")) - 140, 1, "circInOut")
        else doTweenY('charDeathTwn', "charGameOver", (screenHeight - getProperty("charGameOver.height")) - 310, 1, "circInOut")
        end
        
        for i = 1, #gameOverTaunts[oppGenName][1] do
            doTweenAlpha('done'..i, "tauntTxtGameOver"..i, 1, 1)
        end
    elseif (tmr == "opengameover") then
        stopSound("golosemusic")
        openCustomSubstate("GameOver", true)
    elseif (tmr == "jingle") then
        playSound(fldr.."jingles/"..((songName:lower()):gsub(" ", "-")), 1, 'golosemusic')
        runTimer("jinglequickend", 3)
        runTimer("opengameover", 4)
    elseif (tmr == "jinglequickend") then soundFadeOut("golosemusic", 1, 0)
    elseif (tmr == "anvilsound") then
        stopSound("gofall")
        playSound(fldr.."ANVIL", 1)
        runTimer("finishgocircle", 0.2)
        runTimer("runGOBG", 0.5)
    elseif (tmr == "finishgocircle") then
        doTweenX("circleX", "circleGameOver.scale", 0.2, 0.55)
        doTweenY("circleY", "circleGameOver.scale", 0.2, 0.55)
    elseif (tmr == "runGOBG") then 
        doTweenAlpha("bgIn", "bgGameOver", 1, 0.25)
    elseif (tmr == "stupidFuckinMusicTimerCausePsychEngineDoesntHaveAnOnMusicEndFunction") then
        if (getRandomInt(0,255) == 0) then playMusic(gameOverMusic.."-vox", 1)
        else playMusic(gameOverMusic, 1)
        end
        runTimer("stupidFuckinMusicTimerCausePsychEngineDoesntHaveAnOnMusicEndFunctionTwo", 30, 0)
    elseif (tmr == "stupidFuckinMusicTimerCausePsychEngineDoesntHaveAnOnMusicEndFunctionTwo") then
        if (getRandomInt(0,255) == 0) then playMusic(gameOverMusic.."-vox", 1)
        else playMusic(gameOverMusic, 1)
        end
    end
end

function onSoundFinished(snd)
    if (snd == 'golosemusic' and getSoundVolume("golosemusic") ~= nil and getSoundVolume("golosemusic") <= 0) then cancelTimer("opengameover")
        runTimer("opengameover", 0.000000000001)
    end
end