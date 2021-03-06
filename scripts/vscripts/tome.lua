local Constants = require('consts') -- XP TABLE

function UpgradeStats(keys)
	local caster = keys.caster
	local cost = keys.ability:GetCost() 
	local str = keys.Str
	local agi = keys.Agi
	local int = keys.Int

	if not caster or not caster:IsRealHero() then return end
	if caster:HasModifier("modifier_arc_warden_tempest_double") then return end
	
	_G.tPlayers[caster:GetPlayerOwnerID() ] = _G.tPlayers[caster:GetPlayerOwnerID() ] or {}
	_G.tPlayers[caster:GetPlayerOwnerID() ].books = _G.tPlayers[caster:GetPlayerOwnerID() ].books or 0
	_G.tPlayers[caster:GetPlayerOwnerID() ].books = _G.tPlayers[caster:GetPlayerOwnerID() ].books + cost

	if str then caster:ModifyStrength(str) end
	if agi then caster:ModifyAgility(agi) end
	if int then caster:ModifyIntellect(int) end
end


function tome_levelup(keys)
	local caster = keys.caster
	if not caster or not caster:IsRealHero() then return end
	if caster:HasModifier("modifier_arc_warden_tempest_double") then return end
	local level = caster:GetLevel()
	local need_exp = Constants.XP_PER_LEVEL_TABLE[level+1]
	local old_exp = Constants.XP_PER_LEVEL_TABLE[level]
	if not need_exp then need_exp = 0 end
	if not old_exp then old_exp = 0 end
	local cost = keys.ability:GetCost() 
	_G.tPlayers[caster:GetPlayerOwnerID() ] = _G.tPlayers[caster:GetPlayerOwnerID() ] or {}
	_G.tPlayers[caster:GetPlayerOwnerID() ].books = _G.tPlayers[caster:GetPlayerOwnerID() ].books or 0
	_G.tPlayers[caster:GetPlayerOwnerID() ].books = _G.tPlayers[caster:GetPlayerOwnerID() ].books + cost

	caster:HeroLevelUp(true)
	caster:AddExperience(need_exp - old_exp,  true, true)
end

function MedicalTractat(keys)
	local caster = keys.caster
	if not caster then return end
	
	if not(caster.medical_tractates) then
		caster.medical_tractates = 0
	end
	local cost = keys.ability:GetCost() 
	_G.tPlayers[caster:GetPlayerOwnerID() ] = _G.tPlayers[caster:GetPlayerOwnerID() ] or {}
	_G.tPlayers[caster:GetPlayerOwnerID() ].books = _G.tPlayers[caster:GetPlayerOwnerID() ].books or 0
	_G.tPlayers[caster:GetPlayerOwnerID() ].books = _G.tPlayers[caster:GetPlayerOwnerID() ].books + cost

	caster.medical_tractates = caster.medical_tractates + 1
	
	caster:RemoveModifierByName("modifier_medical_tractate") 
	while (caster:HasModifier("modifier_medical_tractate")) do
		caster:RemoveModifierByName("modifier_medical_tractate") 
	end
	caster:AddNewModifier(caster, nil, "modifier_medical_tractate", null)

end

function Eat_gem(keys)
	local caster = keys.caster
	if not caster then return end
	if not caster:IsRealHero() then return end

	local hero_item = CreateItem("item_gem", caster, caster) 
	caster.item_gem = hero_item
	caster:AddNewModifier(caster, caster.item_gem, "modifier_item_gem_of_true_sight", {})
end