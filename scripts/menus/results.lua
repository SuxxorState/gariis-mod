local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local levelEnds = {["full-house"] = true} -- for story mode and allat
local songArtists = {["fuzzy-dice"] = "Vruzzzen", ["dis-track"] = "sock.clip", ["full-house"] = "Vruzzzen", ["twenty-sixteen"] = "George"}
local musicDelays = {["perfect"] = 95/24, ["excellent"] = 0, ["great"] = 5/24, ["good"] = 3/24, ["shit"] = 2/24}
local sauces = {"Whire's Gentle Zest", "Hoppin Honey Mustard", "Outburst", "Garden Grown Habanero", "Shit The Bed", "Solar Flare", "Suxxor's Secret Sauce"}
local resultsMusic = "results/results"
local resultsMusicDef = "results/resultsNORMAL"
local bgFrame = 0
local inResults = false
local keyPresses = 0
local scoreMulti = 1
local canUpdate = true
local rnkstats = {0,0,0,0,0,0}
local percentLerp = 0
local percentTarget = 0

function onCreate()
    for i=1,3 do precacheSound('scribble'..i) end
	precacheSound(resultsMusic)
end

function setupSpice(speed, hpamt, missamt, pushback, scrmult)
    if (scrmult ~= nil) then scoreMulti = scrmult end
end

function onEndSong()
	if ((not botPlay) and (not practice) and canUpdate) then
		if (not isStoryMode or levelEnds[utils.songNameFmt]) and (not inResults) then 
			openCustomSubstate("resultsmenu", false)
			inResults = true
			return Function_Stop;
		end
		updateCampaignStats()
	elseif (canUpdate) then utils:exitToMenu()
		return Function_Stop;
	end
end

function updateCampaignStats()
	if not isStoryMode then return end

	local rnks = {"sck", "gud", "bd", "sht"}
	for _,rnk in pairs(rnks) do makeLuaText(rnk..'Txt', "", 0, 20, 0) end
	runHaxeCode([[
		var ranks:Array<String> = ["sck", "gud", "bd", "sht"];
		for (i in 0...4) {
			game.modchartTexts.get(ranks[i] + "Txt").text += ratingsData[i].hits;
		}
	]])
	if (utils:getGariiData("storyStats") ~= nil) then rnkstats = utils:getGariiData("storyStats") end
	for i,rnk in pairs(rnks) do rnkstats[i] = rnkstats[i] + tonumber(getTextString(rnk.."Txt")) end
	rnkstats[5] = rnkstats[5] + (misses - keyPresses)
	rnkstats[6] = rnkstats[6] + score
	utils:setGariiData("storyStats", rnkstats)
end

function noteMissPress()
	keyPresses = keyPresses + 1
end

