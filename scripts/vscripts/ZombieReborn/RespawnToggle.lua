bRespawnToggle = false

--Maps should trigger this when they want to stop/start zombie respawning
--OnWhatever -> zr_toggle_respawn -> Trigger -> Delay 0 -> Once Only
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
        ScriptPrintMessageChatAll(tr(" \x04[Zombie:Reborn]\x01 Respawning is disabled!"))
    end
    if bRespawnToggle == true then
        Convars:SetInt("mp_respawn_on_death_t", 1)
        Convars:SetInt("mp_respawn_on_death_ct", 1)
        ScriptPrintMessageChatAll(tr(" \x04[Zombie:Reborn]\x01 Respawning is enabled!"))
    end
    bRespawnToggle = not bRespawnToggle
end
