local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local sauces = {"Whire's Gentle Zest", "Hoppin' Honey Mustard", "Outburst", "Garden Grown Habanero"}
local textspeed = {-1.75, 2.75, -0.75}
local keyCombo = {{"TWO", "NUMPADTWO"}, {"ZERO", "NUMPADZERO"}, {"TWO", "NUMPADTWO"}, {"ONE", "NUMPADONE"}}
local curKey = 1
local highwayjammin = false
local curSauce = 1
local sauceTrueFX = {--speed, hpamt, missamt, pushback
	{2.25, 1.5, nil, 0.010, 0.5},
	{2.5, 1.25, nil, 0.013, 0.75},
	{2.75, 1, nil, 0.018, 1},
	{3, 0.75, nil, 0.023, 1.25},
	{3.25, nil, 5, nil, 1.5},
	{3.5, nil, 3, nil, 1.75},
	{4, nil, 0, nil, 2},
}

local spsFld = "spice/"
local ndlAngs = {-77, -48, -14, 24, 58, 84, 105}
local inMenu = false
local sssCounter = 0
local hasSimple = false
local hasHarder = false
local playedCrossout = false

function onStartCountdown(tick)
	if (utils:getGariiData("curSauce") ~= nil) then 
		callOnLuas("setupSpice", sauceTrueFX[utils:getGariiData("curSauce")])
		close()
	else
		if (utils:getGariiData("harderSauces") ~= nil) then
			table.insert(sauces, "Shit The Bed")
			table.insert(sauces, "Solar Flare")
		end
		hasSimple = checkFileExists('data/'..utils.songNameFmt..'/'..utils.songNameFmt..'-simple.json')
		hasHarder = checkFileExists('data/'..utils.songNameFmt..'/'..utils.songNameFmt..'-harder.json')
		inMenu = true
		setProperty('inCutscene', true)
		setProperty('camHUD.alpha', 0)

		makeLuaSprite('white','',0,0)
		makeGraphic("white", screenWidth, screenHeight, "FFFFFF")
		addLuaSprite('white', true)
		setObjectCamera('white', 'other')
		
		for i=0,2 do
			makeAnimatedLuaSprite('spstex'..i,spsFld..'heat bg texts',1830 - (750 * i),30)
			addAnimationByPrefix('spstex'..i, 'reg', "choose ur heat", 24, false)
			addAnimationByPrefix('spstex'..i, 'hj', "highway jammin", 24, false)
			--setProperty("spstex"..i..".alpha", 0.75)
			playAnim('spstex'..i, 'reg')
			addLuaSprite('spstex'..i, true)
			setObjectCamera('spstex'..i, 'other')

			makeAnimatedLuaSprite('tastex'..i,spsFld..'heat bg texts',-1200 + (825 * i),413)
			addAnimationByPrefix('tastex'..i, 'reg', "prepare ur tastebudz", 24, false)
			setProperty("tastex"..i..".alpha", 0.75)
			addLuaSprite('tastex'..i, true)
			setObjectCamera('tastex'..i, 'other')
		end
		makeAnimatedLuaSprite('loltex',spsFld..'heat bg texts',1280,215)
		addAnimationByPrefix('loltex', 'reg', "thank you wire", 24, false)
		setProperty("loltex.alpha", 0.5)
		setProperty("loltex.active", false)
		addLuaSprite('loltex', true)
		setObjectCamera('loltex', 'other')

		makeAnimatedLuaSprite('bfspice',spsFld..'truckcouple-heat',450,50)
		for i=0,6 do addAnimationByPrefix("bfspice", 'sauce'..(i+1), "exp"..i, 24, false) end
		addLuaSprite('bfspice', true)
		setObjectCamera('bfspice', 'other')
		
		makeLuaSprite('gre','',0,630)
		makeGraphic("gre", screenWidth, 200, "333333")
		addLuaSprite('gre', true)
		setObjectCamera('gre', 'other')

		makeLuaSprite('blcak','',-120,-50)
		makeGraphic("blcak", 500, 1000, "000000")
		setProperty("blcak.angle", -10)
		addLuaSprite('blcak', true)
		setObjectCamera('blcak', 'other')

		makeAnimatedLuaSprite('spsflavs',spsFld..'heatflavors',10,screenHeight - 80)
		for i=0,6 do addAnimationByPrefix("spsflavs", 'sauce'..(i+1), "desc"..i, 24, true) end
		addLuaSprite('spsflavs', true)
		setObjectCamera('spsflavs', 'other')
		
		makeAnimatedLuaSprite('sausbtls',spsFld..'saucebottles',10,10)
		for i=0,6 do addAnimationByPrefix("sausbtls", 'sauce'..(i+1), "sauc"..i, 24, true) end
		for i=2,3 do addAnimationByPrefix("sausbtls", 'sauce'..(i+1).."-old", "oldsauc"..i, 24, true) end
		addLuaSprite('sausbtls', true)
		setObjectCamera('sausbtls', 'other')
				
		makeAnimatedLuaSprite('sausdescs',spsFld..'heatdescs',20,150)
		for i=0,6 do addAnimationByPrefix("sausdescs", 'sauce'..(i+1), "sauc"..i, 24, true) end
		addLuaSprite('sausdescs', true)
		setObjectCamera('sausdescs', 'other')

		makeAnimatedLuaSprite('nosimplechart',spsFld..'no simple chart',15,360)
		addAnimationByPrefix("nosimplechart", 'reg', "no simple chart", 24, false)
		addLuaSprite('nosimplechart', true)
		setObjectCamera('nosimplechart', 'other')

		if (#sauces >= 5) then makeLuaSprite('spsmeterbg',spsFld..'spicemeterbg',30,screenHeight - 240)
		elseif (#sauces >= 3) then makeLuaSprite('spsmeterbg',spsFld..'spicemeterbglocked',30,screenHeight - 240)
		else makeLuaSprite('spsmeterbg',spsFld..'spicemeterbgnormallocked',30,screenHeight - 240)
		end
		addLuaSprite('spsmeterbg', true)
		setObjectCamera('spsmeterbg', 'other')

		makeLuaSprite('spsneedle',spsFld..'spiceneedle',175,screenHeight - 185)
		setProperty("spsneedle.angle", ndlAngs[curSauce])
		addLuaSprite('spsneedle', true)
		setObjectCamera('spsneedle', 'other')

		makeLuaSprite('spstxt',spsFld..'spice text',65,screenHeight - 45)
		addLuaSprite('spstxt', true)
		setObjectCamera('spstxt', 'other')

		for i=0,2 do
			makeLuaSprite('cru'..i,'bg/crumple'..i,0,0)
			setObjectCamera('cru'..i,'other')
			setProperty('cru'..i..'.alpha', 0.75)
			setProperty('cru'..i..'.visible', i==0)
			addLuaSprite('cru'..i,true)
		end
		runTimer("crumple", 120/130)
		runTimer("wirequote", 30)
		
		makeLuaSprite('pprovr','bg/paperbase',0,-380)
		scaleObject('pprovr', 1.15, 1.1)
		setProperty("pprovr.alpha", 0.5)
		setProperty("pprovr.flipX", true)
		addLuaSprite('pprovr', true)
		setBlendMode('pprovr', "multiply")
		setObjectCamera('pprovr', 'other')

		playMusic('freaky-hotmix', 1, true)

		changeSelected(0)
		return Function_Stop;
	end
end

local doingSomething = false
function onUpdatePost(elapsed)
	if (curSauce == 7 and (getProperty("spsneedle.angle") >= ndlAngs[curSauce] - 2 or getProperty("spsneedle.angle") <= ndlAngs[curSauce] + 2)) then
		setProperty("spsneedle.angle", ndlAngs[curSauce] + getRandomInt(-2,2))
	else
		setProperty("spsneedle.angle", utils:lerp(getProperty("spsneedle.angle"), ndlAngs[curSauce], 0.25))
	end
	utils:setDiscord("Choosing Their Heat", "["..sauces[curSauce].."]") --CHANGE DAMN YOU

	for i=0,2 do
		setProperty('spstex'..i..".x", getProperty('spstex'..i..".x") + (textspeed[1] * (60/framerate)))
		if (getProperty('spstex'..i..".x") < -970) then setProperty('spstex'..i..".x", 1280) end
		setProperty('tastex'..i..".x", getProperty('tastex'..i..".x") + (textspeed[2] * (60/framerate)))
		if (getProperty('tastex'..i..".x") > 1280) then setProperty('tastex'..i..".x", -1200) end
		if (luaSpriteExists("loltex") and getProperty("loltex.active")) then setProperty('loltex.x', getProperty('loltex.x') + (textspeed[3] * (60/framerate)))
			if (getProperty('loltex.x') < -2510) then removeLuaSprite("loltex", true) end
		end
	end

	if inMenu and not doingSomething then
		if keyJustPressed('back') then
			utils:exitToMenu(true)
			doingSomething = true
		elseif keyJustPressed('accept') then
			doingSomething = true
			utils:setGariiData("curSauce", curSauce)

			if(curSauce == 7) then
				runHaxeCode([[
					import backend.Paths;
					import backend.Song;
					import backend.Highscore;
					var ogName:String = Paths.formatToSongPath(PlayState.SONG.song);
					if (PlayState.isStoryMode) {
						for (i in 0...PlayState.storyPlaylist.length) {PlayState.storyPlaylist[i] += "-sss";}
					}
					PlayState.SONG = Song.loadFromJson(Highscore.formatSong(ogName+"-sss", 0), ogName+"-sss");
				]])
			elseif(curSauce >= 5 and hasHarder) then
				runHaxeCode([[
					import backend.Difficulty;
					Difficulty.list.push("Harder");
					PlayState.storyDifficulty = 1;
				]])
				loadSong(nil, 1)
			elseif (curSauce <= 2 and hasSimple) then
				runHaxeCode([[
					import backend.Difficulty;
					Difficulty.list.push("Simple");
					PlayState.storyDifficulty = 1;
				]])
				loadSong(nil, 1)
			end
			stopSound("fuzzyloopstart") --brah
			restartSong()
			close()
		elseif keyJustPressed('ui_left') then
			changeSelected(-1)
		elseif keyJustPressed('ui_right') then
			changeSelected(1)
		end

		if keyReleased('ui_left') and getProperty("leftarw.animation.curAnim.name") ~= "arwsel" then
			playAnim("leftarw", "arwsel")
		elseif keyPressed('ui_left') and getProperty("leftarw.animation.curAnim.name") ~= "arwhold" then
			playAnim("leftarw", "arwhold")
		end

		if keyReleased('ui_right') and getProperty("ritearw.animation.curAnim.name") ~= "arwsel"  then
			playAnim("ritearw", "arwsel")
		elseif keyPressed('ui_right') and getProperty("leftarw.animation.curAnim.name") ~= "arwhold" then
			playAnim("ritearw", "arwhold")
		end

		if not highwayjammin then
			if (utils:keyListPressed(keyCombo[curKey])) then
				curKey = curKey + 1
				if curKey > #keyCombo then
					curKey = 1
					playMusic('highway-jammin', 1, true)
					highwayjammin = true
					changeSelected(0)
					for i=0,2 do playAnim('spstex'..i, "hj") end
				end
			elseif (keyboardJustPressed("ANY") and (not utils:keyListPressed(keyCombo[curKey]))) then curKey = 1
			end
		end
	end
end

function changeSelected(lol)
	curSauce = curSauce + lol
	if (curSauce > #sauces) then
		curSauce = #sauces
		if (#sauces < 5) then
			utils:playSound("lockedMenu")
			setProperty("spsneedle.angle", ndlAngs[curSauce] + 5)
		end
		return
		--[[if (getDataFromSave("gariis-mod_v0.95", "harderSauces") ~= nil and #sauces < 7) then
			if (sssCounter < 10) then sssCounter = sssCounter+1
				cancelTimer("sssTimer")
				setProperty("spsneedle.angle", getProperty("spsneedle.angle") + sssCounter)
				runTimer("sssTimer", 0.5)
			else table.insert(sauces, "Suxxor's Secret Sauce")
				curSauce = #sauces
			end
		end]]--
	elseif (curSauce <= 2 and (not hasSimple) and (not playedCrossout)) then
		playedCrossout = true
		playAnim("nosimplechart", 'reg')
	elseif (curSauce < 1) then curSauce = 1
		return
	end

	if (lol ~= 0) then utils:playSound("gaugeScroll") end
	playAnim("bfspice", "sauce"..curSauce)
	if (curSauce >= 3 and curSauce <= 4 and highwayjammin) then playAnim("sausbtls", "sauce"..curSauce.."-old")
	else playAnim("sausbtls", "sauce"..curSauce)
	end
	playAnim("sausdescs", "sauce"..curSauce)
	playAnim("spsflavs", "sauce"..curSauce)
	setProperty("spsflavs.x", 210 + ((screenWidth - getProperty("spsflavs.frameWidth"))/2))
	setProperty("spsflavs.y", screenHeight - math.min((85 + getProperty("spsflavs.frameHeight"))/2, 85))
	setProperty("nosimplechart.visible", curSauce <= 2 and (not hasSimple))

	setTextString('nameTxt', sauces[curSauce])
end

local crumpnum = 0
function onTimerCompleted(tag)
	if(tag == "sssTimer") then
		sssCounter = 0
	elseif (tag == "crumple") then
		crumpnum = crumpnum + 1
		for i = 0,2 do setProperty('cru'..i..'.visible', (crumpnum % 3) == i) end
		runTimer("crumple", 120/130)
	elseif (tag == "wirequote") then setProperty("loltex.active", true)
	end
end

function destroySpiceMenu()
	inMenu = false
	setProperty('camHUD.alpha', 0.95)
	playMusic('freakyMenu', 0, true)

	removeLuaSprite('pprovr', true)
	removeLuaSprite('bfspice', true)
	removeLuaSprite('spsmeterbg', true)
	removeLuaSprite('spsneedle', true)
	removeLuaSprite('spstxt', true)

	removeLuaText("nameTxt", true)
end