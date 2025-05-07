local utils = (require (getVar("folDir").."scripts.backend.utils")):new() --ough we love utils
local fonts = {
    ["poker-freak"] = {name = "poker-freak", width = 15, height = 21, antialiasing = false, animated = false},
    ["rom-byte"] = {name = "rom-byte", width = 8, height = 8, disableLowercase = true, antialiasing = false, animated = false},
    ["lumeglyph"] = {name = "lumeglyph", dynamicSize = true, animateNames = true, antialiasing = true, randomSpacing = {0,1}, animated = true}
}
local loadedFont = {}
local Font = {}
local rawAlphaNumerals = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ",", ".", "!", "?", ":", "<", ">", "+", "-", "%", "'", "(", ")", '"', "/", "©"}
local sheetNames = {["0"] = "zero", ["1"] = "one", ["2"] = "two", ["3"] = "three", ["4"] = "four", ["5"] = "five", ["6"] = "six", ["7"] = "seven", ["8"] = "eight", ["9"] = "nine", ["!"] = "exclamation", [","] = "comma", ["."] = "period", ["?"] = "question", [":"] = "colon", ["<"] = "less than", [">"] = "greater than", ["+"] = "plus", ["-"] = "minus", ['"'] = "quotations", ["©"] = "copyright"} --any characters that need special names
local animateFixedNames = {["/"] = "slash", ["\\"] = "backslash"}
local excemptDynamicPos = {
    ["lumeglyph"] = {["'"] = {y = 0}, ["p"] = {y = 11}, ["q"] = {y = 11}, ["g"] = {y = 11}, ["y"] = {y = 11}}
}
list = {}
atts = {}

function Font:new(calledFont)
    local self = setmetatable({}, {__index = self})
    loadedFont = fonts[calledFont] or "poker-freak"
    return self
end

function Font:loadFont(calledFont)
    loadedFont = fonts[calledFont]
end

