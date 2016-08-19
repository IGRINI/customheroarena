function takedamage(params)
	local damage = params.Damage
	local attacker = params.attacker
	local hero = params.caster
	local ability = params.ability
	local reduction_percentage = ability:GetLevelSpecialValueFor("reduce_percent", ability:GetLevel() - 1) / 100

	if not hero then return end
	if hero:IsIllusion() then return end
	

	if IsUnitBossGlobal(attacker) then return end

	local attacker_name = attacker:GetUnitName()

	if attacker_name == "dota_fountain" then
		return
	end
	
	if attacker == hero then return end
	
	if hero then 
		if hero:GetHealth() > damage - damage*reduction_percentage then
			hero:Heal(damage * reduction_percentage, ability)
		end
	end

	local damage_int_pct_add = 1
	if hero:IsRealHero() then
		damage_int_pct_add = hero:GetIntellect()
		damage_int_pct_add = damage_int_pct_add / 16 / 100 + 1
	end 

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

	--[[
	if damage > 15 and attacker and hero and attacker~=hero then 
		if attacker:GetHealth() < damage then
			--ApplyDamage({ victim = attacker, attacker = hero, damage = attacker:GetHealth(),	damage_type = DAMAGE_TYPE_PURE })
			attacker:Kill(ability, hero)
		else
			ApplyDamage({ victim = attacker, attacker = attacker, damage = damage-1,	damage_type = DAMAGE_TYPE_PURE })
			ApplyDamage({ victim = attacker, attacker = hero, damage = 1, damage_type = DAMAGE_TYPE_PURE })
		end
	end]]
end