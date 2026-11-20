local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local D = require(game.ReplicatedStorage.Shared.BrainrotData)
local HEIGHTS = { 6, 10, 14, 18 }
local Wave = {
    State = { Phase = "CALM", Remaining = D.Calm, Height = 6, Cycle = 0 },
}

function Wave.Start(world, economy, base, remote)
    local function publish(phase, remaining, height, cycle)
        Wave.State = {
            Phase = phase,
            Remaining = remaining,
            Height = height,
            Cycle = cycle,
        }
        remote:FireAllClients("Wave", Wave.State)
    end

    local function countdown(phase, duration, height, cycle)
        for secondsLeft = duration, 1, -1 do
            publish(phase, secondsLeft, height, cycle)
            task.wait(1)
        end
    end

    task.spawn(function()
        local cycleNumber = 0
        while true do
            cycleNumber += 1
            local waveHeight = HEIGHTS[math.min(cycleNumber, #HEIGHTS)]
            countdown("CALM", D.Calm, waveHeight, cycleNumber)
            remote:FireAllClients("Warning", "SIREN: Tsunami incoming! Your base or high ground is safe.")
            for secondsLeft = D.Warning, 1, -1 do
                publish("WARNING", secondsLeft, waveHeight, cycleNumber)
                if secondsLeft == 2 then
                    remote:FireAllClients("Shake", {
                        Duration = 2,
                        Strength = 0.2 + waveHeight / 90,
                    })
                end
                task.wait(1)
            end

            local waterWall = world.Part(
                "TsunamiWall",
                Vector3.new(340, waveHeight, 13),
                Vector3.new(0, waveHeight / 2, -170),
                Color3.fromRGB(47, 179, 235),
                "Wave",
                Enum.Material.Glass
            )
            waterWall.Transparency = 0.35
            waterWall.CanCollide = false
            waterWall.CanTouch = false
            waterWall.CastShadow = false

            local crest = world.Part(
                "WaveFoam",
                Vector3.new(340, 1, 14),
                Vector3.new(0, waveHeight, -170),
                Color3.fromRGB(216, 251, 255),
                "Wave",
                Enum.Material.Neon
            )
            crest.CanCollide = false
            crest.CanTouch = false

            local penalized = {}
            local trailingZ = -170
            local beganAt = os.clock()
            local publishedSecond = -1
            while os.clock() - beganAt < D.Sweep do
                local sweepElapsed = os.clock() - beganAt
                local leadingZ = -170 + 340 * math.min(sweepElapsed / D.Sweep, 1)
                waterWall.Position = Vector3.new(0, waveHeight / 2, leadingZ)
                crest.Position = Vector3.new(0, waveHeight, leadingZ)
                local secondsLeft = math.ceil(D.Sweep - sweepElapsed)
                if secondsLeft ~= publishedSecond then
                    publish("SWEEP", secondsLeft, waveHeight, cycleNumber)
                    publishedSecond = secondsLeft
                end

                for _, participant in ipairs(Players:GetPlayers()) do
                    local avatar = participant.Character
                    local pivot = avatar and avatar:FindFirstChild("HumanoidRootPart")
                    local living = avatar and avatar:FindFirstChildOfClass("Humanoid")
                    if pivot and living and living.Health > 0 and not penalized[participant] then
                        local location = pivot.Position
                        if math.abs(location.X) <= 170
                            and location.Z >= trailingZ - 7
                            and location.Z <= leadingZ + 7
                            and location.Y - 2 < waveHeight
                            and not base.IsHome(participant, location) then
                            penalized[participant] = true
                            base.Drop(participant)
                            economy.Penalize(participant)
                            remote:FireClient(participant, "Caught", location)
                            remote:FireClient(participant, "Toast", "Swept away! Lost your carried creature and 5% cash.")
                        end
                    end
                end
                trailingZ = leadingZ
                RunService.Heartbeat:Wait()
            end
            waterWall:Destroy()
            crest:Destroy()
        end
    end)
end

return Wave
