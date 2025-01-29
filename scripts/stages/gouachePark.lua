local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local camLerp = 0
local lockCam = false

function onCreatePost()
	setProperty("gf.scrollFactor.x", 0.99)
	setProperty("gf.scrollFactor.y", 0.99)
	if (not isStoryMode) or utils:getGariiData("watchedCutscene") then lockCam = true end

    utils:makeBlankBG("blankBG", 2300,1400, "FFFFFF")
	
	if not lowQuality then
		makeAnimatedLuaSprite('sun','bg/sun',400,-625+getRandomInt(-50,50))
		addAnimationByPrefix("sun", "reg", "sun", 20)
		setScrollFactor('sun', 0.1, 0.1)
		addLuaSprite('sun')
	end

	if not lowQuality then
		local shits = 100
		for i=1,4 do
			shits = -shits
			makeAnimatedLuaSprite('cloud'..i,'bg/clouds',getRandomInt(-3000,1500)+(shits*getRandomInt(0,1)),getRandomInt(-850,-500)+(shits*getRandomInt(0,1)))
			setProperty("cloud"..i..".scale.x", getRandomFloat(0.2,0.5))
			setProperty("cloud"..i..".scale.y", getProperty("cloud"..i..".scale.x"))
			for j=1,5 do addAnimationByPrefix('cloud'..i, "reg"..j, "cloud"..j, 20) end
			playAnim('cloud'..i, "reg"..getRandomInt(1,5))
			setProperty("cloud"..i..".flipX", getRandomBool())
			setScrollFactor('cloud'..i, 0.1, 0.1)
			addLuaSprite('cloud'..i)
		end
	end

	makeLuaSprite('horzn','bg/horizon',-1225,410)
	setScrollFactor('horzn', 0.2, 0.2)
	addLuaSprite('horzn')

	makeLuaSprite('bkgrs','bg/far ground',-1225,500)
	setScrollFactor('bkgrs', 0.85, 0.85)
	addLuaSprite('bkgrs')

	if not lowQuality then
		makeAnimatedLuaSprite('bktre','bg/trees',-1200,-450)
		addAnimationByPrefix("bktre", "reg", "far tree", 22)
		setScrollFactor('bktre', 0.85, 0.85)
		addLuaSprite('bktre')
	end

	makeLuaSprite('grs','bg/ground main',-1825,600)
	setScrollFactor('grs', 0.99, 0.99)
	addLuaSprite('grs')
	
	if not lowQuality then
		makeAnimatedLuaSprite('tree','bg/trees',1300,-425)
		addAnimationByPrefix("tree", "reg", "close tree", 20)
		setScrollFactor('tree', 0.99, 0.99)
		addLuaSprite('tree')
	end

	
	if not lowQuality then
		for i=1,2 do
			local spkrShit = {{"speaker carv", 825,550}, {"Hunte Spekor", 300,525}}
			makeAnimatedLuaSprite('spkr'..i,'bg/bgSpeakers', spkrShit[i][2],spkrShit[i][3])
			addAnimationByPrefix("spkr"..i, 'boom', spkrShit[i][1], 24, true)
			playAnim('spkr'..i, 'boom')
			setScrollFactor('spkr'..i, 0.99, 0.99)
			addLuaSprite('spkr'..i)
		end
	end

	makeLuaSprite('bg','bg/paperbase',0,-500)
	setProperty("bg.alpha", 0.75)
	scaleObject('bg', 1.15, 1)
	setScrollFactor('bg', 0, 0.5)
	setBlendMode('bg', "multiply")
	setObjectCamera('bg','other')
	addLuaSprite('bg')

	for i=0,2 do
		makeLuaSprite('cr'..i,'bg/crumple'..i,0,0)
		setObjectCamera('cr'..i,'other')
		setProperty('cr'..i..'.visible', i==0)
		addLuaSprite('cr'..i)
	end
end

function cutsceneOver()
	lockCam = true
end

function onUpdatePost()
	if lockCam then setProperty("camFollow.y", 485) end
	--[[camLerp = utils:lerp(camLerp, cameraX, 0.05)
	if (math.abs(camLerp-cameraX) < 1) then camLerp = cameraX end
	setProperty("bg.x", (-((camLerp-650)/50)) - 100)]]--

	if not lowQuality then
		for i=1,4 do
			if (luaSpriteExists("cloud"..i)) then
				setProperty("cloud"..i..".x", getProperty("cloud"..i..".x") + (0.5 * (60/framerate)))
				if(getProperty("cloud"..i..".x") > 1500) then onResetCloud(i) end
			end
		end
		setProperty("sun.y", getProperty("sun.y") + (0.125 * (15/framerate)))
	end
end

local giggles = 100
function onResetCloud(cl)
	giggles = -giggles
	setProperty("cloud"..cl..".visible", false)
	setProperty("cloud"..cl..".scale.x", getRandomFloat(0.2,0.5))
	setProperty("cloud"..cl..".scale.y", getProperty("cloud"..cl..".scale.x"))
	setProperty("cloud"..cl..".x", -3000+(giggles*getRandomInt(0,1)))
	setProperty("cloud"..cl..".y", getRandomInt(-850,-500)+(giggles*getRandomInt(0,1)))
	playAnim('cloud'..cl, "reg"..getRandomInt(1,5))
	setProperty("cloud"..cl..".flipX", getRandomBool())
	setProperty("cloud"..cl..".visible", true)
end

function onBeatHit()
	for i=1,2 do playAnim('spkr'..i, 'boom', true) end
	if curBeat % 2 == 0 then
		for i = 0,2 do setProperty('cr'..i..'.visible', curBeat % 6 == 2 * i) end
	end
end

function onEvent(name, value1, value2, strumTime)
    local event = name:lower()
    local val1 = value1:lower()
    local val2 = value2:lower()

	if (event == "change character") and (val1 == "gf" or val1 == "girlfriend" or val1 == "1") and (not stringEndsWith(val2, "-support")) then
		setProperty("gf.scrollFactor.x", 0.99)
		setProperty("gf.scrollFactor.y", 0.99)
    end
end