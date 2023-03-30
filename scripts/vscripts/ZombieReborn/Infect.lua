function Infect(hInfected, bKeepPosition)
    local vecOrigin = hInfected:GetOrigin()
    local vecAngles = hInfected:EyeAngles()
    hInfected:SetTeam(CS_TEAM_T)
    if bKeepPosition == false then return end
    hInfected:SetOrigin(vecOrigin)
    hInfected:SetAngles(vecAngles.x, vecAngles.y, vecAngles.z)
end

function Infect_PickMotherZombies()
    local iMZRatio = (Convars:GetInt("zr_infect_spawn_mz_ratio") or iInfectSpawnMZRatio)
    local iMZMinimumCount = (Convars:GetInt("zr_infect_spawn_mz_min_count") or iInfectSpawnMZMinCount)
    local bSpawnType = ((Convars:GetInt("zr_infect_spawn_type") or iInfectSpawnType) == 0)
    local tPlayerTable = Entities:FindAllByClassname("player")
    local iPlayerCount = #tPlayerTable--also counting spectators
    local iMotherZombieCount = math.floor(iPlayerCount / iMZRatio)
    local tMotherZombies = {}

    if iMotherZombieCount < iMZMinimumCount then iMotherZombieCount = iMZMinimumCount end

    -- make players who've been picked as MZ recently less likely to be picked again
    -- store a variable in player's script scope, which gets initialized with value 100 if they are picked to be a mother zombie
    -- the value represents a % chance of the player being skipped next time they are picked to be a mother zombie
    -- If the player is skipped, next random player is picked to be mother zombie (and same skip chance logic applies to him)
    -- the variable gets decreased by 20 every round (if it exists inside player's scope)
    local function PickMotherZombies()
        
        -- No players to choose from
        if tPlayerTable == nil or #tPlayerTable == 0 then
            iMotherZombieCount = #tMotherZombies
            return
        end
        
        local tPlayerTableShuffled = table.shuffle(tPlayerTable)

        for idx = 1, #tPlayerTableShuffled do
            local hPlayer = tPlayerTableShuffled[idx]
            local tPlayerScope = hPlayer:GetOrCreatePrivateScriptScope()

            local iSkipChance = tPlayerScope.MZSpawn_SkipChance or 0
            -- if MZSpawn_SkipChance is not initialized, then the if below is guaranteed to not pass
            -- Roll for player's chance to skip being picked as MZ
            if math.random(1, 100) <= iSkipChance then
                -- player succeeded the roll and avoided being picked as MZ,
                -- reduce the value of his SkipChance script scope variable (just for good measure)
                tPlayerScope.MZSpawn_SkipChance = tPlayerScope.MZSpawn_SkipChance - 20
            else
                -- player failed the roll, pick him as MZ and initialize/refresh value of the SkipChance variable in his script scope
                tPlayerScope.MZSpawn_SkipChance = 100
                table.insert(tMotherZombies, hPlayer)
                
                -- remove player from players table so they can't be chosen again
                table.RemoveValue(tPlayerTable, hPlayer)
            end

            if #tMotherZombies == iMotherZombieCount then return end
        end
    end

    repeat PickMotherZombies() until #tMotherZombies == iMotherZombieCount

    -- can iterate over the tMotherZombies here to print players who got picked as MZ to console
    -- (in the future, when we surely get access to player's steamid and nickname from lua)

    for index,player in pairs(tMotherZombies) do
        Infect(player,bSpawnType)
    end
    print("Player count: " .. iPlayerCount .. ", Mother Zombies Spawned: " .. iMotherZombieCount)
end

-- hook this to OnRoundStart in main script
function Infect_OnRoundStart()
    local iMZSpawntimeMinimum = (Convars:GetInt("zr_infect_spawn_time_min") or iInfectSpawntimeMin)
    local iMZSpawntimeMaximum = (Convars:GetInt("zr_infect_spawn_time_max") or iInfectSpawntimeMax)
    local iMZSpawntime = math.random(iMZSpawntimeMinimum,iMZSpawntimeMaximum)

    -- reduce mother zombie spawn skip chance for players who have that variable in their script scope
    for k,player in pairs(Entities:FindAllByClassname("player")) do
        local scope = player:GetOrCreatePrivateScriptScope()
        if scope.MZSpawn_SkipChance then scope.MZSpawn_SkipChance = scope.MZSpawn_SkipChance - 20 end
    end

    -- announce time remaining to infection and do infection at countdown<=0
    local MZSelection_Countdown = iMZSpawntime
    Timers:CreateTimer("MZSelection_Timer",{
        callback = function()
            if MZSelection_Countdown <= 0 then
                ScriptPrintMessageCenterAll("First infection has started!")
                ScriptPrintMessageChatAll(" \x04[Zombie:Reborn]\x01 First infection has started! Good luck, survivors!")
                Infect_PickMotherZombies()
                Timers:RemoveTimer("MZSelection_Timer")
            elseif MZSelection_Countdown <= 15 then
                if MZSelection_Countdown == 1 then ScriptPrintMessageCenterAll("First infection in \x071 second\x01!")
                else ScriptPrintMessageCenterAll("First infection in \x07"..MZSelection_Countdown.." seconds\x01!") end
                if MZSelection_Countdown % 5 == 0 then
                    ScriptPrintMessageChatAll(" \x04[Zombie:Reborn]\x01 First infection in \x07"..MZSelection_Countdown.." seconds\x01!")
                end
            end
            MZSelection_Countdown = MZSelection_Countdown - 1
            return 1
        end
    })
end