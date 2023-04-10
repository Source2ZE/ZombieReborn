print("Starting ZombieReborn!")

require("ZombieReborn.util.const")
require("ZombieReborn.util.functions")
require("ZombieReborn.util.timers")

require("ZombieReborn.Convars")
require("ZombieReborn.Infect")
require("ZombieReborn.Knockback")
require("ZombieReborn.RepeatKiller")
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

    --print("Enabling spawn for T")

    Convars:SetInt("mp_respawn_on_death_t", 1)
    Convars:SetInt("mp_respawn_on_death_ct", 1)
    --Convars:SetInt('mp_ignore_round_win_conditions',1)

    ScriptPrintMessageChatAll("The game is \x05Humans vs. Zombies\x01, the goal for zombies is to infect all humans by knifing them.")
    
    SetAllHuman()
    SetupRepeatKiller()
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
    if event.weapon == "" or event.attacker_pawn == -1 then
        return
    end
    local hAttacker = EHandleToHScript(event.attacker_pawn)
    local hVictim = EHandleToHScript(event.userid_pawn)

    if hAttacker:GetTeam() == CS_TEAM_T and hVictim:GetTeam() == CS_TEAM_CT then
        --Prevent Infecting the player in the same tick as the player is dying
        InfectAsync(hVictim, true)
    end

    -- Infect Humans that died after first infection has started
    if ZR_ROUND_STARTED and ZR_ZOMBIE_SPAWNED and hVictim:GetTeam() == CS_TEAM_CT then
        InfectAsync(hVictim, false)
    end

    --Allow the round to end if there's no CT left
    --ignore if zombie has yet to spawn or event come from zombie
    if not ZR_ZOMBIE_SPAWNED or hVictim:GetTeam() == CS_TEAM_T then
        return
    end

    local tPlayerTable = Entities:FindAllByClassname("player")
    for _, player in ipairs(tPlayerTable) do
        if player:GetTeam() == CS_TEAM_CT then
            --ignore if the player on ct team is the current hVictim
            --since they have yet to switch team from Infect
            if player ~= hVictim and player:IsAlive() then
                return
            end
        end
    end

    --print("Disabling spawn for T")
    --Side effect: the last player infected/died doesn't respawn until the next round start
    Convars:SetInt("mp_respawn_on_death_t", 0)
end

function OnPlayerSpawn(event)
    --__DumpScope(0, event)
    local hPlayer = EHandleToHScript(event.userid_pawn)

    -- Infect late spawners & change mother zombie who died back to normal zombie
    if ZR_ZOMBIE_SPAWNED then
        --Delay this too since sometime sethealth on player doesn't work
        InfectAsync(hPlayer, false)
        return
    end

    -- force switch team for player who tries to join the T side
    if not ZR_ZOMBIE_SPAWN_READY and hPlayer:GetTeam() == CS_TEAM_T then
        --print("Forcing player to ct")
        CureAsync(hPlayer, false)
    end
        
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
}