function onCustomSubstateCreate(tag)
    if tag == "resultsmenu" then
		updateCampaignStats()
		for i=0,2 do
			makeLuaSprite('bgResults'..i, 'pause/pausebg'..i, 0, 0)
			setObjectCamera('bgResults'..i, 'other')
			addLuaSprite('bgResults'..i)
			setProperty('bgResults'..i..'.alpha', 0)
			doTweenAlpha('bgResults'..i, 'bgResults'..i, 0.5, 2.5, 'circOut')
			setProperty('bgResults'..i..'.visible', i == bgFrame)
		end
		runTimer('switchbgFrame', 1)

		makeLuaText('finalRanking', "", 0, -200, 0)
		
		makeLuaText('sickTxt', "Sicks: ", 0, 20, 0)
		setTextFont('sickTxt', "Lasting Sketch.ttf")
		setTextBorder('sickTxt', 2, '000000')
		addLuaText('sickTxt')
		setTextSize('sickTxt', 64)
		setObjectCamera('sickTxt', 'other')
		
		makeLuaText('goodTxt', "Goods: ", 0, 20, 75)
		setTextFont('goodTxt', "Lasting Sketch.ttf")
		setTextBorder('goodTxt', 2, '000000')
		addLuaText('goodTxt')
		setTextSize('goodTxt', 64)
		setObjectCamera('goodTxt', 'other')
		
		makeLuaText('badTxt', "Bads: ", 0, 20, 150)
		setTextFont('badTxt', "Lasting Sketch.ttf")
		setTextBorder('badTxt', 2, '000000')
		addLuaText('badTxt')
		setTextSize('badTxt', 64)
		setObjectCamera('badTxt', 'other')
		
		makeLuaText('shitTxt', "Shits: ", 0, 20, 225)
		setTextFont('shitTxt', "Lasting Sketch.ttf")
		setTextBorder('shitTxt', 2, '000000')
		addLuaText('shitTxt')
		setTextSize('shitTxt', 64)
		setObjectCamera('shitTxt', 'other')
		
		local combinedMiss = (misses - keyPresses)
		local campScr = score
		if (isStoryMode) then 
			local rnks = {"sicks", "goods", "bads", "shits"}
			for i,rnk in pairs(rnks) do makeLuaText(rnk, ""..rnkstats[i], 0, 20, 0) end
			combinedMiss = rnkstats[5]
			campScr = rnkstats[6]
			makeLuaText("campScr", ""..campScr, 0, 20, 0)
		end
		makeLuaText('missTxt', "Misses: "..combinedMiss, 0, 20, 300)
		setTextFont('missTxt', "Lasting Sketch.ttf")
		setTextBorder('missTxt', 2, '000000')
		addLuaText('missTxt')
		setTextSize('missTxt', 64)
		setObjectCamera('missTxt', 'other')

		makeLuaText('totalMisses', ""..combinedMiss, 0,0,0)
					
		makeLuaText('scoreTxt', "Score: "..campScr, 0, 20, screenHeight - 210)
		setTextFont('scoreTxt', "Lasting Sketch.ttf")
		setTextBorder('scoreTxt', 2, '000000')
		addLuaText('scoreTxt')
		setTextSize('scoreTxt', 64)
		setObjectCamera('scoreTxt', 'other')
						
		makeLuaText('multTxt', "Diff Multiplier: "..scoreMulti.."x", 0, 20, screenHeight - 160)
		setTextFont('multTxt', "Lasting Sketch.ttf")
		setTextBorder('multTxt', 2, '000000')
		addLuaText('multTxt')
		setTextSize('multTxt', 64)
		setObjectCamera('multTxt', 'other')

		makeLuaText('finalScoreTxt', "FINAL SCORE: "..math.floor(campScr * scoreMulti), 0, 20, screenHeight - 110)
		setTextFont('finalScoreTxt', "Lasting Sketch.ttf")
		setTextBorder('finalScoreTxt', 2, '000000')
		addLuaText('finalScoreTxt')
		setTextSize('finalScoreTxt', 96)
		setObjectCamera('finalScoreTxt', 'other')
		if not (isStoryMode) then setProperty("songScore", math.floor(campScr * scoreMulti)) end				

		local curArtist = songArtists[utils.songNameFmt] or "unknown"
		makeLuaText('songStatTxt', utils.songName.." By "..curArtist, 0, 0, 0)
		setTextFont('songStatTxt', "Lasting Sketch.ttf")
		setTextBorder('songStatTxt', 2, '000000')
		addLuaText('songStatTxt')
		setTextSize('songStatTxt', 48)
		setObjectCamera('songStatTxt', 'other')

		makeLuaText('clearPercTxt', "", 0, 0, 0)
		
		runHaxeCode([[
			import backend.WeekData;
			var ranks:Array<String> = ["sick", "good", "bad", "shit"];
			for (i in 0...4) {
				if (game.modchartTexts.exists(ranks[i] + "s")) {
					game.modchartTexts.get(ranks[i] + "Txt").text += game.modchartTexts.get(ranks[i] + "s").text;
				} else {
					game.modchartTexts.get(ranks[i] + "Txt").text += ratingsData[i].hits;
				}
			}
			var leltext:FlxText = game.modchartTexts.get("finalRanking");
			var missedes:Int = Std.parseInt(game.modchartTexts.get("totalMisses").text);
			var goods:Int = ratingsData[0].hits + ratingsData[1].hits;
			var okays:Int = goods + ratingsData[2].hits + ratingsData[3].hits;
			if (PlayState.isStoryMode) {
				goods = Std.parseInt(game.modchartTexts.get("sicks").text) + Std.parseInt(game.modchartTexts.get("goods").text);
				okays = goods + Std.parseInt(game.modchartTexts.get("bads").text) + Std.parseInt(game.modchartTexts.get("shits").text);
				PlayState.storyDifficulty = 0;
				PlayState.campaignScore = Std.parseInt(game.modchartTexts.get("campScr").text) - game.songScore; //okay to explain this, the second endSong is called again and it isnt roadblocked, it'll add the song score to it, giving a score HIGHER than what should be given. so this fixes that.
			}
			var totals:Int = okays + missedes;

			if (goods/totals == 1) leltext.text = "Perfect";
			else if (goods/totals >= 0.9) leltext.text = "Excellent";
			else if (goods/totals >= 0.8) leltext.text = "Great";
			else if (goods/totals >= 0.6) leltext.text = "Good";
			else leltext.text = "Shit";

			if (PlayState.isStoryMode) {
				game.modchartTexts.get("songStatTxt").text = WeekData.getCurrentWeek().storyName;
			}

			game.modchartTexts.get("songStatTxt").text = Math.floor((goods/totals)*100) + "%    " + game.modchartTexts.get("songStatTxt").text;
			game.ratingPercent = Math.floor((goods/totals)*100)/100;
			game.modchartTexts.get("clearPercTxt").text = Math.floor((goods/totals)*100);
		]])
		if (utils:getGariiData("curSauce") ~= nil) then 
			setTextString("songStatTxt", sauces[utils:getGariiData("curSauce")].." "..getTextString("songStatTxt"))
		end
		setProperty("songStatTxt.x", screenWidth - (getProperty("songStatTxt.width") + 20))
				
		makeLuaSprite('bfFinal', 'results/bf'..getTextString("finalRanking"), 0, 0)
		setObjectCamera('bfFinal', 'other')
		addLuaSprite('bfFinal')

		percentTarget = tonumber(getTextString("clearPercTxt"))
		percentLerp = percentTarget - 36
		if percentLerp < 0 then percentLerp = 0 end
		setTextString("clearPercTxt", "")
		setTextFont('clearPercTxt', "Lasting Sketch.ttf")
		setTextBorder('clearPercTxt', 2, '000000')
		addLuaText('clearPercTxt')
		screenCenter('clearPercTxt')
		setTextSize('clearPercTxt', 128)
		setObjectCamera('clearPercTxt', 'other')

		runTimer("startFuckin", 37 / 24)
		runTimer("startMusic", musicDelays[getTextString("finalRanking"):lower()] or 0)

		changeSelected(0)
    end
