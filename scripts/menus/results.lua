local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local levelEnds = {["full-house"] = true} -- for story mode and allat
local songArtists = {["fuzzy-dice"] = "Vruzzzen", ["dis-track"] = "sock.clip", ["full-house"] = "Vruzzzen", ["twenty-sixteen"] = "Suxxor"}
local musicDelays = {["perfect"] = 95/24, ["excellent"] = 0, ["great"] = 5/24, ["good"] = 3/24, ["shit"] = 2/24}
local sauces = {"Whire's Gentle Zest", "Hoppin Honey Mustard", "Outburst", "Garden Grown Habanero", "Shit The Bed", "Solar Flare", "Suxxor's Secret Sauce"}
local resultsMusic = "results/results"
local resultsMusicDef = "results/resultsNORMAL"
local finalRanking = "Shit"
local bgFrame = 0
local inResults = false
local keyPresses = 0
local scoreMulti = 1
local canUpdate = true
local rnkstats = {0,0,0,0,0,0}
local ratingAccumulation = {0,0,0,0}
local combinedMiss = (misses - keyPresses)
local campScr = score
local ratingPercent = 0
local percentLerp = 0
local percentTarget = 0

function onCreate()
    for i=1,3 do precacheSound('scribble'..i) end
	precacheSound(resultsMusic)
end

function setupSpice(stats)
    if (stats.scoreMult ~= nil) then scoreMulti = stats.scoreMult end
end

function onEndSong()
	if ((not botPlay) and (not practice) and canUpdate) then
		if ((stringEndsWith(version, "1.0-prerelease") or stringEndsWith(version, "1.0") or stringStartsWith(version, "1.0.1") or stringStartsWith(version, "1.0.2") or stringStartsWith(version, "1.0.2h"))) then --workaround for the story mode bug that SHOULD HAVE BEEN NOTICED PRIOR TO 1.0'S RELEASE.
			if (isStoryMode and week == "garii" and utils.songNameFmt == "fuzzy-dice") then
				loadSong("Full House")
				utils:runHaxeCode([[PlayState.storyPlaylist = ["Full House"];]])
				updateCampaignStats()
				calculateEverything()
				return Function_Stop;
			end
		else
			if (not isStoryMode or levelEnds[utils.songNameFmt]) and (not inResults) then
				openCustomSubstate("resultsmenu", false)
				inResults = true
				return Function_Stop;
			end
			updateCampaignStats()
			calculateEverything()
		end
	elseif (canUpdate) then utils:exitToMenu()
		return Function_Stop;
	end
end

function updateCampaignStats()
	if not isStoryMode then return end

	if (utils:getGariiData("storyStats") ~= nil) then rnkstats = utils:getGariiData("storyStats") end
	rnkstats[5] = rnkstats[5] + (misses - keyPresses)
	rnkstats[6] = rnkstats[6] + score
	utils:setGariiData("storyStats", rnkstats)
end

function goodNoteHit(id)
	if (getPropertyFromGroup('notes', id, 'rating') == "unknown") then return end

    local ranks = {"sick", "good", "bad", "shit"}
	if (isStoryMode) then rnkstats[utils:indexOf(ranks, getPropertyFromGroup('notes', id, 'rating'))] = rnkstats[utils:indexOf(ranks, getPropertyFromGroup('notes', id, 'rating'))] + 1 end
    ratingAccumulation[utils:indexOf(ranks, getPropertyFromGroup('notes', id, 'rating'))] = ratingAccumulation[utils:indexOf(ranks, getPropertyFromGroup('notes', id, 'rating'))] + 1
end

function noteMissPress()
	keyPresses = keyPresses + 1
end

function calculateEverything()
	if (isStoryMode) then
		for i= 1,4 do ratingAccumulation[i] = rnkstats[i] end
		combinedMiss = rnkstats[5]
		campScr = rnkstats[6]
	end

	local goods = ratingAccumulation[1] + ratingAccumulation[2]
	local okays = goods + ratingAccumulation[3] + ratingAccumulation[4]
	local totals = okays + combinedMiss

	ratingPercent = math.floor((goods/totals)*100)/100
	if (ratingPercent == 1) then finalRanking = "Perfect"
	elseif (ratingPercent >= 0.9) then finalRanking = "Excellent"
	elseif (ratingPercent >= 0.8) then finalRanking = "Great"
	elseif (ratingPercent >= 0.6) then finalRanking = "Good"
	end
