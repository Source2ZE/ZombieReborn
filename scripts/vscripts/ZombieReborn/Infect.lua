ZR_INFECT_DAMAGE = 3141

function Infect(hInflictor, hInfected, bKeepPosition, bDead)
    DebugPrint("Infecting a player")

    local vecOrigin = hInfected:GetOrigin()
    local vecAngles = hInfected:EyeAngles()

    --Human was already killed by the knife itself, delay the infection a bit
    if bDead then
        InfectAsync(hInfected, bKeepPosition, false)
        return
    elseif hInfected:GetHealth() == 0 then
        --Infect was called on a spectator somehow during initial infection, nope out
        print("Attempted to infect a spectator!")
        return
    end

    --Give proper kill credit
    --By killing the player before they suicide from SetTeam
    if hInflictor then
        DebugPrint("Infected player was knifed by a zombie")
        --SOS: Cannot get hAttacker to work
        --CTakeDamageInfo CreateDamageInfo (handle hInflictor, handle hAttacker, Vector force, Vector hitPos, float flDamage, int damageTypes)
        local cDamageInfo = CreateDamageInfo(hInflictor, nil, Vector(0, 0, 100), Vector(0, 0, 0), ZR_INFECT_DAMAGE, DMG_BULLET)
        hInfected:TakeDamage(cDamageInfo)
        DestroyDamageInfo(cDamageInfo)
    else
        DebugPrint("Infected player has spawned late")
    end

    hInfected:SetTeam(CS_TEAM_T)

    -- Asynchronously kill any utils held by the infected player AND any nades threwn by said player
    local tHeldWeapons = hInfected:GetEquippedWeapons()
    for _, hWeapon in ipairs(tHeldWeapons) do
        if hWeapon and hWeapon:GetClassname() ~= "weapon_knife" then
            DoEntFireByInstanceHandle(hWeapon, "Kill", "", 0.02, nil, nil)
        end
    end

    local tThrewnNades = Entities:FindAllByClassname("hegrenade_projectile")
    for __, hProjectile in ipairs(tThrewnNades) do
        if hProjectile and hProjectile:GetOwner() == hInfected then
            DoEntFireByInstanceHandle(hProjectile, "Kill", "", 0.02, nil, nil)
        end
    end

    DebugPrint("Setting regular zombie class")
    InjectPlayerClass(PickRandomZombieDefaultClass(), hInfected)

    if bKeepPosition == false then
        DebugPrint("Infection is not in-place")
        return
    end
    hInfected:SetOrigin(vecOrigin)
    hInfected:SetAngles(vecAngles.x, vecAngles.y, vecAngles.z)
end

tMZList = {}
function InfectMotherZombie(hInfected, bKeepPosition)
    DebugPrint("Infecting a player to mother zombie")

    if hInfected:GetHealth() == 0 then
        --Infect was called on a spectator somehow during initial infection, nope out
        print("Attempted to infect a spectator!")
        return
    end

    local vecOrigin = hInfected:GetOrigin()
    local vecAngles = hInfected:EyeAngles()

    tMZList[hInfected] = true
    hInfected:SetTeam(CS_TEAM_NONE)
    hInfected:SetTeam(CS_TEAM_T)

    -- Asynchronously kill any utils held by the infected player AND any nades threwn by said player
    local tHeldWeapons = hInfected:GetEquippedWeapons()
    for _, hWeapon in ipairs(tHeldWeapons) do
        if hWeapon and hWeapon:GetClassname() ~= "weapon_knife" then
            DoEntFireByInstanceHandle(hWeapon, "Kill", "", 0.02, nil, nil)
        end
    end

    local tThrewnNades = Entities:FindAllByClassname("hegrenade_projectile")
    for __, hProjectile in ipairs(tThrewnNades) do
        if hProjectile and hProjectile:GetOwner() == hInfected then
            DoEntFireByInstanceHandle(hProjectile, "Kill", "", 0.02, nil, nil)
        end
    end

    DebugPrint("Setting mother zombie class")
    InjectPlayerClass(ZRClass.Zombie.MotherZombie, hInfected)

    tMZList[hInfected] = nil
    if bKeepPosition == false then
        DebugPrint("Infection is not in-place")
        return
    end
    hInfected:SetOrigin(vecOrigin)
    hInfected:SetAngles(vecAngles.x, vecAngles.y, vecAngles.z)
