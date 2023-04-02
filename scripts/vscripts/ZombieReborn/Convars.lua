-- Infect
Convars:RegisterConvar("zr_infect_spawn_type", "1", "Type of Mother Zombies Spawn [0 = MZ spawn where they stand, 1 = MZ get teleported back to spawn on being picked]", FCVAR_RELEASE)
Convars:RegisterConvar("zr_infect_spawn_time_min", "15", "Minimum time in which Mother Zombies should be picked, after round start", FCVAR_RELEASE)
Convars:RegisterConvar("zr_infect_spawn_time_max", "15", "Maximum time in which Mother Zombies should be picked, after round start", FCVAR_RELEASE)
Convars:RegisterConvar("zr_infect_spawn_mz_ratio", "7", "Ratio of all Players to Mother Zombies to be spawned at round start", FCVAR_RELEASE)
Convars:RegisterConvar("zr_infect_spawn_mz_min_count", "2", "Minimum amount of Mother Zombies to be spawned at round start", FCVAR_RELEASE)

-- Knockback
Convars:RegisterConvar("zr_knockback_scale", "5", "Knockback damage multiplier", FCVAR_RELEASE)