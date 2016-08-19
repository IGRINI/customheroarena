function VengeanceArmorSuccess(event)
	local caster = event.caster
	local ability = event.ability
	local target = event.attacker
	local heal = event.Damage or 0
	local cooldown = ability:GetCooldown( ability:GetLevel() -1)
	if not caster or not ability or not target then end
	if caster:IsIllusion() then return end
	
	if heal < 10 then return end
	if ability:GetCooldownTimeRemaining() > 0 then return end

	caster:Heal(heal, ability)
	caster:PerformAttack(target, false, false, true, false, true)
	ability:StartCooldown(cooldown)

end