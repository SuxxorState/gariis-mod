local utils = (require (getVar("folDir").."scripts.backend.utils")):new() --new sets up any internal variables so that they can be used.
local fldr = "pause/"
local pausemusic = fldr.."pit-stop"
local pauseSel = 0
local diffint = -1
local canPause = true

function onCreate()
    for i=1,3 do precacheSound(fldr..'scribble'..i) end
	precacheSound(pausemusic)
end

function onPause()
    if (canPause) then openCustomSubstate("PauseMenu", true) end
    return Function_Stop;
end

function disablePause() canPause = false end
function enablePause() canPause = true end

function onCustomSubstateCreate(css)
    if (css ~= "PauseMenu") then return end

	if (utils:getGariiData("curSauce") ~= nil) then 
		diffint = utils:getGariiData("curSauce")-1
	end
	playSound(pausemusic, 0, 'bgmusic')
	setSoundTime('bgmusic', getRandomInt(0,30000))
	soundFadeIn('bgmusic', 3, 0, 0.3)
	
	makeAnimatedLuaSprite('bgPause', fldr..'pausebg', 0, 0)
	addAnimationByPrefix("bgPause", 'reg', "pausebg", 1)
	insertToCustomSubstate('bgPause')
	setProperty('bgPause.alpha', 0)
	doTweenAlpha('bgPause', 'bgPause', 0.5, 2.5, 'circOut')
	
	makeLuaSprite('pausePaper', fldr..'paper', -300, 0)
	screenCenter('pausePaper', 'y')
	insertToCustomSubstate('pausePaper')
	doTweenX('pausePaper', 'pausePaper', -85, 1, 'circOut')

	makeAnimatedLuaSprite('pauseSelected', fldr..'selected',10 - (300-85),300)
	addAnimationByPrefix("pauseSelected", 'reg', "selected", 2)
	insertToCustomSubstate('pauseSelected')
	doTweenX('pauseSelected', 'pauseSelected', 10, 1, 'circOut')

	local stickfolds = {""}
	local stickies = {}
	if (utils:getGariiData("stickyNotes") ~= nil) then
		for i,fold in pairs(utils:getGariiData("stickyNotes")) do 
			table.insert(stickfolds, fold.."/") 
		end
	end
	for i,fold in pairs(stickfolds) do
		for j,note in pairs(utils:dirFileList('images/'..fldr..'stickynotes/'..fold)) do --quick stickie grab
			if (stringEndsWith(note, ".png")) then table.insert(stickies, fold..string.sub(note, 1, #note - 4)) end
		end
	end
	makeLuaSprite('pauseStickyNote', fldr..'stickynotes/'..stickies[getRandomInt(1, #stickies)],0,0)
	setProperty('pauseStickyNote.x', screenWidth - (getProperty("pauseStickyNote.width") + 10))
	setProperty('pauseStickyNote.y', screenHeight + 100)
	insertToCustomSubstate('pauseStickyNote')

	makeLuaSprite('pausePlrHand', fldr..'hands/'..stringSplit(boyfriendName, "-")[1].."hand",0,0) --if anyone questions it, cup has no hands. so his sprite is blank. duh.
	setProperty('pausePlrHand.x', getProperty("pauseStickyNote.x") + (getProperty("pauseStickyNote.width") - getProperty("pausePlrHand.width"))/2)
	setProperty('pausePlrHand.y', getProperty("pauseStickyNote.y") - 70)
	insertToCustomSubstate('pausePlrHand')

	makeLuaSprite('pauseCardboard', fldr..'songboard',0,-20)
	setProperty('pauseCardboard.x', screenWidth - (getProperty("pauseCardboard.width") - 40))
	insertToCustomSubstate('pauseCardboard')

	makeLuaSprite('pauseDiff', fldr..'diffs/diff '..diffint,0,95)
	setProperty('pauseDiff.x', getProperty('pauseCardboard.x') + (((getProperty('pauseCardboard.width')-10) - getProperty('pauseDiff.width'))/2) + 15)
	insertToCustomSubstate('pauseDiff')
	
	makeLuaSprite('pauseName', fldr..'names/'..utils.songNameFmt,0,5)
	setProperty('pauseName.x', getProperty('pauseCardboard.x') + (((getProperty('pauseCardboard.width')-10) - getProperty('pauseName.width'))/2) - 5)
	insertToCustomSubstate('pauseName')

	runTimer('stickyNoteAppear', 1.5)
	changeSelected(0)
	local pausePhrases = {"Paused", "Not Playing", "Waiting", "Taking a Break"}
	if (isStoryMode) then utils:setDiscord("Story Mode ("..pausePhrases[getRandomInt(1,#pausePhrases)]..")", utils.songName.." ["..utils:getHeat(true).."]", getProperty("dad.healthIcon"))
	else utils:setDiscord("Freeplay ("..pausePhrases[getRandomInt(1,#pausePhrases)]..")", utils.songName.." ["..utils:getHeat(true).."]", getProperty("dad.healthIcon"))
	end
end

function onCustomSubstateUpdate(css)
    if (css ~= "PauseMenu") then return end

	if keyJustPressed('back') then
		closeCustomSubstate("PauseMenu")
	elseif keyJustPressed('accept') then
		if (pauseSel == 0) then 
			closeCustomSubstate("PauseMenu")
		elseif (pauseSel == 1) then 
			restartSong()
		elseif (pauseSel == 2) then 
			utils:enterOptions()
		elseif (pauseSel == 3) then 
			utils:exitToMenu()
		end
	elseif keyJustPressed('ui_up') then
		changeSelected(-1)
	elseif keyJustPressed('ui_down') then
		changeSelected(1)
	end
end

function changeSelected(amt)
	if (amt ~= 0) then playSound(fldr..'scribble'..getRandomInt(1,3), getRandomFloat(0.5,0.9)) end

	pauseSel = pauseSel + amt
	if (pauseSel > 3) then pauseSel = 0
	elseif (pauseSel < 0) then pauseSel = 3 end

	setProperty("pauseSelected.y", 200 + (pauseSel * 100))
end


function onSoundFinished(snd)
    if (snd == 'bgmusic') then
        playSound(pausemusic, 0.5, 'bgmusic')
    end
end

function onTimerCompleted(tmr)
	if (tmr == "stickyNoteAppear") then
		doTweenY("stickyPlace", "pauseStickyNote", screenHeight - (getProperty("pauseStickyNote.height") + 10), 1, 'sineOut')
		doTweenY("stickyHandUp", "pausePlrHand", (screenHeight - (getProperty("pauseStickyNote.height") + 10)) - 70, 1, 'sineOut')
    end
end

function onTweenCompleted(twn)
    if (twn == 'stickyHandUp') then
        doTweenY("stickyHandDown", "pausePlrHand", screenHeight + 50, 0.5, 'sineIn')
    end
end


function onCustomSubstateDestroy(tag)
    if (tag ~= "PauseMenu") then return end

	stopSound('bgmusic')
	
	for _,spr in pairs({'pauseSelected', 'bgPause', 'pausePaper', 'pauseStickyNote', 'pausePlrHand', 'pauseCardboard', 'pauseDiff', 'pauseName'}) do
		removeLuaSprite(spr) 
	end

	for _,twn in pairs({"stickyPlace", "stickyHandUp", "stickyHandDown", 'pausePaper', 'pauseSelected'}) do
		cancelTween(twn) --ik this isnt necessary but its kinda a habit from source coding
	end

	cancelTimer('stickyNoteAppear')
end