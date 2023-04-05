-- FUCK LUA
-- Hardcoded, edit this script if you want to edit values

human = {
    model = {
       -- SWAT
        "characters/models/ctm_swat/ctm_swat_variante.vmdl",
        "characters/models/ctm_swat/ctm_swat_variantf.vmdl",
        "characters/models/ctm_swat/ctm_swat_varianth.vmdl",
        "characters/models/ctm_swat/ctm_swat_varianti.vmdl",
        "characters/models/ctm_swat/ctm_swat_variantj.vmdl",
        "characters/models/ctm_swat/ctm_swat_variantk.vmdl",
        -- ST6
        "characters/models/ctm_st6/ctm_st6_variante.vmdl",
        "characters/models/ctm_st6/ctm_st6_variantg.vmdl",
        "characters/models/ctm_st6/ctm_st6_varianti.vmdl",
        "characters/models/ctm_st6/ctm_st6_variantj.vmdl",
        "characters/models/ctm_st6/ctm_st6_variantk.vmdl",
        "characters/models/ctm_st6/ctm_st6_variantl.vmdl",
        "characters/models/ctm_st6/ctm_st6_variantm.vmdl",
        "characters/models/ctm_st6/ctm_st6_variantn.vmdl",
        -- SAS
        "characters/models/ctm_sas/ctm_sas.vmdl",
        "characters/models/ctm_sas/ctm_sas_variantf.vmdl",
        "characters/models/ctm_sas/ctm_sas_variantg.vmdl",
        --FBI
        "characters/models/ctm_fbi/ctm_fbi.vmdl",
        "characters/models/ctm_fbi/ctm_fbi_varianta.vmdl",
        "characters/models/ctm_fbi/ctm_fbi_variantb.vmdl",
        "characters/models/ctm_fbi/ctm_fbi_variantc.vmdl",
        "characters/models/ctm_fbi/ctm_fbi_variantd.vmdl",
        "characters/models/ctm_fbi/ctm_fbi_variante.vmdl",
        "characters/models/ctm_fbi/ctm_fbi_variantf.vmdl",
        "characters/models/ctm_fbi/ctm_fbi_variantg.vmdl",
        "characters/models/ctm_fbi/ctm_fbi_varianth.vmdl",
    },
	health = 100,
    speed = 1.0,
    scale = 1.0,
	gravity = 1.0,
	colorR = 255,
	colorG = 255,
	colorB = 255
}

zombie= {
    model = {
        "characters/models/tm_jumpsuit/tm_jumpsuit_varianta.vmdl",
        "characters/models/tm_jumpsuit/tm_jumpsuit_variantb.vmdl",
        "characters/models/tm_jumpsuit/tm_jumpsuit_variantc.vmdl",
    },
	health = 10000,
    speed = 1.05,
    scale = 1.05,
	gravity = 1.0,
	colorR = 255,
	colorG = 150,
	colorB = 150
}

mother_zombie= {
    model = {
        "characters/models/tm_phoenix_heavy/tm_phoenix_heavy.vmdl",
    },
	health = 40000,
    speed = 1.15,
    scale = 1.15,
	gravity = 0.9,
	colorR = 255,
	colorG = 100,
	colorB = 100
}


function SetPlayerClass(hPlayer, tClassname)
    hPlayer:SetModel(tClassname.model[RandomInt(1,#tClassname.model)])
    hPlayer:SetHealth(tClassname.health)
    hPlayer:SetMaxHealth(tClassname.health)
    --speed
    hPlayer:SetAbsScale(tClassname.scale)
    --gravity
    hPlayer:SetRenderColor(tClassname.colorR, tClassname.colorG, tClassname.colorB)
end