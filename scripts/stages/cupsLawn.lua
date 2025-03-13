local utils = (require (getVar("folDir").."scripts.backend.utils")):new()

function onCreate()
    utils:makeBlankBG("blankBG", screenWidth,screenHeight, "FFFFFF")

	makeLuaSprite('cr0','bg/crumple0',0,0)
	setScrollFactor('cr0', 0, 0)
	utils:setObjectCamera('cr0','other')
	addLuaSprite('cr0',false)

	makeLuaSprite('cr1','bg/crumple1',0,0)
	setScrollFactor('cr1', 0, 0)
	utils:setObjectCamera('cr1','other')
	setProperty('cr1.alpha', 0)
	addLuaSprite('cr1',false)

	makeLuaSprite('cr2','bg/crumple2',0,0)
	setScrollFactor('cr2', 0, 0)
	utils:setObjectCamera('cr2','other')
	setProperty('cr2.alpha', 0)
	addLuaSprite('cr2',false)
end

function onCreatePost()
	makeLuaSprite('bg','bg/paperalt',0,0)
	scaleObject('bg', 1.25, 1.25)
	setScrollFactor('bg', 0, 0)
	setBlendMode('bg', "multiply")
	utils:setObjectCamera('bg','other')
	addLuaSprite('bg',false)

	triggerEvent("Camera Follow Pos", 600, 400)
end

function onCountdownTick()
	triggerEvent("Camera Follow Pos", 600, 400)
end

function onBeatHit()
	if curBeat % 6 == 0 then
		setProperty('cr0.alpha', 1)
		setProperty('cr1.alpha', 0)
		setProperty('cr2.alpha', 0)
	end
	if curBeat % 6 == 2 then
		setProperty('cr0.alpha', 0)
		setProperty('cr1.alpha', 1)
		setProperty('cr2.alpha', 0)
	end
	if curBeat % 6 == 4 then
		setProperty('cr0.alpha', 0)
		setProperty('cr1.alpha', 0)
		setProperty('cr2.alpha', 1)
	end
end