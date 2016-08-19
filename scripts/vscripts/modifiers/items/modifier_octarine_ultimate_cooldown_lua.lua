modifier_octarine_ultimate_cooldown_lua = class({})

function modifier_octarine_ultimate_cooldown_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		--MODIFIER_PROPERTY_IS_SCEPTER,
	}
 
	return funcs
end

function modifier_octarine_ultimate_cooldown_lua:GetAttributes()
	local attrs = {
			MODIFIER_ATTRIBUTE_PERMANENT,
			MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE,
		}

	return attrs
end

function modifier_octarine_ultimate_cooldown_lua:GetModifierScepter()
	return 1
end

function modifier_octarine_ultimate_cooldown_lua:IsHidden()
	return true
end

function modifier_octarine_ultimate_cooldown_lua:GetModifierPercentageCooldown(params)
	return 25
end

function modifier_octarine_ultimate_cooldown_lua:IsPurgable()
	return false
end


function modifier_octarine_ultimate_cooldown_lua:OnCreated(event)
end
