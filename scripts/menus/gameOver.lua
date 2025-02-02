local utils = (require (getVar("folDir").."scripts.backend.utils")):new() 
local doingshit = false
local isFallen = false
local gameovermusic = "gameover/sad"
local gameoverchar = "truckerboy"
local oppGenName = ""
local gameovertaunts = {
    ["garii"] = {{"F4F3AD"}, --provide text colour as index 1 then the quotes after
        {"You either are trying too hard, or aren't trying hard enough...Funny, both mean you're ass."}, {"Stupid boy, you make me look bad!"}, {"You dont know the beginning of godhood, boy."}, {"Give it up to this guy, everybody! You fucking suck!"}, 
        {"Does baby want something easier?\nTOO BAD! I HATE CHILDREN!!"}, {"Damn. For how much you were bragging,\nyou sure did disappoint!"}, {"You know how to tie knots? Oh, wait, you have velcro shoes. Nevermind."}, {"I'm guessing she has the cock?"},
        {"Yes, yes, reset time, like you always do.\nFuckin'...sore loser ass power."}, {"Don't you have anything better to do?"}, {"I would call you a pansy! But that would be an insult to Atlas's craft."}, {"Here's a lore dump for you: YOU SUCK... A LOT."},
        {"If you can't handle the heat, then GET OUT OF MY GODDAMN WAY!!"}, {"Hey. You, pressing the keys. I know a good mod for you. https://gamebanana.com/mods/44238"}, {"This is for big boys, go get ready for kindergarten."}, {"Imma get some Wendy's"},
        {"I'm not mad, I'm just disappointed. I'm mad too, I lied."}, {"Aww, why dont you just beat me with the\ntalent you have-OH WAIT YOU DONT HAVE ANY TALENT!!!"}, {"Alright, cool. That was lame. I'm going home."}, {"Tempted to make things harder just for you.\nYou know what? I will. Have fun."}
    }, 
    ["carv"] = {{"4D664D", "DBAF85"},
        {"What? Expecting us to\nplay fair wit'cha?", "Your struggles are\nfunny little man."}, {"I was expecting more from you. Disappointing.", "A newborn baby would\ndo better than you."}, {"Well, toodles!", "Into the pit of lava they go."},
        {"Okay but like, hear me out though.", "We are NOT doing this beepin shit with other people."}, {"Y'know, me and my band made this song.", "Sorry to hear that."}, {"WE'RE the dynamic duo 'round here!", "We are not dynamic, Carv."},
        {"Ugly sunovabitches.", "Euthanization was the only option for them..."}, {"This is time I COULD BE USING for other things.", "Eh, I would probably be on the couch doing nothing."}, {"Hey Hunte, wanna go to the beach?", "No"}, {"Neeeeerds!", "NEEEEERDS!"},
        {"Gaaaaaaaay", "Could go for a mean weiner right about now."}
    },
    ["foxy"] = {{"8FC79B"},
        {"What? Was I supposed to go easy or somn'?\nAtlas, was I supposed to go easy on him?"}, {"F16 to F24, the cup has been eradicated.\nI repeat, the cup has been eradicated."}, {"Uh, awkward."}, {"16 OC is your limit, cup."}, {"I wonder y u suk"},
        {"Didn't even need to call LL for this."}, {"On days like these, drinks like you...\nEven heck is too good for you."}, {"What? I ain't gonna get shot."}, {"Were the fish bones too much for you?"}, {"Catster blaster BLAST!"}, {"ez"}, {"Eat it, hollowhead!"}
    }
}

function onCreate()
    precacheSound(gameovermusic)
    precacheImage('gameOver/silhouette')
end

function onSongStart()
    if doingshit then
        runHaxeCode([[
            import objects.Character;

            PlayState.instance.vocals.stop();
            PlayState.instance.opponentVocals.stop();
            FlxG.sound.music.fadeOut(0.5, 0, function(twn:FlxTween) {
                FlxG.sound.music.stop();
            });
        ]])
    end
end

