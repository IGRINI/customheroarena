function OnAttack(event)
	local ability	= event.ability
	local target 	= event.target
	local heal_pct 	= event.heal_pct	or 0
	local caster 	= event.caster

	if caster:IsIllusion() or target:IsIllusion() then return end
	
	if IsUnitBossGlobal(target) then
		heal_pct = heal_pct / 6
	end

	local damage = target:GetHealth() * heal_pct / 100

	ApplyDamage({ victim = target, attacker = caster, damage = damage,	damage_type = DAMAGE_TYPE_PHYSICAL })
	caster:Heal(damage, ability) 
end