end

function InfectAsync(hInfected, bKeepPosition, bKilled)
    DoEntFireByInstanceHandle(hInfected, "runscriptcode", "Infect(nil, thisEntity, " .. tostring(bKeepPosition) .. "," .. tostring(bKilled) .. ")", 0.01, nil, nil)
end

tCureList = {}
function Cure(hPlayer, bKeepPosition)
    DebugPrint("Curing a player")

    local vecOrigin = hPlayer:GetOrigin()
    local vecAngles = hPlayer:EyeAngles()

    tCureList[hPlayer] = true
    hPlayer:SetTeam(CS_TEAM_NONE)
    hPlayer:SetTeam(CS_TEAM_CT)
    InjectPlayerClass(PickRandomHumanDefaultClass(), hPlayer)
    tCureList[hPlayer] = nil
    if bKeepPosition == false then
        DebugPrint("Curing is not in-place")
        return
    end
    hPlayer:SetOrigin(vecOrigin)
    hPlayer:SetAngles(vecAngles.x, vecAngles.y, vecAngles.z)
end

function CureAsync(hPlayer, bKeepPosition)
    DoEntFireByInstanceHandle(hPlayer, "runscriptcode", "Cure(thisEntity, " .. tostring(bKeepPosition) .. ")", 0.01, nil, nil)
end

