tMapConfigs = nil

function SetupMapConfig()
    tMapConfigs = LoadKeyValues("cfg\\zr\\mapcfgs\\" .. GetMapName() .. ".cfg")
    print("Loading map config for " .. GetMapName())
    if tMapConfigs == nil then
        print("No config found!")
    else
        ExecuteMapConfig()
    end
end

function ExecuteMapConfig()
    print("Executing config!")
    for k, v in pairs(tMapConfigs) do
        print(k .. " " .. v)
        Convars:SetInt(k, v)
    end
end