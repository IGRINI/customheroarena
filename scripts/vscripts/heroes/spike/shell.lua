function Shell(params)
	local damage = params.Damage
	local attacker = params.attacker
	local hero = params.caster
	local ability = params.ability
	local return_damage_percent = ability:GetLevelSpecialValueFor("return_damage", ability:GetLevel() - 1) / 100

	local damage_int_pct_add = hero:GetIntellect()

	local damage_int_pct_add = 1
	if hero:IsRealHero() then
		damage_int_pct_add = hero:GetIntellect()
		damage_int_pct_add = damage_int_pct_add / 16 / 100 + 1
	end 

	if attacker == hero then return end

	if not attacker or hero:IsIllusion() then return end
	 
	if attacker:IsMagicImmune() then
		return
	end

	local attacker_name = attacker:GetUnitName()

	if attacker_name == "dota_fountain" then
		return
	end

	if IsUnitBossGlobal(attacker) then return end

	damage = damage*return_damage_percent / damage_int_pct_add

	if damage > 2 then
		if attacker:GetHealth() < damage + 1 then
			attacker:Kill(ability, hero)
		else
			attacker:SetHealth(attacker:GetHealth() - damage - 1)
			attacker:Heal(1, ability) 
			ApplyDamage({ victim = attacker, attacker = hero, damage = 1, damage_type = DAMAGE_TYPE_PURE })
		end
	end

	if attacker:GetHealth() == 0 then
		attacker:Kill(ability, hero)
	end
end