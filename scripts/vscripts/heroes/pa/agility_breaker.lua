function OnHeroKilled(keys)
	if not keys then print("KEYS ERROR") return end
	local caster = keys.caster
	local ability = keys.ability
	local stack_modifier_name = keys.ModifierName

	local current_stack = caster:GetModifierStackCount( stack_modifier_name, ability )

	caster:RemoveModifierByName(stack_modifier_name) 
	ability:ApplyDataDrivenModifier(caster, caster, stack_modifier_name, {}) 


	caster:SetModifierStackCount( stack_modifier_name, ability, current_stack + 1 )

	--for i,x in pairs(keys) do print(i, x) end
end