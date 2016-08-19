function EchoSabreAttack(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local modifier_name = keys.ModifierName
	local cooldown = ability:GetCooldown(ability:GetLevel() )


	if caster:IsRangedAttacker() then return end
	if caster:IsIllusion() then return end

	if ability:GetCooldownTimeRemaining() ~= 0 then return end

	ability:StartCooldown(cooldown)

	ability:ApplyDataDrivenModifier(caster, target, modifier_name, {})

	caster:PerformAttack(target, true, true, true, true, true)

	print("DEAL ATTACK!")
end