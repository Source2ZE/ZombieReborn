--[[
    Class:
        ZRClass.Human:
            Default

        ZRClass.Zombie:
            Default
            MotherZombie

        InjectPlayerClass(class, player) to change class
--]]

ZRClass = {
    Human = {},
    Zombie = {}
}

function GenerateMetaTableConfig(tClass, parent)
    local mt = {
        __index = tClass
    }
    --metatable for the player, allowing them to use function of this class
    tClass.mt = mt;

    --metatable for the class, allowing this class to extends parent
    mt = {
        __index = parent
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
    GenerateMetaTableConfig(tClass, ZRClass.Human.Default);
    ZRClass.Human[name] = tClass;
end

function AddZombieClass(tClass, name)
    GenerateMetaTableConfig(tClass, ZRClass.Zombie.Default);
    ZRClass.Zombie[name] = tClass;
end

local tPlayerClassConfig = LoadKeyValues("cfg/zr/playerclass.cfg")
--Player will use these stats if certain stats doesn't exist in their class
local CPlayerHumanDefault = tPlayerClassConfig.Human.Default
GenerateMetaTableConfig(CPlayerHumanDefault, CBasePlayerPawn)
local CPlayerZombieDefault = tPlayerClassConfig.Zombie.Default
GenerateMetaTableConfig(CPlayerZombieDefault, CBasePlayerPawn)

ZRClass.Human.Default = CPlayerHumanDefault
ZRClass.Zombie.Default = CPlayerZombieDefault

--Do something when this class is injected onto the player
function CPlayerHumanDefault:OnInjection()
    local thisClass = self.zrclass
    --accessing value indirectly through the player handle would also work
    --such as self.health. But this value might be overriden by mapper who would
    --like to set value directly on the player handle as well
    local model = thisClass.model[tostring(RandomInt(1,table.size(thisClass.model)))]
    self:SetModel(model)
    self:SetHealth(thisClass.health)
    self:SetMaxHealth(thisClass.health)
    self:SetAbsScale(thisClass.scale)
    self:SetRenderColor(thisClass.color.r, thisClass.color.g, thisClass.color.b)
end
function CPlayerHumanDefault:IsClass(tClass)
    return self.zrclass == tClass
end

--Do something when this class is injected onto the player
function CPlayerZombieDefault:OnInjection()
    local thisClass = self.zrclass
    local model = thisClass.model[tostring(RandomInt(1,table.size(thisClass.model)))]
    self:SetModel(model)
    self:SetHealth(thisClass.health)
    self:SetMaxHealth(thisClass.health)
    self:SetAbsScale(thisClass.scale)
    self:SetRenderColor(thisClass.color.r, thisClass.color.g, thisClass.color.b)
    --Start Regenerating health
    self:SetContextThink("Regen", self.Regen, 0)
end
function CPlayerZombieDefault:IsClass(tClass)
    return self.zrclass == tClass
end
function CPlayerZombieDefault:Regen()
    self:SetHealth(Clamp(self:GetHealth() + self.zrclass.health_regen_count, 0, self.health))
    return self.zrclass.health_regen_interval
end
--Optional: Do some clean up when player is freed from this class
function CPlayerZombieDefault:Release()
    --Remove Regen
    self:SetContextThink("Regen", nil, 0)
end

--Generating other classes from playerclass.cfg that overrides the default value/extends its functionality

for k, v in pairs(tPlayerClassConfig.Human) do
    if k ~= "Default" then
        AddHumanClass(v, k);
    end
end
for k, v in pairs(tPlayerClassConfig.Zombie) do
    if k ~= "Default" then
        AddZombieClass(v, k);
    end
end
--print("Human Class: ")
--table.dump(ZRClass.Human)
--print("Zombie Class: ")
--table.dump(ZRClass.Zombie)


--For Mappers/Server Operator that want more for their class
--ent_fire !self runscriptcode "InjectPlayerClass(CPlayerAdmin, thisEntity)"
--shoot or ent_fire !self runscriptcode "thisEntity:LaunchGrenade()"
--ent_fire !self runscriptcode "InjectPlayerClass(CPlayerHumanDefault, thisEntity)" to restore
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
    --print(hPlayer:IsClass(CPlayerAdmin))
    if hPlayer:IsClass(CPlayerAdmin) then 
        hPlayer:LaunchGrenade()
    end
end
CPlayerAdmin.weapon_fire = ListenToGameEvent("weapon_fire", OnWeaponFired, nil)
--]]

--Doesn't support extending custom class on top of each other right now/