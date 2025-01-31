local utils = (require (getVar("folDir").."scripts.backend.utils")):new() --debug text...
local bubbleloopin = "8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31"
local animDirs = {"Left", "Down", "Up", "Right"}
--variables dependent on the bubble
local bubbleChars = {}
local bubbleFiles = {}
local charBubbles = {}
local bubbleCharAnims = {}
local bubbleNotes = {}
local playerAct = {}
local bubbleCanLoop = {}
local bubbleAnims = {}

function onRequestBubble(chr) --checks to see if a txt file exists for a given character's bubble and goes off of that. did i really just softcode a softcode file system.
    local chrgrab = chr
    chr = getProperty(chr..".curCharacter") or chr --for the extra opp script, its gotta check if the char name is the var name of an actual char or not

    if (checkFileExists("images/bubbles/"..chr..".txt")) then
        local spltchrtxt = stringSplit(getTextFromFile("images/bubbles/"..chr..".txt").." ", "\n")
        local bublntes = {}
        local chranimz = {}
        local noteBubls = {"", "bubble-only"}
        local chrref = ""
        local bublpos = {}

        if (getProperty("dad.curCharacter") == chr) then chrgrab = "dad"
            bublpos = {defaultOpponentX, defaultOpponentY}
        elseif (getProperty("boyfriend.curCharacter") == chr) then chrgrab = "boyfriend"
            bublpos = {defaultBoyfriendX, defaultBoyfriendY}
        elseif (getProperty("gf.curCharacter") == chr) then chrgrab = "gf"
            bublpos = {defaultGirlfriendX, defaultGirlfriendY}
        else
            bublpos = {getProperty(chrgrab..".x"), getProperty(chrgrab..".y")}
            noteBubls = {chrgrab.."-note"}
        end
        if (chr == "garii") then noteBubls = {"", "bubble-only", "fake-alt-anim", "side-alt-anim", "snide-alt-anim", "angry-alt-anim", "done-alt-anim"}
        elseif (chr == "truckerboy-girl") then noteBubls = {"", "bubble-only", "smug-alt-anim", "confused-alt-anim"}
        elseif (chr == "truckerboy") then noteBubls = {"", "bubble-only", "confused-alt-anim"} end

        for i,ln in pairs(spltchrtxt) do
            local fln = string.sub(ln, 1, #ln-1) --removes the line break
            
            if (i == 1) then chrref = fln
            elseif (i == 2 and stringSplit(fln, ", ") ~= nil) then bublntes = stringSplit(fln, ", ")
            elseif (stringSplit(fln, ", ") ~= nil and #stringSplit(fln, ", ") > 1 and #fln > 1 and (not stringStartsWith(fln, "--"))) then
                local lnsplit = stringSplit(fln, ", ")

                if (#lnsplit > 3) then
                    local offtbl = {tonumber(lnsplit[3]), tonumber(lnsplit[4])}
                    table.remove(lnsplit, 4)
                    lnsplit[3] = offtbl
                end
                fln = lnsplit
                table.insert(chranimz, fln)
            end
        end
        onCreateBubble(chrgrab, bublpos[1], bublpos[2], chrgrab == "boyfriend" or chrgrab == "gf", chrgrab == "boyfriend" or chrgrab == "gf", chranimz, noteBubls, chrref)

    else utils:trc("bubbleHandler: ".."could not find bubble text file for "..chr, 2)
    end
end

function onCreateBubble(char, bublX, bublY, playable, loopable, bublanims, useableNotes, chroverride)
    if (chroverride ~= nil) then bubbleFiles[char] = chroverride
    elseif (char ~= "boyfriend" and char ~= "gf" and char ~= "dad") then bubbleFiles[char] = char
    else bubbleFiles[char] = getProperty(char..".curCharacter")  end
    table.insert(bubbleChars, char)
    playerAct[char] = playable
    bubbleCanLoop[char] = loopable
    charBubbles[bubbleFiles[char]] = bublanims
    bubbleCharAnims[char] = {}
    bubbleNotes[char] = {}
    for i, note in pairs(useableNotes) do bubbleNotes[char][utils:lwrKebab(note)] = true end

    makeAnimatedLuaSprite(char.."Bubbles", "bubbles/"..bubbleFiles[char], bublX, bublY)
    for i, anim in ipairs(charBubbles[bubbleFiles[char]]) do
        addAnimationByPrefix(char.."Bubbles", anim[1], anim[2], 22, false)
        addOffset(char.."Bubbles", anim[1], anim[3][1], anim[3][2])
        table.insert(bubbleCharAnims[char], anim[1])
        if loopable then
            addAnimationByIndices(char.."Bubbles", anim[1].."-loop", anim[2], bubbleloopin, 22, true) --for when the character is holding down a key after hitting a note.
            addOffset(char.."Bubbles", anim[1].."-loop", anim[3][1], anim[3][2])
            table.insert(bubbleCharAnims[char], anim[1].."-loop")
        end
    end
    setProperty(char.."Bubbles.alpha", 0)
	addLuaSprite(char.."Bubbles", true)
    utils:trc("bubbleHandler: ".."Made "..char.."Bubbles", 1)
end

function opponentNoteHit(id, dir, noteType, isSustainNote)
    for i,char in pairs(bubbleChars) do
        if bubbleNotes[char][utils:lwrKebab(noteType)] and (not playerAct[char]) then bubbleAnimatePose(char, dir, getPropertyFromGroup("notes", id, "animSuffix")) end
    end
end

function goodNoteHit(id, dir, noteType, isSustainNote)
    for i,char in pairs(bubbleChars) do
        if bubbleNotes[char][utils:lwrKebab(noteType)] and playerAct[char] then bubbleAnimatePose(char, dir, getPropertyFromGroup("notes", id, "animSuffix")) end
    end
end

function noteMiss(id, dir, noteType, isSustainNote)
    for i,char in pairs(bubbleChars) do
        if bubbleNotes[char][utils:lwrKebab(noteType)] and playerAct[char] then bubbleAnimatePose(char, dir, "miss"..getPropertyFromGroup("notes", id, "animSuffix")) end
    end
end

function noteMissPress(dir)
    for i,char in pairs(bubbleChars) do
        if playerAct[char] then bubbleAnimatePose(char, dir, "miss") end
    end
end

function onEvent(name, value1, value2, strumTime)
    local event = utils:lwrKebab(name)
    local val1 = utils:lwrKebab(value1)
    local val2 = utils:lwrKebab(value2)

    if (val2 == "bf") then val2 = "boyfriend" end
    if (val2 == "girlfriend") then val2 = "gf" end

    if (event == "play-animation") or (event == "extra-char-play-anim") then
        bubbleAnimate(val2, val1:upper())
    end
end

function bubbleAnimatePose(char, dir, suff)
    bubbleAnimate(char, (animDirs[dir+1]:upper())..suff, true)
end

function bubbleAnimate(char, anim)
    if not (utils:tableContains(bubbleCharAnims[char], "bubble"..anim)) then
        setProperty(char.."Bubbles.alpha", 0)
        return 
    end

    if (getModSetting('gariiDebug')) then setProperty(char.."Bubbles.alpha", getModSetting('bubbleOpacity'))
    else setProperty(char.."Bubbles.alpha", 1)
    end
    playAnim(char.."Bubbles", 'bubble'..anim, true)
    bubbleAnims[char] = 'bubble'..anim
end

function onUpdatePost(elp)
    for i,char in pairs(bubbleChars) do
        local shitass = (stringStartsWith(getProperty(char..".animation.curAnim.name"), "idle") or stringStartsWith(getProperty(char..".atlas.anim.lastPlayedAnim"), "idle"))
        if (stringStartsWith(version, "1.0.")) then shitass = (stringStartsWith(callMethod(char..".getAnimationName"), "idle")) end
        if (shitass) then --actually wait this is way simpler
            setProperty(char.."Bubbles.alpha", 0)
        end
        if getProperty(char.."Bubbles.animation.curAnim.finished") and bubbleCanLoop[char] then --why was i having trouble with this. why.
            playAnim(char.."Bubbles", bubbleAnims[char].."-loop", false)
        end
    end
end

function onDeleteBubble(char)
    if (luaSpriteExists(char.."Bubbles")) then
        removeLuaSprite(char.."Bubbles", true)
        utils:trc("bubbleHandler: Destroyed "..char.."Bubbles", 1)
    else utils:trc("bubbleHandler: "..char.."Bubbles".." does not exist.", 2)
    end
end