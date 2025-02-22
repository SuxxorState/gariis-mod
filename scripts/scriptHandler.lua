local errored = false
local bkend, menus, chars, songs, stges, objts = 'scripts/backend/', 'scripts/menus/', 'scripts/chars/', 'scripts/songs/', 'scripts/stages/', 'scripts/objects/' --heehee hoohoo crack
local lastChr = {["boyfriend"] = "", ["gf"] = "", ["dad"] = ""}

luaDebugMode = (getModSetting('gariiDebug') ~= nil and getModSetting('gariiDebug'))
errored = not (stringStartsWith(version, "1.0.") or stringStartsWith(version, "0.7")) --set as 1.0.x because 1.0 kinda fucking sucks
if (not errored) then
    initSaveData("gariis-mod_v0.96", "SuxxorState")
    setProperty("autoUpdateRPC", false)

    hudType = getPropertyFromClass("states.PlayState", "stageUI")
    setVar("hudType", hudType)

    for a, b in pairs(getRunningScripts()) do  if (string.find(b, "scriptHandler.lua") ~= nil) then
            setVar("folDir", string.sub(b, 1, #b - #"scripts/scriptHandler.lua"))
    end end
    utils = (require (getVar("folDir").."scripts.backend.utils")):new()
    if (utils:getGariiData("dirFldr") == nil or utils:getGariiData("dirFldr") ~= nil) then utils:setGariiData("dirFldr", getVar("folDir")) end
    
    addLuaScript(bkend..'globalFunctions')
    addLuaScript(bkend.."achievementStalker")
    addLuaScript(objts..'customSoundTray')
    addLuaScript(objts..'stickerTrans')
    addLuaScript(objts..'cursor')
    if (utils:lwrKebab(songName) == "gariis-arcade") then --arcade menu handles the heavy lifting for everything non-fnf related
        addLuaScript(menus..'arcade')
        close()
    else
        addLuaScript(menus.."heat")
        if (utils:getGariiData("curSauce") ~= nil) then --kinda dont want the song loaded when you're in the heat menu. takes up unneccesary memory
            addLuaScript(stges..curStage)
            addLuaScript(objts.."bubbleHandler")
            addLuaScript(songs..utils:lwrKebab(songName))
            addLuaScript(bkend..hudType.."HUD")
            addLuaScript(menus..'pause')
            addLuaScript(menus.."gameOver")
            addLuaScript(menus..'results')
        end
    end

    callOnLuas("initLuas")
end

function onCreatePost()   
    if (errored or utils:getGariiData("curSauce") == nil or utils:lwrKebab(songName) == "gariis-arcade") then return end

    for chr,nm in pairs(lastChr) do
        if (getProperty(chr..".curCharacter") ~= nil) then
            callOnLuas("onRequestBubble", {utils:lwrKebab(getProperty(chr..".curCharacter"))})
            addLuaScript(chars..utils:lwrKebab(getProperty(chr..".curCharacter")).."Handler")
            lastChr[chr] = getProperty(chr..".curCharacter")
        end
    end
end

--general functions that need to constantly be active, as tossing them in globalFunctions breaks shit
function onStartCountdown()
    if (not errored) then return end

    setProperty("inCutscene", true)
    utils:playSound("errorjingle", 1)

    makeLuaSprite('garError','error',0,0)
    addLuaSprite('garError', true)
    setObjectCamera('garError', 'other')

    makeLuaText('errorTxt', "HEY!! Garii's Mod is not built for this version! Please use Psych 0.7.X or higher! (DO NOT USE 1.0 THAT SHIT SUCKS USE 1.0.l OR HIGHER)", 1000, 12, 600)
    setTextFont('errorTxt', "Lasting Sketch.ttf")
    setTextBorder('errorTxt', 1, '000000')
    addLuaText('errorTxt')
    setTextSize('errorTxt', 32)
    setObjectCamera('errorTxt', 'other')
    screenCenter('errorTxt', 'x')
    return Function_Stop;
end

function onEvent(name, value1, value2, strumTime)
    local event = utils:lwrKebab(name)
    local val1 = utils:lwrKebab(value1)
    local val2 = utils:lwrKebab(value2)

	if (event == "change-character") then
        local valExc = {["gf"] = "gf", ["girlfriend"] = "gf", ["1"] = "gf", ["dad"] = "dad", ["opponent"] = "dad", ["0"] = "dad"}
        local chngChr = valExc[val1] or "boyfriend"

        removeLuaScript(chars..utils:lwrKebab(lastChr[chngChr]).."Handler")
        callOnLuas("onDeleteBubble", {chngChr})
        callOnLuas("onRequestBubble", {utils:lwrKebab(getProperty(chngChr..".curCharacter"))})
        addLuaScript(chars..utils:lwrKebab(getProperty(chngChr..".curCharacter")).."Handler")
        lastChr[chngChr] = getProperty(chngChr..".curCharacter")
    end
end

--yellow debug texts are conflicts scripts run into that are not fatal, usually whenever a script just fails to find something and safely ignores it
--green debug texts are things scripts were successfully able to do; like make a sprite or execute a reflection function
--light blue debug texts are the "default" colour; typically for things that are not tied to anything, or give information about something
--lavender debug texts are in-script errors that prevent a good chunk of something from functioning; like if a function that was imperative for a minigame to not be softlocked failed to run
--any other debug texts were made by some external source outside of gariis mod (like the engine itself); usually they don't mean anything as failing to load scripts might be what i want