print("Starting ZombieReborn!")

require "util.functions"
require "util.timers"
require "ZombieReborn.PickMotherZombies"

Convars:RegisterConvar("zr_knockback_scale", "5", "Knockback damage multiplier", 0)

ZR_ROUND_STARTED = false

-- round start logic
function OnRoundStart(event)
    ScriptPrintMessageChatAll("The game is \x05Humans vs. Zombies\x01, the goal for zombies is to infect all humans by knifing them.")
    SetAllHuman()
    MZSelection_OnRoundStart()
    ZR_ROUND_STARTED = true
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

function ApplyKnockback(hHuman, hZombie, iDamage)
    local iScale = Convars:GetInt("zr_knockback_scale")

    -- Registering convars seems to be broken at the moment so just force the default for now
    if iScale == nil then
        iScale = 5
    end

    local vecAttackerAngle = AnglesToVector(hHuman:EyeAngles())
    local vecKnockback = vecAttackerAngle * iDamage * iScale
    hZombie:ApplyAbsVelocityImpulse(vecKnockback)
end

function OnPlayerHurt(event)
    if event.weapon == "" or event.attacker_pawn == nil then return end
    local hAttacker = EHandleToHScript(event.attacker_pawn)
    local hVictim = EHandleToHScript(event.userid_pawn)

    if hAttacker:GetTeam() == 3 and hVictim:GetTeam() == 2 then
        ApplyKnockback(hAttacker, hVictim, event.dmg_health)
    elseif hAttacker:GetTeam() == 2 and hVictim:GetTeam() == 3 then
        Infect(hVictim, true)
    end
end

-- player_death doesn't have dmg_health, so it has a separate callback
function OnPlayerDeath(event)
    if event.weapon == "" or event.attacker_pawn == nil then return end
    local hAttacker = EHandleToHScript(event.attacker_pawn)
    local hVictim = EHandleToHScript(event.userid_pawn)

    if hAttacker:GetTeam() == 2 and hVictim:GetTeam() == 3 then
        Infect(hVictim, true)
    end
end

ListenToGameEvent("round_start", OnRoundStart, nil)
ListenToGameEvent("player_hurt", OnPlayerHurt, nil)
ListenToGameEvent("player_death", OnPlayerDeath, nil)