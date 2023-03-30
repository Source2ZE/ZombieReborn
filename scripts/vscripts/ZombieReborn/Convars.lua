-- Registering convars seems to be broken at the moment, so we currently expose the default values as variables as well

-- Infect
local Config = {
    Infect = {
        SpawnType = 1,
        SpawnTimeMin = 15,
        SpawnTimeMax = 15,
        SpawnMZRatio = 7,
        SpawnMZMinCount = 2
    },
    Knockback = {
        Scale = 5
    }
}

Convars:RegisterConvar("zr_infect_spawn_type", tostring(Config.Infect.spawnType), "Type of Mother Zombies Spawn [0 = MZ spawn where they stand, 1 = MZ get teleported back to spawn on being picked]", 0)
Convars:RegisterConvar("zr_infect_spawn_time_min", tostring(Config.Infect.spawnTimeMin), "Minimum time in which Mother Zombies should be picked, after round start", 0)
Convars:RegisterConvar("zr_infect_spawn_time_max", tostring(Config.Infect.spawnTimeMax), "Maximum time in which Mother Zombies should be picked, after round start", 0)
Convars:RegisterConvar("zr_infect_spawn_mz_ratio", tostring(Config.Infect.spawnMZRatio), "Ratio of all Players to Mother Zombies to be spawned at round start", 0)
Convars:RegisterConvar("zr_infect_spawn_mz_min_count", tostring(Config.Infect.spawnMZMinCount), "Minimum amount of Mother Zombies to be spawned at round start", 0)

Convars:RegisterConvar("zr_knockback_scale", tostring(knockbackConfig.scale), "Knockback damage multiplier", 0)

-- Create a table to store cvars
Convars.Infect = {
    SpawnType = Convars:GetInt("zr_infect_spawn_type") or Config.Infect.spawnType,
    SpawnTimeMin = Convars:GetInt("zr_infect_spawn_time_min") or Config.Infect.spawnTimeMin,
    SpawnTimeMax = Convars:GetInt("zr_infect_spawn_time_max") or Config.Infect.spawnTimeMax,
    SpawnMZRatio = Convars:GetInt("zr_infect_spawn_mz_ratio") or Config.Infect.spawnMZRatio,
    SpawnMZMinCount = Convars:GetInt("zr_infect_spawn_mz_min_count") or Config.Infect.spawnMZMinCount
}

Convars.Knockback = {
    Scale = Convars:GetInt("zr_knockback_scale") or Config.Knockback.scale
}