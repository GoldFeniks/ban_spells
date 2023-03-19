function main()
    local entity_id = GetUpdatedEntityID()

    local action_comp_id = EntityGetFirstComponentIncludingDisabled(entity_id, 'ItemActionComponent')
    if action_comp_id == nil then
        return
    end

    local action_id = ComponentGetValue2(action_comp_id, 'action_id')
    if action_id == nil then
        return
    end

    local banned = GlobalsGetValue("997956878_BANNED_SPELLS_IDS", "")
    local enabled = string.find(banned , '@' .. action_id .. '@' ) == nil    

    EntitySetComponentsWithTagEnabled(entity_id, 'enabled_in_hand', enabled)

    local comp_id = GetUpdatedComponentID()
    EntitySetComponentIsEnabled(entity_id, comp_id, true)
end

main()
