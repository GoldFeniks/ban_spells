dofile("data/scripts/lib/mod_settings.lua")

local mod_id = "ban_spells"
mod_settings_version = 1

mod_settings = 
{
    {
        category_id = "GENERAL",
        ui_name = "GENERAL",
        settings = {
            {
                id = "SHOW_SPELL_DESCRIPTION",
                ui_name = "Show spell description",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "HIDE_DEFAULT",
                ui_name = "Hide mod by default",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "SHOW_BANNED_SPELLS_INGAME",
                ui_name = "Show banned spells ingame",
                value_default = true,
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART
            },
            {
                id = "TOTAL_WIDTH",
                ui_name = "Total width",
                value_default = "0",
                allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART
            }
        }
    },
    {
        category_id = "MAIN_PANEL",
        ui_name = "MAIN PANEL",
        ui_description = "Panel with banned spells list",
        settings = {
            {
                id = "MAIN_PANEL_X_COORDINATE",
                ui_name = "X coordinate",
                value_default = "20",
                allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "MAIN_PANEL_Y_COORDINATE",
                ui_name = "Y coordinate",
                value_default = "298",
                allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "MAIN_PANEL_N_ROWS",
                ui_name = "N rows",
                value_default = "2",
                allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "MAIN_PANEL_N_COLS",
                ui_name = "N columns",
                value_default = "10",
                allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
        }
    },
    {
        category_id = "SPELLS_PANEL",
        ui_name = "SPELL PANEL",
        ui_description = "Spell selection panel",
        settings = {
            {
                id = "SPELLS_PANEL_HIDE_DEFAULT",
                ui_name = "Hide by default",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "SPELLS_PANEL_N_ROWS",
                ui_name = "N rows",
                value_default = "2",
                allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
            {
                id = "SPELLS_PANEL_N_COLS",
                ui_name = "N columns",
                value_default = "22",
                allowed_characters = "0123456789",
                scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
            },
        }
    }
}


function ModSettingsUpdate(init_scope)
    local old_version = mod_settings_get_version(mod_id)
    mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
    return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
    mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end
