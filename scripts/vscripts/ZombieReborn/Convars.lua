-- Infect
Convars:RegisterConvar("zr_infect_spawn_type", "1", "Type of Mother Zombies Spawn [0 = MZ spawn where they stand, 1 = MZ get teleported back to spawn on being picked]", FCVAR_RELEASE)
Convars:RegisterConvar("zr_infect_spawn_time_min", "15", "Minimum time in which Mother Zombies should be picked, after round start", FCVAR_RELEASE)
Convars:RegisterConvar("zr_infect_spawn_time_max", "15", "Maximum time in which Mother Zombies should be picked, after round start", FCVAR_RELEASE)
Convars:RegisterConvar("zr_infect_spawn_mz_ratio", "7", "Ratio of all Players to Mother Zombies to be spawned at round start", FCVAR_RELEASE)
Convars:RegisterConvar("zr_infect_spawn_mz_min_count", "2", "Minimum amount of Mother Zombies to be spawned at round start", FCVAR_RELEASE)
Convars:RegisterConvar("zr_infect_spawn_crash_fix", "0", "Whether to use a poor workaround for Mother Zombie selection randomly crashing", FCVAR_RELEASE)

-- Debug
Convars:RegisterConvar("zr_debug_print", "0", "Whether to print extra information during infection or curing", FCVAR_RELEASE)

-- Knockback
Convars:RegisterConvar("zr_knockback_scale", "5", "Knockback damage multiplier", FCVAR_RELEASE)

-- AntiStack
Convars:RegisterConvar("zr_antistack_enable", "0", "Temporary fix to allow zombie knife through each other", FCVAR_RELEASE)
Convars:RegisterConvar("zr_antistack_range", "20", "AntiStack knife range", FCVAR_RELEASE)

Convars:RegisterConvar("zr_use_cs2fixes_team_switch", "0", "Whether to rely on CS2Fixes' team switching on round start.", FCVAR_RELEASE)
