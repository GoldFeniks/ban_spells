dofile_once("data/scripts/gun/gun_actions.lua")


-- Banned state variables and functions
local sorted_actions = {}
for i, spell in ipairs(actions) do
    table.insert(sorted_actions, spell)
end

table.sort(sorted_actions, function (a, b)
    return string.lower(GameTextGetTranslatedOrNot(a.name)) < string.lower(GameTextGetTranslatedOrNot(b.name))
end)

local _spell_letters = {}
for i, action in ipairs(sorted_actions) do
    _spell_letters[string.lower(string.sub(GameTextGetTranslatedOrNot(action.name), 1, 1))] = true
end

local spell_letters = {}
for item in pairs(_spell_letters) do
    table.insert(spell_letters, item)
end
table.sort(spell_letters)

local spells = {}
local banned = ModSettingGet("ban_spells.BANNED_SPELLS") or ""
for spell_id in string.gmatch(banned, '([^,]+)') do
    for i, action in ipairs(sorted_actions) do
        if action.id == spell_id then
            table.insert(spells, action)
        end
    end
end

local function _set_globals()
    local spells_ids = {}
    for i, spell in ipairs(spells) do
        table.insert(spells_ids, spell.id)
    end

    ModSettingSet("ban_spells.BANNED_SPELLS", table.concat(spells_ids, ","))


    for i, spell in ipairs(spells) do
        spells_ids[i] = '@' .. spell.id .. '@'
    end

    GlobalsSetValue("997956878_BANNED_SPELLS_IDS", table.concat(spells_ids, ","))    
end


-- Gui setup
dofile_once("mods/modloader/files/gui/box.lua")
dofile_once("mods/modloader/files/gui/gui.lua")
dofile_once("mods/modloader/files/gui/grid.lua")
dofile_once("mods/modloader/files/gui/text.lua")
dofile_once("mods/modloader/files/gui/image.lua")
dofile_once("mods/modloader/files/gui/layout.lua")
dofile_once("mods/modloader/files/gui/button.lua")

-- Options 
local hide_spell_selection = ModSettingGet("ban_spells.SPELLS_PANEL_HIDE_DEFAULT")
local hide_default = ModSettingGet("ban_spells.HIDE_DEFAULT")
local banned_n_rows = tonumber(ModSettingGet("ban_spells.MAIN_PANEL_N_ROWS") or "2")
local banned_n_cols = tonumber(ModSettingGet("ban_spells.MAIN_PANEL_N_COLS") or "2")
local spells_n_rows = tonumber(ModSettingGet("ban_spells.SPELLS_PANEL_N_ROWS") or "2")
local spells_n_cols = tonumber(ModSettingGet("ban_spells.SPELLS_PANEL_N_COLS") or "2")
local x_start = tonumber(ModSettingGet("ban_spells.MAIN_PANEL_X_COORDINATE") or "100")
local y_start = tonumber(ModSettingGet("ban_spells.MAIN_PANEL_Y_COORDINATE") or "100")
local total_width = tonumber(ModSettingGet("ban_spells.TOTAL_WIDTH") or "0")
local show_spell_description = ModSettingGet("ban_spells.SHOW_SPELL_DESCRIPTION")

local filter = ""
local hide = hide_default
local panel = gui.inventory_open:add("banned spells gui")