function Font:createNewText(name, dax,day, txt, algnmnt, clr, camra)
    if (txt == nil) then txt = " " end
    if (algnmnt == nil) then algnmnt = "LEFT" end
    if (clr == nil) then clr = "FFFFFF" end --defaults
    if (camra == nil) then camra = "other" end

    if (#txt > 0) then
        local splttxt = utils:numToStr(txt)
        local chrx = dax
        local biggestChar = 0
        for i,chr in pairs(splttxt) do
            if (loadedFont.dynamicSize == nil) then
                chrx = dax + ((i-1) * loadedFont.width)
                if (algnmnt:lower() == "right") then chrx = (dax + ((i-1) * (loadedFont.width))) - (loadedFont.width * #txt) end
            end
            makeAnimatedLuaSprite(name..i, "fonts/"..loadedFont.name,chrx, day)
            addAnimations(name..i)
            setChar(name..i, chr)
            setProperty(name..i..".x", chrx)
            if (loadedFont.dynamicSize ~= nil) then
                if (loadedFont.randomSpacing ~= nil) then chrx = chrx + getProperty(name..i..".frameWidth") + getRandomFloat(loadedFont.randomSpacing[1], loadedFont.randomSpacing[2])
                else chrx = chrx + getProperty(name..i..".frameWidth") + 4
                end
                if (getProperty(name..i..".frameHeight") > biggestChar) then biggestChar = getProperty(name..i..".frameHeight") end
            end
            setProperty(name..i..".antialiasing", loadedFont.antialiasing)
            setProperty(name..i..".active", loadedFont.animated)
            setProperty(name..i..".color", getColorFromHex(clr))
            utils:setObjectCamera(name..i, camra)
            addLuaSprite(name..i)
            if (i > 1) then setObjectOrder(name..i, getObjectOrder(name.."1")) end
        end

        if (loadedFont.dynamicSize ~= nil) then
            for i,chr in pairs(splttxt) do
                if (excemptDynamicPos[loadedFont.name][chr] ~= nil) then setProperty(name..i..".y", day + excemptDynamicPos[loadedFont.name][chr].y)
                else setProperty(name..i..".y", day + (biggestChar - getProperty(name..i..".frameHeight")))
                end
            end
        end
    end
    
    table.insert(list, name)
    local txtAtts = {x = dax, y = day, text = txt, alignment = algnmnt:lower(), color = clr, length = #txt, maxlength = #txt, scalex = 1, scaley = 1, visible = true, alpha = 1, cam = camra, font = loadedFont.name}
    atts[name] = txtAtts
end

function addAnimations(name, curFont)
    if (curFont == nil) then curFont = loadedFont end
    for i,chr in pairs(rawAlphaNumerals) do
        local suffix = " "
        if (curFont.animateNames ~= nil) then suffix = " char" end
        if (chr:match("%a")) then --upper and lowercase
            if (curFont.animateNames ~= nil) then
                addAnimationByPrefix(name, chr:upper(), "upper "..chr..suffix)
                addAnimationByPrefix(name, chr:lower(), "lower "..chr..suffix)
            else
                addAnimationByPrefix(name, chr:upper(), chr:upper()..suffix)
                addAnimationByPrefix(name, chr:lower(), chr:lower()..suffix)
            end
        else
            local shtName = chr
            if (curFont.animateNames ~= nil and animateFixedNames[chr] ~= nil) then shtName = animateFixedNames[chr]
            elseif (sheetNames[chr] ~= nil) then shtName = sheetNames[chr]
            end
            addAnimationByPrefix(name, chr, shtName..suffix)
        end
    end
end

function setChar(name, chr)
    if (chr == " ") then 
        playAnim(name, "o")
        setProperty(name..".visible", false)
        setProperty(name..".active", false)
    else setProperty(name..".visible", true)
        setProperty(name..".active", true)
        playAnim(name, chr)
    end
end

function Font:setTextX(name, newx)
    if (newx == atts[name].x) then return end
    local dynamicX = newx
    for i=1,atts[name].length do
        if (fonts[atts[name].font].dynamicSize) then
            setProperty(name..i..".x", dynamicX)
            if (fonts[atts[name].font].randomSpacing ~= nil) then dynamicX = dynamicX + getProperty(name..i..".frameWidth") + (getRandomFloat(fonts[atts[name].font].randomSpacing[1], fonts[atts[name].font].randomSpacing[2]) * atts[name].scalex)
            else dynamicX = dynamicX + getProperty(name..i..".frameWidth") + (4 * atts[name].scalex)
            end
        else
            if (atts[name].alignment == "right") then setProperty(name..i..".x", (newx + ((i-1) * (fonts[atts[name].font].width * atts[name].scalex))) - (fonts[atts[name].font].width * atts[name].length * atts[name].scalex))
            else setProperty(name..i..".x", newx + ((i-1) * (fonts[atts[name].font].width * atts[name].scalex)))
            end
        end
    end
    atts[name].x = newx
end

function Font:setTextY(name, newy)
    if (newy == atts[name].y) then return end
    if (fonts[atts[name].font].dynamicSize) then
        local biggestChar = 0
        for i=1,atts[name].length do
            if (getProperty(name..i..".frameHeight") > biggestChar) then biggestChar = getProperty(name..i..".frameHeight") end
        end
        local splttxt = utils:numToStr(atts[name].text)
        for i,chr in pairs(splttxt) do
            if (excemptDynamicPos[atts[name].font][chr] ~= nil) then setProperty(name..i..".y", newy + (excemptDynamicPos[atts[name].font][chr].y * atts[name].scaley))
            else setProperty(name..i..".y", newy + (biggestChar - getProperty(name..i..".frameHeight")))
            end
        end
    else
        for i=1,atts[name].length do
            setProperty(name..i..".y", newy)
        end
    end
    atts[name].y = newy
end

function Font:setTextCamera(name, newcam)
    if (newcam == atts[name].cam) then return end
    for i=1,atts[name].length do
        utils:setObjectCamera(name..i, newcam)
    end
    atts[name].cam = newcam
end

function Font:tweenTextX(name, newx, time, ease)
    for i=1,atts[name].length do
        doTweenX(name..i.."x", name..i, newx + (getProperty(name..i..".x") - atts[name].x), time, ease)
    end
    atts[name].x = newx
end

function Font:tweenTextY(name, newy, time, ease)
    for i=1,atts[name].length do
        doTweenY(name..i.."y", name..i, newy, time, ease)
    end
    atts[name].y = newy
end

function Font:tweenTextAlpha(name, newalpha, time, ease)
    for i=1,atts[name].length do
        doTweenAlpha(name..i.."alpha", name..i, newalpha, time, ease)
    end
    atts[name].alpha = newalpha
end

function Font:setTextString(name, txt)
    txt = txt or " "
    if (txt == atts[name].text) then return end
    local leg = atts[name].length
    local splttxt = utils:numToStr(txt)
    local dynamicX = atts[name].x
    local biggestChar = 0
    if (#splttxt > leg) then leg = #splttxt end
    
    for i= 1,leg do
        if (not luaSpriteExists(name..i)) then
            makeAnimatedLuaSprite(name..i, "fonts/"..atts[name].font,0, atts[name].y)
            addAnimations(name..i, fonts[atts[name].font])
            setProperty(name..i..".antialiasing", false)
            setProperty(name..i..".visible", atts[name].visible)
            setProperty(name..i..".color", getColorFromHex(atts[name].color))
            setProperty(name..i..".active", fonts[atts[name].font].animated)
            scaleObject(name..i, atts[name].scalex, atts[name].scaley)
            updateHitbox(name..i)
            utils:setObjectCamera(name..i, atts[name].cam)
            addLuaSprite(name..i, true)
            if (i > 1) then setObjectOrder(name..i, getObjectOrder(name.."1")) end
        end
        
        if (i > #splttxt) then removeLuaSprite(name..i, true)
        else setChar(name..i, splttxt[i])
            setProperty(name..i..".visible", atts[name].visible and splttxt[i] ~= " ")
            setProperty(name..i..".alpha", atts[name].alpha)

            if (fonts[atts[name].font].dynamicSize) then
                setProperty(name..i..".x", dynamicX)
                if (fonts[atts[name].font].randomSpacing ~= nil) then dynamicX = dynamicX + getProperty(name..i..".frameWidth") + (getRandomFloat(fonts[atts[name].font].randomSpacing[1], fonts[atts[name].font].randomSpacing[2]) * atts[name].scalex)
                else dynamicX = dynamicX + getProperty(name..i..".frameWidth") + (4 * atts[name].scalex)
                end
                if (getProperty(name..i..".frameHeight") > biggestChar) then biggestChar = getProperty(name..i..".frameHeight") end
            else
                if (atts[name].alignment == "right") then setProperty(name..i..".x", (atts[name].x + ((i-1) * (fonts[atts[name].font].width * atts[name].scalex))) - (fonts[atts[name].font].width * #splttxt * atts[name].scalex))
                else setProperty(name..i..".x", atts[name].x + ((i-1) * (fonts[atts[name].font].width * atts[name].scalex)))
                end
            end
        end
    end
    if (fonts[atts[name].font].dynamicSize) then
        for i,chr in pairs(splttxt) do
            if (excemptDynamicPos[atts[name].font][chr] ~= nil) then setProperty(name..i..".y", atts[name].y + (excemptDynamicPos[atts[name].font][chr].y * atts[name].scaley))
            else setProperty(name..i..".y", atts[name].y + (biggestChar - getProperty(name..i..".frameHeight")))
            end
        end
    end
    atts[name].text = txt
    atts[name].length = #splttxt
    if (#splttxt > atts[name].maxlength) then  atts[name].maxlength = #splttxt end
end

function Font:setTextScale(name, scalx, scaly)
    if (scalx == atts[name].scalex and scaly == atts[name].scaley) then return end
    local dynamicX = atts[name].x
    local biggestChar = 0
    for i=1,atts[name].length do
        scaleObject(name..i, scalx, scaly)
        updateHitbox(name..i)
        if (fonts[atts[name].font].dynamicSize) then
            setProperty(name..i..".x", dynamicX)
            if (fonts[atts[name].font].randomSpacing ~= nil) then dynamicX = dynamicX + getProperty(name..i..".frameWidth") + (getRandomFloat(fonts[atts[name].font].randomSpacing[1], fonts[atts[name].font].randomSpacing[2]) * scalx)
            else dynamicX = dynamicX + getProperty(name..i..".frameWidth") + (4 * scalx)
            end
        else
            if (atts[name].alignment == "right") then setProperty(name..i..".x", (atts[name].x + ((i-1) * (fonts[atts[name].font].width * scalx))) - (fonts[atts[name].font].width * atts[name].length * scalx))
            else setProperty(name..i..".x", atts[name].x + ((i-1) * (fonts[atts[name].font].width * scalx)))
            end
        end
        if (fonts[atts[name].font].dynamicSize) then
            for i=1,atts[name].length do
                if (getProperty(name..i..".frameHeight") > biggestChar) then biggestChar = getProperty(name..i..".frameHeight") end
            end
        else
            setProperty(name..i..".y", atts[name].y)
        end
    end
    if (fonts[atts[name].font].dynamicSize) then
        local splttxt = utils:numToStr(atts[name].text)
        for i,chr in pairs(splttxt) do
            if (excemptDynamicPos[atts[name].font][chr] ~= nil) then setProperty(name..i..".y", atts[name].y + (excemptDynamicPos[atts[name].font][chr].y * atts[name].scaley))
            else setProperty(name..i..".y", atts[name].y + (biggestChar - getProperty(name..i..".frameHeight")))
            end
        end
    end
    atts[name].scalex = scalx
    atts[name].scaley = scaly
end

function Font:setTextVisible(name, visible)
    for i=1,atts[name].length do
        setProperty(name..i..".visible", visible and utils:numToStr(atts[name].text)[i] ~= " ")
    end
    atts[name].visible = visible
end

function Font:setTextAlpha(name, alpha)
    for i=1,atts[name].length do
        setProperty(name..i..".alpha", alpha)
    end
    atts[name].alpha = alpha
end

function Font:setTextColour(name, clr)
    for i=1,atts[name].length do
        setProperty(name..i..".color", getColorFromHex(clr))
    end
    atts[name].color = clr
end

function Font:screenCenter(name, axis)
    axis = axis or "XY"

    if (axis:match("X") or axis:match("x")) then
        for i=1,atts[name].length do
            setProperty(name..i..".x", ((screenWidth - (atts[name].length * (fonts[atts[name].font].width * atts[name].scalex))) / 2) + ((i-1) * (fonts[atts[name].font].width * atts[name].scalex)))
        end
        atts[name].x = ((screenWidth - (atts[name].length * (fonts[atts[name].font].width * atts[name].scalex))) / 2)
    end
    if (axis:match("Y") or axis:match("y")) then
        for i=1,atts[name].length do
            setProperty(name..i..".y", (screenHeight - getProperty(name..i..".frameHeight")) / 2)
        end
        atts[name].y = (screenHeight - getProperty(name.."1.frameHeight")) / 2
    end
end

function Font:textExists(name) return (utils:indexOf(list, name) ~= nil) end
function Font:getTextX(name) return atts[name].x end
function Font:getTextY(name) return atts[name].y end
function Font:getTextLength(name) return atts[name].length end
function Font:getTextVisible(name) return atts[name].visible end
function Font:sheetName(name) return sheetNames[name] end

function Font:removeText(name, destroy)
    if (utils:indexOf(list, name) == nil) then return end
    
    destroy = destroy or true
    for i = 1,atts[name].maxlength do
        removeLuaSprite(name..i, destroy)
    end
    table.remove(list, utils:indexOf(list, name))
    atts[name] = nil
end

function Font:destroyAll()
    for _,txt in pairs(list) do
        for i = 1,atts[txt].maxlength do
            removeLuaSprite(txt..i, true)
        end
    end
    list = {}
    atts = {}
end

return Font