function Infect_PickMotherZombies()
    DebugPrint("Picking mother zombies...")

    --tell OnPlayerSpawn to not force switch human who's been picked as mother zombie
    ZR_ZOMBIE_SPAWN_READY = true

    local iMZRatio = Convars:GetInt("zr_infect_spawn_mz_ratio")
    local iMZMinimumCount = Convars:GetInt("zr_infect_spawn_mz_min_count")
    local bSpawnType = (Convars:GetInt("zr_infect_spawn_type") == 0)
    local tPlayerTable = Entities:FindAllByClassname("player")
    local iPlayerCount = #tPlayerTable --also counting spectators
    local iMotherZombieCount = math.floor(iPlayerCount / iMZRatio)
    local tMotherZombies = {}

    if iMotherZombieCount < iMZMinimumCount then
        iMotherZombieCount = iMZMinimumCount
    end

    local iRemovedPlayers = 0

    -- remove players that belong to invalid teams from player table before proceeding with first infection logic
    for i = iPlayerCount, 1, -1 do
        if tPlayerTable[i]:GetTeam() < 2 then
            table.remove(tPlayerTable, i)
            iRemovedPlayers = iRemovedPlayers + 1
        end
    end

    DebugPrint("Infect_PickMotherZombies: Removed " .. iRemovedPlayers .. " invalid players from initial infection")
    DebugPrint("Infect_PickMotherZombies: Picking " .. iMotherZombieCount .. " mother zombies")

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

        DebugPrint("Infect_PickMotherZombies:PickMotherZombies: Shuffling player table")
        local tPlayerTableShuffled = table.shuffle(vlua.clone(tPlayerTable))

        for idx = 1, #tPlayerTableShuffled do
            local hPlayer = tPlayerTableShuffled[idx]
            local tPlayerScope = hPlayer:GetOrCreatePrivateScriptScope()

            local iSkipChance = tPlayerScope.MZSpawn_SkipChance or 0
            -- if MZSpawn_SkipChance is not initialized, then the if below is guaranteed to not pass
            -- Roll for player's chance to skip being picked as MZ
            if RandomInt(1, 100) <= iSkipChance then
                -- player succeeded the roll and avoided being picked as MZ
                DebugPrint("Infect_PickMotherZombies:PickMotherZombies: Skipping a player during initial infection selection (SkipChance = " .. iSkipChance .. "%)")
            else
                -- player failed the roll, pick him as MZ and set his Skip Chance to 100%
                DebugPrint("Infect_PickMotherZombies:PickMotherZombies: Inserting a player into initial infection (SkipChance = " .. iSkipChance .. "%)")
                tPlayerScope.MZSpawn_SkipChance = 100
                table.insert(tMotherZombies, hPlayer)

                -- remove player from players table so they can't be chosen again
                table.RemoveValue(tPlayerTable, hPlayer)
            end

            if #tMotherZombies == iMotherZombieCount then
                return
            end
        end
    end

    local iFailSafeCounter = 5

    repeat
        -- If we somehow don't have enough mother zombies after going through the players table 5 times,
        -- set Skip Chance of everyone but already picked mother zombies to 0
        if iFailSafeCounter == 0 then
            DebugPrint("Infect_PickMotherZombies: Not enough mother zombies after calling PickMotherZombies 5 times, resetting everyone's Skip Chance")
            for i = 1, #tPlayerTable do
                tPlayerTable[i]:GetOrCreatePrivateScriptScope().MZSpawn_SkipChance = 0
            end
        end
        iFailSafeCounter = iFailSafeCounter - 1

        DebugPrint("Infect_PickMotherZombies: Calling PickMotherZombies with " .. #tMotherZombies .. " out of " .. iMotherZombieCount .. " mother zombies chosen")
        PickMotherZombies()
    until #tMotherZombies == iMotherZombieCount

    -- Reduce the Skip Chance of everyone but mother zombies picked in current round
    -- tPlayerTable here contains only players who were not chosen to be mother zombies
    for i = 1, #tPlayerTable do
        local scope = tPlayerTable[i]:GetOrCreatePrivateScriptScope()
        if scope.MZSpawn_SkipChance then
            scope.MZSpawn_SkipChance = scope.MZSpawn_SkipChance - 20
        end
    end

    -- can iterate over the tMotherZombies here to print players who got picked as MZ to console
    -- (in the future, when we surely get access to player's steamid and nickname from lua)

    DebugPrint("Infect_PickMotherZombies: Infecting mother zombies")

    -- Mother zombie spawned
    ZR_ZOMBIE_SPAWNED = true

    for index, player in pairs(tMotherZombies) do
        if Convars:GetInt("zr_infect_spawn_crash_fix") == 1 then
            DoEntFireByInstanceHandle(player, "SetHealth", "0", 0.01, nil, nil)
        else
            -- add a small delay between each just to be extra safe
            DoEntFireByInstanceHandle(player, "RunScriptCode", "InfectMotherZombie(thisEntity, " .. tostring(bSpawnType) .. ")", 0.05 * index, nil, nil)
        end
    end
    print("Player count: " .. iPlayerCount .. ", Mother Zombies Spawned: " .. iMotherZombieCount)
end

function Infect_OnRoundFreezeEnd()
    local iMZSpawntimeMinimum = Convars:GetInt("zr_infect_spawn_time_min")
    local iMZSpawntimeMaximum = Convars:GetInt("zr_infect_spawn_time_max")
    local iMZSpawntime = RandomInt(iMZSpawntimeMinimum, iMZSpawntimeMaximum)

    -- announce time remaining to infection and do infection at countdown<=0
    local MZSelection_Countdown = iMZSpawntime
    Timers:CreateTimer("MZSelection_Timer", {
        callback = function()
            if MZSelection_Countdown <= 0 then
                ScriptPrintMessageCenterAll("First infection has started!")
                ScriptPrintMessageChatAll(" \x04[Zombie:Reborn]\x01 First infection has started! Good luck, survivors!")
                Infect_PickMotherZombies()
                Timers:RemoveTimer("MZSelection_Timer")
            elseif MZSelection_Countdown <= 15 then
                if MZSelection_Countdown == 1 then
                    ScriptPrintMessageCenterAll("First infection in \x071 second\x01!")
                else
                    ScriptPrintMessageCenterAll("First infection in \x07" .. MZSelection_Countdown .. " seconds\x01!")
                end
                if MZSelection_Countdown % 5 == 0 then
                    ScriptPrintMessageChatAll(" \x04[Zombie:Reborn]\x01 First infection in \x07" .. MZSelection_Countdown .. " seconds\x01!")
                end
            end
            MZSelection_Countdown = MZSelection_Countdown - 1
            return 1
        end,
    })
end
