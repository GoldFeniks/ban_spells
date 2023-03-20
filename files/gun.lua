dofile_once("mods/modloader/files/modloader.lua")

local mod = modloader:register("ban_spells")

local func = mod.functions:load("draw_action")
func:disable_original()

local on_action_cast = mod.events:add("on_action_cast")
func:append(function (instant_reload_if_empty)
    local action = nil

    state_cards_drawn = state_cards_drawn + 1

    if reflecting then  return  end


    if ( #deck <= 0 ) then
        if instant_reload_if_empty and ( force_stop_draws == false ) then
            move_discarded_to_deck()
            order_deck()
            start_reload = true
        else
            reloading = true
            return true -- <------------------------------------------ RETURNS
        end
    end

    if #deck > 0 then
        -- draw from the start of the deck
        action = deck[ 1 ]

        table.remove( deck, 1 )

        for _, value in pairs(on_action_cast(action.id)) do
            if not value then
                return false
            end
        end
        
        -- update mana
        local action_mana_required = action.mana
        if action.mana == nil then
            action_mana_required = ACTION_MANA_DRAIN_DEFAULT
        end

        if action_mana_required > mana then
            OnNotEnoughManaForAction()
            table.insert( discarded, action )
            return false -- <------------------------------------------ RETURNS
        end

        if action.uses_remaining == 0 then
            table.insert( discarded, action )
            return false -- <------------------------------------------ RETURNS
        end

        mana = mana - action_mana_required
    end

    --- add the action to hand and execute it ---
    if action ~= nil then
        play_action( action )
    end

    return true
end)


local func = mod.functions:load("_play_permanent_card")
func:disable_original()
func:append(function (action_id)
    for _, value in pairs(on_action_cast(action_id)) do
        if not value then
            return
        end
    end

    for i,action in ipairs(actions) do
        if action.id == action_id then
            playing_permanent_card = true
            action_clone = {}
            clone_action( action, action_clone )
            action_clone.permanently_attached = true
            action_clone.uses_remaining = -1
            handle_mana_addition( action_clone )
            play_action( action_clone )
            
            playing_permanent_card = false
            break
        end
    end
end)

on_action_cast:subscribe(function (action_id)
    local banned = GlobalsGetValue("997956878_BANNED_SPELLS_IDS", "")

    if string.find(banned , '@' .. action_id .. '@' ) ~= nil then
        return false
    end

    return true
end)
