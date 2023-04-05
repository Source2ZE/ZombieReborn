tBaseClassConfig = LoadKeyValues("cfg/zr/baseclass.cfg")
tPlayerClassConfig = LoadKeyValues("cfg/zr/playerclass.cfg")

if tBaseClassConfig == nil or tPlayerClassConfig == nil then print("TABLE NOT EXIST") end

tPlayerClass = {}

table.insert(tPlayerClass, tBaseClassConfig)

function merge(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            merge(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
end

for k, v in pairs(tPlayerClassConfig) do
    local loadout = v.loadout
    if v.loadout ~= nil then
        local basic_table = tBaseClassConfig[loadout]
        merge(basic_table, v)
        tPlayerClass[k] = basic_table
    elseif v.base_class ~= nil then
        -- but... looks like no difference with loadout and base_class?
        -- if so, then probably we should merge base_class and loadout?
        local basic_table = tBaseClassConfig[v.base_class]
        merge(basic_table, v)
        tPlayerClass[k] = basic_table
    else
        print("Load config failed: Unable to determine loadout or base_class.\n" .. debug.traceback())
    end
end

function SetPlayerClass(hPlayer, sClassname)
    local tPlayer = tPlayerClass[sClassname]
    if tPlayer == nil then 
        print("Player class not exist: " .. sClassname)
        return
    end
    -- TBD: Probably we can set teams at here.
    -- But this requires us to add more extra field to identify team.
    -- Then, is this really necessary?

    -- SET PLAYER DATA
    hPlayer:SetHealth(tPlayer.health)
    hPlayer:SetMaxHealth(tPlayer.health)
    hPlayer:SetGravity(tPlayer.gravity)
    -- hPlayer:SetModel(tPlayer.model)
    -- hInfected:SetScale(tPlayerClass.scale)
    -- hInfected:SetArmor(tPlayerClass.armor)
end