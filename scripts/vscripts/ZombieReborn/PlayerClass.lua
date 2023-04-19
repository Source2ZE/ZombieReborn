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
ZRPlayer = {}

function GetOrCreateZRPlayer(hPly)
    if hPly.__zr__ then
        return hPly
    elseif ZRPlayer[hPly] then
        return ZRPlayer[hPly]
    end
    local hFakePly = vlua.clone(hPly)
    ZRPlayer[hPly] = hFakePly
    -- To distinguish ZRPlayer from normal player handle
    hFakePly.__zr__ = true
    return hFakePly
end

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

function InjectPlayerClass(tClass, hPly)
    hPly = GetOrCreateZRPlayer(hPly)
    if hPly.Release then
        hPly:Release()
    end
    setmetatable(hPly, tClass.mt)
    hPly:OnInjection()
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
    local model = self.model[tostring(RandomInt(1, table.size(self.model)))]
    self:SetModel(model)
    self:SetMaxHealth(self.health)
    self:SetHealth(self.health)
    self:SetAbsScale(self.scale)
    self:SetRenderColor(self.color.r, self.color.g, self.color.b)
end

--Do something when this class is injected onto the player
function CPlayerZombieBase:OnInjection()
    local model = self.model[tostring(RandomInt(1, table.size(self.model)))]
    self:SetModel(model)
    self:SetMaxHealth(self.health)
    self:SetHealth(self.health)
    self:SetAbsScale(self.scale)
    self:SetRenderColor(self.color.r, self.color.g, self.color.b)
    --Start Regenerating health
    self:SetContextThink("Regen", self.Regen, 0)
end

function CPlayerZombieBase:Regen()
    self = GetOrCreateZRPlayer(self) --self is somehow a normal player handle here
    self:SetHealth(Clamp(self:GetHealth() + self.health_regen_count, 0, self.health))
    return self.health_regen_interval
end
--Optional: Do some clean up when player is freed from this class
function CPlayerZombieBase:Release()
    --Remove Regen
    self:SetContextThink("Regen", nil, 0)
end

--Generating rest of the classes from playerclass.cfg that overrides the default value/extends its functionality
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

--For Mappers/Server Operator that want more for their class
--ent_fire !self runscriptcode "InjectPlayerClass(ZRClass.Human.Admin, thisEntity)"
--shoot or ent_fire !self runscriptcode "thisEntity:LaunchGrenade()"
--ent_fire !self runscriptcode "InjectPlayerClass(ZRClass.Human.Base, thisEntity)" to restore
--[[
local CPlayerAdmin = {
    health = 9999999,
    speed = 1,
    scale = 5,
    gravity = 0,
    color = {
        r = 0, g = 0, b = 0
    }
}
AddHumanClass(CPlayerAdmin, "Admin")
function CPlayerAdmin:LaunchGrenade()
    local hEnt = SpawnEntityFromTableSynchronous("hegrenade_projectile", {
        origin = self:EyePosition(),
        basevelocity = self:EyeAngles():Forward() * 500
    })
    DoEntFireByInstanceHandle(hEnt, "InitializeSpawnFromWorld", "", 0, nil, nil);
end

local OnWeaponFired = function(event)
    local hPlayer = EHandleToHScript(event.userid_pawn)
    hPlayer = GetOrCreateZRPlayer(hPlayer)
    if hPlayer:IsInstance(CPlayerAdmin) then 
        hPlayer:LaunchGrenade()
    end
end
CPlayerAdmin.weapon_fire = ListenToGameEvent("weapon_fire", OnWeaponFired, nil)
--]]

--Doesn't support extending custom class on top of each other right now/
