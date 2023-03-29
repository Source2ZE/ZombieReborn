print("Starting ZombieReborn!")
require("util.timers")
ZR_ZOMBIE_INFECT_TIME = 20
ZR_ROUND_STARTED = false
Convars:RegisterConvar("zr_knockback_scale", "5", "Knockback damage multiplier", 0)
tWeaponConfigs = LoadKeyValues("cfg\\zr\\weapons.cfg")

--remove duplicated listeners upon manual reload
if tListenerIds then
	for k, v in ipairs(tListenerIds) do
		StopListeningToGameEvent(v)
	end
end

---countdown timer
function ZR_ONROUNDSTART(event)
    local countdown = ZE_ZOMBIE_INFECT_TIME
    print("STARTING A NEW ROUND")
   -- SetAllHuman()
    ZE_ROUND_STARTED = false

    Timers:CreateTimer("ZEINFECTTIMER", {
        callback = function()
            countdown = countdown - 1
            ScriptPrintMessageCenterAll("First infection in " .. countdown .. " seconds")

            if countdown <= 0 then
                Timers:RemoveTimer("ZEINFECTTIMER")
            end

            return 1
        end
    })
end

-- Apparently entity indices take up the first 14 bits of an EHandle, need more testing to really verify this
function EHandleToHScript(iPawnId)
    return EntIndexToHScript(bit.band(iPawnId, 0x3FFF))
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

function Infect(hInfected, bKeepPosition)
    local vecOrigin = hInfected:GetOrigin()
    local vecAngles = hInfected:EyeAngles()
    hInfected:SetTeam(2)
    if bKeepPosition == false then return end
    hInfected:SetOrigin(vecOrigin)
    hInfected:SetAngles(vecAngles.x, vecAngles.y, vecAngles.z)
end

function ApplyKnockback(hHuman, hZombie, iDamage, sWeapon)
    local iScale = Convars:GetInt("zr_knockback_scale")

    -- Registering convars seems to be broken at the moment so just force the default for now
    if iScale == nil then
        iScale = 5
    end

	if tWeaponConfigs and tWeaponConfigs[sWeapon] and tWeaponConfigs[sWeapon].knockback then
		iScale = iScale * tWeaponConfigs[sWeapon].knockback
	end

    -- For Hegrenade
	if sWeapon == "hegrenade" and tRecordedGrenadePosition[hHuman] then
		local vecDisplacementNorm = (hZombie:GetCenter() - tRecordedGrenadePosition[hHuman]):Normalized()
		local vecKnockback = vecDisplacementNorm * iDamage * iScale
		hZombie:ApplyAbsVelocityImpulse(vecKnockback)
		return
	end

    local vecAttackerAngle = AnglesToVector(hHuman:EyeAngles())
    local vecKnockback = vecAttackerAngle * iDamage * iScale
    hZombie:ApplyAbsVelocityImpulse(vecKnockback)
end

function OnPlayerHurt(event)
    --__DumpScope(0, event)
    if event.weapon == "" or event.attacker_pawn == nil then return end
    local hAttacker = EHandleToHScript(event.attacker_pawn)
    local hVictim = EHandleToHScript(event.userid_pawn)

    if hAttacker:GetTeam() == 3 and hVictim:GetTeam() == 2 then
        ApplyKnockback(hAttacker, hVictim, event.dmg_health, event.weapon)
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

tRecordedGrenadePosition = {}
function OnGrenadeDetonate(event)
	--__DumpScope(0, event)
	local hThrower = EHandleToHScript(event.userid_pawn)
	local vecDetonatePosition = Vector(event.x, event.y, event.z)
	tRecordedGrenadePosition[hThrower] = vecDetonatePosition
end

tListenerIds = {
    ListenToGameEvent("player_hurt", OnPlayerHurt, nil),
    ListenToGameEvent("player_death", OnPlayerDeath, nil),
    ListenToGameEvent("hegrenade_detonate", OnGrenadeDetonate, nil),
    ListenToGameEvent("round_start", ZR_ONROUNDSTART, nil)
}