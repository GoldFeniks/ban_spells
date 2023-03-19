dofile_once("mods/modloader/files/modloader.lua")

local mod = modloader:register("ban_spells")

mod:add_gui("mods/ban_spells/files/gui.lua")
mod:append("data/scripts/gun/gun.lua", "mods/ban_spells/files/gun.lua")
mod.entities:patch("data/entities/misc/custom_cards/energy_shield.xml",  "mods/ban_spells/files/patch_entity.lua")
mod.entities:patch("data/entities/misc/custom_cards/tiny_ghost.xml",     "mods/ban_spells/files/patch_entity.lua")
mod.entities:patch("data/entities/misc/custom_cards/torch_electric.xml", "mods/ban_spells/files/patch_entity.lua")
mod.entities:patch("data/entities/misc/custom_cards/torch.xml",          "mods/ban_spells/files/patch_entity.lua")

mod:finalize()