function panel:initialize(gui)
    if not self.first_init then
        if hide_default then
            hide = true
        end

        return
    end

    if total_width == nil or total_width <= 0 then
        total_width, _ = GuiGetScreenDimensions(gui)
        self.initialized = false
    end

    -- Hide/show button
    self:add_object(button:new{
        x=520, y=25,

        __update=function(self, gui)
            self.text = hide and "Show" or "Hide"
        end,

        on_clicked=function(self, gui)
            hide = not hide
        end
    })


    local spell_hover_function = function (self, gui)
        GuiTooltip(gui,
            GameTextGetTranslatedOrNot(self.spell.name),
            show_spell_description and GameTextGetTranslatedOrNot(self.spell.description) or ""
        )
    end


    -- Banned spells panel
    local banned_spell_buttons = {}
    local banned_spells = grid:new{
        n_rows=banned_n_rows,
        n_cols=banned_n_cols,
        item_width=16,
        item_height=16,
        col_margin=2,
        row_margin=2,

        __update=function (self, gui)
            for i, spell in ipairs(spells) do
                local button = banned_spell_buttons[spell.id]
                if not button.in_container then
                    button.in_container = true
                    self:add_child(button)
                end

                button.idx = i
            end
        end
    }

    for i, spell in ipairs(sorted_actions) do
        banned_spell_buttons[spell.id] = image_button:new{
            idx=-1,
            spell=spell,
            in_container=false,
            sprite_filename=spell.sprite,
            on_hover=spell_hover_function,

            on_clicked=function (self, gui)
                if self.idx ~= -1 then
                    table.remove(spells, self.idx)
                    _set_globals()
                end

                self.in_container = false
                banned_spells:remove_child(self)
            end
        }
    end


    -- Spell selection panel
    local spell_buttons = {}
    local spells_selection = grid:new{
        n_rows=spells_n_rows,
        n_cols=spells_n_cols,
        item_width=16,
        item_height=16,
        children=spell_buttons,
        col_margin=2,
        row_margin=2,
    }

    for i, spell in ipairs(sorted_actions) do
        table.insert(spell_buttons, image_button:new{
            spell=spell,
            sprite_filename=spell.sprite,
            on_hover=spell_hover_function,

            on_clicked=function (self, gui)
                if not banned_spell_buttons[self.spell.id].in_container then
                    table.insert(spells, self.spell)
                    _set_globals()
                end
            end
        })
    end

    
    -- Spell selection/banning controls/info
    local total_text = box:new{
        width=banned_spells.width,
        padding_x=4,
        padding_y=4,
        children={
            text:new{
                __update=function (self, gui)
                    self.text = "Total: " .. tostring(#spells)
                end
            },
            button:new{
                text="Clear",

                on_clicked=function (self, gui)
                    spells = {}
                    _set_globals()

                    for i, button in ipairs(banned_spells.children) do
                        button.in_container = false
                    end
                    banned_spells.children = {}
                end
            },
            button:new{
                __update=function (self, gui)
                    self.text = hide_spell_selection and "Show spells" or "Hide spells"
                end,

                on_clicked=function (self, gui)
                    hide_spell_selection = not hide_spell_selection
                end
            }
        }
    }


    -- Filters
    local filter_button_render = function (self, x, y)
        button.__render(self, x, y)

        if self.letter == filter then
            GuiText(self.__gui.get_current_gui(), x, y + 3, self.underscore)
        end
    end

    local filter_button_clicked = function (self, gui)
        filter = self.letter        

        for i, spell_button in ipairs(spell_buttons) do
            local name = GameTextGetTranslatedOrNot(spell_button.spell.name)
            name = name and string.lower(name) or ""            

            spell_button.enabled = filter == "" or name == "" or string.sub(name, 1, 1) == filter
        end  
    end


    -- Spell selection and filter area
    local filters = {
        button:new{
            text="All",
            letter="",
            underscore="__",
            __render=filter_button_render,
            on_clicked=filter_button_clicked
        }
    }

    for i, letter in ipairs(spell_letters) do
        table.insert(filters, button:new{
            text=string.upper(letter),
            letter=letter,
            underscore="_",
            __render=filter_button_render,
            on_clicked=filter_button_clicked
        })
    end

    local filters_box = box:new{
        width=spells_selection.width,
        padding_x=4,
        padding_y=4,
        children=filters
    }


    -- Add everything together
    self:add_object(box:new{
        x=x_start, y=y_start,
        width=total_width,
        padding_x=10,
        padding_y=2,

        __update=function (self, gui)
            self.enabled = not hide
        end,

        children={
            box:new{
                width=banned_spells.width,
                padding_y=2,
                children={
                    banned_spells,
                    total_text,
                }
            },
            box:new{
                width=spells_selection.width,
                padding_y=2,

                __update=function (self, gui)
                    self.enabled = not hide_spell_selection
                end,

                children={
                    spells_selection,
                    filters_box
                }
            }
        }
    })
end


if ModSettingGet("ban_spells.SHOW_BANNED_SPELLS_INGAME") then
    local panel = gui.inventory_closed:add("banned spells gui")

    function panel:initialize(gui)
        if self.first_init then
            local width, height = GuiGetScreenDimensions(gui)

            self.banned_spell_images = {}
            for i, spell in ipairs(sorted_actions) do
                self.banned_spell_images[spell.id] = image:new{sprite_filename=spell.sprite}
            end

            self.box = self:add_object(box:new{
                x=20, y=325,
                width=width - 40,
                padding_x=4,
                padding_y=4,

                __update=function (self, gui)
                    self.y = height - self.height - 5
                end
            })
        end

        self.box.children = {}
        for i, spell in ipairs(spells) do
            self.box:add_child(self.banned_spell_images[spell.id])
        end
    end
end
