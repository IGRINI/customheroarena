function OnSpellStart( event )
	local caster 			= event.caster
	local point 			= event.target_points[1]
	local ability 			= event.ability

	ability.direction 		= caster:GetForwardVector()
	ability.speed 			= 1600/25
	ability.traveled 		= 0
	ability.distance 		= (caster:GetAbsOrigin() - point):Length2D() 
	ability.units 			= {}
	ability.damage 			= event.Damage or 100
	ability.modifier_name 	= event.ModifierName
end

function MotionHorizontal( event )
	local caster = event.target
	local ability = event.ability

	if ability.traveled < ability.distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.direction*ability.speed)
		ability.traveled = ability.traveled + ability.speed
		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin() , nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false) 
		if units then
			for i = 1, #units do
				if not ability.units[ units[i] ] then
					ability.units[units[i]] = 1
					caster:PerformAttack(units[i], false, false, true, false, true)
					ApplyDamage({ victim = units[i], attacker = caster, damage = ability.damage,	damage_type = DAMAGE_TYPE_PHYSICAL })
				end
			end
		end
	else
		caster:InterruptMotionControllers(true)
		caster:RemoveModifierByName(ability.modifier_name)
	end
end