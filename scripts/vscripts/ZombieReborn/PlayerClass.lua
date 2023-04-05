--[[
    Available class:
        human:
        CPlayerHumanDefault
        CPlayerAdmin(example)

        zombie:
        CPlayerZombieDefault
        CPlayerMotherZombie

        InjectPlayerClass(class, player) to change class
--]]


function GenerateMetaTableConfig(tClass, parent)
    local mt = {
        __index = tClass
    }
    --metatable for the player, allowing them to use function of this class
    tClass.mt = mt;

    --metatable for the class, allowing this class to extends CBasePlayerPawn
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

function AddHumanClass(tClass)
    GenerateMetaTableConfig(tClass, CPlayerHumanDefault);
end

function AddZombieClass(tClass)
    GenerateMetaTableConfig(tClass, CPlayerZombieDefault);
end

tPlayerClassConfig = LoadKeyValues("cfg/zr/playerclass.cfg")
if tPlayerClassConfig == nil then print("TABLE NOT EXIST") end

--Player will use these stats if certain stats doesn't exist in their class
CPlayerHumanDefault = tPlayerClassConfig.human_default
GenerateMetaTableConfig(CPlayerHumanDefault, CBasePlayerPawn)
CPlayerZombieDefault = tPlayerClassConfig.zombie_default
GenerateMetaTableConfig(CPlayerZombieDefault, CBasePlayerPawn)

--Do something when this class is injected onto the player
function CPlayerHumanDefault:OnInjection()
    local thisClass = self.zrclass
    --accessing value indirectly through the player handle would also work
    --such as self.health. But this value might be overriden by mapper who would
    --like to set value directly on the player handle as well
    local model = thisClass.model[tostring(RandomInt(1,thisClass.model_count))]
    self:SetModel(model)
    self:SetHealth(thisClass.health)
    self:SetMaxHealth(thisClass.health)
    self:SetAbsScale(thisClass.scale)
    self:SetRenderColor(thisClass.colorR, thisClass.colorG, thisClass.colorB)
end
function CPlayerHumanDefault:IsClass(tClass)
    return self.zrclass == tClass
end

--Do something when this class is injected onto the player
function CPlayerZombieDefault:OnInjection()
    local thisClass = self.zrclass
    local model = thisClass.model[tostring(RandomInt(1,thisClass.model_count))]
    self:SetModel(model)
    self:SetHealth(thisClass.health)
    self:SetMaxHealth(thisClass.health)
    self:SetAbsScale(thisClass.scale)
    self:SetRenderColor(thisClass.colorR, thisClass.colorG, thisClass.colorB)
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

--Adding news classes that overrides the default value/extends its functionality
CPlayerMotherZombie = tPlayerClassConfig.mother_zombie
AddZombieClass(CPlayerMotherZombie)


--ent_fire !self runscriptcode "InjectPlayerClass(CPlayerAdmin, thisEntity)"
--shoot or ent_fire !self runscriptcode "thisEntity:LaunchGrenade()"
--ent_fire !self runscriptcode "InjectPlayerClass(CPlayerHumanDefault, thisEntity)" to restore
--More examples
CPlayerAdmin = {
    health = 9999999,
    speed = 1,
    scale = 5,
    gravity = 0,
    colorR = 0,
	colorG = 0,
	colorB = 0
}
AddHumanClass(CPlayerAdmin)
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

--Doesn't support extending custom class on top of each other right now/