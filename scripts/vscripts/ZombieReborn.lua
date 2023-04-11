print("Starting ZombieReborn!")

require("ZombieReborn.util.const")
require("ZombieReborn.util.functions")
require("ZombieReborn.util.timers")

require("ZombieReborn.Convars")
require("ZombieReborn.Infect")
require("ZombieReborn.Knockback")
require("ZombieReborn.RespawnToggle")
require("ZombieReborn.AmmoReplenish")
require("ZombieReborn.PlayerClass")

ZR_ROUND_STARTED = false
ZR_ZOMBIE_SPAWNED = false -- Check if first zombie spawned
ZR_ZOMBIE_SPAWN_READY = false -- Check if first zombie is spawning

Convars:SetInt("mp_autoteambalance", 0)
Convars:SetInt("mp_limitteams", 0)

--remove duplicated listeners upon manual reload
if tListenerIds then
    for k, v in ipairs(tListenerIds) do
        StopListeningToGameEvent(v)
    end
end

-- round start logic
function OnRoundStart(event)
    -- Make sure point_clientcommand exists
    clientcmd = Entities:FindByClassname(nil, "point_clientcommand")

    if clientcmd == nil then
        clientcmd = SpawnEntityFromTableSynchronous("point_clientcommand", { targetname = "vscript_clientcommand" })
    end

    --Here we force some cvars that are essential for the scripts to work
    Convars:SetInt("mp_weapons_allow_pistols", 3)
    Convars:SetInt("mp_weapons_allow_smgs", 3)
    Convars:SetInt("mp_weapons_allow_heavy", 3)
    Convars:SetInt("mp_weapons_allow_rifles", 3)

    Convars:SetInt("mp_respawn_on_death_t", 1)
    Convars:SetInt("mp_respawn_on_death_ct", 1)
    --Convars:SetInt('mp_ignore_round_win_conditions',1)

    --print("Enabling spawn for T")
    ScriptPrintMessageChatAll("The game is \x05Humans vs. Zombies\x01, the goal for zombies is to infect all humans by knifing them.")

    --Setup various functions and gameplay elements
    SetAllHuman()
    SetupRespawnToggler()
    SetupAmmoReplenish()

    Timers:RemoveTimer("MZSelection_Timer")

    ZR_ROUND_STARTED = true
end

function SetAllHuman()
    local bRespawn = Convars:GetBool("mp_respawn_on_death_ct")
    Convars:SetBool("mp_respawn_on_death_ct", true)

    for i = 1, 64 do
        local hController = EntIndexToHScript(i)

        if hController ~= nil then
            Cure(hController:GetPawn(), true)
        end
    end

    Convars:SetBool("mp_respawn_on_death_ct", bRespawn)
end

function OnPlayerHurt(event)
    --__DumpScope(0, event)
    if event.weapon == "" or event.attacker_pawn == nil then
        return
    end
    local hAttacker = EHandleToHScript(event.attacker_pawn)
    local hVictim = EHandleToHScript(event.userid_pawn)

    if hAttacker:GetTeam() == CS_TEAM_CT and hVictim:GetTeam() == CS_TEAM_T then
        Knockback_Apply(hAttacker, hVictim, event.dmg_health, event.weapon)
    elseif hAttacker:GetTeam() == CS_TEAM_T and hVictim:GetTeam() == CS_TEAM_CT then
        Infect(hAttacker, hVictim, true)
    end
end

