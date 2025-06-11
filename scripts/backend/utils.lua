local defWindowTitle = "Friday Night Funkin': Psych Engine"
local saveDir = "gariis-mod_v1.01"
local Utils = {}
local songNameFmt = ""
if stringEndsWith(songName, "-sss") then songNameFmt = (stringSplit(songName, "-s")[1]):lower():gsub(" ", "-")
else songNameFmt = (songName):lower():gsub(" ", "-") end
local countdownChecks = {[0] = false, false, false, false}

function Utils:new() --ive seen videos where they're like "dont make a general class/file called utils and sort it all out" and to that i say i do not give a shit ill do what i want look at me go
    local self = setmetatable({}, {__index = self})

    if stringEndsWith(songName, "-sss") then self.songName = stringSplit(songName, "-s")[1]
    else self.songName = songName end

    if stringEndsWith(songName, "-sss") then self.songNameFmt = (stringSplit(songName, "-s")[1]):lower():gsub(" ", "-")
    else self.songNameFmt = (songName):lower():gsub(" ", "-") end

    self.countdownChecks = {[0] = false, false, false, false}

    self.hudType = getVar("hudType")
    for a, b in pairs(getRunningScripts()) do  if (string.find(b, "scriptHandler.lua") ~= nil) then
        self.folDir = string.sub(b, 1, #b - #"scripts/scriptHandler.lua")
    end end

    return self
end

function Utils:setWindowTitle(lole)
    setPropertyFromClass('openfl.Lib', 'application.window.title', lole)
end

function Utils:setDiscord(details, state, smallImageKey, hasStartTimestamp, endTimestamp)
    changeDiscordPresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp)
end

