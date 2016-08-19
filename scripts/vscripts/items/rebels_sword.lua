function OnAttack( keys )
	local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	local disarmor 			= keys.Disarmor
	local modifier_name 	= keys.ModifierName
	local duration 			= keys.Duration
	local max_disarmor_pct 	= keys.MaxDisarmor / 100

	if caster:IsIllusion() then return end
	
	if target:HasModifier(modifier_name) then
		local stack_count 			= target:GetModifierStackCount(modifier_name, caster)
		local target_armor_total 	= target:GetPhysicalArmorValue() + stack_count

		ability:ApplyDataDrivenModifier(caster, target, modifier_name, { duration = duration })

		if stack_count < max_disarmor_pct*target_armor_total then
			ability:ApplyDataDrivenModifier(caster, target, modifier_name, { duration = duration })
			target:SetModifierStackCount(modifier_name, caster, stack_count + disarmor)
		end
	else
		ability:ApplyDataDrivenModifier(caster, target, modifier_name, { duration = duration })
		target:SetModifierStackCount(modifier_name, caster, disarmor)
	end
end