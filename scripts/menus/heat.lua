local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local sauces = {"Whire's Gentle Zest", "Hoppin' Honey Mustard", "Outburst", "Garden Grown Habanero", "Shit The Bed", "Solar Flare"}
local sauceFX = {
	["whire's-gentle-zest"] = 	{chart = "simple",	needleAngle = -84; 	scrollSpd = 2.25, 	hpMult = 1.5, 	missCap = nil, 	hpLoss = 0.010, scoreMult = 0.5},
	["hoppin'-honey-mustard"] = {chart = "simple",	needleAngle = -50; 	scrollSpd = 2.5, 	hpMult = 1.25, 	missCap = nil, 	hpLoss = 0.013, scoreMult = 0.75},
	["outburst"] = 				{chart = "normal",	needleAngle = -14; 	scrollSpd = 2.75, 	hpMult = 1, 	missCap = nil, 	hpLoss = 0.018, scoreMult = 1},
	["garden-grown-habanero"] = {chart = "normal",	needleAngle = 24; 	scrollSpd = 3, 		hpMult = 0.75, 	missCap = nil, 	hpLoss = 0.023, scoreMult = 1.25},
	["shit-the-bed"] = 			{chart = "expert",	needleAngle = 64; 	scrollSpd = 3.25, 	hpMult = nil, 	missCap = 5, 	hpLoss = nil, 	scoreMult = 1.5},
	["solar-flare"] = 			{chart = "expert",	needleAngle = 91; 	scrollSpd = 3.5, 	hpMult = nil, 	missCap = 3, 	hpLoss = nil, 	scoreMult = 1.75},
	[""] = 						{chart = "master",	needleAngle = 105; 	scrollSpd = 4, 		hpMult = nil, 	missCap = 0, 	hpLoss = nil, 	scoreMult = 2},
}
local chartList, lastChart = {}, ""
local gariNormal, ridMeOfHim, goodbyeGarii = {x = 0, y = 0}, false, false
local textspeed = {-1.75, 2.75, -0.75}
local keyCombo = {{"TWO", "NUMPADTWO"}, {"ZERO", "NUMPADZERO"}, {"TWO", "NUMPADTWO"}, {"ONE", "NUMPADONE"}}
local curKey = 1
local highwayjammin = false
local curSauce = 1
local spsFld = "spice/"
local inMenu = false
local sssCounter = 0

