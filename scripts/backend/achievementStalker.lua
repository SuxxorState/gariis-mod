local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local achievements = {
    ["fuzzy-dice-fc"] = {title = "Capicola Gang", gariiPoints = 10},    --done
    ["fuzzy-dice-ex-fc"] = {title = "All Bark No Bite", gariiPoints = 10},    --done
    ["full-house-fc"] = {title = "The Power Of Two", gariiPoints = 10},    --done
    ["full-house-ex-fc"] = {title = "Decked Out", gariiPoints = 10},    --done
    ["episode-ii-fc"] = {title = "Show Off", gariiPoints = 10},    --done
    ["episode-ii-ex-fc"] = {title = "You Made Your Point", gariiPoints = 10},    --done
    ["story-deaths"] = {title = "The Part Where He Kills You", gariiPoints = 10},
    ["no-pose"] = {title = "Not Feelin' It", gariiPoints = 10},    --done
    ["garii-hud-death"] = {title = "KNOCK IT OFF!!!", gariiPoints = 10},
    
    ["100k-chips"] = {title = "The Big Cheese", gariiPoints = 10},
    ["true-bjs"] = {title = "The House Is Cheating!", gariiPoints = 10},
    ["tb-foak"] = {title = "Planet X", gariiPoints = 10},
    ["no-fish"] = {title = "Go...Fish?", gariiPoints = 10},

    ["stag-quarters"] = {title = "Dollar Fitty", gariiPoints = 10},    --done
    ["no-power-save"] = {title = "Saved By The Bell", gariiPoints = 10},    --done
    ["no-doors-save"] = {title = "Lino's Bad Day", gariiPoints = 10},    --done
    ["the-yapper"] = {title = "Keep Talking and I'll Explode", gariiPoints = 10},    --done
    ["stag-deaths"] = {title = "Rocket Science", gariiPoints = 10},    --done

    ["bt-simple"] = {title = "Who Put These Here?", gariiPoints = 10},    --done
    ["bt-5simple"] = {title = "Handle With Care", gariiPoints = 10},    --done
    ["bt-speedy"] = {title = "Little Smiley Face", gariiPoints = 10},    --done
    ["bt-expert"] = {title = "Minefield in a Bush", gariiPoints = 10},    --done
    ["bt-5expert"] = {title = "Clusterluck", gariiPoints = 10},    --done
    ["bt-exp-speed"] = {title = "Horticulturist", gariiPoints = 10},    --done

    ["fl-everyfruit"] = {title = "Pic-a-nic Basket", gariiPoints = 10},    --done
    ["fl-everytrash"] = {title = "Junkyard", gariiPoints = 10},    --done
    ["fl-16levels"] = {title = "Salad Dressing", gariiPoints = 10},    --done
    ["fl-64levels"] = {title = "Sandwich Tower", gariiPoints = 10},    --done
    ["fl-deaths"] = {title = "Knuckle Sandwich", gariiPoints = 10},
    ["fl-pacifist"] = {title = "Green Hamm", gariiPoints = 25},
    ["fl-sadist"] = {title = "Seeing Red Wine", gariiPoints = 25},
    ["fl-rebirth"] = {title = "Byte Overflow", gariiPoints = 100},
    ["fl-2rebirth"] = {title = "Exquisitely Stuffed", gariiPoints = 250},

    ["all-achievements"] = {title = "Don't You Have Anything Better to Do?", gariiPoints = 10},
}
local queuedAchievements = {}
local lastCheckedAch = ""
local ratingAccumulation = {0,0,0,0}
local keyPresses = 0
local posesHit = 0
local canEndSong, canEndSongII = true, true
local ENDINGLESONG = false

function goodNoteHit(id,_,nType)
    if (stringStartsWith(utils:lwrKebab(nType), "pose-note")) then posesHit = posesHit + 1 end

    if (getPropertyFromGroup('notes', id, 'rating') == "unknown") then return end

    local ranks = {"sick", "good", "bad", "shit"}
    ratingAccumulation[utils:indexOf(ranks, getPropertyFromGroup('notes', id, 'rating'))] = ratingAccumulation[utils:indexOf(ranks, getPropertyFromGroup('notes', id, 'rating'))] + 1
end

function noteMissPress()
	keyPresses = keyPresses + 1
end

function onCreate()
    --utils:setGariiData("achievements", nil)
end

