local utils = (require (getVar("folDir").."scripts.backend.utils")):new()
local achievements = {
    ["garii's-mod"] = {
        {save = "fuzzy-dice-fc", title = "Capicola Gang", description = "100% Clear Fuzzy Dice", iconFile = "fuzzydice", secret = false, gariiPoints = 10},
        {save = "full-house-fc", title = "The Power Of Two", description = "100% Clear Full House", iconFile = "", secret = false, gariiPoints = 10},
        {save = "episode-ii-fc", title = "Show Off", description = "100% Clear Episode ][ without dying once", iconFile = "", secret = false, gariiPoints = 25},

        --{save = "fuzzy-dice-rm-fc", title = "All Bark No Bite", description = "100% Clear Fuzzy Dice rematch", iconFile = "", secret = false, gariiPoints = 20},
        --{save = "full-house-rm-fc", title = "Decked Out", description = "100% Clear Full House rematch", iconFile = "", secret = false, gariiPoints = 20},
        --{save = "episode-ii-rm-fc", title = "You Made Your Point", description = "100% Clear Episode ][ rematch without dying once", iconFile = "", secret = false, gariiPoints = 50},

        {save = "story-deaths", title = "The Part Where He Kills You", description = "Experience every possible death Episode ][ has to offer", iconFile = "portal2", secret = false, gariiPoints = 25},
        {save = "no-pose", title = "Not Feelin' It", description = "Beat Full House without ever hitting a pose note", iconFile = "", secret = false, gariiPoints = 10},
    },

    ["skobeloff-casino"] = {
        {save = "100k-chips", title = "The Big Cheese", description = "Get one hundred thousand or more poker chips in the casino", iconFile = "", secret = false, gariiPoints = 50},
        {save = "true-bjs", title = "The House Is Cheating!", description = "End in a draw with both you and the house having a true blackjack", iconFile = "", secret = false, gariiPoints = 25},
        {save = "tb-foak", title = "Planet X", description = "Get the highest Five of a Kind you can get in Picture poker", iconFile = "", secret = false, gariiPoints = 25},
        {save = "no-fish", title = "Go...Fish?", description = "It doesn't exist. You're hallucinating.", iconFile = "", secret = false, gariiPoints = 10},
    },

    ["some-time-at-garii's"] = {
        {save = "stag-quarters", title = "Dollar Fitty", description = "Survive all six quarters at Garii's Manor", iconFile = "", secret = false, gariiPoints = 50},
        {save = "no-power-save", title = "Saved By The Bell", description = "Hit the end of a quarter whilst in a blackout", iconFile = "", secret = false, gariiPoints = 25},
        {save = "no-doors-save", title = "Lino's Bad Day", description = "Hit the end of a quarter with all three of your doors disabled", iconFile = "", secret = false, gariiPoints = 20},
        {save = "the-yapper", title = "Keep Talking and I'll Explode", description = "Skip every Garii broadcast", iconFile = "", secret = false, gariiPoints = 10},
        {save = "stag-deaths", title = "Rocket Science", description = "Die to every lethal character at Garii's Manor", iconFile = "", secret = false, gariiPoints = 20},
        --{save = "stag-7-20", title = "7/20 Blazin", description = "Survive Night-mare at Garii's Manor", iconFile = "", secret = false, gariiPoints = 75},
    },

    ["bushtrimmer"] = {
        {save = "bt-simple", title = "Who Put These Here?", description = "Beat a round of Bushtrimmer", iconFile = "mine", secret = false, gariiPoints = 10},
        {save = "bt-5simple", title = "Handle With Care", description = "Beat 5 rounds of Bushtrimmer", iconFile = "flag", secret = false, gariiPoints = 25},
        {save = "bt-speedy", title = "Little Smiley Face", description = "Beat a round of Bushtrimmer in under a minute", iconFile = "smiley", secret = false, gariiPoints = 20},
        {save = "bt-expert", title = "Minefield in a Bush", description = "Beat a round of Bushtrimmer on Expert", iconFile = "mine-bush", secret = false, gariiPoints = 25},
        {save = "bt-5expert", title = "Clusterluck", description = "Beat 5 rounds of Bushtrimmer in a row on Expert", iconFile = "boom", secret = false, gariiPoints = 50},
        {save = "bt-exp-speed", title = "Horticulturist", description = "Beat a round of Bushtrimmer on Expert in under two minutes", iconFile = "shears", secret = false, gariiPoints = 75},
    },
    
    ["fuzzlings!"] = {
        {save = "fl-everyfruit", title = "Pic-a-nic Basket", description = "Gather Every Food and Drink in Fuzzlings!", iconFile = "", secret = false, gariiPoints = 10},
        {save = "fl-everytrash", title = "Junkyard", description = "Collect Every Type of Trash in Fuzzlings!", iconFile = "", secret = false, gariiPoints = 25},
        {save = "fl-16levels", title = "Salad Dressing", description = "Beat 16 Levels in Fuzzlings!", iconFile = "", secret = false, gariiPoints = 20},
        {save = "fl-64levels", title = "Sandwich Tower", description = "Beat 64 Levels in Fuzzlings!", iconFile = "", secret = false, gariiPoints = 50},
        --{save = "fl-256levels", title = "Byte Overflow", description = "Beat the 256/0th Level in Fuzzlings!", iconFile = "", secret = false, gariiPoints = 100},
        --{save = "fl-512levels", title = "Exquisitely Stuffed", description = "Beat the 256/0th Level With Both Boy and Girl", iconFile = "", secret = false, gariiPoints = 250},
        {save = "fl-deaths", title = "Knuckle Sandwich", description = "Die to every fuzzling as both Boy and Girl", iconFile = "", secret = false, gariiPoints = 25},
    }
}

function onUpdatePost()

end

function onEndSong()
    if (misses > 0) then return end

    if (songName == "fuzzy-dice") then
        unlockAchievement("fuzzy-dice-fc")
    elseif (songName == "full-house") then
        unlockAchievement("full-house-fc")
    end
end

function onCreatePost()
    unlockAchievement(1, "dummy")
end

function unlockAchievement(ind, dir)
    local save = utils:getGariiData("achievements") or {}

    if (save[dir] == nil) then save[dir] = {} 
    elseif (save[dir][ind][1] == true) then return end

    save[dir][ind] = {true, os.time(os.date('*t'))}
    --utils:setGariiData("achievements", save)
    debugPrint(save)
end