function onStartCountdown(tick)
	if (utils:getGariiData("curSauce") ~= nil) then 
		callOnLuas("setupSpice", {sauceFX[utils:lwrKebab(sauces[utils:getGariiData("curSauce")])]})
		close()
	else
		local goodSauces = {}
		for i,dif in pairs(sauces) do
			local leCurChart, noBogusChart = sauceFX[utils:lwrKebab(dif)].chart, sauceFX[utils:lwrKebab(dif)].chart
			if (sauceFX[utils:lwrKebab(dif)].chart == "normal") then leCurChart = "‿" end

			if (checkFileExists('data/'..utils.songNameFmt..'/'..utils.songNameFmt..'-'..leCurChart..'.json')) then
				if ((noBogusChart == "expert" and utils:getGariiData("expertSauces") == true) or noBogusChart ~= "expert") then
					if (not utils:tableContains(chartList, noBogusChart)) then table.insert(chartList, noBogusChart) end
					table.insert(goodSauces, dif)
				end
			end
		end
		if (#chartList == 1 and chartList[1] == "normal") then ridMeOfHim = true
		else sauces = goodSauces
		end
		inMenu = true
		setProperty('inCutscene', true)
		setProperty('camHUD.alpha', 0)

		makeLuaSprite('white','',0,0)
		makeGraphic("white", screenWidth, screenHeight, "FFFFFF")
		quickAddSprite('white')
		
		for i=0,2 do
			makeAnimatedLuaSprite('spstex'..i,spsFld..'heat bg texts',1830 - (750 * i),30)
			addAnimationByPrefix('spstex'..i, 'reg', "choose ur heat", 24, false)
			addAnimationByPrefix('spstex'..i, 'hj', "highway jammin", 24, false)
			--setProperty("spstex"..i..".alpha", 0.75)
			playAnim('spstex'..i, 'reg')
			quickAddSprite('spstex'..i)

			makeAnimatedLuaSprite('tastex'..i,spsFld..'heat bg texts',-1200 + (825 * i),413)
			addAnimationByPrefix('tastex'..i, 'reg', "prepare ur tastebudz", 24, false)
			setProperty("tastex"..i..".alpha", 0.75)
			quickAddSprite('tastex'..i)
		end
		makeAnimatedLuaSprite('loltex',spsFld..'heat bg texts',1280,215)
		addAnimationByPrefix('loltex', 'reg', "thank you wire", 24, false)
		setProperty("loltex.alpha", 0.5)
		setProperty("loltex.active", false)
		quickAddSprite('loltex')

		makeAnimatedLuaSprite('bfspice',spsFld..'truckcouple-heat',450,50)
		for i=0,6 do addAnimationByPrefix("bfspice", 'sauce'..(i+1), "exp"..i, 24, false) end
		quickAddSprite('bfspice')
		
		makeLuaSprite('gre','',0,630)
		makeGraphic("gre", screenWidth, 200, "333333")
		quickAddSprite('gre')
		
		makeLuaSprite('pprovr','bg/paperbase',0,-380)
		scaleObject('pprovr', 1.15, 1.1)
		setProperty("pprovr.alpha", 0.5)
		setProperty("pprovr.flipX", true)
		quickAddSprite('pprovr')
		setBlendMode('pprovr', "multiply")

		for i=0,2 do
			makeLuaSprite('cru'..i,'bg/crumple'..i,0,0)
			setProperty('cru'..i..'.visible', i==0)
			quickAddSprite('cru'..i)
		end
		runTimer("crumple", 120/130)
		runTimer("wirequote", 30)

		makeLuaSprite('blcak','gameOver/black-paper',-120,-50)
		setGraphicSize('blcak', 500,1000)
		setProperty("blcak.angle", -10)
		quickAddSprite('blcak')

		makeAnimatedLuaSprite('spsflavs',spsFld..'heatflavors',10,screenHeight - 80)
		for i=0,6 do addAnimationByPrefix("spsflavs", 'sauce'..(i+1), "desc"..i, 24, true) end
		quickAddSprite('spsflavs')
				
		makeFlxAnimateSprite("sausdescs", 10, 19, "spice/desctexts")
		for i=0,6 do addAnimationBySymbol("sausdescs", 'sauce'..(i+1), "descs/sauc"..i) end
		quickAddSprite('sausdescs')

		if (#sauces >= 5) then makeLuaSprite('spsmeterbg',spsFld..'spicemeterbg',30,screenHeight - 240)
		elseif (#sauces >= 3) then makeLuaSprite('spsmeterbg',spsFld..'spicemeterbglocked',30,screenHeight - 240)
		else makeLuaSprite('spsmeterbg',spsFld..'spicemeterbgnormallocked',30,screenHeight - 240)
		end
		quickAddSprite('spsmeterbg')

		makeLuaSprite('spsneedle',spsFld..'spiceneedle',175,screenHeight - 200)
		setProperty("spsneedle.angle", sauceFX[utils:lwrKebab(sauces[curSauce])].needleAngle)
		quickAddSprite('spsneedle')

		makeAnimatedLuaSprite('chartgarii',spsFld..'garii chart',150,screenHeight - 120)
		addAnimationByPrefix("chartgarii", "hurt", "garii chart hurt")
		for _,dif in pairs(chartList) do addAnimationByPrefix("chartgarii", dif, "garii chart "..dif) end
		playAnim("chartgarii", sauceFX[utils:lwrKebab(sauces[curSauce])].chart)
		gariNormal = {x = 150 + (getProperty("chartgarii.frameWidth") / 2), y = (screenHeight - 120) + (getProperty("chartgarii.frameHeight") / 2)}
		quickAddSprite('chartgarii')
		
		makeAnimatedLuaSprite('spstxt',spsFld..'chart texts',65,screenHeight - 50)
		addAnimationByPrefix("spstxt", "reg", "heat text")
		for _,dif in pairs(chartList) do addAnimationByPrefix("spstxt", dif, dif.. " txt") end
		addOffset('spstxt', 'normal', 0, 0)
		addOffset('spstxt', 'simple', 0, 6)
		addOffset('spstxt', 'expert', -6, 1)
		addOffset('spstxt', 'reg', 0, 3)
		playAnim("spstxt", sauceFX[utils:lwrKebab(sauces[curSauce])].chart)
		quickAddSprite('spstxt')
		
		makeLuaSprite('fgGameOver', 'gameOver/not-black-paper',-120,-50)
		setGraphicSize('fgGameOver', 500,1000)
		setBlendMode('fgGameOver', "multiply")
		setProperty("fgGameOver.alpha", 0.75)
		setProperty("fgGameOver.angle", -10)
		quickAddSprite('fgGameOver')
		
		makeAnimatedLuaSprite('sausbtls',spsFld..'saucebottles',10,10)
		for i=0,6 do addAnimationByPrefix("sausbtls", 'sauce'..(i+1), "sauc"..i, 24, true) end
		for i=2,3 do addAnimationByPrefix("sausbtls", 'sauce'..(i+1).."-old", "oldsauc"..i, 24, true) end
		quickAddSprite('sausbtls')

		playMusic('freaky-hotmix', 1, true)

		changeSelected(0)
		if (ridMeOfHim) then runTimer("killHim", 0.75) end
		return Function_Stop;
	end
end

function quickAddSprite(spr)
	addLuaSprite(spr)
	utils:setObjectCamera(spr, 'other')
end

local accX = 1 * getRandomInt(-3,3,"0")
local accY = -5
local doingSomething = false
function onUpdatePost(elapsed)
	if (curSauce == 7 and (getProperty("spsneedle.angle") >= sauceFX[utils:lwrKebab(sauces[curSauce])].needleAngle - 2 or getProperty("spsneedle.angle") <= sauceFX[utils:lwrKebab(sauces[curSauce])].needleAngle + 2)) then
		setProperty("spsneedle.angle", sauceFX[utils:lwrKebab(sauces[curSauce])].needleAngle + getRandomInt(-2,2))
	else
		setProperty("spsneedle.angle", utils:lerp(getProperty("spsneedle.angle"), sauceFX[utils:lwrKebab(sauces[curSauce])].needleAngle, 0.25))
	end
	utils:setDiscord("Choosing Their Heat", "["..sauces[curSauce].."]") --CHANGE DAMN YOU

	if (goodbyeGarii) then
		setProperty("chartgarii.x", getProperty("chartgarii.x") + accX)
        setProperty("chartgarii.y", getProperty("chartgarii.y") + accY)
        if (accX < 0) then accX = math.min(accX + 0.01, 0)
        else accX = math.max(accX - 0.01, 0)
        end
        accY = accY + math.min((0.25 * (math.abs(accY) + 0.1)), 0.25)
		if (getProperty("chartgarii.y") > 750) then 
			goodbyeGarii = false 
			removeLuaSprite("chartgarii")
		end
	end
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
				utils:runHaxeCode([[
					import backend.Paths;
					import backend.Song;
					import backend.Highscore;
					var ogName:String = Paths.formatToSongPath(PlayState.SONG.song);
					if (PlayState.isStoryMode) {
						for (i in 0...PlayState.storyPlaylist.length) {PlayState.storyPlaylist[i] += "-sss";}
					}
					PlayState.SONG = Song.loadFromJson(Highscore.formatSong(ogName+"-sss", 0), ogName+"-sss");
				]])
			elseif (sauceFX[utils:lwrKebab(sauces[curSauce])].chart ~= "normal" and utils:tableContains(chartList, utils:lwrKebab(sauceFX[utils:lwrKebab(sauces[curSauce])].chart))) then
				utils:runHaxeCode([[
					import backend.Difficulty;
					Difficulty.list = ["]]..sauceFX[utils:lwrKebab(sauces[curSauce])].chart..[["];
				]])
				loadSong()
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
			setProperty("spsneedle.angle", sauceFX[utils:lwrKebab(sauces[curSauce])].needleAngle + 5)
		end
		return
		--[[if (getDataFromSave("gariis-mod_v0.95", "expertSauces") ~= nil and #sauces < 7) then
			if (sssCounter < 10) then sssCounter = sssCounter+1
				cancelTimer("sssTimer")
				setProperty("spsneedle.angle", getProperty("spsneedle.angle") + sssCounter)
				runTimer("sssTimer", 0.5)
			else table.insert(sauces, "Suxxor's Secret Sauce")
				curSauce = #sauces
			end
		end]]--
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
	if (not ridMeOfHim) then
		playAnim("spstxt", sauceFX[utils:lwrKebab(sauces[curSauce])].chart)
		playAnim("chartgarii", sauceFX[utils:lwrKebab(sauces[curSauce])].chart, true, false, getProperty("chartgarii.animation.curAnim.curFrame")+1)
		if (lastChart ~= sauceFX[utils:lwrKebab(sauces[curSauce])].chart) then
			cancelTimer("gariichartstretch")
			cancelTimer("gariichartnormal")
			stretchGarii(1.2, 0.8)
			runTimer("gariichartstretch", 2/24)
		end
	end
	setProperty("spsflavs.x", 210 + ((screenWidth - getProperty("spsflavs.frameWidth"))/2))
	setProperty("spsflavs.y", screenHeight - math.min((85 + getProperty("spsflavs.frameHeight"))/2, 85))
	lastChart = sauceFX[utils:lwrKebab(sauces[curSauce])].chart

	setTextString('nameTxt', sauces[curSauce])
end

function stretchGarii(wid, hei)
	scaleObject("chartgarii", wid, hei)
	setProperty("chartgarii.x", gariNormal.x - (getProperty("chartgarii.width")/2))
	setProperty("chartgarii.y", gariNormal.y - (getProperty("chartgarii.height")/2))
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
	elseif (tag == "gariichartstretch") then
		stretchGarii(0.8, 1.2)
		runTimer("gariichartnormal", 2/24)
	elseif (tag == "gariichartnormal") then stretchGarii(1,1)
	elseif (tag == "killHim") then
		playAnim("chartgarii", "hurt")
		utils:playSound("gariknockedoff")
		goodbyeGarii = true
		runTimer("changeText", 1.5)
	elseif (tag == "changeText") then doTweenY("loleTextDown", "spstxt", screenHeight + 10, 0.75)
	elseif (tag == "changeTextUp") then doTweenY("loleTextUp", "spstxt", screenHeight - 50, 0.75)
	end
end

function onTweenCompleted(twn)
    if (twn == "loleTextDown") then
		playAnim("spstxt", "reg")
		runTimer("changeTextUp", 0.25)
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