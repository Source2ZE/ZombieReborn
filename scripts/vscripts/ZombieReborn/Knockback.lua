tWeaponConfigs = LoadKeyValues("cfg\\zr\\weapons.cfg")

function Knockback_Apply(hHuman, hZombie, iDamage, sWeapon)
    local iScale = (Convars:GetInt("zr_knockback_scale") or iKnockbackScale)

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

    -- For Molotov
    if sWeapon == "inferno" and tRecordedMolotovPosition[hHuman] then
        local vecDisplacementNorm = (hZombie:GetCenter() - tRecordedMolotovPosition[hHuman]):Normalized()
        local vecKnockback = vecDisplacementNorm * iDamage * iScale
        vecKnockback = Vector(vecKnockback.x, vecKnockback.y, 0)
        hZombie:ApplyAbsVelocityImpulse(vecKnockback)
        return
    end

    local vecAttackerAngle = AnglesToVector(hHuman:EyeAngles())
    local vecKnockback = vecAttackerAngle * iDamage * iScale
    hZombie:ApplyAbsVelocityImpulse(vecKnockback)
end

tRecordedGrenadePosition = {}
function Knockback_OnGrenadeDetonate(event)
    --__DumpScope(0, event)
    local hThrower = EHandleToHScript(event.userid_pawn)
    local vecDetonatePosition = Vector(event.x, event.y, event.z)
    tRecordedGrenadePosition[hThrower] = vecDetonatePosition
end

tRecordedMolotovPosition = {}
function Knockback_OnMolotovDetonate(event)
    --__DumpScope(0, event)
    local hThrower = EHandleToHScript(event.userid_pawn)
    local vecDetonatePosition = Vector(event.x, event.y, event.z)
    tRecordedMolotovPosition[hThrower] = vecDetonatePosition
end