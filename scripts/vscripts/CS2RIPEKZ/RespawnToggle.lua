bRespawnToggle = false

-- Not gonna use this but keeping anyway
function SetupRespawnToggler()
    bRespawnToggle = false
    local tKeyValues = {}
    tKeyValues.targetname = "zr_toggle_respawn"
    hRelay = SpawnEntityFromTableSynchronous("logic_relay", tKeyValues)
    hRelay:RedirectOutput("OnTrigger", "ToggleRespawn", hRelay)
end

function ToggleRespawn()
    if bRespawnToggle == false then
        Convars:SetInt("mp_respawn_on_death_t", 0)
        Convars:SetInt("mp_respawn_on_death_ct", 0)
        ScriptPrintMessageChatAll(" \x04[Zombie:Reborn]\x01 Respawning is disabled!")
    end
    if bRespawnToggle == true then
        Convars:SetInt("mp_respawn_on_death_t", 1)
        Convars:SetInt("mp_respawn_on_death_ct", 1)
        ScriptPrintMessageChatAll(" \x04[Zombie:Reborn]\x01 Respawning is enabled!")
    end
    bRespawnToggle = not bRespawnToggle
end
