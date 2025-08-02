-- name: [CS] Sybil
-- description: Many platfrom

local TEXT_MOD_NAME = "[CS] Sybil"

if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

--local E_MODEL_SYBIL = smlua_model_util_get_id("sybil_geo")   -- Located in "actors"
--local TEX_ICON_SYBIL = get_texture_info("sybil-icon")

--[[local PALETTE_SYBIL = {
    [PANTS]  = "5656FF",
    [SHIRT]  = "4F8B4A",
    [GLOVES] = "360099",
    [SHOES]  = "995B53",
    [HAIR]   = "8F1F31",
    [SKIN]   = "FFA787",
    [CAP]    = "5153FF",
	[EMBLEM] = "000672"
}
]]

--    _G.charSelect.character_add_palette_preset(E_MODEL_SYBIL, PALETTE_SYBIL)


CHAR_SYBIL = _G.charSelect.character_add(
    "Sybil", -- Character Name
    "Cat-Bunny-goat-lady, she will slide cancel u", -- Description
    "Honi", -- Credits
    "e3e643",           -- Menu Color
    E_MODEL_MARIO,       -- Character Model
    CT_MARIO,           -- Override Character
    TEX_CHAR_LIFE_ICON, -- Life Icon
    1,                  -- Camera Scale
    0                   -- Vertical Offset
)