--[[
weapon_reload event does not fire so we can't replenish ammo when players reloaded
Workaround is using sv_infinite_ammo 2 but that introduces infinite grenades

This function removes players grenade if he threw one
Removes all grenades even if player had 2 HE grenades
--]]

function RemoveGrenade(event)
    -- Don't do anything if infinite ammo is off
    if Convars:GetInt("sv_infinite_ammo") == 0 then return end

    local hPlayer = EHandleToHScript(event.userid_pawn)

    -- Support all grenades for now
    local tGrenades = {"weapon_hegrenade", "weapon_molotov", "weapon_incgrenade", "weapon_flashbang", "weapon_smokegrenade", "weapon_decoy"}    

    -- For the love of god aint no way lua is this shit
    for key, value in ipairs(tGrenades) do
        if event.weapon == value then
            local tPlayerWeapons = hPlayer:GetEquippedWeapons()

            for key, value in ipairs(tPlayerWeapons) do
                local hWeapon = value

                for key, value in ipairs(tGrenades) do
                    if value == hWeapon:GetClassname() then
                        -- Create only one clientcommand to avoid string table leak
                        if Entities:FindByClassname(nil, "point_clientcommand") == nil then
                            local hClientCMD = SpawnEntityFromTableSynchronous("point_clientcommand", nil)
                        end
                        -- Reassign the variable because lua is awful
                        hClientCMD = Entities:FindByClassname(nil, "point_clientcommand")

                        -- Remove the grenade (delay it else bug happens)
                        DoEntFireByInstanceHandle(hWeapon, "Kill", "", 0.10, nil, nil)

                        -- Ugly hack to switch guns because killed grenade leaves you with nothing equipped
                        DoEntFireByInstanceHandle(hClientCMD, "Command", "lastinv", 0.15, hPlayer, hPlayer)
                    end
                end
            end
        end
    end
end