function HealPct(keys)
	local caster = keys.caster
	local ability = keys.ability
	local heal_pct = keys.HealPct/100
	local total_heal = caster:GetMaxHealth()*heal_pct
	caster:Heal(total_heal, ability) 
end