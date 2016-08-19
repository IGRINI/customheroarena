function FaceOfDeath( event )
	-- Variables
	local caster 			= event.caster
	local target 			= event.target
	local ability 			= event.ability
	local damage_pct 		= event.dmg_pct / 100
	local damage 			= ability:GetLevelSpecialValueFor( "heal_amount" , ability:GetLevel() - 1 ) + target:GetHealth()*damage_pct
	local heal 				= ability:GetLevelSpecialValueFor( "heal_amount" , ability:GetLevel() - 1 ) + target:GetHealth()*damage_pct
	local projectile_speed 	= ability:GetSpecialValueFor( "projectile_speed" )
	local particle_name 	= "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf"

	-- Play the ability sound
	caster:EmitSound("Hero_Abaddon.DeathCoil.Cast")
	target:EmitSound("Hero_Abaddon.DeathCoil.Target")

	-- If the target and caster are on a different team, do Damage. Heal otherwise
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		ApplyDamage({ victim = target, attacker = caster, damage = damage,	damage_type = DAMAGE_TYPE_MAGICAL })
	else
		target:Heal( heal, caster)
	end

	-- Create the projectile
	local info = {
		Target = target,
		Source = caster,
		Ability = ability,
		EffectName = particle_name,
		bDodgeable = false,
			bProvidesVision = true,
			iMoveSpeed = projectile_speed,
        iVisionRadius = 0,
        iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( info )

end