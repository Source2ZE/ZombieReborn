zombieKnife = {}
function testKnife(hPlayer)
    if zombieKnife[hPlayer] then
        -- zombie has already knifed someone
        return
    end
    local knifeRange = Convars:GetInt("zr_antistack_range")
    local vecStart = hPlayer:EyePosition()
    local vecEnd = vecStart + hPlayer:EyeAngles():Forward() * knifeRange
    local traceData = {
        startpos = vecStart,
        endpos = vecEnd,
    }
    --To make sure zombie can't knife someone through walls
    TraceLine(traceData)
    vecEnd = traceData.pos
    --DebugDrawLine(vecStart, vecEnd, 255, 0, 0, false, 5)
    local candidates = Entities:FindAllByClassnameWithin("player", vecStart, 72 + knifeRange)
    for i, v in ipairs(candidates) do
        if v:GetTeam() == CS_TEAM_CT and v:IsAlive() then
            local traceData2 = {
                startpos = vecStart,
                endpos = vecEnd,
                ent = v,
            }
            --Trace against player bounding box
            TraceCollideable(traceData2)
            if traceData2.hit then
                --Infect the player if test succeeded
                --DebugDrawBox(v:GetAbsOrigin(), v:GetBoundingMins(), v:GetBoundingMaxs(), 0, 0, 255, 100, 5);
                DebugPrint("Attempting to infect player through stack")
                Infect(hPlayer, v, true, false)
                return
            end
        end
    end
end

local OnWeaponFired = function(event)
    if Convars:GetInt("zr_antistack_enable") == 0 then
        return
    end
    local hPlayer = EHandleToHScript(event.userid_pawn)
    if hPlayer:GetTeam() ~= CS_TEAM_T then
        return
    end
    zombieKnife[hPlayer] = nil
    --Queue a trace test one frame after
    DoEntFireByInstanceHandle(hPlayer, "CallScriptFunction", "testKnife", 0.01, hPlayer, hPlayer)
end

local OnPlayerHurt = function(event)
    if Convars:GetInt("zr_antistack_enable") == 0 or event.weapon == "" or event.attacker_pawn == nil then
        return
    end
    local hAttacker = EHandleToHScript(event.attacker_pawn)
    local hVictim = EHandleToHScript(event.userid_pawn)
    if hAttacker:GetTeam() ~= CS_TEAM_T or hVictim:GetTeam() ~= CS_TEAM_CT then
        return
    end
    --tell the test to ignore if zombie already knifed someone
    zombieKnife[hAttacker] = true
end

ListenToGameEvent("weapon_fire", OnWeaponFired, nil)
ListenToGameEvent("player_hurt", OnPlayerHurt, nil)
