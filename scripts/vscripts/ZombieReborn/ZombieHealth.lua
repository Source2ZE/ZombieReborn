g_PlayerHealthRecord = g_PlayerHealthRecord or {}
g_PlayerNextRecoveryTime = g_PlayerNextRecoveryTime or {}

local ZOMBIE_HEALTH_RECOVER_INTERVAL = 1
local ZOMBIE_HEALTH_DEFAULT_VALUE = 1400

function SetupZombieHealth()
    g_PlayerHealthRecord = {}

    Timers:CreateTimer("ZombieHealth_Timer",{
        callback = function()
            xpcall(ApplyZombieHealthRecoveryAll, PrintLuaError)
            return 0.1
        end
    })
end

function SetZombieHealthRecord(hPlayer, iValue)
    g_PlayerHealthRecord[hPlayer:GetEntityIndex()] = iValue
end

function SetZombieHealthRecordInfection(hAttacker, hVictim)
    local iCustomHealth = math.max(hAttacker:GetHealth() / 2, ZOMBIE_HEALTH_DEFAULT_VALUE)
    SetZombieHealthRecord(hVictim, iCustomHealth)
end

function ApplyMaxHealthOnInfection(hPlayer)
    local CustomHealth = g_PlayerHealthRecord[hPlayer:GetEntityIndex()] or math.max(hPlayer:GetMaxHealth(), ZOMBIE_HEALTH_DEFAULT_VALUE)
    hPlayer:SetHealth(CustomHealth)
    hPlayer:SetMaxHealth(CustomHealth)
end

function PauseZombieHealthRecovery(hPlayer)
    g_PlayerNextRecoveryTime[hPlayer:GetEntityIndex()] = Time() + 1
end

function ApplyZombieHealthRecoveryAll()
    local tPlayerTable = Entities:FindAllByClassname("player")
    for _, hPlayer in ipairs(tPlayerTable) do
        ApplyZombieHealthRecovery(hPlayer)
    end
end

function ApplyZombieHealthRecovery(hPlayer)
    if not g_PlayerNextRecoveryTime[hPlayer:GetEntityIndex()] or Time() > g_PlayerNextRecoveryTime[hPlayer:GetEntityIndex()] then
        if hPlayer:GetTeam() == CS_TEAM_T and hPlayer:IsAlive() then
            hPlayer:SetHealth(math.min(hPlayer:GetHealth() + 350, g_PlayerHealthRecord[hPlayer:GetEntityIndex()] or ZOMBIE_HEALTH_DEFAULT_VALUE))
            g_PlayerNextRecoveryTime[hPlayer:GetEntityIndex()] = Time() + 1
        end
    end
end