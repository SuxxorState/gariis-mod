local utils = (require (getVar("folDir").."scripts.backend.utils")):new() --new sets up any internal variables so that they can be used.
local pausemusic = "pause/pitstop"
local bgframe = 0
local selframe = 0
local pauseSel = 0
local diffint = -1
local canPause = true

function onCreate()
    for i=1,3 do precacheSound('scribble'..i) end
	precacheSound(pausemusic)
end

function onPause()
    if (canPause) then openCustomSubstate("pausemenu", true) end
    return Function_Stop;
end

function disablePause()
	canPause = false
end

function enablePause()
	canPause = true
end

function onCustomSubstateCreate(tag)
    if tag == "pausemenu" then
		if (utils:getGariiData("curSauce") ~= nil) then 
			diffint = utils:getGariiData("curSauce")-1
		end
        playSound(pausemusic, 0, 'bgmusic')
		setSoundTime('bgmusic', getRandomInt(0,30000))
		soundFadeIn('bgmusic', 3, 0, 0.3)
        
		for i=0,2 do
			makeLuaSprite('bgPause'..i, 'pause/pausebg'..i, 0, 0)
			setObjectCamera('bgPause'..i, 'other')
			addLuaSprite('bgPause'..i)
			setProperty('bgPause'..i..'.alpha', 0)
			doTweenAlpha('bgPause'..i, 'bgPause'..i, 0.5, 2.5, 'circOut')
			setProperty('bgPause'..i..'.visible', i == bgframe)
		end
		runTimer('switchBGframe', 1)
        
		makeLuaSprite('pausePaper', 'pause/paper', -300, 0)
		setObjectCamera('pausePaper', 'other')
		screenCenter('pausePaper', 'y')
		addLuaSprite('pausePaper')
		doTweenX('pausePaper', 'pausePaper', -85, 1, 'circOut')

		for i=0,2 do
			makeLuaSprite('pauseSelected'..i, 'pause/selected'..i,10 - (300-85),300)
			setObjectCamera('pauseSelected'..i, 'other')
			addLuaSprite('pauseSelected'..i)
			doTweenX('pauseSelected'..i, 'pauseSelected'..i, 10, 1, 'circOut')
			setProperty('pauseSelected'..i..'.visible', i == selframe)
		end
		runTimer('switchSelFrame', 0.75)

		local stickfolds = {""}
		local stickies = {}
		if (utils:getGariiData("stickyNotes") ~= nil) then
			for i,fold in pairs(utils:getGariiData("stickyNotes")) do 
				table.insert(stickfolds, fold.."/") 
			end
		end
		for i,fold in pairs(stickfolds) do
			for j,note in pairs(utils:dirFileList('images/pause/stickynotes/'..fold)) do --quick stickie grab
				if (stringEndsWith(note, ".png")) then table.insert(stickies, fold..string.sub(note, 1, #note - 4)) end
			end
		end
		makeLuaSprite('pauseStickyNote', 'pause/stickynotes/'..stickies[getRandomInt(1, #stickies)],0,0)
		setProperty('pauseStickyNote.x', screenWidth - (getProperty("pauseStickyNote.width") + 10))
		setProperty('pauseStickyNote.y', screenHeight + 100)
		setObjectCamera('pauseStickyNote', 'other')
		addLuaSprite('pauseStickyNote')

		makeLuaSprite('pauseBFHand', 'pause/hands/'..stringSplit(boyfriendName, "-")[1].."hand",0,0) --if anyone questions it, cup has no hands. so his sprite is blank. duh.
		setProperty('pauseBFHand.x', getProperty("pauseStickyNote.x") + (getProperty("pauseStickyNote.width") - getProperty("pauseBFHand.width"))/2)
		setProperty('pauseBFHand.y', getProperty("pauseStickyNote.y") - 70)
		setObjectCamera('pauseBFHand', 'other')
		addLuaSprite('pauseBFHand')

		makeLuaSprite('pauseCardboard', 'pause/songboard',0,-20)
		setProperty('pauseCardboard.x', screenWidth - (getProperty("pauseCardboard.width") - 40))
		setObjectCamera('pauseCardboard', 'other')
		addLuaSprite('pauseCardboard')

		makeLuaSprite('pauseDiff', 'pause/diffs/diff '..diffint,0,95)
		setProperty('pauseDiff.x', getProperty('pauseCardboard.x') + (((getProperty('pauseCardboard.width')-10) - getProperty('pauseDiff.width'))/2) + 15)
		setObjectCamera('pauseDiff', 'other')
		addLuaSprite('pauseDiff')
		
		makeLuaSprite('pauseName', 'pause/names/'..utils.songNameFmt,0,5)
		setProperty('pauseName.x', getProperty('pauseCardboard.x') + (((getProperty('pauseCardboard.width')-10) - getProperty('pauseName.width'))/2) - 5)
		setObjectCamera('pauseName', 'other')
		addLuaSprite('pauseName')

		runTimer('stickyNoteAppear', 1.5)
		changeSelected(0)
		local pausePhrases = {"Paused", "Not Playing", "Waiting", "Taking a Break"}
		if (isStoryMode) then utils:setDiscord("Story Mode ("..pausePhrases[getRandomInt(1,#pausePhrases)]..")", utils.songName.." ["..utils:getHeat(true).."]", getProperty("dad.healthIcon"))
		else utils:setDiscord("Freeplay ("..pausePhrases[getRandomInt(1,#pausePhrases)]..")", utils.songName.." ["..utils:getHeat(true).."]", getProperty("dad.healthIcon"))
		end
    end
end

function onCustomSubstateUpdate(tag)
    if tag == "pausemenu" then
		if keyJustPressed('back') then
			closeCustomSubstate("pausemenu")
		elseif keyJustPressed('accept') then
			if pauseSel == 0 then
				closeCustomSubstate("pausemenu")
			elseif pauseSel == 1 then
				restartSong()
			elseif pauseSel == 2 then
				utils:enterOptions()
			elseif pauseSel == 3 then
				utils:exitToMenu()
			end
		elseif keyJustPressed('ui_up') then
			changeSelected(-1)
		elseif keyJustPressed('ui_down') then
			changeSelected(1)
		end
    end
end

function changeSelected(amt)
	if (amt ~= 0) then playSound('scribble'..getRandomInt(1,3), getRandomFloat(0.5,0.9)) end

	pauseSel = pauseSel + amt
	if (pauseSel > 3) then pauseSel = 0
	elseif (pauseSel < 0) then pauseSel = 3 end

	for i=0,2 do 
		setProperty("pauseSelected"..i..".y", 200 + (pauseSel * 100))
	end
end


function onSoundFinished(tag)
    if tag == 'bgmusic' then
        playSound(pausemusic, 0.5, 'bgmusic')
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if (tag == 'switchBGframe') then
        bgframe = bgframe + 1
		if (bgframe > 2) then bgframe = 0 end

		for i=0,2 do 
			setProperty('bgPause'..i..".visible", i == bgframe) 
		end
        runTimer('switchBGframe', 2)
	elseif (tag == 'switchSelFrame') then
		selframe = selframe + 1
		if (selframe > 2) then selframe = 0 end
		for i=0,2 do 
			setProperty('pauseSelected'..i..'.visible', i == selframe)
		end
		runTimer('switchSelFrame', 1)
	elseif tag == "stickyNoteAppear" then
		doTweenY("stickyPlace", "pauseStickyNote", screenHeight - (getProperty("pauseStickyNote.height") + 10), 1, 'sineOut')
		doTweenY("stickyHandUp", "pauseBFHand", (screenHeight - (getProperty("pauseStickyNote.height") + 10)) - 70, 1, 'sineOut')
    end
end

function onTweenCompleted(tag)
    if tag == 'stickyHandUp' then
        doTweenY("stickyHandDown", "pauseBFHand", screenHeight + 50, 0.5, 'sineIn')
    end
end


function onCustomSubstateDestroy(tag)
    if tag == "pausemenu" then
        stopSound('bgmusic')
        
		for i=0,2 do 
			removeLuaSprite('bgPause'..i, false)
			removeLuaSprite('pauseSelected'..i, false) 
		end
        
        removeLuaSprite('pausePaper', false)
		removeLuaSprite('pauseStickyNote', false)
		removeLuaSprite('pauseBFHand', false)
		removeLuaSprite('pauseCardboard', false)
		removeLuaSprite('pauseDiff', false)
		removeLuaSprite('pauseName', false)

		cancelTween("stickyPlace") --ik this isnt necessary but its kinda a habit from source coding
		cancelTween("stickyHandUp")
		cancelTween("stickyHandDown")
		cancelTween('pausePaper')
		cancelTween('pauseSelected')

		cancelTimer('stickyNoteAppear')
		cancelTimer('switchBGframe')
    end
end