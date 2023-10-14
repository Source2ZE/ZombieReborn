--[[
    Class:
        ZRClass.Human:
            Default

        ZRClass.Zombie:
            Default
            MotherZombie

        InjectPlayerClass(class, player) to change class
		Use Built-in hPlayer:IsInstance(class) to check class
--]]

ZRClass = {
    Human = {}, --table
    Zombie = {},
    Default = {
        Human = {}, --array
        Zombie = {},
    },
}

function GenerateMetaTableConfig(tClass, parent)
    local mt = {
        __index = tClass,
    }
    --metatable for the player, allowing them to use function of this class
    tClass.mt = mt

    --metatable for the class, allowing this class to extends parent
    mt = {
        __index = parent,
    }
    setmetatable(tClass, mt)
end

function InjectPlayerClass(tClass, player)
    if player.Release then
        player:Release()
    end
    setmetatable(player, tClass.mt)
    player.zrclass = tClass
    player:OnInjection()
end

function AddHumanClass(tClass, name)
    ZRClass.Human[name] = tClass
    if tClass.team_default == 1 then
        table.insert(ZRClass.Default.Human, tClass)
    end
    GenerateMetaTableConfig(tClass, ZRClass.Human.Base)
end

function AddZombieClass(tClass, name)
    ZRClass.Zombie[name] = tClass
    if tClass.team_default == 1 then
        table.insert(ZRClass.Default.Zombie, tClass)
    end
    GenerateMetaTableConfig(tClass, ZRClass.Zombie.Base)
end

function PickRandomHumanDefaultClass()
    return ZRClass.Default.Human[RandomInt(1, #ZRClass.Default.Human)]
end

function PickRandomZombieDefaultClass()
    return ZRClass.Default.Zombie[RandomInt(1, #ZRClass.Default.Zombie)]
end

local tPlayerClassConfig = LoadKeyValues("cfg/zr/playerclass.cfg")
--Player will use these stats if certain stats doesn't exist in their class
local CPlayerHumanBase = tPlayerClassConfig.Human.Base
GenerateMetaTableConfig(CPlayerHumanBase, CBasePlayerPawn)
local CPlayerZombieBase = tPlayerClassConfig.Zombie.Base
GenerateMetaTableConfig(CPlayerZombieBase, CBasePlayerPawn)

ZRClass.Human.Base = CPlayerHumanBase
if CPlayerHumanBase.team_default == 1 then
    table.insert(ZRClass.Default.Human, CPlayerHumanBase)
end
ZRClass.Zombie.Base = CPlayerZombieBase
if CPlayerZombieBase.team_default == 1 then
    table.insert(ZRClass.Default.Zombie, CPlayerZombieBase)
end

--Do something when this class is injected onto the player
function CPlayerHumanBase:OnInjection()
    local thisClass = self.zrclass
    --accessing value indirectly through the player handle would also work
    --such as self.health. But this value might be overriden by mapper who would
    --like to set value directly on the player handle as well
    local modelIndex = tostring(RandomInt(1, table.size(thisClass.model)))
    local model = thisClass.model[modelIndex]
    local maxSkinIndex = tonumber(thisClass.max_skin_index[modelIndex])

    -- Ensure this model is precached
    SpawnEntityFromTableSynchronous("prop_dynamic", { model = model }):Kill()
    self:SetModel(model)

    if maxSkinIndex ~= nil then
        DoEntFireByInstanceHandle(self, "skin", tostring(RandomInt(0, maxSkinIndex)), 0.01, nil, nil)
    end

    DebugPrint("CPlayerHumanBase:OnInjection: Model set")
    self:SetMaxHealth(thisClass.health)
    self:SetHealth(thisClass.health)
    self:SetAbsScale(thisClass.scale)
    DebugPrint("CPlayerHumanBase:OnInjection: Scale set to " .. thisClass.scale)
    self:SetRenderColor(thisClass.color.r, thisClass.color.g, thisClass.color.b)
end

--Do something when this class is injected onto the player
function CPlayerZombieBase:OnInjection()
    local thisClass = self.zrclass
    local modelIndex = tostring(RandomInt(1, table.size(thisClass.model)))
    local model = thisClass.model[modelIndex]
    local maxSkinIndex = tonumber(thisClass.max_skin_index[modelIndex])

    -- Ensure this model is precached
    SpawnEntityFromTableSynchronous("prop_dynamic", { model = model }):Kill()
    self:SetModel(model)

    if maxSkinIndex ~= nil then
        DoEntFireByInstanceHandle(self, "skin", tostring(RandomInt(0, maxSkinIndex)), 0.01, nil, nil)
    end

    DebugPrint("CPlayerZombieBase:OnInjection: Model set")
    self:SetMaxHealth(thisClass.health)
    self:SetHealth(thisClass.health)
    self:SetAbsScale(thisClass.scale)
    DebugPrint("CPlayerZombieBase:OnInjection: Scale set to " .. thisClass.scale)
    self:SetRenderColor(thisClass.color.r, thisClass.color.g, thisClass.color.b)
    --Start Regenerating health
    self:SetContextThink("Regen", self.Regen, 0)
end

function CPlayerZombieBase:Regen()
    self:SetHealth(Clamp(self:GetHealth() + self.zrclass.health_regen_count, 0, self.health))
    return self.zrclass.health_regen_interval
end
--Optional: Do some clean up when player is freed from this class
function CPlayerZombieBase:Release()
    --Remove Regen
    self:SetContextThink("Regen", nil, 0)
end

--Generating other classes from playerclass.cfg that overrides the default value/extends its functionality

for k, v in pairs(tPlayerClassConfig.Human) do
    if k ~= "Base" and v.enabled then
        AddHumanClass(v, k)
    end
end
for k, v in pairs(tPlayerClassConfig.Zombie) do
    if k ~= "Base" and v.enabled then
        AddZombieClass(v, k)
    end
end

--print("Human Class: ")
--table.dump(ZRClass.Human)
--print("Zombie Class: ")
--table.dump(ZRClass.Zombie)

