function patch_entity(entity, mod)
    entity:add_lua_script{
        path="mods/ban_spells/files/passive_fix.lua",
        interval=10,
        parameters={
            execute_times=-1,
            _tags="enabled_in_hand"
        }
    }
end