local doodooScreen = utils:getGariiData("doodooScreen3") or false
local pausedIt = false
function onUpdate()
    if (lastCheckedAch ~= queuedAchievements[1] and queuedAchievements[1] ~= nil) then
        spawnAchievementPopup(queuedAchievements[1])
        lastCheckedAch = queuedAchievements[1]
    end
    if (pausedIt and keyJustPressed("accept")) then
		endSong()
	end
end

local bitch = false
local levelEnds = {["fuzzy-dice"] = false, ["full-house"] = true} -- for story mode and allat
function onEndSong()
    ENDINGLESONG = true
    if (posesHit <= 0 and utils.songNameFmt == "full-house") then
        unlockAchievement("no-pose")
    end
    calculateFC()
    if (doodooScreen ~= true) and (isStoryMode and utils.songNameFmt == "full-house") then
        utils:setGariiData("doodooScreen3", true)
		makeLuaSprite('bfFinal', 'win', 0, 0)
		utils:setObjectCamera('bfFinal', 'other')
		addLuaSprite('bfFinal')
		doodooScreen = true
		pausedIt = true
		return Function_Stop;
	end
    if ((canEndSong and canEndSongII)) then
        if (stringStartsWith(version, "1.0") and isStoryMode and week == "garii" and utils.songNameFmt == "fuzzy-dice") then --workaround for the story mode bug that should not be a problem
            loadSong("Full House")
            utils:runHaxeCode([[PlayState.storyPlaylist = ["Full House"];]])
            return Function_Stop;
        end
        if (((not isStoryMode) or levelEnds[utils.songNameFmt]) and (not bitch)) then
            bitch = true
            utils:endToMenu()
            return Function_Stop;
        end
    else return Function_Stop;
    end
end


function unlockAchievement(ach)
    local save = utils:getGariiData("achievements") or {}

    if (save[ach] == nil) then save[ach] = {} end
    if (save[ach][1] == true or achievements[ach] == nil or botPlay or practice) then return false end

    save[ach] = {true, os.time(os.date('*t'))}
    utils:setGariiData("achievements", save)
    table.insert(queuedAchievements, ach)
    return true
end

function calculateFC()
	local goods = ratingAccumulation[1] + ratingAccumulation[2]
	local totals = goods + ratingAccumulation[3] + ratingAccumulation[4] + (misses - keyPresses)
	local ratingPercent = math.floor((goods/totals)*100)/100

    if (ratingPercent == 1) then
        if (stringEndsWith(difficultyPath, "expert")) then canEndSong = not unlockAchievement(utils:lwrKebab(songName).."-ex-fc")
        else canEndSong = not unlockAchievement(utils:lwrKebab(songName).."-fc")
        end
        local clears = utils:getGariiData("levelClear")
        if (isStoryMode) then
            table.insert(clears, utils.songNameFmt)
            utils:setGariiData("levelClear", clears)
            if (levelEnds[utils.songNameFmt]) then --i would make this flexible with other levels but eye dee gaff
                if (utils:tableContains(clears, "fuzzy-dice")) then
                    if (stringEndsWith(difficultyPath, "expert")) then canEndSongII = not unlockAchievement("episode-ii-ex-fc")
                    else canEndSongII = not unlockAchievement("episode-ii-fc")
                    end
                end
            end
        end
	end
end

function spawnAchievementPopup(ach)
    utils:playSound("achievements/unlock")
    runTimer("achievementDestroy", 6)

    makeLuaSprite("achievementBack", "achievements/popup", 450, 50)
    utils:setObjectCamera("achievementBack", "other")
    addLuaSprite("achievementBack", true)

    makeLuaText('achievementTxt', "Achievement unlocked",0, 523, 54)
    utils:quickFormatTxt('achievementTxt', "segoe-semi.ttf", 22, "FFFFFF")
    utils:setObjectCamera("achievementTxt", "other")
    addLuaText("achievementTxt", true)
    
    makeLuaText('actualAchTxt', achievements[ach].gariiPoints.."G - "..achievements[ach].title,0, 523, 81)
    utils:quickFormatTxt('actualAchTxt', "segoe-semi.ttf", 22, "FFFFFF")
    utils:setObjectCamera("actualAchTxt", "other")
    addLuaText("actualAchTxt", true)
end

function onTimerCompleted(tmr)
    if (tmr == "achievementDestroy") then
        removeLuaSprite("achievementBack")
        removeLuaText("achievementTxt")
        removeLuaText("actualAchTxt")
        table.remove(queuedAchievements, 1)
        if (ENDINGLESONG and #queuedAchievements <= 0) then
            canEndSong = true
            endSong()
        end
    end
end