modifier_godmode = class({})

function modifier_godmode:IsHidden()
	return false
end

function modifier_godmode:IsPurgable()
	return false
end

function modifier_godmode:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
 
	return funcs
end

function modifier_godmode:GetModifierIncomingDamage_Percentage(params)
	return -100
end