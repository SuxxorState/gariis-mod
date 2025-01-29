local utils = (require (getVar("folDir").."scripts.backend.utils")):new()

function onCreate()
    setProperty("skipCountdown", true)
    if (utils:getGariiData("hasSeenSimGretina") == nil or utils:getGariiData("hasSeenSimGretina") == false) then
        os.execute("start https://www.youtube.com/watch?v=Y0jjTnrDCXY&ab_channel=SimGretina") --so that people dont think we made the song. cause we didnt, nor is it for the mod. and i dont want the credit for such an amazing song.
        utils:setGariiData("hasSeenSimGretina", true)
    end
end

function onStepHit()
    if curStep == 1 then setProperty("boyfriend.stunned", false) end
end
