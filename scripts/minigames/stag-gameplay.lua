local utils = (require (getVar("folDir").."scripts.backend.utils")):new() 
local font = (require (getVar("folDir").."scripts.objects.fontHandler")):new("poker-freak")
local fld = "minigames/stag/"
local aFld, gFld, bFld = fld.."ambience/", fld.."garii/", fld.."brodcats/"
local chrList = {"slot", "carv", "hnte", "lino", "jack", "gari", "faze"}
local chrStats = {
    ["gari"] = {ai = 0, cam = 1, action = 1, atDoor = false, bored = 0, aggro = 0, aggroList = {}, cooldown = 5, presetAI = {7,3,4,5,10,12,20}, camOffsets = {
        {-7, -787,0}, {-6, -1045,-305}, {-5, -966,-211}, {-4, -438,0}, {-3, -1248,-286}, {-2, -483,-310}, {-1, 0,-315}, 
        {1, -377,-329}, {2, -809,-367}, {3, -277,-396}, {4, -917,-133}, {5, -628,-289}, {6, -882,-398}, {7, -532,-157}
    }},
    ["carv"] = {ai = 0, cam = 1, cooldown = 3, moveNum = 0, presetAI = {0,7,6,7,9,12,20}, camOffsets = {{1, -798,-598}, {2, -415,-360}, {3, 0,-416}, {4, -566, -130}, {5, -1098,-192}}},
    ["hnte"] = {ai = 0, cam = 3, stage = 1, cooldown = 6, camDelay = 0, presetAI = {0,6,5,3,8,11,20}, camOffsets = {{3, -373,-145}, {4, -429,-14}, {8, 0,-244}}},
    ["faze"] = {ai = 0, cam = 1, egoMeter = 0, timerRan = false, cooldown = 3, curPath = {}, memCam = 0, presetAI = {0,0,6,4,6,8,20}, camOffsets = {{1, -427,-637}, {2, -415,-580}, {3, -174,-246}, {4, -128,-229}, {5, -289,-448}, {6, -1100,-139}, {7, -77,-304}}},
    ["slot"] = {ai = 0, cam = 0, inOffice = false, cooldown = 15, presetAI = {0,0,1,2,4,6,20}, camOffsets = {{1, -704,-319}, {2, -1077,-327}, {3, -1112,-170}, {4, -222,-597}, {5, -1243,-273}, {6, -415,-400}, {7, -358,-274}}},
    ["lino"] = {ai = 0, cam = 1, cooldown = 7, presetAI = {0,0,0,8,6,10,20}, camOffsets = {{-2, -999,0}, {-1, -286,0}, {1, -618,-610}, {2, -691,-503}, {3, -697,0}, {5, 0,-179}, {6, -61,-264}, {7, -327,0}}},
    ["jack"] = {ai = 0, cam = 5, action = 1, polarity = false, usedSwitch = false, inOffice = false, lookMeter = 0, bored = 0, cooldown = 5, presetAI = {0,0,0,0,7,9,20}, camOffsets = {{-6, -1100,-229}, {-5, -979,-226}, {1, -651,-263}, {2, -211,-268}, {3, -958,-109}, {5, -756,-204}, {6, -693,-370}, {7, -734,-480}}}, 
}
local qtrCallLists = {
    {{"garimad", 3.8}, {"gariexit", 1}, {"garimad", 3.8}, {"garitime", 2.9}, {"garipissed"}},
    {{"garifakehappy", 2.4}, {"gariunhappy", 6.8}, {"garimad"}},
    {{"garitime", 1.2}, {"garimad", 12.7}, {"garipissed", 5.6}, {"gariugh", 3.2}, {"gariunhappy", 2.9}, {"fazesock", 2.2}, {"garimad", 2.8}, {"fazesock", 1.9}, {"garimad", 1.4}, {"gariunhappy", 1.4}, {"gariugh", 3.5}, {"gariunhappy"}},
    {{"gariphone", 7.3}, {"gariunhappy", 2.5}, {"garipoint", 2.7}, {"gariagree", 2}, {"garimad", 3.6}, {"garipissed", 1.9}, {"gariwtf"}},
    {{"gariyawn", 3.5}, {"garitired", 1.5}, {"gariunhappy", 3}, {"garicough", 2.7}, {"garitired", 2.3}, {"gariburp", 1}, {"garitired", 4}, {"gariunhappy", 3.6}, {"gariugh", 1.2}, {"gariunhappy", 3.2}, {"garitired"}},
    {{"goonscarv", 1.2}, {"goonshnte", 0.9}, {"goonscarv", 3.3}, {"goonshnte", 14.1}, {"goonscarv", 11.5}, {"goonshnte"}}
}
local curQtrCallList = {}
local qtrCallTime = 0
local pwrLoad = 0
local idleTime = 0
local curQtr, curTime, curPwr, curCam = 1, 0, 100, 1
local camUP,camCooldown, statUp,statCooldown = false,false, false,false
local camNames = {"Livingroom", "Anteroom", "Hallway N", "Storage Closet", "Family Room", "Hallway S", "Lavatory"}
local posiblDors = {"lef", "cen", "rig"}
local doorStats = {{active = false, disabled = false}, {active = false, disabled = false}, {active = false, disabled = false}}--each door in order > open status, disabled
local heatStats = {{active = false, disabled = false}, {active = false, disabled = false}, {active = false, disabled = false}}--work exactly the same as a door more or less
local canUpdate, hasPower = false, true
local blink = false
local jumpQueued = ""

