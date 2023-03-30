bRepeatKillerToggle = false

--Setup the initial logic_relay for repeat killer
--Maps should toggle this when they want to stop zombie respawning
--OnWhatever -> zr_toggle_repeatkiller -> Trigger -> Delay 0 -> Once Only
function SetupRepeatKiller()
    bRepeatKillerToggle = false
    local tKeyValues = {}
    tKeyValues.targetname = "zr_toggle_repeatkiller"
    hRelay = SpawnEntityFromTableSynchronous("logic_relay", tKeyValues)
    hRelay:RedirectOutput("OnTrigger", "ToggleRepeatKiller", hRelay)
end

function ToggleRepeatKiller()
    if bRepeatKillerToggle == false then
        DoEntFireByInstanceHandle(hRelay,"RunScriptCode","Convars:SetInt('mp_respawn_on_death_t',0)",0,nil,nil)
        DoEntFireByInstanceHandle(hRelay,"RunScriptCode","Convars:SetInt('mp_ignore_round_win_conditions',0)",0,nil,nil)
        ScriptPrintMessageChatAll(" \x04[Zombie:Reborn]\x01 Repeat-Killer enabled")
    end
    if bRepeatKillerToggle == true then
        DoEntFireByInstanceHandle(hRelay,"RunScriptCode","Convars:SetInt('mp_respawn_on_death_t',1)",0,nil,nil)
        DoEntFireByInstanceHandle(hRelay,"RunScriptCode","Convars:SetInt('mp_ignore_round_win_conditions',1)",0,nil,nil)
        ScriptPrintMessageChatAll(" \x04[Zombie:Reborn]\x01 Repeat-Killer disabled")
    end

    bRepeatKillerToggle =  not bRepeatKillerToggle
end