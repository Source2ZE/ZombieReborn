print("Starting CS2RIPEKZ!")

require("CS2RIPEKZ.util.const")
require("CS2RIPEKZ.util.functions")
require("CS2RIPEKZ.util.timers")

require("CS2RIPEKZ.Convars")

Convars:SetInt("mp_autoteambalance", 0)
Convars:SetInt("mp_limitteams", 0)

--remove duplicated listeners upon manual reload
if tListenerIds then
    for k, v in ipairs(tListenerIds) do
        StopListeningToGameEvent(v)
    end
end

DebugPrint("CS2RIPEKZ loaded!")

--Load a custom map config, if it exists
SendToServerConsole("exec " .. "kz/maps/" .. GetMapName() .. ".cfg")

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
    Convars:SetInt("mp_give_player_c4", 0)
    Convars:SetInt("mp_friendlyfire", 0)
    Convars:SetInt("mp_respawn_on_death_t", 1)
    Convars:SetInt("mp_respawn_on_death_ct", 1)
    Convars:SetStr("bot_quota_mode", "fill")
    Convars:SetInt('mp_ignore_round_win_conditions',1)

    --print("Enabling spawn for T")
    ScriptPrintMessageChatAll("The game is \x05KZ\x01, the goal is to jump good.")

    --Timers:RemoveTimer("MZSelection_Timer")
end

function OnPlayerSpawn(event)

end

tListenerIds = {
    ListenToGameEvent("player_spawn", OnPlayerSpawn, nil),
    ListenToGameEvent("round_start", OnRoundStart, nil)
}
