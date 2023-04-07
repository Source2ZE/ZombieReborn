function SetupAmmoReplenish()
    -- Create timer to replenish ammo
    if not Timers:TimerExists(zr_ammo_timer) then
        Timers:CreateTimer("zr_ammo_timer", {
            callback = function()
                DoEntFire("weapon_*", "SetReserveAmmoAmount", "999", 0, nil, nil)
                return 5
            end,
        })
    end
end
