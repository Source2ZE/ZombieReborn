print("Starting ZombieReborn!")

require "util.functions"
require "util.timers"
require "ZombieReborn.Convars"
require "ZombieReborn.Infect"
require "ZombieReborn.Knockback"

ZR_ROUND_STARTED = false

Convars:SetInt("mp_autoteambalance",0)
Convars:SetInt("mp_limitteams",0)

-- time after round start when tts should stop respawning
test_repeatkiller_time = 40

--remove duplicated listeners upon manual reload
if tListenerIds then
    for k, v in ipairs(tListenerIds) do
        StopListeningToGameEvent(v)
    end
end

-- round start logic
function OnRoundStart(event)
    Convars:SetInt("mp_respawn_on_death_t",1)
    Convars:SetInt('mp_ignore_round_win_conditions',1)
    ScriptPrintMessageChatAll("The game is \x05Humans vs. Zombies\x01, the goal for zombies is to infect all humans by knifing them.")
    SetAllHuman()
    Infect_OnRoundStart()
    DoEntFireByInstanceHandle(world,"RunScriptCode","Convars:SetInt('mp_respawn_on_death_t',0)",test_repeatkiller_time,nil,nil)
    DoEntFireByInstanceHandle(world,"RunScriptCode","Convars:SetInt('mp_ignore_round_win_conditions',0)",test_repeatkiller_time,nil,nil)
    DoEntFireByInstanceHandle(world,"RunScriptCode","Say(nil,'RepeatKiller activated',false)",test_repeatkiller_time,nil,nil)
    ZR_ROUND_STARTED = true
end

function SetAllHuman()
    Convars:SetBool("mp_respawn_on_death_ct", true)

    for i = 1, 64 do
        local hController = EntIndexToHScript(i)

        if hController ~= nil then
            local hPawn = hController:GetPawn():SetTeam(3)
        end
    end

    Convars:SetBool("mp_respawn_on_death_ct", false)
end

function OnPlayerHurt(event)
    --__DumpScope(0, event)
    if event.weapon == "" or event.attacker_pawn == nil then return end
    local hAttacker = EHandleToHScript(event.attacker_pawn)
    local hVictim = EHandleToHScript(event.userid_pawn)

    if hAttacker:GetTeam() == 3 and hVictim:GetTeam() == 2 then
        Knockback_Apply(hAttacker, hVictim, event.dmg_health, event.weapon)
    elseif hAttacker:GetTeam() == 2 and hVictim:GetTeam() == 3 then
        Infect(hVictim, true)
    end
end

-- player_death doesn't have dmg_health, so it has a separate callback
function OnPlayerDeath(event)
    --__DumpScope(0, event)
    if event.weapon == "" or event.attacker_pawn == -1 then return end
    local hAttacker = EHandleToHScript(event.attacker_pawn)
    local hVictim = EHandleToHScript(event.userid_pawn)

    if hAttacker:GetTeam() == 2 and hVictim:GetTeam() == 3 then
        Infect(hVictim, true)
    end
end

tListenerIds = {
    ListenToGameEvent("player_hurt", OnPlayerHurt, nil),
    ListenToGameEvent("player_death", OnPlayerDeath, nil),
    ListenToGameEvent("hegrenade_detonate", Knockback_OnGrenadeDetonate, nil),
    ListenToGameEvent("molotov_detonate", Knockback_OnMolotovDetonate, nil),
    ListenToGameEvent("round_start", OnRoundStart, nil)
}