end

function onCustomSubstateCreate(tag)
    if tag == "resultsmenu" then
		updateCampaignStats()
		calculateEverything()
		for i=0,2 do
			makeLuaSprite('bgResults'..i, 'pause/pausebg'..i, 0, 0)
			utils:setObjectCamera('bgResults'..i, 'other')
			addLuaSprite('bgResults'..i)
			setProperty('bgResults'..i..'.alpha', 0)
			doTweenAlpha('bgResults'..i, 'bgResults'..i, 0.5, 2.5, 'circOut')
			setProperty('bgResults'..i..'.visible', i == bgFrame)
		end
		runTimer('switchbgFrame', 1)

		makeLuaText('sickTxt', "Sicks: "..ratingAccumulation[1], 0, 20, 0)
		setTextFont('sickTxt', "Lasting Sketch.ttf")
		setTextBorder('sickTxt', 2, '000000')
		addLuaText('sickTxt')
		setTextSize('sickTxt', 64)
		utils:setObjectCamera('sickTxt', 'other')

		makeLuaText('goodTxt', "Goods: "..ratingAccumulation[2], 0, 20, 75)
		setTextFont('goodTxt', "Lasting Sketch.ttf")
		setTextBorder('goodTxt', 2, '000000')
		addLuaText('goodTxt')
		setTextSize('goodTxt', 64)
		utils:setObjectCamera('goodTxt', 'other')

		makeLuaText('badTxt', "Bads: "..ratingAccumulation[3], 0, 20, 150)
		setTextFont('badTxt', "Lasting Sketch.ttf")
		setTextBorder('badTxt', 2, '000000')
		addLuaText('badTxt')
		setTextSize('badTxt', 64)
		utils:setObjectCamera('badTxt', 'other')

		makeLuaText('shitTxt', "Shits: "..ratingAccumulation[4], 0, 20, 225)
		setTextFont('shitTxt', "Lasting Sketch.ttf")
		setTextBorder('shitTxt', 2, '000000')
		addLuaText('shitTxt')
		setTextSize('shitTxt', 64)
		utils:setObjectCamera('shitTxt', 'other')

		makeLuaText('missTxt', "Misses: "..combinedMiss, 0, 20, 300)
		setTextFont('missTxt', "Lasting Sketch.ttf")
		setTextBorder('missTxt', 2, '000000')
		addLuaText('missTxt')
		setTextSize('missTxt', 64)
		utils:setObjectCamera('missTxt', 'other')

		makeLuaText('scoreTxt', "Score: "..campScr, 0, 20, screenHeight - 210)
		setTextFont('scoreTxt', "Lasting Sketch.ttf")
		setTextBorder('scoreTxt', 2, '000000')
		addLuaText('scoreTxt')
		setTextSize('scoreTxt', 64)
		utils:setObjectCamera('scoreTxt', 'other')

		makeLuaText('multTxt', "Diff Multiplier: "..scoreMulti.."x", 0, 20, screenHeight - 160)
		setTextFont('multTxt', "Lasting Sketch.ttf")
		setTextBorder('multTxt', 2, '000000')
		addLuaText('multTxt')
		setTextSize('multTxt', 64)
		utils:setObjectCamera('multTxt', 'other')

		makeLuaText('finalScoreTxt', "FINAL SCORE: "..math.floor(campScr * scoreMulti), 0, 20, screenHeight - 110)
		setTextFont('finalScoreTxt', "Lasting Sketch.ttf")
		setTextBorder('finalScoreTxt', 2, '000000')
		addLuaText('finalScoreTxt')
		setTextSize('finalScoreTxt', 96)
		utils:setObjectCamera('finalScoreTxt', 'other')
		if not (isStoryMode) then setProperty("songScore", math.floor(campScr * scoreMulti)) end

		local curArtist = songArtists[utils.songNameFmt] or "unknown"
		makeLuaText('songStatTxt', utils.songName.." By "..curArtist, 0, 0, 0)
		setTextFont('songStatTxt', "Lasting Sketch.ttf")
		setTextBorder('songStatTxt', 2, '000000')
		addLuaText('songStatTxt')
		setTextSize('songStatTxt', 48)
		utils:setObjectCamera('songStatTxt', 'other')

		utils:runHaxeCode([[
			import backend.WeekData;
			if (PlayState.isStoryMode) {
				PlayState.storyDifficulty = 0;
				PlayState.campaignScore = Std.parseInt(game.modchartTexts.get("campScr").text) - game.songScore; //okay to explain this, the second endSong is called again and it isnt roadblocked, it'll add the song score to it, giving a score HIGHER than what should be given. so this fixes that.
			}

			if (PlayState.isStoryMode) {
				game.modchartTexts.get("songStatTxt").text = WeekData.getCurrentWeek().storyName;
			}
		]])

		rating = ratingPercent
		if (utils:getGariiData("curSauce") ~= nil) then setTextString("songStatTxt", sauces[utils:getGariiData("curSauce")].." "..(ratingPercent * 100).."%    "..getTextString("songStatTxt"))
		else setTextString("songStatTxt", (ratingPercent * 100).."%    "..getTextString("songStatTxt"))
		end
		setProperty("songStatTxt.x", screenWidth - (getProperty("songStatTxt.width") + 20))

		makeLuaSprite('bfFinal', 'results/bf'..finalRanking, 0, 0)
		utils:setObjectCamera('bfFinal', 'other')
		addLuaSprite('bfFinal')

		percentTarget = ratingPercent * 100
		percentLerp = percentTarget - 36
		if percentLerp < 0 then percentLerp = 0 end
		makeLuaText("clearPercTxt")
		setTextString("clearPercTxt", "")
		setTextFont('clearPercTxt', "Lasting Sketch.ttf")
		setTextBorder('clearPercTxt', 2, '000000')
		addLuaText('clearPercTxt')
		screenCenter('clearPercTxt')
		setTextSize('clearPercTxt', 128)
		utils:setObjectCamera('clearPercTxt', 'other')

		runTimer("startFuckin", 37 / 24)
		runTimer("startMusic", musicDelays[finalRanking:lower()] or 0)
    end
