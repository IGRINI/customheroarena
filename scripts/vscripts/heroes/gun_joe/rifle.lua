local TIMER_TICK = 0.3

local modifiers = {
	["modifier_item_monkey_king_bar"] = "item_monkey_king_bar",
	["modifier_item_abyssal_blade"] = "item_abyssal_blade",
	["modifier_item_cranium_basher"] = "item_basher",
	["modifier_item_mjollnir"] = "item_mjollnir",
	["modifier_item_mjollnir"] = "item_mjollnir_2",
	["modifier_item_maelstrom"] = "item_maelstrom",
	["modifier_passive_possessed_sword"] = "item_possessed_sword",
	["modifier_passive_kings_bar"] = "item_kings_bar"
}

local item_placebo = "item_circlet"

local inventory_items = {}

function MachineGun_start( keys )
	-- Variables
	local caster = keys.caster
	Timers:CreateTimer("rifle_check_pid".. caster:GetPlayerID(),{ --таймер следующей дуэльки
                endTime = TIMER_TICK,
                callback = function()
                	if caster and caster:IsAlive() then
                    	RemoveModifiers(caster, modifiers)
                    else
                    	return nil
                    end
                    return TIMER_TICK
                end})	
end

function RemoveModifiers( unit , modifiers_table)
	if not unit then
		return
	end

	if not unit:IsAlive() then
		return
	end

	for x, _ in pairs(modifiers_table) do
		unit:RemoveModifierByName(x)
	end
end

function IsItemInModifier(item)
	for _, x in pairs(modifiers) do
		if x == item:GetName() then return true end
	end
	return false
end

function MachineGun_stop( keys )
	-- Variables
	local caster = keys.caster
	Timers:RemoveTimer("rifle_check_pid".. caster:GetPlayerID())

	local item, new_item
	local items_to_delete = {}

	for i = 0, 5 do
		item = caster:GetItemInSlot(i)
		if item and IsItemInModifier(item) then
			new_item = CreateItem(item:GetName(), caster, caster) 
			new_item:SetPurchaseTime(0)
			caster:RemoveItem(item)
			UTIL_Remove(item)
			caster:AddItem(new_item)
		elseif not item then
			new_item = CreateItem(item_placebo, caster, caster)
			new_item:SetPurchaseTime(0)
			table.insert(items_to_delete, new_item)
			caster:AddItem(new_item)

		end
	end

	for i = 0, 5 do
		item = caster:GetItemInSlot(i)

		for _, x in pairs(items_to_delete) do
			if item == x then
				caster:RemoveItem(item)
				UTIL_Remove(item)
			end
		end
	end

end