-- player_death doesn't have dmg_health, so it has a separate callback
function OnPlayerDeath(event)
    --__DumpScope(0, event)
    -- attacker_pawn == -1 when player died from trigger hurt
    -- if event.weapon == "" or event.attacker_pawn == -1 then
    --     return
    -- end
    local hAttacker = EHandleToHScript(event.attacker_pawn)
    local hVictim = EHandleToHScript(event.userid_pawn)

    --When player died from switching team, their GetTeam() is the team they are switching to
    --ignore zombie or during round start
    if not ZR_ZOMBIE_SPAWNED or hVictim:GetTeam() == CS_TEAM_T then
        return
    end

    --Allow the round to end if there's no CT left
    --ignore if zombie has yet to spawn or event come from zombie
    local tPlayerTable = Entities:FindAllByClassname("player")
    for _, player in ipairs(tPlayerTable) do
        if player:GetTeam() == CS_TEAM_CT then
            --return if the player on ct team is the current hVictim
            --since they have yet to switch team from Infect
            if player ~= hVictim and player:IsAlive() then
                return
            end
        end
    end

    --print("Disabling spawn for T")
    --Side effect: the last player infected/died doesn't respawn until the next round start
    Convars:SetInt("mp_respawn_on_death_t", 0)
    Convars:SetInt("mp_respawn_on_death_ct", 0)
end

function OnPlayerSpawn(event)
    --__DumpScope(0, event)
    local hPlayer = EHandleToHScript(event.userid_pawn)

    -- Infect late spawners & change mother zombie who died back to normal zombie
    if ZR_ZOMBIE_SPAWNED and tCureList[hPlayer] == nil then
        --Delay this too since sometime sethealth on player doesn't work
        InfectAsync(hPlayer, false)
        return
    end

    -- force switch team for player who tries to join the T side
    -- if not ZR_ZOMBIE_SPAWN_READY and hPlayer:GetTeam() == CS_TEAM_T then
    --     --print("Forcing player to ct")
    --     CureAsync(hPlayer, false)
    -- end
end

function OnItemEquip(event)
    --__DumpScope(0, event)
    local hPlayer = EHandleToHScript(event.userid_pawn)

    if hPlayer:GetTeam() == CS_TEAM_T then
        local tInventory = hPlayer:GetEquippedWeapons()

        for key, value in ipairs(tInventory) do
            if value:GetClassname() ~= "weapon_knife" then
                value:Destroy()
                DoEntFireByInstanceHandle(clientcmd, "command", "lastinv", 0.1, hPlayer, hPlayer)
            end
        end
    end
end

function OnRoundEnd(event)
    ZR_ZOMBIE_SPAWNED = false
    ZR_ZOMBIE_SPAWN_READY = false
end

function OnPlayerTeam(event)
    --__DumpScope(0, event)
    local hPlayer = EHandleToHScript(event.userid_pawn)
    if ZR_ZOMBIE_SPAWNED and event.team == CS_TEAM_CT and tCureList[hPlayer] == nil then
        --SetTeam doesn't work on the same tick as well :pepemeltdown:
        DoEntFireByInstanceHandle(hPlayer, "runscriptcode", "thisEntity:SetTeam(CS_TEAM_T)", 0.01, nil, nil)
    elseif not ZR_ZOMBIE_SPAWN_READY and event.team == CS_TEAM_T then
        DoEntFireByInstanceHandle(hPlayer, "runscriptcode", "thisEntity:SetTeam(CS_TEAM_CT)", 0.01, nil, nil)
    end
end

tListenerIds = {
    ListenToGameEvent("player_hurt", OnPlayerHurt, nil),
    ListenToGameEvent("player_death", OnPlayerDeath, nil),
    ListenToGameEvent("player_spawn", OnPlayerSpawn, nil),
    ListenToGameEvent("round_start", OnRoundStart, nil),
    ListenToGameEvent("hegrenade_detonate", Knockback_OnGrenadeDetonate, nil),
    ListenToGameEvent("molotov_detonate", Knockback_OnMolotovDetonate, nil),
    ListenToGameEvent("round_freeze_end", Infect_OnRoundFreezeEnd, nil),
    ListenToGameEvent("item_equip", OnItemEquip, nil),
    ListenToGameEvent("round_end", OnRoundEnd, nil),
    ListenToGameEvent("player_team", OnPlayerTeam, nil),
}
