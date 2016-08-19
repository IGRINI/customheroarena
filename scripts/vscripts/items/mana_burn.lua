--[[Mana drain and damage part of Mana Break
	Author: Pizzalol
	Date: 11.07.2015.]]

--[[
	Ty pizzalol :)
]]
function ManaBreak( keys )
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local manaBurn = ability:GetLevelSpecialValueFor("mana_burn", (ability:GetLevel() - 1))
	local manaDamage = ability:GetLevelSpecialValueFor("burn_to_damage", (ability:GetLevel() - 1))/100

	if not target or not IsValidEntity(target) then end
	local damageTable = {}
	damageTable.attacker = caster
	damageTable.victim = target
	damageTable.damage_type = ability:GetAbilityDamageType()
	damageTable.ability = ability

	-- If the target is not magic immune then reduce the mana and deal damage
	if not target:IsMagicImmune() then
		-- Checking the mana of the target and calculating the damage
		if(target:GetMana() >= manaBurn) then
			damageTable.damage = manaBurn * manaDamage
			target:ReduceMana(manaBurn)
		else
			damageTable.damage = target:GetMana() * manaDamage
			target:ReduceMana(manaBurn)
		end
		ApplyDamage(damageTable)
	end
end