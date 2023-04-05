-- FUCK LUA
-- Hardcoded, edit this script if you want to edit values

human = {
    model = "characters/models/ctm_heavy/ctm_heavy.vmdl",
	health = 100,
    speed = 1.0,
    scale = 1.0,
	gravity = 1.0,
	colorR = 255,
	colorG = 255,
	colorB = 255
}

zombie= {
    model = "characters/models/tm_jumpsuit/tm_jumpsuit_variantb.vmdl",
	health = 10000,
    speed = 1.05,
    scale = 1.05,
	gravity = 1.0,
	colorR = 255,
	colorG = 150,
	colorB = 150
}

mother_zombie= {
    model = "characters/models/tm_phoenix_heavy/tm_phoenix_heavy.vmdl",
	health = 40000,
    speed = 1.15,
    scale = 1.15,
	gravity = 0.9,
	colorR = 255,
	colorG = 100,
	colorB = 100
}


function SetPlayerClass(hPlayer, tClassname)
    hPlayer:SetModel(tClassname.model)
    hPlayer:SetHealth(tClassname.health)
    hPlayer:SetMaxHealth(tClassname.health)
    --speed
    hPlayer:SetAbsScale(tClassname.scale)
    --gravity
    hPlayer:SetRenderColor(tClassname.colorR, tClassname.colorG, tClassname.colorB)
end