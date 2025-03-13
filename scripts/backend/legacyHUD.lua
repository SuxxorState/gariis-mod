local hudFld = "legacyUI/"
local utils = (require (getVar("folDir").."scripts.backend.utils")):new()

local lasthp = -1
local maxhp = 10001
local hpx = 1165
local hpy = 10
local maxsouls = 5
local soulsleft = maxsouls

function onCreatePost() --in general this hud kinda fucking sucks however thats the spirit of the song so it fits
    setProperty('showComboNum', false)
    setProperty('showRating', false)
    utils:disableHUD({"healthBar", "scoreTxt", "timeBar", "timeTxt"})

    for i = 0, getProperty("unspawnNotes.length")-1 do
        setPropertyFromGroup("unspawnNotes", i, "multAlpha", 1)
    end
    
    local barpos = {screenWidth - 550, 40}
    if (downscroll) then barpos = {100, screenHeight - 85} end
    makeAnimatedLuaSprite("hpbarback", hudFld.."hudnums", barpos[1]-10, barpos[2])
    addAnimationByPrefix("hpbarback", "reg" ,"hp bar", 24, true)
    utils:setObjectCamera("hpbarback", 'hud')
    setProperty("hpbarback.flipX", downscroll)
    addLuaSprite("hpbarback")
    
    makeAnimatedLuaSprite("hpbarfill", hudFld.."hudnums", barpos[1], barpos[2]-4)
    addAnimationByPrefix("hpbarfill", "reg" ,"bar fill", 24, true)
    utils:setObjectCamera("hpbarfill", 'hud')
    setProperty("hpbarfill.flipX", downscroll)
    addLuaSprite("hpbarfill")

    if downscroll then hpx = 440
        hpy = screenHeight - 40 
    end
    local maxnum = utils:numToStr(maxhp)
    for i = 0,#maxnum-1 do
        makeAnimatedLuaSprite("hudnumdyn"..i, hudFld.."fishbones", (hpx - (((#maxnum * 2)+1) * 25)) + (25 * i), hpy)
        makeAnimatedLuaSprite("hudnumstc"..i, hudFld.."fishbones", (hpx - (#maxnum * 25)) + (25 * i), hpy)
        for j = 0,9 do
            local numnames = {"zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}
            for k = 1,3 do
                addAnimationByPrefix("hudnumdyn"..i, j.."-"..k, numnames[j+1]..k, 24, true)
                addAnimationByPrefix("hudnumstc"..i, j.."-"..k, numnames[j+1]..k, 24, true)
            end
        end
        utils:setObjectCamera("hudnumdyn"..i, 'hud')
        utils:setObjectCamera("hudnumstc"..i, 'hud')
        addLuaSprite("hudnumdyn"..i)
        addLuaSprite("hudnumstc"..i)
    end
        
    makeAnimatedLuaSprite("hudlbl", hudFld.."fishbones", (hpx - ((#maxnum * 2)+3) * 25), hpy)
    addAnimationByPrefix("hudlbl", "reg" ,"hp text", 24, true)
    utils:setObjectCamera("hudlbl", 'hud')
    addLuaSprite("hudlbl")

    makeAnimatedLuaSprite("hudnumsls", hudFld.."fishbones", (hpx - ((#maxnum+1) * 25)) + 5, hpy)
    addAnimationByPrefix("hudnumsls", "reg" ,"slash", 24, true)
    utils:setObjectCamera("hudnumsls", 'hud')
    addLuaSprite("hudnumsls")

    makeAnimatedLuaSprite("scrtxt", hudFld.."fishbones", screenWidth - 400, 10)
    addAnimationByPrefix("scrtxt", "reg" ,"score", 24, true)
    utils:setObjectCamera("scrtxt", 'hud')
    --addLuaSprite("scrtxt")
    
    makeAnimatedLuaSprite("scrnum0", hudFld.."fishbones", screenWidth - 285, 10)
    for j = 0,9 do
        local numnames = {"zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}
        addAnimationByPrefix("scrnum0", ""..j ,numnames[j+1].."1", 24, true)
    end
    addAnimationByPrefix("scrnum0", "-" ,"negative", 24, true)
    playAnim("scrnum0", "0")
    utils:setObjectCamera("scrnum0", 'hud')
    --addLuaSprite("scrnum0")

    local bigframe = 0
    local souly = screenHeight - 70
    if (downscroll) then souly = 20 end
    for i = 1,maxsouls do
        local ranom = getRandomInt(1,5)
        local solpos = 75 + (65 * i)
        if (downscroll) then solpos = (screenWidth - 155) - (65 * i) end

        makeAnimatedLuaSprite("soul"..i, hudFld.."hudnums", solpos, souly)
        addAnimationByPrefix("soul"..i, "reg" ,"heart"..ranom, 24, true)
        addAnimationByPrefix("soul"..i, "break" ,"brokenheart"..ranom, 24, false)
        playAnim("soul"..i, "reg")
        if (getProperty("soul"..i..".frameHeight") > bigframe) then bigframe = getProperty("soul"..i..".frameHeight") end
        playAnim("soul"..i, "0")
        utils:setObjectCamera("soul"..i, 'hud')
        addLuaSprite("soul"..i)
    end
    for i = 1,maxsouls do
        setProperty("soul"..i..".y", souly + ((bigframe - getProperty("soul"..i..".frameHeight"))/2))
    end
    local comboy = souly - 60
    if (downscroll) then comboy = souly + 60 end
    makeAnimatedLuaSprite("combolbl", hudFld.."fishbones", (screenWidth - 305) + 25, comboy)
    addAnimationByPrefix("combolbl", "reg" ,"hits", 24, true)
    utils:setObjectCamera("combolbl", 'hud')
    addLuaSprite("combolbl")

    setProperty("iconP1.flipX", not downscroll)
    setProperty("iconP2.flipX", downscroll)
    onRecalculateRating()
end

function onUpdatePost()
    local iconsz = {"iconP1", "iconP2"}
    if downscroll then iconsz = {"iconP2", "iconP1"} end
    setProperty(iconsz[2]..".x", 0)
    setProperty(iconsz[2]..".y", screenHeight - 150)
    setProperty(iconsz[1]..".x", screenWidth - 150)
    setProperty(iconsz[1]..".y", 0)
    setProperty("iconP1.angle", utils:lerp(getProperty("iconP1.angle"), 0, 0.25))
    setProperty("iconP2.angle", utils:lerp(getProperty("iconP2.angle"), 0, 0.25))

    if (lasthp ~= getProperty("health")) then
        updateHealth()
    end

    if (keyboardJustPressed("I")) then
        breakSoul()
    end
end

local comboMaxLen = 0
function onRecalculateRating()
    local scrstr = utils:numToStr(score)

    for i = 1, #scrstr do
        if (not luaSpriteExists("scrnum"..(i-1))) then
            makeAnimatedLuaSprite("scrnum"..(i-1), hudFld.."fishbones", screenWidth - (285 - (25 * (i-1))), 10)
            for j = 0,9 do
                local numnames = {"zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}
                addAnimationByPrefix("scrnum"..(i-1), ""..j ,numnames[j+1].."1", 24, true)
            end
            utils:setObjectCamera("scrnum"..(i-1), 'hud')
            --addLuaSprite("scrnum"..(i-1))
        end
        playAnim("scrnum"..(i-1), ""..scrstr[i])
        setProperty("scrnum"..(i-1)..".y", 5 + (getProperty("scrtxt.frameHeight") - getProperty("scrnum"..(i-1)..".frameHeight")))
    end

    local comstr = utils:numToStr(combo)
    if (#comstr > comboMaxLen) then comboMaxLen = #comstr end
    local comboy = screenHeight - 130
    local combox = 305
    if (downscroll) then combox = screenWidth - 165
        comboy = 75
    end
    local exsub = (combox - ((#comstr * 25) + 85))

    if (combo < 5) then
        for i = 1, comboMaxLen do
            setProperty("comnum"..(i-1)..".visible", false)
            setProperty("combolbl.visible", false)
        end
    else
        setProperty("combolbl.visible", true)
        for i = 1, #comstr do
            if (not luaSpriteExists("comnum"..(i-1))) then
                makeAnimatedLuaSprite("comnum"..(i-1), hudFld.."fishbones", combox, comboy)
                for j = 0,9 do
                    local numnames = {"zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}
                    for k = 1,3 do
                        addAnimationByPrefix("comnum"..(i-1), j.."-"..k, numnames[j+1]..k, 24, true)
                    end
                end
                utils:setObjectCamera("comnum"..(i-1), 'hud')
                addLuaSprite("comnum"..(i-1))
            end
            playAnim("comnum"..(i-1), ""..comstr[i].."-"..getRandomInt(1,3))
            setProperty("comnum"..(i-1)..".y", comboy + (getProperty("combolbl.frameHeight") - getProperty("comnum"..(i-1)..".frameHeight")))
            setProperty("comnum"..(i-1)..".x", exsub)
            exsub = exsub + getProperty("comnum"..(i-1)..".frameWidth") + getRandomInt(3,6)
            setProperty("comnum"..(i-1)..".visible", true)
        end
        setProperty("combolbl.x", exsub + 10)
    end
end

function onBeatHit()
    local turnamt = 10
    if curBeat % 2 == 0 then
        setProperty("iconP1.angle", turnamt)
        setProperty("iconP2.angle", turnamt)
    else
        setProperty("iconP1.angle", -turnamt)
        setProperty("iconP2.angle", -turnamt)
    end
end

function breakSoul()
    if (soulsleft <= 0) then return end

    if (luaSpriteExists("soul"..soulsleft)) then
        playAnim("soul"..soulsleft, "break")
        setProperty("soul"..soulsleft..".x", getProperty("soul"..soulsleft..".x") - 4) -- i LOOOVE offsets and how they DONT DO THEM IN THE XML.
    end
    soulsleft = soulsleft - 1
end

function updateHealth()
    if (math.min(math.floor(maxhp * (lasthp/2)), maxhp) >= maxhp and lasthp <= getProperty("health")) then return end -- prevents number jitter when hp is at max

    lasthp = getProperty("health")

    scaleObject('hpbarfill', math.min((getProperty("health")/2), 1), 1)
    if not downscroll then setProperty("hpbarfill.x", 20 + getProperty("hpbarback.x") + ((getProperty("hpbarback.width") - 5) * (1 - math.min((getProperty("health")/2), 1)))) end

    local healthconv = math.max(0, math.min(math.floor(maxhp * (getProperty("health")/2)), maxhp))
    local maxnum = utils:numToStr(maxhp)
    local exsub = (hpx - (((#maxnum * 2)+1) * 25))
    local dynnum = utils:numToStr(healthconv)
    local starter = #maxnum - #dynnum 
    
    for i = 0,#maxnum-1 do
        playAnim("hudnumstc"..i, ""..maxnum[i+1].."-"..getRandomInt(1,3))
        setProperty("hudnumstc"..i..".y", hpy + (25 - getProperty("hudnumstc"..i..".frameHeight")))

        if (starter < (i+1)) then
            playAnim("hudnumdyn"..i, ""..dynnum[i+1-starter].."-"..getRandomInt(1,3))
            setProperty("hudnumdyn"..i..".y", hpy + (25 - getProperty("hudnumdyn"..i..".frameHeight")))
            setProperty("hudnumdyn"..i..".x", exsub)
            exsub = exsub + getProperty("hudnumdyn"..i..".frameWidth") + getRandomInt(3,6)
            setProperty("hudnumdyn"..i..".visible", true)
        else
            setProperty("hudnumdyn"..i..".visible", false)
        end
    end

    setProperty("hudnumsls.x", exsub + getRandomInt(4,8))
    exsub = exsub + getProperty("hudnumsls.frameWidth") + 10 + getRandomInt(3,6)

    for i = 0,#maxnum-1 do
        setProperty("hudnumstc"..i..".x", exsub)
        exsub = exsub + getProperty("hudnumstc"..i..".frameWidth") + getRandomInt(3,6)
    end

    if not downscroll then 
        local hptxtwidth = exsub - (hpx - (((#maxnum * 2)+1) * 25)) --grabs the entire width of the text

        for i = 0,#maxnum-1 do
            local indinumx = getProperty("hudnumdyn"..i..".x") - (hpx - (((#maxnum * 2)+1) * 25)) --grabs the individual alphanumeral pos without any x
            setProperty("hudnumdyn"..i..".x", (hpx - hptxtwidth) + indinumx)

            local indistcx = getProperty("hudnumstc"..i..".x") - (hpx - (((#maxnum * 2)+1) * 25)) --ditto
            setProperty("hudnumstc"..i..".x", (hpx - hptxtwidth) + indistcx)
        end

        local indislsx = getProperty("hudnumsls.x") - (hpx - (((#maxnum * 2)+1) * 25))
        setProperty("hudnumsls.x", (hpx - hptxtwidth) + indislsx)

        setProperty("hudlbl.x", (hpx - hptxtwidth) - 50)
    end
end