end

function percUpdate()
	percentLerp = math.floor(getProperty("percentSpr.x"))
	if (getTextString('clearPercTxt') ~= "Clear:\n"..percentLerp.."%") then
		utils:playSound("scrollMenu")
		setTextString('clearPercTxt', "Clear:\n"..percentLerp.."%")
		screenCenter('clearPercTxt')
	end
end

function percCompleted()
	utils:playSound("confirmMenu")
	if (percentLerp ~= percentTarget) then
		percentLerp = percentTarget
		setTextString('clearPercTxt', "Clear:\n"..percentLerp.."%")
	end
	runTimer("endFuckin", 0.75)
end

function onCustomSubstateUpdate(tag)
    if tag == "resultsmenu" and canUpdate then
		utils:runHaxeCode([[
			FlxG.sound.music.pause(); 
			game.vocals.pause();
			game.opponentVocals.pause();
		]])--song needs to SHUT UP. AND NOT KICK THE PLAYER OUT.
		if keyJustPressed('back') or keyJustPressed('accept') then
			canUpdate = false
			if (luaSoundExists("resultsMusic")) then
				startTween("resultsMusic", "resultsMusic", {volume = 0}, 0.8)
				startTween("resultsMusicPitch", "resultsMusic", {pitch = 3}, 0.1)
				startTween("resultsMusicPitch2", "resultsMusic", {pitch = 0.5}, 0.4, {startDelay = 0.1})
			end
			runTimer("endWait", 0.9)
		end
    end
end

function onSoundFinished(tag)
    if tag == 'resultsMusic' then
        utils:playSound(resultsMusic, 1, 'resultsMusic')
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
		resultsMusic = resultsMusic..finalRanking:upper()
		if (checkFileExists(getVar("folDir").."sounds/"..resultsMusic.."-intro.ogg", true)) then
			utils:playSound(resultsMusic.."-intro", 1, 'resultsMusic')
		elseif (checkFileExists(getVar("folDir").."sounds/"..resultsMusic..".ogg", true)) then utils:playSound(resultsMusic, 1, 'resultsMusic')
		else resultsMusic = resultsMusicDef
			utils:playSound(resultsMusicDef, 1, 'resultsMusic')
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