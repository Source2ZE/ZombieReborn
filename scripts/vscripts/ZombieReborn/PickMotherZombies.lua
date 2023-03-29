iMZSpawnType = 1
iMZSpawntimeMinimum = 20
iMZSpawntimeMaximum = 25
iHumanToZombieSpawnRatio = 14
iMinimumMotherZombieCount = 2

Convars:RegisterConvar("zr_spawn_type", tostring(iMZSpawnType), "Type of Mother Zombies Spawn [0 = MZ spawn where they stand, 1 = MZ get teleported back to spawn on being picked]", 0)
Convars:RegisterConvar("zr_spawn_time_minimum", tostring(iMZSpawntimeMinimum), "Minimum time in which Mother Zombies should be picked, after round start", 0)
Convars:RegisterConvar("zr_spawn_time_maximum", tostring(iMZSpawntimeMaximum), "Maximum time in which Mother Zombies should be picked, after round start", 0)
Convars:RegisterConvar("zr_spawn_human_mz_ratio", tostring(iHumanToZombieSpawnRatio), "Ratio of all Players to Mother Zombies to be spawned at round start", 0)
Convars:RegisterConvar("zr_spawn_mz_minimum_count", tostring(iMinimumMotherZombieCount), "Minimum amount of Mother Zombies to be spawned at round start", 0)

function PickAndInfectMotherZombies ()
    local iMZRatio = (Convars:GetInt("zr_spawn_human_mz_ratio") or iHumanToZombieSpawnRatio)
    local iMZMinimumCount = (Convars:GetInt("zr_spawn_mz_minimum_count") or iMinimumMotherZombieCount)
    local boolSpawnType = ((Convars:GetInt("zr_spawn_type") or iSpawnType) == 0)
    local tPlayerTable = Entities:FindAllByClassname("player")
    local iPlayerCount = table.getn(tPlayerTable)--also counting spectators
    local iMotherZombieCount = math.floor(iPlayerCount / iMZRatio)
    local tMotherZombies = {}

    if iMotherZombieCount < iMZMinimumCount then iMotherZombieCount = iMZMinimumCount end

    -- attempt to replicate the "players being less likely to be picked for mz if they've been picked recently" system
    -- store a variable in player's script scope, which gets initialized with value 100 if they are picked to be a mother zombie
    -- the value represents a % chance of the player being skipped next time they are picked to be a mother zombie 
    -- If the player is skipped, next random player is picked to be mother zombie (and same skip chance logic applies to him)
    -- the variable gets decreased by 20 every round (if it exists inside player's scope)
    repeat
        local hPlayer = tPlayerTable[math.random(1,iPlayerCount)]
        local tPlayerScope = hPlayer:GetOrCreatePrivateScriptScope()
        local iSkipChance = tPlayerScope.MZSpawn_SkipChance or 0
        -- if MZSpawn_SkipChance is not initialized, then the if below is guaranteed to not pass
        -- Roll for player's chance to skip being picked as MZ
        if math.random(1,100) <= iSkipChance then
            -- player succeeded the roll and avoided being picked as MZ,
            -- reduce the value of his SkipChance script scope variable (just for good measure)
            tPlayerScope.MZSpawn_SkipChance = tPlayerScope.MZSpawn_SkipChance - 20
        else
            -- player failed the roll, pick him as MZ and initialize/refresh value of the SkipChance variable in his script scope
            tPlayerScope.MZSpawn_SkipChance = 100
            table.insert(tMotherZombies,hPlayer)
        end
        -- if hPlayer hasn't been picked as MZ,
        -- then repeat ... until loop will just run again, UNTIL there are desired amount of mother zombies picked
    until table.getn(tMotherZombies) == iMotherZombieCount

    -- can iterate over the tMotherZombies here to print players who got picked as MZ to console
    -- (in the future, when we surely get access to player's steamid and nickname from lua)

    for index,player in pairs(tMotherZombies) do
        Infect(player,boolSpawnType)
    end
    print("Player count: " .. iPlayerCount .. ", Mother Zombies Spawned: " .. iMotherZombieCount)
end

-- hook this to OnRoundStart in main script
function MZSelection_OnRoundStart ()
    local iMZSpawntimeMinimum = (Convars:GetInt("zr_spawn_time_minimum") or iMZSpawntimeMinimum)
    local iMZSpawntimeMaximum = (Convars:GetInt("zr_spawn_time_maximum") or iMZSpawntimeMaximum)
    local iMZSpawntime = math.random(iMZSpawntimeMinimum,iMZSpawntimeMaximum)
    print(iMZSpawntime)

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
                ScriptPrintMessageCenterAll(" \x04[Zombie:Reborn]\x01 Mother Zombies have spawned!")
                ScriptPrintMessageChatAll(" \x04[Zombie:Reborn]\x01 Mother Zombies have spawned! Good luck, survivors!")
                PickAndInfectMotherZombies()
                Timers:RemoveTimer("MZSelection_Timer")
            elseif MZSelection_Countdown <= 15 then
                ScriptPrintMessageCenterAll("Mother Zombies will spawn in \x07"..MZSelection_Countdown.." seconds\x01!")
                if MZSelection_Countdown % 5 == 0 then
                    ScriptPrintMessageChatAll(" \x04[Zombie:Reborn]\x01 Mother Zombies will spawn in \x07"..MZSelection_Countdown.." seconds\x01!")
                end
            end
            MZSelection_Countdown = MZSelection_Countdown - 1
            return 1
        end
    })
end