end

function percUpdate()
	percentLerp = math.floor(getProperty("percentSpr.x"))
	if (getTextString('clearPercTxt') ~= "Clear:\n"..percentLerp.."%") then
		playSound("scrollMenu")
		setTextString('clearPercTxt', "Clear:\n"..percentLerp.."%")
		screenCenter('clearPercTxt')
	end
end

function percCompleted()
	playSound("confirmMenu")
	if (percentLerp ~= percentTarget) then
		percentLerp = percentTarget
		setTextString('clearPercTxt', "Clear:\n"..percentLerp.."%")
	end
	runTimer("endFuckin", 0.75)
end

function onCustomSubstateUpdate(tag)
    if tag == "resultsmenu" and canUpdate then
		runHaxeCode([[
			FlxG.sound.music.pause(); 
			game.vocals.pause();
			game.opponentVocals.pause();
		]])--song needs to SHUT UP. AND NOT KICK THE PLAYER OUT.
		if keyJustPressed('back') or keyJustPressed('accept') then
			canUpdate = false
			runHaxeCode([[
				if (game.modchartSounds.exists("resultsMusic")) {
					FlxTween.tween(game.modchartSounds.get("resultsMusic"), {volume: 0}, 0.8);
					FlxTween.tween(game.modchartSounds.get("resultsMusic"), {pitch: 3}, 0.1, {onComplete: _ -> { 
						FlxTween.tween(game.modchartSounds.get("resultsMusic"), {pitch: 0.5}, 0.4); 
					}});
			}
			]])
			runTimer("endWait", 0.9)
		end
    end
end

function onSoundFinished(tag)
    if tag == 'resultsMusic' then
        playSound(resultsMusic, 1, 'resultsMusic')
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if (tag == "startFuckin") then
		local tag_valParam = {x = percentTarget}
		local tag_optnParam = {ease = 'quartOut', onUpdate = 'percUpdate', onComplete = 'percCompleted'}
		makeLuaSprite('percentSpr', '', percentLerp, 0)
		startTween('percTwn', 'percentSpr', tag_valParam, 58 / 24, tag_optnParam)
	elseif (tag == "endFuckin") then
		doTweenAlpha("percAlp", "clearPercTxt", 0, 0.5, "quartOut")
	elseif (tag == "startMusic") then
		resultsMusic = resultsMusic..getTextString("finalRanking"):upper()
		if (checkFileExists(getVar("folDir").."sounds/"..resultsMusic.."-intro.ogg", true)) then
			playSound(resultsMusic.."-intro", 1, 'resultsMusic')
		elseif (checkFileExists(getVar("folDir").."sounds/"..resultsMusic..".ogg", true)) then playSound(resultsMusic, 1, 'resultsMusic')
		else resultsMusic = resultsMusicDef
			playSound(resultsMusicDef, 1, 'resultsMusic')
		end
	elseif (tag == 'switchbgFrame') then
        bgFrame = bgFrame + 1
		if (bgFrame > 2) then bgFrame = 0 end

		for i=0,2 do 
			setProperty('bgResults'..i..".visible", i == bgFrame) 
		end
        runTimer('switchbgFrame', 2)
	elseif (tag == "endWait") then
		utils:endToMenu()
    end
end

function onCustomSubstateDestroy(tag)
    if tag == "resultsmenu" then
        stopSound('resultsMusic')
        
		for i=0,2 do 
			removeLuaSprite('bgResults'..i, false)
		end
    end
end