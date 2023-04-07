print("Starting ZombieReborn!")

require("ZombieReborn.util.const")
require("ZombieReborn.util.functions")
require("ZombieReborn.util.timers")

require("ZombieReborn.PlayerClass")

require("ZombieReborn.Convars")
require("ZombieReborn.Infect")
require("ZombieReborn.Knockback")
require("ZombieReborn.RepeatKiller")
require("ZombieReborn.AmmoReplenish")

ZR_ROUND_STARTED = false
ZR_ZOMBIE_SPAWNED = false -- Check if first zombie spawned

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
    --Convars:SetInt('mp_ignore_round_win_conditions',1)

    ScriptPrintMessageChatAll("The game is \x05Humans vs. Zombies\x01, the goal for zombies is to infect all humans by knifing them.")

    SetAllHuman()
    SetupRepeatKiller()
    SetupAmmoReplenish()

    Timers:RemoveTimer("MZSelection_Timer")

    ZR_ROUND_STARTED = true
end

function SetAllHuman()
    Convars:SetBool("mp_respawn_on_death_ct", true)

    for i = 1, 64 do
        local hController = EntIndexToHScript(i)

        if hController ~= nil then
            hController:GetPawn():SetTeam(CS_TEAM_CT)
            --SetPlayerClass(hController:GetPawn(), "human")
            InjectPlayerClass(ZRClass.Human.Default, hController:GetPawn())
        end
    end

    Convars:SetBool("mp_respawn_on_death_ct", false)
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

    --Prevent Infecting the player in the same tick as the player dying
    if hAttacker:GetTeam() == CS_TEAM_T and hVictim:GetTeam() == CS_TEAM_CT then
        DoEntFireByInstanceHandle(hVictim, "runscriptcode", "Infect(nil, thisEntity, true)", 0.01, nil, nil)
    end

    -- Infect Humans that died after first infection has started
    if ZR_ROUND_STARTED and ZR_ZOMBIE_SPAWNED and hVictim:GetTeam() == CS_TEAM_CT then
        --Prevent Infecting the player in the same tick as the player dying
        DoEntFireByInstanceHandle(hVictim, "runscriptcode", "Infect(nil, thisEntity, false)", 0.01, nil, nil)
    end

    --Allow the round to end if there's no CT left
    --ignore if zombie has yet to spawn
    if not ZR_ZOMBIE_SPAWNED then
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

-- Infect late spawners
function OnPlayerSpawn(event)
    --__DumpScope(0, event)
    local hPlayer = EHandleToHScript(event.userid_pawn)

    if ZR_ZOMBIE_SPAWNED and hPlayer:GetTeam() == CS_TEAM_CT then
        Infect(nil, hPlayer, true)
    end
end

function OnItemEquip(event)
    --__DumpScope(0, event)
    local hPlayer = EHandleToHScript(event.userid_pawn)

    if ZR_ZOMBIE_SPAWNED and hPlayer:GetTeam() == CS_TEAM_T then
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