function preloadGame(qtr, ais)
    curQtr = qtr
    for i,chr in pairs(chrList) do chrStats[chr].ai = chrStats[chr].presetAI[qtr] end
    if (ais ~= nil and #ais == 7) then for i,chr in pairs(chrList) do chrStats[chr].ai = ais[i] end end
    chrStats["gari"].cam,chrStats["jack"].cam,chrStats["lino"].cam,chrStats["faze"].cam = getRandomInt(1,7),getRandomInt(1,7,"4,5,6"),getRandomInt(2,6,"4,5"),getRandomInt(1,7)

    makeAssets()
end

function makeAssets()
    for _,snd in pairs({"6am", "ambience/ambience", "bangnoyell", "bangyell", "cameraflip", "cameraflipdown", "ambience/clicks", "congrat", "doordeny", "doorclose", "dooropen", "ambience/drip", "ambience/drippy", "hurt1", "hurt2", "hurt3", "jumpscare", "ambience/pop", "ambience/shh", "ambience/stupid", "ambience/stupidphoneihate","ambience/wind"}) do precacheSound(fld..snd) end

    utils:makeBlankBG("officeBlack", screenWidth,screenHeight, "000000", "hud")

    makeOneShotSpr('tvbg', "tvbg", nil, 831,265, 'hud', false)
    makeAnimatedLuaSprite('tvanims',fld..'tv',831,265)
    for _,anim in pairs({"gariexit", "garifakehappy", "garimad", "garipissed", "garitime", "garitv", "gariugh", "gariunhappy", "tvstatic", "fazesock", "gariagree", "gariwtf", "garipoint", "gariphone", "gariyawn", "garitired", "gariburp", "garicough", "goonscarv", "goonshnte"}) do
        addAnimationByPrefix('tvanims', anim, anim, 2, true)
    end
    setProperty("tvanims.visible", false)
    addLuaSprite('tvanims')
    utils:setObjectCamera('tvanims', 'hud')

    makeOneShotSpr('ofic', "ofic", nil, 0,0, 'hud')

    for _,dor in pairs({{"gari", 802,205}, {"carv", 637,235}, {"hnte", 1325,80}, {"slot", 876,282}, {"dorlef", 69,87}, {"dorcen", 504,205}, {"dorrig", 1413,111}, {"btnlef", 11, 317}, {"btncen", 465,324}, {"btnrig", 1452,304}, {"jack", 302,202}}) do
        makeOneShotSpr('ofic'..dor[1], 'ofic'..dor[1], nil, dor[2],dor[3], 'hud', false)
    end

    makeOneShotSpr('cameraBG', "cameratablet", nil, 278,-27, 'hud', false)

    makeAnimatedLuaSprite('cammain',fld..'cambgs',0, 0)
    for i = 1,7 do addAnimationByPrefix('cammain', "cam"..i, "cam0"..i, 24, true) end
    setProperty("cammain.visible", false)
    addLuaSprite('cammain')
    utils:setObjectCamera('cammain', 'other')

    for _,chr in pairs(chrList) do
        if (chrStats[chr].camOffsets ~= nil and chrStats[chr].ai > 0) then
            local ofsts = chrStats[chr].camOffsets
            precacheImage(fld..chr.."jumpscare")
            makeAnimatedLuaSprite('cam'..chr,fld..chr.."cams",0,0)
            for i = 1,#ofsts do addAnimationByPrefix('cam'..chr, ""..ofsts[i][1], chr..ofsts[i][1], 24, true) 
            addOffset("cam"..chr,""..ofsts[i][1], ofsts[i][2],ofsts[i][3]) end
            setProperty("cam"..chr..".visible", false)
            addLuaSprite('cam'..chr)
            utils:setObjectCamera('cam'..chr, 'other')
            runTimer(chr.."MO", chrStats[chr].cooldown + 5)
        end
    end
    makeOneShotSpr('fazeCamCover', "fazecamcover", nil, 0,0, 'other', false)
    
    makeOneShotSpr('cammap', "stag-cams", "cameramap", 957,365, 'other', false)
    makeOneShotSpr('vntmap', "stag-cams", "mapvents", 976,367, 'other', false)
    setProperty("vntmap.alpha", 0.3)

    for i,cam in pairs({{965,625}, {1157,632}, {1174,553}, {1229,472}, {1025,372}, {949,429}, {965,340}}) do
        makeAnimatedLuaSprite('cambtn'..i,fld.."stag-cams",cam[1],cam[2])
        addAnimationByPrefix('cambtn'..i, 'desel', "cam"..i.."desel", 24, true)
        addAnimationByPrefix('cambtn'..i, 'sel', "cam"..i.."sel", 24, true)
        playAnim("cambtn"..i, "desel")
        setProperty('cambtn'..i..".visible", false)
        addLuaSprite('cambtn'..i)
        utils:setObjectCamera('cambtn'..i, 'other')
    end

    makeOneShotSpr('camBtn', "cambumbup", nil, 0,0, 'hud')
    setProperty("camBtn.x", (screenWidth-getProperty("camBtn.width"))/2 + 300)
    setProperty("camBtn.y", screenHeight-(getProperty("camBtn.height") + 10))

    makeOneShotSpr('camBtnDwn', "cambumbdown", nil, 0,0, 'other', false)
    setProperty("camBtnDwn.x", (screenWidth-getProperty("camBtnDwn.width"))/2)
    setProperty("camBtnDwn.y", screenHeight-(getProperty("camBtnDwn.height") + 10))
    setProperty("camBtnDwn.alpha", 0.75)
    
    if (chrStats["lino"].ai > 0) then
        makeOneShotSpr('statBtn', "statbumbup", nil, 0,0, 'hud')
        setProperty("statBtn.x", (screenWidth-getProperty("statBtn.width"))/2 -300)
        setProperty("statBtn.y", screenHeight-(getProperty("statBtn.height") + 10))
            
        makeOneShotSpr('statBtnDwn', "statbumbdown", nil, 0,0, 'other', false)
        setProperty("statBtnDwn.x", (screenWidth-getProperty("statBtnDwn.width"))/2 -300)
        setProperty("statBtnDwn.y", screenHeight-(getProperty("statBtnDwn.height") + 10))
        setProperty("statBtnDwn.alpha", 0.75)

        makeOneShotSpr('statbg', "statuspanel", nil, 70,0, 'hud', false)
        setProperty("statbg.y", screenHeight-(getProperty("statbg.height")-20))
        
        makeOneShotSpr('statuslayout', "stag-cams", "cameramap", 227,365, 'other', false)
        makeOneShotSpr('statusvents', "stag-cams", "mapvents", 246,367, 'other', false)
        setProperty("statuslayout.color", getColorFromHex("DBAF85"))
        setProperty("statusvents.color", getColorFromHex("DBAF85"))
        setProperty("statuslayout.alpha", 0.25)
        setProperty("statusvents.alpha", 0.75)
        
        for i,door in pairs({{150,230}, {320,230}, {490,230}}) do
            makeAnimatedLuaSprite('statdoor'..i,fld.."stag-stats",door[1],door[2])
            addAnimationByPrefix('statdoor'..i, 'closed', "doorclosed", 24, true)
            addAnimationByPrefix('statdoor'..i, 'open', "dooropen", 24, true)
            addAnimationByPrefix('statdoor'..i, 'faulty', "doorfaulty", 24, true)
            addOffset('statdoor'..i, "closed", 0,0) --dude
            addOffset('statdoor'..i, "open", 0,0)
            addOffset('statdoor'..i, "faulty", 53,0)
            playAnim('statdoor'..i, "open")
            setProperty('statdoor'..i..".color", getColorFromHex("DBAF85"))
            setProperty('statdoor'..i..".visible", false)
            addLuaSprite('statdoor'..i)
            utils:setObjectCamera('statdoor'..i, 'other')
        end

        for i,heat in pairs({{280,516}, {243,424}, {444,560}}) do
            makeAnimatedLuaSprite('statheat'..i,fld.."stag-stats",heat[1],heat[2])
            for j,anim in pairs({{"active","heatactive", 0,0}, {"idle","heatdeselected", 0,0}, {"selected","heatselected", 0,0}, {"faulty","heatdisabled", 0,0}}) do
                addAnimationByPrefix('statheat'..i, anim[1], anim[2], 24, true)
                addOffset('statheat'..i, anim[2], anim[3],anim[4])
            end
            playAnim("statheat"..i, "idle")
            setProperty('statheat'..i..".color", getColorFromHex("DBAF85"))
            setProperty('statheat'..i..".visible", false)
            addLuaSprite('statheat'..i)
            utils:setObjectCamera('statheat'..i, 'other')
        end
    
        font:createNewText("huntesysTxt", 100, 65, "HunteSYS v0.1.1", "LEFT", "DBAF85")
        font:setTextCamera("huntesysTxt", "other")
        font:setTextVisible("huntesysTxt", false)
        
        font:createNewText("statSectTxt", 245, 100, "SECTOR 12", "LEFT", "DBAF85")
        font:setTextCamera("statSectTxt", "other")
        font:setTextScale("statSectTxt", 1.5, 1.5)
        font:setTextVisible("statSectTxt", false)
        
        font:createNewText("statusTimeTxt", 590, 65, "00:00:00", "RIGHT", "DBAF85")
        font:setTextCamera("statusTimeTxt", "other")
        font:setTextVisible("statusTimeTxt", false)
        
        font:createNewText("statPowerTxt", 100, 160, "RC: 20kWh", "LEFT", "DBAF85")
        font:setTextCamera("statPowerTxt", "other")
        font:setTextVisible("statPowerTxt", false)
        
        font:createNewText("statLoadTxt", 100, 190, "Sector Load: 0kWh", "LEFT", "DBAF85")
        font:setTextCamera("statLoadTxt", "other")
        font:setTextVisible("statLoadTxt", false)

        for _,chr in pairs(chrList) do
            if (chrStats[chr].ai > 0) then
                makeOneShotSpr('vent'..chr, "stag-stats", "vent-"..chr, 0,0, 'other',false)
            end
        end
    end
    
    font:createNewText("amTxt", 0, 20, " ", "RIGHT")
    font:setTextX("amTxt", screenWidth - 20)
    font:setTextScale("amTxt", 2, 2)
    font:setTextCamera("amTxt", "other")
    
    font:createNewText("qtrTxt", 0, 70, " ", "RIGHT")
    font:setTextX("qtrTxt", screenWidth - 20)
    font:setTextCamera("qtrTxt", "other")
        
    font:createNewText("powaTxt", 20, screenHeight - 60, " ")
    font:setTextScale("powaTxt", 2, 2)
    font:setTextCamera("powaTxt", "other")
end

function activateFNAF()
    setProperty("camHUD.width", 1580)
    callOnLuas("initCursor")

    runTimer("initCall", 1)

    font:setTextString("qtrTxt", "Quarter "..curQtr)
    for _,chr in pairs(chrList) do
        if (chrStats[chr].camOffsets ~= nil and chrStats[chr].ai > 0) then runTimer(chr.."MO", chrStats[chr].cooldown + 5) end
    end
    runTimer("timeInc", 1/60, 0)

    utils:playSound(aFld.."ambience", 0.1, "ambience")
    runTimer("ambnoises", 15)
    runTimer("blink",1)
    canUpdate = true

    updateCams(false)
end

function makeOneShotSpr(tag, name, anim, lax, lay, cam, visd)
    if anim ~= nil then --because im freakin lazy and feel one function works fine
    makeAnimatedLuaSprite(tag,fld..name,lax,lay)
    addAnimationByPrefix(tag, 'reg', anim, 24, true)
    else makeLuaSprite(tag, fld..name, lax,lay)
    end
    addLuaSprite(tag)
    if (visd ~= nil and visd == false) then setProperty(tag..".visible", false) end --a lot of sprs start off not visible
    utils:setObjectCamera(tag, cam)
end

function onUpdatePost(elp)
    if not canUpdate then return end
    
    pwrLoad = (elp / 200)
    chrStats["hnte"].camDelay = math.max(chrStats["hnte"].camDelay - elp, 0)

    curPwr = curPwr - (elp / 200)
    for i,dor in pairs(doorStats) do if (dor.active) then 
        curPwr = curPwr - (elp / 20) 
        pwrLoad = pwrLoad + (elp / 20)
    end end
    for i,heat in pairs(heatStats) do if (heat.active) then 
        curPwr = curPwr - (elp / 40) 
        pwrLoad = pwrLoad + (elp / 40)
    end end
    for i = 1,3 do if (heatStats[i]) then curPwr = curPwr - (elp / 20) pwrLoad = pwrLoad + (elp / 20) end end
    font:setTextString("powaTxt", "Powe: "..math.floor(curPwr).."%")
    if curPwr <= 0 then curPwr = 0 
        powerDown()
    end

    if (luaSpriteExists("mutebtn") and mouseClicked() and utils:mouseWithinBounds({10,10, 155,82}, "other")) then
        removeLuaSprite("mutebtn", true)
        removeLuaSprite("tvbg", true)
        removeLuaSprite("tvanims", true)
        cancelTimer("callAdvance")
        stopSound("phonecallintro")
        stopSound("phonecall")
        local muteList = utils:getGariiData("STaGmutes")
        if (not utils:tableContains(muteList, curQtr)) then
            table.insert(muteList, curQtr)
            utils:setGariiData("STaGmutes", muteList)
            local achievementDone = true
            for i = 1,6 do
                if (not utils:tableContains(muteList, i)) then
                    achievementDone = false
                end
            end
            if (achievementDone) then
                callOnLuas("unlockAchievement", {"the-yapper"})
            end
        end
    end

    if (chrStats["jack"].inOffice and not camUP and not statUP) then
        chrStats["jack"].lookMeter = chrStats["jack"].lookMeter + elp
    end

    if (statUP and hasPower) then curPwr = curPwr - (elp / 200) 
        pwrLoad = pwrLoad + (elp / 200)
        for i,btn in pairs({{281,518}, {244,426}, {445,562}}) do
            if (mouseClicked() and utils:mouseWithinBounds({btn[1],btn[2], btn[1]+24,btn[2]+15}, "other")) then
                toggleHeat(i)
            end
        end
    elseif (camUP and hasPower) then curPwr = curPwr - (elp / 200) 
        chrStats["hnte"].camDelay = getRandomInt(3,5) --balancing
        pwrLoad = pwrLoad + (elp / 200)
        for i,btn in pairs({{965,625}, {1157,632}, {1174,553}, {1229,472}, {1025,372}, {949,429}, {965,340}}) do
            if (mouseClicked() and utils:mouseWithinBounds({btn[1],btn[2], btn[1]+48,btn[2]+36}, "other")) then
                updateCams(true, i)
            end
        end
    else
        idleTime = idleTime + elp 
        if (idleTime >= 10 and (not utils:tableContains(chrStats["gari"].aggroList, "idle"))) then
            table.insert(chrStats["gari"].aggroList, "idle")
            chrStats["gari"].aggro = chrStats["gari"].aggro + 1
        elseif (idleTime < 10 and utils:tableContains(chrStats["gari"].aggroList, "idle")) then
            chrStats["gari"].aggroList[utils:indexOf(chrStats["gari"].aggroList, "idle")] = nil
            chrStats["gari"].aggro = chrStats["gari"].aggro - 1
        end
        if (getMouseX("camOther") > 1000 and getProperty("camHUD.x") > -300) then
            setProperty("camHUD.x", getProperty("camHUD.x") - (12 * (60/framerate)))
        elseif (getMouseX("camOther") < 200 and getProperty("camHUD.x") < 0) then
            setProperty("camHUD.x", getProperty("camHUD.x") + (12 * (60/framerate)))
        end

        local withinbounds = false
        for i,btn in pairs({{11,317, 64,415}, {465,324, 516,387}, {1452,304, 1540,361}}) do
            if (utils:mouseWithinBounds(btn, "hud")) then
                withinbounds = true
                if (doorStats[i].disabled) then callOnLuas("cursorPlayAnim", {"bad"}) end
                if (mouseClicked()) then toggleDoor(i) end
            end
        end
        if (not withinbounds) then callOnLuas("cursorPlayAnim") end

        if (mouseClicked()) then 
            if (utils:mouseWithinBounds({1295,357, 1311,366}, "hud")) then utils:playSound("minigames/stag/car_honk", 1, "carhonk") 
            elseif (utils:mouseWithinBounds({312,403, 331,415}, "hud")) then utils:playSound("minigames/stag/car_stupid"..getRandomInt(1,2), 1, "carstupid") 
            end
        end
    end

    setProperty("camBtn.visible", (getProperty("camHUD.x") <= -300))
    setProperty("statBtn.visible", (getProperty("camHUD.x") >= 0))

    if (keyJustPressed("back")) then 
        restartSong() --temporary solution
        callOnLuas("backToMinigameHUB")
        destroyMenu()
        destroyTrans()
        removeLuaScript('scripts/minigames/stag-menu')
        close() 
    end

    if (keyJustPressed("reset")) then 
        curTime = 21601
    end

    if (not hasPower) then return end
    if utils:mouseWithinBounds({getProperty("camBtn.x"),getProperty("camBtn.y"), getProperty("camBtn.x")+getProperty("camBtn.width"),screenHeight}, "hud") and getProperty("camBtn.visible") then 
        toggleCam() 
        camCooldown = true
    else camCooldown = false
    end

    if (chrStats["lino"].ai <= 0) then return end
    font:setTextString("statPowerTxt", "RC: "..(math.max(36 - (curQtr*6), 0) + ((math.floor(curPwr*60)/1000))).."kWh")
    font:setTextString("statLoadTxt", "Sector Load: "..(math.floor((pwrLoad / (elp / 100)) * 36.5)/1000).."kWh")

    if utils:mouseWithinBounds({getProperty("statBtn.x"),getProperty("statBtn.y"), getProperty("statBtn.x")+getProperty("statBtn.width"),screenHeight}, "hud") and getProperty("statBtn.visible") then 
        toggleStat(true) 
        statCooldown = true
    else statCooldown = false
    end
end

function toggleStat(fuck)
    if statCooldown then return end
    if (fuck) then statUP = not statUP 
        idleTime = 0
    end

    for i,spr in pairs({"statBtnDwn", "statbg", "statuslayout", "statusvents"}) do
        setProperty(spr..".visible", statUP)
    end
    for i,txt in pairs({"huntesysTxt", "statSectTxt", "statLoadTxt", "statPowerTxt", "statusTimeTxt"}) do
        font:setTextVisible(txt, statUP)
    end
    font:setTextVisible("amTxt", not statUP)
    font:setTextVisible("qtrTxt", not statUP)
    font:setTextVisible("powaTxt", not statUP)
    updateStats()

    if not fuck then return end
    if statUP then utils:playSound(fld.."cameraflip", 0.8)
        utils:playSound(fld.."statopen", 0.8)
    else utils:playSound(fld.."cameraflipdown", 0.8)
    end
end

function toggleCam()
    if camCooldown then return end
    camUP = not camUP
    idleTime = 0
    
    setProperty("camBtnDwn.visible", camUP)
    if (chrStats["slot"].inOffice and camUP) then 
        chrStats["slot"].inOffice = false
        chrStats["slot"].cam = 0
        cancelTimer("slotJumpscr")
    elseif (curCam == chrStats["slot"].cam and not camUP) then     
        chrStats["slot"].inOffice = true
        runTimer("slotJumpscr", 1.5) 
    end
    setProperty("oficslot.visible", chrStats["slot"].inOffice)

    setProperty("cameraBG.visible", camUP)
    setProperty("cammain.visible", camUP)
    setProperty("cammap.visible", camUP)
    setProperty("vntmap.visible", camUP)
    updateCams(false)
    for i = 1,7 do setProperty('cambtn'..i..".visible", camUP) end
    if camUP then utils:playSound(fld.."cameraflip", 0.8)
    else utils:playSound(fld.."cameraflipdown", 0.8)
    end
    
    if camUP then return end
    cancelTimer("fazeEgoInc")
    chrStats["faze"].timerRan = false
    if (jumpQueued ~= "") then jumpscare(jumpQueued) end
end

function toggleHeat(hat)
    heatStats[hat].active = not heatStats[hat].active
    updateStats()
    if (heatStats[3-(chrStats["gari"].cam%3)].active and math.abs(chrStats["gari"].cam) >= 9 and math.abs(chrStats["gari"].cam) <= 11 and (not utils:tableContains(chrStats["gari"].aggroList, "heat"))) then
        table.insert(chrStats["gari"].aggroList, "heat")
        chrStats["gari"].aggro = chrStats["gari"].aggro + 1
        runTimer("gariHeatDeAggro", 15)
    end
end

forcingJack = false
function updateCams(snd, camChange)
    if snd then utils:playSound(fld.."changecam", 0.75) end
    if (camChange ~= nil and camChange ~= curCam) then
        cancelTimer("fazeEgoInc")
        chrStats["faze"].timerRan = false
        chrStats["faze"].egoMeter = math.max(0, chrStats["faze"].egoMeter - 1)
    end
    curCam = camChange or curCam
    for i = 1,7 do 
        if (i == curCam) then playAnim("cambtn"..i, "sel")
        else playAnim("cambtn"..i, "desel") 
        end
    end
    playAnim("cammain", "cam"..curCam)

    for _,chr in pairs(chrList) do 
        if (luaSpriteExists("cam"..chr)) then
            setProperty("cam"..chr..".visible", chrStats[chr].ai > 0 and utils:subtablesContains(chrStats[chr].camOffsets, 1, curCam) and (curCam == math.abs(chrStats[chr].cam)) and camUP)
            playAnim("cam"..chr, ""..chrStats[chr].cam)
            if (chrStats[chr].atDoor ~= nil and chrStats[chr].atDoor) then playAnim("cam"..chr, chrStats[chr].cam.."atDoor") end
        end
    end
    setProperty("fazeCamCover.visible", chrStats["faze"].egoMeter >= 5 and chrStats["faze"].ai > 0 and chrStats["faze"].cam == curCam and camUP)
    if (-curCam == chrStats["jack"].cam and (chrStats["jack"].cam == -6 or chrStats["jack"].cam == -5) and (not forcingJack)) then
        forcingJack = true
        runTimer("jackCountdown", 2)
    end

    if (chrStats["faze"].ai <= 0 or chrStats["gari"].ai <= 0) then return end
    if (chrStats["faze"].cam == math.abs(chrStats["gari"].cam) and (not utils:tableContains(chrStats["gari"].aggroList, "faze"))) then
        table.insert(chrStats["gari"].aggroList, "faze")
        chrStats["gari"].aggro = chrStats["gari"].aggro + 1
    elseif (utils:tableContains(chrStats["gari"].aggroList, "faze") and chrStats["faze"].cam ~= math.abs(chrStats["gari"].cam)) then
        chrStats["gari"].aggroList[utils:indexOf(chrStats["gari"].aggroList, "faze")] = nil
        chrStats["gari"].aggro = chrStats["gari"].aggro - 1
    end
end

function updateStats()
    local ventPos = {[-8] = {426,488}, [-9] = {456,590}, [-10] = {256,381}, [-11] = {292,547}, [-12] = {386,446}, [8] = {484,488}, [9] = {456,565}, [10] = {256,448}, [11] = {293,519}, [12] = {355,446}}
    for i=1,3 do 
        if (doorStats[i].disabled) then playAnim('statdoor'..i, "faulty")
            setProperty('statdoor'..i..".color", getColorFromHex("C55252"))
        elseif (doorStats[i].active) then playAnim('statdoor'..i, "closed")
            setProperty('statdoor'..i..".color", getColorFromHex("8FC79B"))
        else  playAnim('statdoor'..i, "open")
            setProperty('statdoor'..i..".color", getColorFromHex("DBAF85"))
        end
        setProperty('statdoor'..i..".visible", statUP and ((blink and doorStats[i].disabled) or (not doorStats[i].disabled))) 
        if (heatStats[i].disabled) then playAnim('statheat'..i, "faulty")
            setProperty('statheat'..i..".color", getColorFromHex("C55252"))
        elseif (heatStats[i].active) then playAnim('statheat'..i, "active")
            setProperty('statheat'..i..".color", getColorFromHex("8FC79B"))
        else playAnim('statheat'..i, "idle")
            setProperty('statheat'..i..".color", getColorFromHex("DBAF85"))
        end
        setProperty('statheat'..i..".visible", statUP) 
    end
    for _,chr in pairs(chrList) do 
        if (luaSpriteExists("vent"..chr)) then
            setProperty("vent"..chr..".visible", chrStats[chr].ai > 0 and (ventPos[chrStats[chr].cam] ~= nil) and statUP and blink)
            if (ventPos[chrStats[chr].cam] ~= nil) then
                setProperty("vent"..chr..".x", ventPos[chrStats[chr].cam][1] - (getProperty("vent"..chr..".frameWidth")/2))
                setProperty("vent"..chr..".y", ventPos[chrStats[chr].cam][2] - (getProperty("vent"..chr..".frameHeight")/2))
            end
        end
    end
end


function toggleDoor(dor)
    if camUP then return end
    if doorStats[dor].disabled then utils:playSound(fld.."doordeny", 0.8)
        return 
    end

    doorStats[dor].active = not doorStats[dor].active
    setProperty("oficdor"..posiblDors[dor]..".visible", doorStats[dor].active)
    setProperty("oficbtn"..posiblDors[dor]..".visible", doorStats[dor].active)
    if (doorStats[dor].active) then utils:playSound(fld.."doorclose", 0.8)
    else utils:playSound(fld.."dooropen", 0.8)
    end
end

function powerDown()
    if not canUpdate or not hasPower then return end
    hasPower = false
    stopSound("ambience")
    if camUP then toggleCam() end
    for i = 1,3 do
        doorStats[i].active = false
        setProperty("oficdor"..posiblDors[i]..".visible", false)
        setProperty("oficbtn"..posiblDors[i]..".visible", false)
        utils:playSound(fld.."dooropen", 0.8) 
        doorStats[i].disabled = true
    end
    utils:playSound(fld.."powerdown", 0.8) 
end

function jumpscare(char)
    if not canUpdate then return end
    disableGame()
    if camUP then toggleCam() end
    local jumpscareList = utils:getGariiData("STaGjumpscrs") or {}
    if (not utils:tableContains(jumpscareList, char)) then
        table.insert(jumpscareList, char)
        utils:setGariiData("STaGjumpscrs", jumpscareList)
        local achievementDone = true
        for _,chr in pairs(chrList) do
            if (not utils:tableContains(jumpscareList, chr)) then
                achievementDone = false
            end
        end
        if (achievementDone) then
            callOnLuas("unlockAchievement", {"stag-deaths"})
        end
    end

    makeLuaSprite('jmpscr',fld..char..'jumpscare',0,0)
    screenCenter("jmpscr", "x")
    setProperty("jmpscr.y", screenHeight - getProperty("jmpscr.height"))
    addLuaSprite('jmpscr')
    utils:setObjectCamera('jmpscr', 'other')
    utils:playSound(fld.."jumpscare", 1, "jmp")
    if (char == "slot") then setSoundPitch("jmp", 0.5) end
    runTimer("endinSTaG", 2)
end

function jumpCountdown(char, timera)
    timera = timera or 5
    jumpQueued = char
    runTimer("forceJumpscare", timera)
end

function nightOver()
    if not canUpdate then return end
    debugPrint("NIGHT IS OVER")
    disableGame()
    utils:playSound(fld.."6am", 1)
    
    makeLuaSprite('stagfg','',0,0)
    makeGraphic("stagfg", screenWidth, screenHeight, "000000")
    addLuaSprite('stagfg')
    utils:setObjectCamera('stagfg', 'other')
    
    makeLuaText('samTxt', calcAMPM((5+(6*(curQtr-1)))*3600,true,false), 0, 0, 0)
    setTextFont('samTxt', "Lasting Sketch.ttf")
    setTextBorder('samTxt', 2, '000000')
    setTextSize('samTxt', 128)
    screenCenter("samTxt")
    utils:setObjectCamera('samTxt', 'other')
    addLuaText('samTxt')

    if (curQtr < 7 and (utils:getGariiData("STaGprog") < curQtr+1)) then
        if (curQtr >= 6) then callOnLuas("unlockAchievement", {"stag-quarters"}) end
        utils:setGariiData("STaGprog", curQtr + 1)
    end
    if (not hasPower) then callOnLuas("unlockAchievement", {"no-power-save"}) end
    if (doorStats[1].disabled and doorStats[2].disabled and doorStats[3].disabled) then callOnLuas("unlockAchievement", {"no-doors-save"}) end

    runTimer("cheer", 4)
    runTimer("changesamtxt", 2)
    runTimer("endinSTaG", 10)
end

function disableGame()
    canUpdate = false
    cancelTimer("forceFlipCams")
    cancelTimer("timeInc")
    stopSound("ambience")
    for _,chr in pairs(chrList) do cancelTimer(chr.."MO") 
        removeLuaSprite("ofic"..chr, true)
    end
end

function bangOnDoor()
    if (getRandomInt(1,100) == 1) then utils:playSound(fld.."bangyell", 0.8)
    else utils:playSound(fld.."bangnoyell", 0.8) end
    curPwr = curPwr - getRandomInt(1,3)
end

function rollRndmSound()
    if (getRandomInt(1,1000) == 1) then utils:playSound(fld.."hurt"..getRandomInt(1,3), 0.5) end
end


function moveGarii()
    if (#chrStats["gari"].aggroList >= 1) then utils:trc(chrStats["gari"].aggroList) end
    if (getRandomInt(1,20) > chrStats["gari"].ai) then rollRndmSound() return end

    local doorNums = {[6] = 1, [5] = 2, [8] = 3}
    if (chrStats["gari"].atDoor) then
        if (chrStats["jack"].inOffice) then return end
        chrStats["gari"].atDoor = false
        if (doorStats[doorNums[math.abs(chrStats["gari"].cam)]].active) then
            chrStats["gari"].cam = getRandomInt(1,7)
        else
            chrStats["gari"].cam = 0
            setProperty("oficgari.visible", true)
            jumpCountdown("gari")
        end
        return
    end

    local gariPaths = {
        [-12] = {-8,-9}, [-11] = {1}, [-10] = {7}, [-9] = {2}, [-8] = {0}, [-7] = {10}, [-6] = {0}, [-5] = {0}, [-4] = {8}, [-3] = {4,2,-1}, [-2] = {3,9}, [-1] = {6}, [0] = {0}, 
        {11,2,3}, {-1}, {4,5}, {-3,3,-4}, {-3,-12,12,-5}, {1,7,-6}, {6,-7}, {-9,12,-8}, {-8,8,12}, {11,-12}, {10,-12}, {-10,-11}
    }
    moveDefault("gari", 5, gariPaths, false)

    if (chrStats["gari"].cam == -6 or chrStats["gari"].cam == -5 or chrStats["gari"].cam == -8) then
        chrStats["gari"].atDoor = true
        return
    end
end

function moveLino()
    if (getRandomInt(1,20) > chrStats["lino"].ai) then rollRndmSound() return end
    if (chrStats["lino"].cam >= 9 and chrStats["lino"].cam <= 11) then
        if (heatStats[3-(chrStats["lino"].cam%3)].active) then
            chrStats["lino"].cam = getRandomInt(2,6,"4,5")
        else
            openDoor(3-(chrStats["lino"].cam%3))
            utils:playSound(fld.."ventbreak", 0.75) 
            runTimer("linoNotify", 2)
            doorStats[3-(chrStats["lino"].cam%3)].disabled = true
            toggleStat(false)
            if (chrStats["lino"].cam == 9) then chrStats["lino"].cam = -12
            else chrStats["lino"].cam = 12
            end
        end
        return
    end

    local doorNums = {[2] = 3, [7] = 2, [1] = 1}
    local linoCams = {[-9] = {9}, [-10] = {10}, [-11] = {11}, [-12] = {5}, [-2] = {-9}, [-1] = {-11}, [0] = {0}, [1] = {6,2,-1}, [2] = {3,1,-2}, [3] = {2,1,-1}, [5] = {3}, [6] = {7,1,7}, [7] = {-10}, [9] = {-12}, [10] = {12}, [11] = {12}, [12] = {5}}
    local prevCam = chrStats["lino"].cam

    moveDefault("lino", 5, linoCams, false)
    if ((chrStats["lino"].cam < 0 or chrStats["lino"].cam == 7) and doorStats[doorNums[math.abs(chrStats["lino"].cam)]].disabled) then chrStats["lino"].cam = linoCams[prevCam][math.min(2, #linoCams[prevCam])] end
end

function openDoor(dor)
    if (not doorStats[dor].active) then return end
    doorStats[dor].active = false
    setProperty("oficdor"..posiblDors[dor]..".visible", false)
    setProperty("oficbtn"..posiblDors[dor]..".visible", false)
    utils:playSound(fld.."dooropen", 0.8) 
end

function moveDefault(char, actionAmt, camPaths, shouldBore)
    if shouldBore then chrStats[char].action = getRandomInt(1,actionAmt+chrStats[char].bored)
        if (chrStats[char].action < 3) then chrStats[char].bored = chrStats[char].bored + 1
        else chrStats[char].bored = 0
        end
    else chrStats[char].action = getRandomInt(1,actionAmt)
    end

    if (chrStats[char].action == 1) then return end

    local charCamTo = camPaths[chrStats[char].cam][math.min(chrStats[char].action-1, #camPaths[chrStats[char].cam])] or 0
    local charPrevCam = chrStats[char].cam
    chrStats[char].cam = charCamTo
    playVentSound(chrStats[char].cam)
end

function moveJack()
    if (getRandomInt(1,20) > chrStats["jack"].ai or chrStats["jack"].inOffice) then rollRndmSound() return end

    if (chrStats["jack"].cam < 0) then
        if (doorStats[(chrStats["jack"].cam % 2)+1].active) then
            utils:playSound(fld.."bangnoyell", 1)
            runTimer("jackBangKill",1)
        else
            utils:playSound(fld.."jackroomflicker", 0.75, "jackflicker")
            chrStats["jack"].inOffice = true
            chrStats["jack"].cam = 0
            runTimer("jackOffice", 5)
        end
        chrStats["jack"].usedSwitch = false
    else
        if ((getRandomInt(1,10) - chrStats["jack"].bored) <= 1 and (not chrStats["jack"].usedSwitch)) then chrStats["jack"].polarity = not chrStats["jack"].polarity
            chrStats["jack"].usedSwitch = true
        end

        local jackCams, jackCamsAlt = {{6},{3,1},{2,1},nil,{3},{7,-6},{6,-6}}, {{2,3},{3},{2,5},nil,{-5},{7,1},{6}}
        if (chrStats["jack"].polarity) then moveDefault("jack", 3, jackCamsAlt, true)
        else moveDefault("jack", 3, jackCams, true)
        end
    end
    setProperty("oficjack.visible", chrStats["jack"].inOffice)
    setProperty("oficjack.flipX", chrStats["jack"].polarity)
end

function moveCarv()
    if (getRandomInt(1,20) > chrStats["carv"].ai) then rollRndmSound() return end
    if (getRandomInt(1,10000) == 1) then utils:playSound("carvdum"..getRandomInt(1,3), 0.5) end

    chrStats["carv"].moveNum = chrStats["carv"].moveNum + 1
    if ((chrStats["carv"].moveNum % 3) ~= 1 and (chrStats["carv"].cam ~= curCam or (not camUP))) then return end

    if (chrStats["carv"].cam == 5) then 
        if (chrStats["jack"].inOffice) then return end
        if (doorStats[2].active) then chrStats["carv"].cam = 1
        else chrStats["carv"].cam = chrStats["carv"].cam + 1
            doorStats[2].disabled = true
            jumpCountdown("carv")
        end
    elseif (chrStats["carv"].cam >= 6) then jumpscare("carv")
    else chrStats["carv"].cam = chrStats["carv"].cam + 1
    end            
    setProperty("oficcarv.visible", chrStats["carv"].cam == 6)
end

function moveHunte()
    if (getRandomInt(1,20) > chrStats["hnte"].ai or chrStats["hnte"].camDelay > 0 --[[or (statUP and chrStats["hnte"].stage >= 3 and chrStats["hnte"].stage <= 4)]]) then rollRndmSound() return end

    if (chrStats["hnte"].stage == 4) then 
        if (chrStats["jack"].inOffice) then return end --i was gonna leave hunte able to move whilst jack was in the office but somehow that broke everything???? i dont... i dont even know
        if (doorStats[3].active) then bangOnDoor()
            chrStats["hnte"].stage = 1
        else chrStats["hnte"].stage = chrStats["hnte"].stage + 1
            doorStats[3].disabled = true
            jumpCountdown("hnte")
        end
    elseif (chrStats["hnte"].stage >= 5) then jumpscare("hnte")
    else chrStats["hnte"].stage = chrStats["hnte"].stage + 1
    end
    local hnteCams = {3,4,8,-8,0}
    chrStats["hnte"].cam = hnteCams[chrStats["hnte"].stage]
    playVentSound(chrStats["hnte"].cam)
    setProperty("ofichnte.visible", chrStats["hnte"].stage == 5)
end

function playVentSound(ventnum)
    if (math.abs(ventnum) < 8) then return end

    if (ventnum == -8) then utils:playSound(fld.."ventloud", 1) 
    elseif (ventnum == 8) then utils:playSound(fld.."ventloud", 0.5) 
    elseif (ventnum == -12 or ventnum == 9) then utils:playSound(fld.."ventquiet", 1) 
    else utils:playSound(fld.."ventquiet", 0.5) 
    end
end

function moveSlots()
    if (getRandomInt(1,100) > chrStats["slot"].ai) then chrStats["slot"].cam = 0 return end
    chrStats["slot"].cam = getRandomInt(1,7)
end

function moveFaze()
    if (chrStats["faze"].memCam ~= curCam and curCam ~= chrStats["faze"].cam) then
        chrStats["faze"].memCam = curCam
        if (#chrStats["faze"].curPath >= 1 and utils:tableContains(chrStats["faze"].curPath, chrStats["faze"].memCam)) then
            chrStats["faze"].curPath = utils:removePortion(chrStats["faze"].curPath, utils:indexOf(chrStats["faze"].curPath,chrStats["faze"].memCam))
        else 
            local fazepaths = {{6,2,3}, {1,3}, {1,2,4,5}, {3,5}, {3,4}, {7,1}, {6}} --faze's pathfinding to cam 7 is broken. if cam 1 and cam 6 do not have 6 and 7 (respectively) in the highest priority he cant find cam 7
            chrStats["faze"].curPath = makeNewPath(chrStats["faze"].cam, curCam, utils:removeAllOf(fazepaths, chrStats["faze"].cam))
        end
    end
    if (getRandomInt(1,20) > chrStats["faze"].ai) then rollRndmSound() return end

    if (#chrStats["faze"].curPath >= 1) then
        chrStats["faze"].cam = chrStats["faze"].curPath[1]
        table.remove(chrStats["faze"].curPath, 1)
        cancelTimer("fazeEgoInc")
        chrStats["faze"].egoMeter = 0
        chrStats["faze"].timerRan = false
    end
    if (curCam == chrStats["faze"].cam and chrStats["faze"].timerRan == false and camUP) then
        chrStats["faze"].timerRan = true
        runTimer("fazeEgoInc", (6 - math.floor(chrStats["faze"].ai / 4)) / 5, 5)
    end
end

function makeNewPath(curPos, posTo, allOptions)
    local path = {}
    local options = allOptions[curPos]

    if (utils:tableContains(options, posTo)) then
        path = {posTo}
    else
        local bestPath = {}
        for k,v in pairs(options) do
            local curPath = {v}
            curPath = utils:mergeTables(curPath, makeNewPath(v, posTo, utils:removeAllOf(allOptions, v)))
            if ((#curPath < #bestPath or #bestPath < 1) and utils:tableContains(curPath, posTo)) then bestPath = curPath end
        end
        path = bestPath
    end

    return path
end

function callScreenAdvance()
    qtrCallTime = qtrCallTime + 1
    if (curQtrCallList[qtrCallTime] == nil) then return end
    playAnim("tvanims", curQtrCallList[qtrCallTime][1])
    runTimer("callAdvance", curQtrCallList[qtrCallTime][2])
end


function onSoundFinished(tag)
    if tag == 'ambience' then utils:playSound(aFld.."ambience", 0.05, "ambience")
    elseif tag == 'phonecall' then removeLuaSprite("mutebtn", true)
        removeLuaSprite("tvbg", true)
        removeLuaSprite("tvanims", true)
        cancelTimer("callAdvance")
    elseif tag == "phonecallintro" then utils:playSound(bFld.."qtr"..curQtr.."bcst", 1, "phonecall")
        curQtrCallList = qtrCallLists[curQtr]
        qtrCallTime = 0
        callScreenAdvance()
    end
end

function onTimerCompleted(tag)
    if (tag == "cheer") then utils:playSound(fld.."congrat", 1)
    elseif (tag == "changesamtxt") then setTextString("samTxt", calcAMPM((6+(6*(curQtr-1)))*3600,true,false))
    elseif (tag == "endinSTaG") then restartSong() 
    elseif (tag == "initCall") then
        if (checkFileExists("sounds/"..bFld.."qtr"..curQtr.."bcst.ogg")) then
            makeOneShotSpr('mutebtn', "mutebtn", nil, 10,10, 'other')
            setProperty("mutebtn.alpha", 0.8)
            utils:playSound(bFld.."broadcaststart", 1, "phonecallintro")
            curQtrCallList = {{"garitv", 2.03}, {"tvstatic", 2}}
            setProperty("tvbg.visible", true)
            setProperty("tvanims.visible", true)
            callScreenAdvance()
        end
    elseif (tag == "callAdvance") then callScreenAdvance()
    elseif (tag == "forceJumpscare") then 
        if camUP then toggleCam()
        else jumpscare(jumpQueued) end
    elseif (tag == "gariHeatDeAggro" and utils:tableContains(chrStats["gari"].aggroList, "heat")) then 
        chrStats["gari"].aggroList[utils:indexOf(chrStats["gari"].aggroList, "heat")] = nil
        chrStats["gari"].aggro = chrStats["gari"].aggro - 1
    elseif (tag == "gariJackDeAggro" and utils:tableContains(chrStats["gari"].aggroList, "jack")) then 
        chrStats["gari"].aggroList[utils:indexOf(chrStats["gari"].aggroList, "jack")] = nil
        chrStats["gari"].aggro = chrStats["gari"].aggro - 1
    elseif (tag == "slotJumpscr") then jumpscare("slot")
    elseif (tag == "fazeEgoInc") then chrStats["faze"].egoMeter = chrStats["faze"].egoMeter + 1
        updateCams()
    elseif (tag == "linoNotify") then utils:playSound(fld.."/statuspanel/Windows XP Error", 0.8) 
    elseif (tag == "jackCountdown") then
        if (doorStats[(chrStats["jack"].cam % 2)+1].active) then
            utils:playSound(fld.."bangnoyell", 1)
            runTimer("jackBangKill",1)
        else
            utils:playSound(fld.."jackroomflicker", 0.75, "jackflicker")
            chrStats["jack"].inOffice = true
            chrStats["jack"].cam = 0
            runTimer("jackOffice", 5)
        end
        chrStats["jack"].usedSwitch = false
        forcingJack = false
    elseif (tag == "jackOffice") then 
        if (chrStats["jack"].lookMeter >= 2) then
            jumpscare("jack")
        else
            if (chrStats["jack"].polarity) then chrStats["jack"].cam = 6
                openDoor(1)
            else chrStats["jack"].cam = 5
                openDoor(2)
            end
            chrStats["jack"].inOffice = false
            chrStats["jack"].lookMeter = 0
            if (not utils:tableContains(chrStats["gari"].aggroList, "jack")) then
                table.insert(chrStats["gari"].aggroList, "jack")
                chrStats["gari"].aggro = chrStats["gari"].aggro + 1
                runTimer("gariJackDeAggro", 10)
            end
        end
        stopSound("jackflicker")
        setProperty("oficjack.visible", false)
    elseif (tag == "jackBangKill") then
        local door = 1
        if (chrStats["jack"].polarity) then door = 2 end
        doorStats[door].active = false
        setProperty("oficdor"..posiblDors[door]..".visible", false)
        setProperty("oficbtn"..posiblDors[door]..".visible", false)
        utils:playSound(fld.."dooropen", 0.8) 
        doorStats[door].disabled = true
        jumpCountdown("jack", 2)
    elseif (stringEndsWith(tag, "MO")) then --the master movement code. would also put the ai check here but some characters have different checks than others so im afraid to do so without losing my mind
        local charMoveFuncs = {["gari"] = moveGarii, ["carv"] = moveCarv, ["hnte"] = moveHunte, ["lino"] = moveLino, ["faze"] = moveFaze, ["slot"] = moveSlots, ["jack"] = moveJack}
        if (chrStats[stringSplit(tag, "MO")[1]].aggro ~= nil) then runTimer(tag, chrStats[stringSplit(tag, "MO")[1]].cooldown - chrStats[stringSplit(tag, "MO")[1]].aggro)
        else runTimer(tag, chrStats[stringSplit(tag, "MO")[1]].cooldown)
        end
        charMoveFuncs[stringSplit(tag, "MO")[1]]()
        updateCams()
    elseif (tag == "blink") then blink = not blink
        updateStats()
        runTimer("blink", 1)
    elseif (tag == "timeInc") then
        curTime = curTime + 1
        if (curTime >= 21600) then nightOver()
        elseif (curTime >= 14400 and (not utils:tableContains(chrStats["gari"].aggroList, "4am"))) then table.insert(chrStats["gari"].aggroList, "4am")
            chrStats["gari"].aggro = chrStats["gari"].aggro + 1
        end
        font:setTextString("amTxt", calcAMPM(curTime+(21600*(curQtr-1)), true, false))
        font:setTextString("statusTimeTxt", calcAMPM(curTime+(21600*(curQtr-1)), false, true))
    elseif (tag == "ambnoises") then
        runTimer("ambnoises", getRandomInt(5, 15))
        if (getRandomInt(0,15) ~= 0) then return end

        local amb = {"clicks", "drip", "drippy", "pop", "shh", "stupid", "wind", "stupidphoneihate"}
        utils:playSound(aFld..amb[getRandomInt(1,#amb)], getRandomFloat(0.05, 0.2))
    end
end

function calcAMPM(uncutTime, hourOnly, military)
    local hourRaw = math.floor(uncutTime/3600)
    local minuteRaw = math.floor(uncutTime/60) % 60
    local secondRaw = math.floor(uncutTime) % 60

    local suffix = "AM"
    local cutTimeMil = hourRaw % 24
    local cutTime = hourRaw % 12
    if (cutTime == 0 and (not military)) then cutTime = 12 end
    if (hourRaw % 24) >= 12 then suffix = "PM" end
    if (hourOnly) then return cutTime.." "..suffix end
    if (not military) then return cutTime..":"..formatDigit(minuteRaw)..":"..formatDigit(secondRaw).." "..suffix end
    return formatDigit(cutTimeMil)..":"..formatDigit(minuteRaw)..":"..formatDigit(secondRaw)
end

function formatDigit(num)
    if (num < 10) then return "0"..num end
    return num
end