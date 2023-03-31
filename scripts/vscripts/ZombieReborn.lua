print("Starting ZombieReborn!")

require "ZombieReborn.util.const"
require "ZombieReborn.util.functions"
require "ZombieReborn.util.timers"

require "ZombieReborn.Convars"
require "ZombieReborn.Infect"
require "ZombieReborn.Knockback"
require "ZombieReborn.RepeatKiller"

ZR_ROUND_STARTED = false
ZR_ZOMBIE_SPAWNED = false -- Check if first zombie spawned

Convars:SetInt("mp_autoteambalance",0)
Convars:SetInt("mp_limitteams",0)

--remove duplicated listeners upon manual reload
if tListenerIds then
    for k, v in ipairs(tListenerIds) do
        StopListeningToGameEvent(v)
    end
end

-- round start logic
function OnRoundStart(event)
    ZR_ZOMBIE_SPAWNED = false

    world = Entities:FindByClassname(nil,"worldent")

    Convars:SetInt("mp_respawn_on_death_t",1)
    Convars:SetInt('mp_ignore_round_win_conditions',1)
    ScriptPrintMessageChatAll("The game is \x05Humans vs. Zombies\x01, the goal for zombies is to infect all humans by knifing them.")
    SetAllHuman()
    SetupRepeatKiller()
    ZR_ROUND_STARTED = true
end

function SetAllHuman()
    Convars:SetBool("mp_respawn_on_death_ct", true)

    for i = 1, 64 do
        local hController = EntIndexToHScript(i)

        if hController ~= nil then
            hController:GetPawn():SetTeam(CS_TEAM_CT)
        end
    end

    Convars:SetBool("mp_respawn_on_death_ct", false)
end

function OnPlayerHurt(event)
    --__DumpScope(0, event)
    if event.weapon == "" or event.attacker_pawn == nil then return end
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
    if event.weapon == "" or event.attacker_pawn == -1 then return end
    local hAttacker = EHandleToHScript(event.attacker_pawn)
    local hVictim = EHandleToHScript(event.userid_pawn)

    --Prevent Infecting the player in the same tick as the player dying
    if hAttacker:GetTeam() == CS_TEAM_T and hVictim:GetTeam() == CS_TEAM_CT then
        DoEntFireByInstanceHandle(hVictim, "runscriptcode", "Infect(nil, thisEntity, true)", 0, nil, nil)
    end

    -- Infect Humans that died after first infection has started
    if ZR_ROUND_STARTED and ZR_ZOMBIE_SPAWNED and hVictim:GetTeam() == CS_TEAM_CT then
        --Prevent Infecting the player in the same tick as the player dying
        DoEntFireByInstanceHandle(hVictim, "runscriptcode", "Infect(nil, thisEntity, false)", 0.1, nil, nil)
    end
end

tListenerIds = {
    ListenToGameEvent("player_hurt", OnPlayerHurt, nil),
    ListenToGameEvent("player_death", OnPlayerDeath, nil),
    ListenToGameEvent("round_start", OnRoundStart, nil),
    ListenToGameEvent("hegrenade_detonate", Knockback_OnGrenadeDetonate, nil),
    ListenToGameEvent("molotov_detonate", Knockback_OnMolotovDetonate, nil),
    ListenToGameEvent("round_freeze_end", Infect_OnRoundFreezeEnd, nil)
}