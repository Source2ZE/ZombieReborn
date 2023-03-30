-- Registering convars seems to be broken at the moment, so we currently expose the default values as variables as well

-- Infect
local infectConfig = {
    spawnType = 1,
    spawnTimeMin = 15,
    spawnTimeMax = 15,
    spawnMZRatio = 7,
    spawnMZMinCount = 2
}

Convars:RegisterConvar("zr_infect_spawn_type", tostring(infectConfig.spawnType), "Type of Mother Zombies Spawn [0 = MZ spawn where they stand, 1 = MZ get teleported back to spawn on being picked]", 0)
Convars:RegisterConvar("zr_infect_spawn_time_min", tostring(infectConfig.spawnTimeMin), "Minimum time in which Mother Zombies should be picked, after round start", 0)
Convars:RegisterConvar("zr_infect_spawn_time_max", tostring(infectConfig.spawnTimeMax), "Maximum time in which Mother Zombies should be picked, after round start", 0)
Convars:RegisterConvar("zr_infect_spawn_mz_ratio", tostring(infectConfig.spawnMZRatio), "Ratio of all Players to Mother Zombies to be spawned at round start", 0)
Convars:RegisterConvar("zr_infect_spawn_mz_min_count", tostring(infectConfig.spawnMZMinCount), "Minimum amount of Mother Zombies to be spawned at round start", 0)

-- Knockback
local knockbackConfig = {
    scale = 5
}

Convars:RegisterConvar("zr_knockback_scale", tostring(knockbackConfig.scale), "Knockback damage multiplier", 0)

-- Create a table to store cvars
Convars.Infect = {
    SpawnType = Convars:GetInt("zr_infect_spawn_type") or infectConfig.spawnType,
    SpawnTimeMin = Convars:GetInt("zr_infect_spawn_time_min") or infectConfig.spawnTimeMin,
    SpawnTimeMax = Convars:GetInt("zr_infect_spawn_time_max") or infectConfig.spawnTimeMax,
    SpawnMZRatio = Convars:GetInt("zr_infect_spawn_mz_ratio") or infectConfig.spawnMZRatio,
    SpawnMZMinCount = Convars:GetInt("zr_infect_spawn_mz_min_count") or infectConfig.spawnMZMinCount
}

Convars.Knockback = {
    Scale = Convars:GetInt("zr_knockback_scale") or knockbackConfig.scale
}