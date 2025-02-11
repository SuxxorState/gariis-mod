local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local achievements = {
    ["fuzzy-dice-fc"] = {title = "Capicola Gang", description = "100% Clear Fuzzy Dice"}, --done
    ["full-house-fc"] = {title = "The Power Of Two", description = "100% Clear Full House"}, --done
    ["episode-ii-fc"] = {title = "Show Off", description = "100% Clear Episode ][ without dying once"},
    ["story-deaths"] = {title = "The Part Where He Kills You", description = "Experience every possible death Episode ][ has to offer"},
    ["no-pose"] = {title = "Not Feelin' It", description = "Beat Full House without ever hitting a pose note"}, --done
    ["100k-chips"] = {title = "The Big Cheese", description = "Get one hundred thousand or more poker chips in the casino"}, --done
    ["true-bjs"] = {title = "The House Is Cheating!", description = "End in a draw with both you and the house having a true blackjack"},
    ["tb-foak"] = {title = "Planet X", description = "Get the highest Five of a Kind you can get in Picture Poker"},
    ["no-fish"] = {title = "Go...Fish?", description = "It doesn't exist. You're hallucinating."},
    ["stag-quarters"] = {title = "Dollar Fitty", description = "Survive all six quarters at Garii's Manor"},
    ["no-power-save"] = {title = "Saved By The Bell", description = "Hit the end of a quarter whilst in a blackout"},
    ["no-doors-save"] = {title = "Lino's Bad Day", description = "Hit the end of a quarter with all three of your doors disabled"},
    ["the-yapper"] = {title = "Keep Talking and I'll Explode", description = "Skip every Garii broadcast"},
    ["stag-deaths"] = {title = "Rocket Science", description = "Die to every lethal character at Garii's Manor"},
    ["bt-simple"] = {title = "Who Put These Here?", description = "Clear your first round."},
    ["bt-5simple"] = {title = "Handle With Care", description = "Clear 5 rounds."},
    ["bt-speedy"] = {title = "Little Smiley Face", description = "Clear a round in under a minute."},
    ["bt-expert"] = {title = "Minefield in a Bush", description = "Clear your first round on Expert."},
    ["bt-5expert"] = {title = "Clusterluck", description = "Clear 5 rounds in a row on Expert."},
    ["bt-exp-speed"] = {title = "Horticulturist", description = "Clear a round on Expert in under two minutes."},
    ["fl-everyfruit"] = {title = "Pic-a-nic Basket", description = "Gather every Food and Drink"},
    ["fl-everytrash"] = {title = "Junkyard", description = "Collect Every Type of Trash"},
    ["fl-16levels"] = {title = "Salad Dressing", description = "Beat 16 Levels"},
    ["fl-64levels"] = {title = "Sandwich Tower", description = "Beat 64 Levels"},
    ["fl-deaths"] = {title = "Knuckle Sandwich", description = "Die to every fuzzling as both Boy and Girl"},
}
local ratingAccumulation = {0,0,0,0}
local keyPresses = 0
local posesHit = 0

function onGoodNoteHit(_,_,nType)
    if (stringStartsWith(utils:lwrKebab(nType), "pose-note")) then posesHit = posesHit + 1 end

    if (getPropertyFromGroup('notes', id, 'rating') == "unknown") then return end

    local ranks = {"sick", "good", "bad", "shit"}
    ratingAccumulation[utils:indexOf(ranks, getPropertyFromGroup('notes', id, 'rating'))] = ratingAccumulation[utils:indexOf(ranks, getPropertyFromGroup('notes', id, 'rating'))] + 1
end

function noteMissPress()
	keyPresses = keyPresses + 1
end

function onEndSong()
    if (posesHit <= 0 and utils.songNameFmt == "full-house") then
        unlockAchievement("no-pose")
    end
    calculateFC()
end


function unlockAchievement(ach)
    local save = utils:getGariiData("achievements") or {}

    if (save[ach] == nil) then save[ach] = {}
    elseif (save[ach][1] == true or achievements[ach] == nil) then return end

    save[ach] = {true, os.time(os.date('*t'))}
    utils:setGariiData("achievements", save)
end

function calculateFC()
	local goods = ratingAccumulation[1] + ratingAccumulation[2]
	local totals = goods + ratingAccumulation[3] + ratingAccumulation[4] + (misses - keyPresses)
	local ratingPercent = math.floor((goods/totals)*100)/100

	if (ratingPercent == 1) then
		unlockAchievement(utils:lwrKebab(songName).."-fc")
	end
end