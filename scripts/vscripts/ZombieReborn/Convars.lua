-- Registering convars seems to be broken at the moment, so we currently expose the default values as variables as well

-- Infect
iInfectSpawnType = 1
iInfectSpawntimeMin = 15
iInfectSpawntimeMax = 15
iInfectSpawnMZRatio = 7
iInfectSpawnMZMinCount = 2
Convars:RegisterConvar("zr_infect_spawn_type", tostring(iInfectSpawnType), "Type of Mother Zombies Spawn [0 = MZ spawn where they stand, 1 = MZ get teleported back to spawn on being picked]", 0)
Convars:RegisterConvar("zr_infect_spawn_time_min", tostring(iInfectSpawntimeMin), "Minimum time in which Mother Zombies should be picked, after round start", 0)
Convars:RegisterConvar("zr_infect_spawn_time_max", tostring(iInfectSpawntimeMax), "Maximum time in which Mother Zombies should be picked, after round start", 0)
Convars:RegisterConvar("zr_infect_spawn_mz_ratio", tostring(iInfectSpawnMZRatio), "Ratio of all Players to Mother Zombies to be spawned at round start", 0)
Convars:RegisterConvar("zr_infect_spawn_mz_min_count", tostring(iInfectSpawnMZMinCount), "Minimum amount of Mother Zombies to be spawned at round start", 0)

-- Knockback
iKnockbackScale = 5
Convars:RegisterConvar("zr_knockback_scale", tostring(iKnockbackScale), "Knockback damage multiplier", 0)