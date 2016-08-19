function HealCaster(params)
	local caster = params.caster
	if not caster then return end
	local ability = params.ability
	local heal = params.heal*caster:GetMaxHealth()/500

	caster:Heal(heal, ability) 
end