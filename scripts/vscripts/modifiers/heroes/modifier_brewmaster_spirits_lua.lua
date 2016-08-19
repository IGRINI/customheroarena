modifier_brewmaster_spirits_lua = class({})

function modifier_brewmaster_spirits_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
 
	return funcs
end

function modifier_brewmaster_spirits_lua:IsHidden()
	return true
end

function modifier_brewmaster_spirits_lua:IsPurgable()
	return false
end

function modifier_brewmaster_spirits_lua:GetModifierExtraHealthBonus(params)
	local time = GameRules:GetGameTime() / 60

	return 118*time - 154
end

function modifier_brewmaster_spirits_lua:GetModifierBaseAttack_BonusDamage(params)
	local time = GameRules:GetGameTime() / 60


	return math.abs(0.0984*math.pow(time,2) + 5.49*time - 30)

end

function modifier_brewmaster_spirits_lua:GetModifierAttackSpeedBonus_Constant(params)
	local time = GameRules:GetGameTime() / 60

	return 0.029*math.pow(time,2) + 2.66*time + 16
end

function modifier_brewmaster_spirits_lua:GetModifierPhysicalArmorBonus(params)
	local time = GameRules:GetGameTime() / 60

	return (0.0049*math.pow(time,2) + 1.34*time + 1.66)/1.5
end

function modifier_brewmaster_spirits_lua:OnCreated(event)
end