function onGameOver()
    if (doingshit) then return Function_Stop; end
    doingshit = true

    if (utils:lwrKebab(songName) == "full-house") or (utils:lwrKebab(songName) == "fuzzy-dice" and getSongPosition() >= 67500) then gameoverchar = "truckercouple"
    elseif (utils:lwrKebab(songName) == "twenty-sixteen") then gameoverchar = "cup" 
    end

    cameraSetTarget("boyfriend")
    makeLuaSprite('circleGameOver', 'gameOver/silhouette', 620-1450, 320-900)
    setObjectCamera('circleGameOver', 'other')
    addLuaSprite('circleGameOver')
    setProperty("circleGameOver.alpha", 0.5)
    setProperty("circleGameOver.scale.x", 12)
    setProperty("circleGameOver.scale.y", 12)
    doTweenX("circleX", "circleGameOver.scale", 3, 1)
    doTweenY("circleY", "circleGameOver.scale", 3, 1)

    makeLuaSprite('bgGameOver','gameOver/black-paper',0,0)
    setProperty("bgGameOver.alpha", 0)
	setObjectCamera('bgGameOver','other')
	addLuaSprite('bgGameOver')

    setProperty("inCutscene", true)
    setProperty("boyfriend.visible", false)
    setProperty("boyfriend.stunned", true)
    callOnScripts("disablePause")
    doTweenAlpha("lole", "camHUD", 0, 0.5)
    playSound("gameover/fallin", 0.5, 'gofall')
    runHaxeCode([[
        import objects.Character;

        game.generatedMusic = false;  //disables shit like events... mainly cause of sfx playing

        PlayState.instance.vocals.volume = 0;
        PlayState.instance.opponentVocals.volume = 0;
        PlayState.instance.vocals.stop();
        PlayState.instance.opponentVocals.stop();
        FlxG.sound.music.fadeOut(0.5, 0, function(twn:FlxTween) {
            FlxG.sound.music.stop();
        });

        var bfdead:Character;
        bfdead = new Character(PlayState.instance.boyfriend.getPosition().x, PlayState.instance.boyfriend.getPosition().y, "truckerboy-deaths", true);
        bfdead.x += bfdead.positionArray[0] - PlayState.instance.boyfriend.positionArray[0];
        bfdead.y += bfdead.positionArray[1] - PlayState.instance.boyfriend.positionArray[1];
        add(bfdead);

        bfdead.playAnim("death-anvil");

        PlayState.instance.moveCamera(false);
    ]])
    runTimer("jingle", 0.075)
    runTimer("anvilsound", 36/24)
    return Function_Stop;
end

