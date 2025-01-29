local garchar = ""

function onCreatePost()
    if (stringStartsWith(getProperty("dad.curCharacter"), "garii")) then garchar = "dad"
    elseif (stringStartsWith(getProperty("boyfriend.curCharacter"), "garii")) then garchar = "boyfriend"
    elseif (stringStartsWith(getProperty("gf.curCharacter"), "garii")) then garchar = "gf"
    end

    setProperty(garchar..'.idleSuffix', '-fake')
    playAnim(garchar, "idle-fake", true)
end

function onCountdownTick(counter)
	if (counter == 0) then
        setProperty(garchar..".stunned", true)
        if (songName:lower():gsub(" ", "-") ~= "fuzzy-dice") then
            characterPlayAnim(garchar, "equipGUN", true)
            setProperty(garchar..'.idleSuffix', '')
        else
            if (stringStartsWith(getProperty("boyfriend.curCharacter"), "gari-playable")) then  characterPlayAnim(garchar, "hey-alt", true)
            else characterPlayAnim(garchar, "hey-fake", true)
            end
        end
    elseif (counter == 3) then
        setProperty(garchar..".stunned", false)
    end
end

function onDestroy()
    callOnLuas("onDeleteBubble", {garchar})
end