function Utils:dirFileList(dir)
    local fucked = ""
    for a, b in pairs(getRunningScripts()) do  if (string.find(b, "scriptHandler.lua") ~= nil) then
        fucked = string.sub(b, 1, #b - #"scripts/scriptHandler.lua")
        if (Utils:getGariiData("dirFldr") == nil or Utils:getGariiData("dirFldr") ~= fucked) then Utils:setGariiData("dirFldr", fucked) end
    elseif (getVar("folDir") ~= nil) then
        fucked = getVar("folDir")
    elseif (Utils:getGariiData("dirFldr") ~= nil) then --redundancy bc idc
        fucked = Utils:getGariiData("dirFldr")
    end end
    return directoryFileList(fucked..dir)
end

function Utils:enterOptions()
    Utils:runHaxeCode([[
        import options.OptionsState;
        import backend.MusicBeatState;
        game.paused = true;
        game.vocals.volume = 0;
        MusicBeatState.switchState(new OptionsState());
        if (ClientPrefs.data.pauseMusic != 'None') {
            FlxG.sound.playMusic(Paths.sound(Paths.formatToSongPath("pause/pit-stop")), 0);
            FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
        }
        OptionsState.onPlayState = true;
    ]])
end


function Utils:exitToMenu(delayexit)
    setVar("tryingtoexit", true)
    delayexit = delayexit or false 
    if (delayexit == true) then runTimer("exitSong", 0.1)
    else exitSong() end
    Utils:setWindowTitle(defWindowTitle) --resets window title
    if (not getModSetting('sauceLock')) then Utils:setGariiData("curSauce", nil) end  --makes the game prompt for a difficulty selection again.
    Utils:setGariiData("storyStats", nil)
end

function Utils:endToMenu()
    setVar("tryingtoexit", true)
    local folDir = ""
    for a, b in pairs(getRunningScripts()) do  if (string.find(b, "scriptHandler.lua") ~= nil) then --i dont... i dont know man. shits just kinda finnicky.
        folDir = string.sub(b, 1, #b - #"scripts/scriptHandler.lua")
    end end
    if (not botPlay) and (not practice) then
        if Utils:getGariiData("stickyNotes") == nil then
            if isStoryMode then Utils:setGariiData("stickyNotes", {"fuzzy-dice", "full-house"})
            else Utils:setGariiData("stickyNotes", {songNameFmt, "dis-track"}) end
        else
            local sticks = Utils:getGariiData("stickyNotes")
            if not Utils:tableContains(sticks, songNameFmt) then 
                table.insert(sticks, ""..songNameFmt) 
                Utils:setGariiData("stickyNotes", sticks)
            end
        end
    end

    if (not isStoryMode or songNameFmt == "full-house") then --im probably just gonna make it reset on the final songs of each week. just sounds simpler at this point.
        if (not botPlay) and (not practice) then
            if (isStoryMode) then
                if Utils:getGariiData("expertSauces") == nil then Utils:setGariiData("expertSauces", true) end
                if Utils:getGariiData("levelRevealed") == nil then
                    saveFile(folDir.."weeks/garii.json", "{\n\"storyName\": \"Roadblock Ruckus\",\n\"difficulties\": \"‿\",\n\"hideFreeplay\": false,\n\"weekBackground\": \"orange\",\n\"freeplayColor\": [146,113,253],\n\"weekBefore\": \"tutorial\",\n\"startUnlocked\": true,\n\"weekCharacters\": [\"garii\", \"bftrans\", \"gftrans\"],\n\"songs\": [[\"Fuzzy Dice\", \"garfree\", [177, 82, 82]], [\"Full House\", \"goonsfree\", [67,66,83]]],\n\"hideStoryMode\": false,\n\"weekName\": \"Episode ][\",\n\"hiddenUntilUnlocked\": false\n}", true)
                    deleteFile("pack.png")
                    Utils:setGariiData("levelRevealed", true)
                end
            end
        end
        if (songNameFmt == "twenty-sixteen") and Utils:getGariiData("secretFinished") == nil then
            saveFile(folDir.."weeks/extras.json", "{\n\"storyName\": \"Garii's Xtras\", \n\"difficulties\": \"‿\", \n\"hideFreeplay\": false, \n\"weekBackground\": \"stage\", \n\"freeplayColor\": [146,113,253], \n\"weekBefore\": \"tutorial\", \n\"startUnlocked\": true, \n\"weekCharacters\": [\"dad\", \"bf\", \"gf\"], \n\"songs\": [[\"Twenty-Sixteen\", \"sixteenfree\", [143, 199, 155]]], \n\"hideStoryMode\": true, \n\"weekName\": \"GarXtras\", \n\"hiddenUntilUnlocked\": false\n}", true)
            Utils:setGariiData("secretFinished", true)
        end
    end

    endSong()
    Utils:setWindowTitle(defWindowTitle) --resets window title
    Utils:setGariiData("storyStats", nil)
    if (not getModSetting('sauceLock')) then Utils:setGariiData("curSauce", nil) end  --makes the game prompt for a difficulty selection again.
end

function Utils:getGariiData(varName)
    return getDataFromSave(saveDir, varName);
end

function Utils:setGariiData(varName, arg)
    setDataFromSave(saveDir, varName, arg)
    flushSaveData(saveDir)
end

function Utils:tableContains(tab, varnm)
    if (#tab < 1) then return false end
    for _, val in pairs(tab) do if val == varnm then 
        return true
    end end
    return false
end

function Utils:mergeTables(first, second)
    local master = first
    for i,v in ipairs(second) do
        table.insert(master,v)
    end
    return master
end

function Utils:removePortion(tab, max)
    local tabel = tab
    while #tabel > max do table.remove(tabel, #tabel) end
    return tabel
end

function Utils:subtablesContains(tab, index, varnm)
    if (#tab < 1) then return false end
    for _, val in pairs(tab) do 
        local actval = val[index]
        if actval == varnm then 
            return true
        end 
    end
    return false
end

function Utils:strToNumIndex(tab, ind)
    local counter = 1
    for key,_ in pairs(tab) do
        if (counter == ind) then return key end
        debugPrint(counter)
        counter = counter + 1
    end
    return nil
end

function Utils:toStr(str)
    if type(t) == 'table' then
        local s = '{'
        if is_array(t) then
          for i, v in ipairs(str) do
            if #s > 1 then s = s .. ', ' end
            s = s .. Utils:toStr(v)
          end
        else
          -- It's a non-array table.
          for k, v in pairs(t) do
            if #s > 1 then s = s .. ', ' end
            s = s .. Utils:toStr(k)
            s = s .. ' = '
            s = s .. Utils:toStr(v)
          end
        end
        s = s .. '}'
        return s
      elseif type(str) == 'number' then
        return tostring(str)
      elseif type(str) == 'boolean' then
        return tostring(str)
      elseif type(str) == 'string' then
        return t
      end
      return 'unknown type'
end

function Utils:removeAllOf(tab, var)
    local fixedtab = {}
    for k,v in pairs(tab) do
        local mini = v
        if (Utils:tableContains(mini, var)) then
            table.remove(mini, Utils:indexOf(mini,var))
        end
        table.insert(fixedtab, mini)
    end
    return fixedtab
end

function Utils:indexOf(tab, varnm)
    for i,val in pairs(tab) do
        if (varnm == val) then return i end
    end
    return nil
end

function Utils:getHeat(shorten, heat)
    heat = heat or Utils:getGariiData("curSauce")
    local heats = {"Whire's Gentle Zest", "Hoppin' Honey-Mustard", "Outburst", "Garden Grown Habanero", "Shit The Bed", "Solar Flare" ,"Suxxors Secret Sauce"}
    local heatsht = {"Whire's Zest", "Hoppin' HM", "Outburst", "GG Haba", "Shit Bed", "Sol Flare" ,"Triple S"}
    if (shorten) then return heatsht[heat]
    else return heats[heat]
    end
end

function Utils:disableHUD(fuckasses) --hopefully reduces lag from existing components 
    for i, hudspr in ipairs(fuckasses) do
        setProperty(hudspr..".visible", false)
        setProperty(hudspr..".active", false)
    end
end

function Utils:shuffle(tab)
    local maxval = #tab

    for i=1,#tab do
        local j = getRandomInt(i, maxval)
        local tmp = tab[i]
        tab[i] = tab[j]
        tab[j] = tmp
    end
    return tab
end

function Utils:numSuffix(int)
    local suffix = {[0] = "TH"; "ST", "ND", "RD", "TH"}
    local suf = suffix[math.min(int%10,4)]
    if (int > 10 and int < 20) then suf = "TH" end --i freaking love english
    return suf
end

function Utils:rmpToRng(val, inSt, inNd, nwSt, nwNd)
    return nwSt + (val - inSt) * ((nwNd - nwSt) / (inNd - inSt))
end

function Utils:putErThroughTheRinger(strp) --character file names need to be stripped of any modifiers for lotsa shit so i can think without having to make 50 million alt bubble files
    return stringSplit(stringSplit(stringSplit(stringSplit(Utils:lwrKebab(strp), "-nobrim")[1], "-nosunnies")[1], "-expert")[1], "-simple")[1]
end

function Utils:numToStr(nerm) -- converts a number/string to a table of strings. pretty handy.
    local strnerm = ""..nerm 
    local numtbl = {}

    local skipThisNum = -1
    for i = 1,#strnerm do
        if (i ~= skipThisNum) then
            if (string.byte(string.sub(strnerm, i, i)) > 127) then
                table.insert(numtbl, string.sub(strnerm, i, i+1))
                skipThisNum = i+1
            else table.insert(numtbl, string.sub(strnerm, i, i))
            end
        end
    end

    return numtbl
end

function Utils:convColours(rgb)
	local hexadecimal = ''

	for key, value in pairs(rgb) do
		local hex = ''
		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex			
		end
		if(string.len(hex) == 0)then
			hex = '00'
		elseif(string.len(hex) == 1)then
			hex = '0' .. hex
		end
		hexadecimal = hexadecimal .. hex
	end
	return getColorFromHex(hexadecimal)
end

function Utils:quickFormatTxt(txt, font, size, clr, bordersize, borderclr)
    setTextFont(txt, font)
    setTextBorder(txt, bordersize, borderclr)
    setTextSize(txt, size)
    setTextColor(txt, clr)
end

function Utils:newCountdown(count) --something thats needed as gariis mod starts on a pickup beat
    if (countdownChecks[count]) then return end

    if (count == 0) then Utils:playSound('intro3')
    elseif (count == 1) then 
        Utils:playSound('intro2')
        makeCountSpr("Ready")
    elseif (count == 2) then 
        Utils:playSound('intro1')
        makeCountSpr("Set")
    elseif (count == 3) then 
        Utils:playSound('introGo')
        makeCountSpr("Go")
    end
    countdownChecks[count] = true --countdown checks are a thing because sometimes this function is called more than it should be
end

function makeCountSpr(count)  
    makeLuaSprite('count'..count, "borderlineUI/"..count:lower(),0,0)
    Utils:setObjectCamera('count'..count, 'hud')
    screenCenter('count'..count, 'xy')
    addLuaSprite('count'..count)
    doTweenAlpha('count'..count, 'count'..count, 0, 60 / curBpm, 'cubeInOut')
end

function Utils:lerp(base, target, ratio) return base + ((ratio * (60/framerate)) * (target - base)) end --lerp!
function Utils:remove() setmetatable(self, nil) end
function Utils:lwrKebab(text) if (text ~= nil) then return text:lower():gsub(" ", "-") end end
function Utils:round(numbaj) return math.floor(numbaj + 0.5) end
function Utils:mouseWithinBounds(bnds, cam) return (getMouseX(cam) >= bnds[1] and getMouseX(cam) <= bnds[3] and getMouseY(cam) >= bnds[2] and getMouseY(cam) <= bnds[4]) end
function Utils:keyListPressed(keys)
    local pressed = false
    for _,key in pairs(keys) do  if (keyboardJustPressed(key)) then 
        pressed = true
    end end
    return pressed
end
function Utils:trc(msg, lvl) --making this system the norm instead of just debugprint as it hides the messages when not in debug mode which is really damn handy
    if (true) then return end
    lvl = lvl or 0  --"lvl" is the level of severity of the message, with 0 being none, 1 being good, 2 being non-fatal, and 3 being fatal
    local shits = {[0] = "9AD6FF", "8FC79B", "F4F3AD", "A284B9"}
    local butts = {[0] = "(i)", "(+)", "[!]", "{x}"}

    debugPrint(butts[lvl].." "..msg, shits[lvl])
end
function Utils:extractNum(txt)
    local str = ""
    string.gsub(txt,"%d+",function(e)
     str = str .. e
    end)
    return tonumber(str)
end

function Utils:makeBlankBG(name, width,height, colour, cam)
    removeLuaSprite(name)
    makeLuaSprite(name,'',0,0)
    makeGraphic(name, 1, 1, colour)
	setScrollFactor(name, 0, 0)
	scaleObject(name, width,height)
	screenCenter(name)
    if (cam ~= nil) then Utils:setObjectCamera(name, cam) end
    addLuaSprite(name)
end

function Utils:setObjectCamera(spr, cam) --why do i have to do this period psych engine stay consistent in your fucking updates i hate you
    if (version == "1.0" or version == "1.0-prerelease") then
        local camerafix = ""
        if (cam:lower() == "camhud" or cam:lower() == "hud") then camerafix = "camHUD"
        elseif (cam:lower() == "camother" or cam:lower() == "other") then camerafix = "camOther"
        else camerafix = "camGame"
        end
        setProperty(spr..".camera", instanceArg(camerafix), false, true)
    else setObjectCamera(spr, cam)
    end
end

function Utils:runHaxeCode(code, args, funcs, funcArgs)
    if (version == "1.0" or version == "1.0-prerelease") then
        Utils:trc("utils: Failed to run haxe code. v1.0 sucks lole!", 3)
    else runHaxeCode(code, args, funcs, funcArgs)
    end
end

function Utils:copyTable(t)
    local u = { }
    for k, v in pairs(t) do u[k] = v end
    return setmetatable(u, getmetatable(t))
end

function Utils:formatDigit(num)
    if (num < 10) then return "0"..num end
    return num
end

function Utils:copyTableTable(t)
    local u = {{}}
    for i, v in ipairs(t) do 
        local h = v
        for j, k in ipairs(h) do 
            local t = k
            u[i][j] = t
        end
    end
    return setmetatable(u, getmetatable(t))
end

function Utils:tableLen(t)
    local l = 0
    for i,_ in pairs(t) do
        l = l + 1
    end
    return l
end

function Utils:getSprAnimationName(spr)
    local isSinging = ""
    if (stringStartsWith(version, "1.0")) then isSinging = callMethod(spr..".getAnimationName")
    else
        isSinging = getProperty(spr..".animation.curAnim.name")
        if (isSinging == nil) then getProperty(spr..".atlas.anim.lastPlayedAnim") end
    end
    debugPrint(isSinging)
    return isSinging
end

function Utils:precacheCharList(chr, tab)
    local originalChar = getProperty(chr..".curCharacter")
    for spr,_ in pairs(tab) do
        triggerEvent("Change Character", chr, spr)
    end
    triggerEvent("Change Character", chr, originalChar)
end

function Utils:getKeyFromBind(key, number)
    number = number or 1
    return callMethodFromClass("backend.InputFormatter", "getKeyName", {getProperty("controls.keyboardBinds")[key][number]})
end

function Utils:playSound(file, vol, tag) --for any menus that literally pause the game lole (achievements menu)- from what i know theres no way to grab a list of sounds that are currently playing
    if (not checkFileExists("sounds/"..file..".ogg")) then return end
    if (tag == nil) then tag = "soundNil_"..getRandomInt() end
    Utils:cleanSoundList()
    local soundList = getVar("soundList") or {}
    playSound(file, vol, tag)
    table.insert(soundList, tag)
    setVar("soundList", soundList)
end

function Utils:cleanSoundList() --lol?
    local soundList = getVar("soundList") or {}
    for i,snd in pairs(soundList) do
        if (not luaSoundExists(snd)) then table.remove(soundList, i) end
    end
    setVar("soundList", soundList)
end

function Utils:stopAllKnownSounds()
    Utils:cleanSoundList()
    local soundList = getVar("soundList") or {}
    for _,snd in pairs(soundList) do
        if (luaSoundExists(snd)) then
            stopSound(snd)
        end
    end
end

function Utils:pauseAllKnownSounds()
    Utils:cleanSoundList()
    local soundList = getVar("soundList") or {}
    for _,snd in pairs(soundList) do
        if (luaSoundExists(snd)) then
            pauseSound(snd)
        end
    end
end

function Utils:resumeAllKnownSounds()
    Utils:cleanSoundList()
    local soundList = getVar("soundList") or {}
    for _,snd in pairs(soundList) do
        if (luaSoundExists(snd)) then
            resumeSound(snd)
        end
    end
end

return Utils