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
        print("base_class branch")
    else
        print("Load config failed: Unable to determine loadout or base_class.\n" .. debug.traceback())
    end
end