function onCustomSubstateCreate(tag)
    if (tag ~= "gameover") then return end

    removeLuaSprite("circleGameOver", true)
    playSound(gameovermusic, 0.5, 'gomusic')
    soundFadeIn('gomusic', 3, 0.5, 1)

    makeAnimatedLuaSprite('textGameOver', 'gameOver/gameOverTxt', 0, 20)
    addAnimationByPrefix("textGameOver", "reg" , "game over text", 24, true)
    setObjectCamera('textGameOver', 'other')
    screenCenter("textGameOver", "x")
    addLuaSprite('textGameOver')
    setProperty('textGameOver.y', -220)
    doTweenY('awesome', "textGameOver", 20, 1, "circOut")
    
    makeFlxAnimateSprite('charGameOver', 0,0, 'gameOver/chars')
    addAnimationBySymbol("charGameOver", "firstDeath" , "-deaths/"..gameoverchar.." death", 24, false)
    addAnimationBySymbol("charGameOver", "deathLoop" , "-deaths/"..gameoverchar.." loopdeath", 24, true)
    screenCenter("charGameOver", "x")
    setProperty('charGameOver.x', getProperty('charGameOver.x') + 30) 
    setProperty('charGameOver.y', (screenHeight - getProperty("charGameOver.height")) - 230)
    setObjectCamera('charGameOver', 'other')
    addLuaSprite("charGameOver")
    runTimer('playDeath', 0.5)

    oppGenName = stringSplit(dadName, "-")[1] --there's a reason why i word my character files the way i do, makes finding out what character they are a lot easier without shemantics
    randomquote = getRandomInt(2, #gameovertaunts[oppGenName])
    if (stringStartsWith(version, "1.0.") and deaths > 5 and oppGenName == "garii") then randomquote = 10 end
    
    for i = 1, #gameovertaunts[oppGenName][1] do
        makeLuaText('tauntTxtGameOver'..i, gameovertaunts[oppGenName][randomquote][i], 900 / #gameovertaunts[oppGenName][1], 0, 0)
        if (stringStartsWith(gameovertaunts[oppGenName][randomquote][i], "Tempted to make things harder just for you.") and (not utils:getGariiData("cachedInMyStupidToken"))) then
            utils:setGariiData("cachedInMyStupidToken", true)
            utils:setGariiData("curSauce", math.min(utils:getGariiData("curSauce") + 1, 6))
        end
        setTextFont('tauntTxtGameOver'..i, "Lasting Sketch.ttf")
        setTextColor('tauntTxtGameOver'..i, gameovertaunts[oppGenName][1][i])
        setTextBorder('tauntTxtGameOver'..i, 0, 'FFFFFF')
        screenCenter('tauntTxtGameOver'..i, 'x')
        if (#gameovertaunts[oppGenName][1] > 1) then
            if (i > #gameovertaunts[oppGenName][1] / 2) then 
                setProperty('tauntTxtGameOver'..i..'.x', getProperty("tauntTxtGameOver"..i..".x") + ((getProperty('tauntTxtGameOver'..i..'.fieldWidth')-150) * (i-(#gameovertaunts[oppGenName][1]/2))))
            elseif (i < #gameovertaunts[oppGenName][1] / 2 or (#gameovertaunts[oppGenName][1] % 2 == 0 and i <= #gameovertaunts[oppGenName][1] / 2)) then 
                setProperty('tauntTxtGameOver'..i..'.x', getProperty("tauntTxtGameOver"..i..".x") - ((getProperty('tauntTxtGameOver'..i..'.fieldWidth')-150) * i))
            end
        end
        setTextSize('tauntTxtGameOver'..i, 48)
        if (getProperty("tauntTxtGameOver"..i..".height") < 60) then setProperty('tauntTxtGameOver'..i..'.y', screenHeight - (getProperty("tauntTxtGameOver"..i..".height") + 35))
        else setProperty('tauntTxtGameOver'..i..'.y', screenHeight - (getProperty("tauntTxtGameOver"..i..".height") + 10))
        end

        setProperty('tauntTxtGameOver'..i..'.alpha', 0)
        setObjectCamera('tauntTxtGameOver'..i, 'other')
        addLuaText('tauntTxtGameOver'..i)
    end
    
    makeLuaSprite('fgGameOver','gameOver/not-black-paper',0,0)
	setObjectCamera('fgGameOver','other')
    setBlendMode('fgGameOver', "multiply")
    setProperty("fgGameOver.alpha", 0.75)
	addLuaSprite('fgGameOver')

    runTimer('textappear', 3)
    runTimer('playDeath', 0.5)
end

function onCustomSubstateCreatePost(tag) --praying this fixes the no animations playing glitch
    if (tag ~= "gameover") then return end

    playAnim("textGameOver", "reg")
    playAnim("charGameOver", "firstDeath")
end

function onCustomSubstateUpdate(tag, elp)
    if (tag ~= "gameover") then return end

    if (getProperty("charGameOver.anim.finished")) and getProperty("charGameOver.anim.lastPlayedAnim") ~= "deathLoop" then
        playAnim("charGameOver", "deathLoop")
    elseif (getProperty("charGameOver.anim.lastPlayedAnim") == "preDeath") and isFallen then
        playAnim("charGameOver", "firstDeath")
    end
    if keyJustPressed('back') then
        utils:exitToMenu()
        soundFadeOut('gomusic', 1, 0)
    elseif keyJustPressed('accept') then
        restartSong()
        closeCustomSubstate("gameover")
        soundFadeOut('gomusic', 1, 0)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if (tag == 'playDeath') then 
        isFallen = true
        playAnim("charGameOver", "firstDeath")
    elseif (tag == "textappear") then
        if (gameoverchar ~= "cup") then doTweenY('charDeathTwn', "charGameOver", (screenHeight - getProperty("charGameOver.height")) - 140, 1, "circInOut")
        else doTweenY('charDeathTwn', "charGameOver", (screenHeight - getProperty("charGameOver.height")) - 310, 1, "circInOut")
        end
        
        for i = 1, #gameovertaunts[oppGenName][1] do
            doTweenAlpha('done'..i, "tauntTxtGameOver"..i, 1, 1)
        end
    elseif (tag == "opengameover") then
        stopSound("golosemusic")
        openCustomSubstate("gameover", false)
    elseif (tag == "jingle") then
        playSound("gameover/jingles/"..((songName:lower()):gsub(" ", "-")), 1, 'golosemusic')
        runTimer("jinglequickend", 3)
        runTimer("opengameover", 4)
    elseif (tag == "jinglequickend") then soundFadeOut("golosemusic", 1, 0)
    elseif (tag == "anvilsound") then
        stopSound("gofall")
        playSound("gameover/ANVIL", 1)
        runTimer("finishgocircle", 0.2)
        runTimer("runGOBG", 0.5)
    elseif (tag == "finishgocircle") then
        doTweenX("circleX", "circleGameOver.scale", 0.2, 0.55)
        doTweenY("circleY", "circleGameOver.scale", 0.2, 0.55)
    elseif (tag == "runGOBG") then 
        doTweenAlpha("bgIn", "bgGameOver", 1, 0.25)
    end
end

function onSoundFinished(tag)
    if tag == 'golosemusic' and getSoundVolume("golosemusic") ~= nil and getSoundVolume("golosemusic") <= 0 then cancelTimer("opengameover")
        runTimer("opengameover", 0.000000000001)
    end
end