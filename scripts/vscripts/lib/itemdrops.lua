local table_items_common_earlygame = {
	"item_wraith_band",
	"item_bracer",
	"item_null_talisman",
	"item_gloves",
	"item_blades_of_attack",
}
local table_items_common_midgame = {
	"item_helm_of_iron_will",
	"item_lifesteal",
	"item_mithril_hammer",
	"item_blade_of_alacrity",
	"item_staff_of_wizardry",
	"item_ogre_axe"
}
function CreateItems(SpawnedUnit)
	if not SpawnedUnit then return end
	local item
	if SpawnedUnit:IsNeutralUnitType() then
		local random = math.random(100)
		print("Randomed number is " .. random)
		if GetGameTime() <= 600 then
			if random < 75 then
				item = table_items_common_earlygame[RandomInt(1, #table_items_common_earlygame)]
			elseif random > 75 then
				item = nil
			end
		elseif GetGameTime() >= 600 and GetGameTime <= 1200 then
			if random < 75 then
				item = table_items_common_midgame[RandomInt(1, #table_items_common_midgame)]
			elseif random > 75 then
				item = nil
			end
		--local item_name = CreateItem(item,SpawnedUnit,SpawnedUnit)
		SpawnedUnit:AddItemByName(item)
	end
end

function LaunchItems(KilledUnit)
	if IsServer() then
		if KilledUnit:IsNeutralUnitType() then
		   for i=0,5 do
				local item = KilledUnit:GetItemInSlot(i);
				if item ~= nil then
					local position = KilledUnit:GetAbsOrigin()
					local name = item:GetAbilityName()
					local newItem = CreateItem(name, nil, nil)
					newItem:SetPurchaseTime(0)
					KilledUnit:RemoveItem(item)
					local drop = CreateItemOnPositionSync( position, newItem )
   					newItem:LaunchLoot(false, 300, 0.75, position + RandomVector(RandomFloat(50, 80)))
				end
			end
		end
	end
end