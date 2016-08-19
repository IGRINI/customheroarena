modifier_boss_power = class({})

function modifier_boss_power:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
 
	return funcs
end

function modifier_boss_power:IsHidden()
	return true
end

function modifier_boss_power:OnTakeDamage(params)
	local position 	= self:GetCaster():GetAbsOrigin() 
	local radius  	= 1500
	local attacker  = params.attacker

	if not attacker then return end

	attacker:RemoveModifierByName("modifier_smoke_of_deceit")

end

function modifier_boss_power:GetModifierExtraHealthBonus(params)
	local time = GameRules:GetGameTime()
	local health_multipler = time / 800
	
	local addiditional_health = 0

	if _G.Bosses.deaths then
		if _G.Bosses.deaths[self:GetCaster():GetUnitName()] then
			addiditional_health = 5000+_G.Bosses.deaths[self:GetCaster():GetUnitName()]*5000
		end
	end

	return 10000*health_multipler  + addiditional_health
end

function modifier_boss_power:GetModifierBaseAttack_BonusDamage(params)
	local time = GameRules:GetGameTime() -- seconds

	local addiditional_attack = 0
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_permanent_stun_anti_camp") then 
		self:GetCaster():SetHealth(9999999) 
		self:GetCaster():AddNewModifier(caster, nil, "modifier_invulnerable", { duration = 15 }) 
	end

	caster:RemoveModifierByName("modifier_axe_berserkers_cal")
	caster:RemoveModifierByName("modifier_permanent_stun_anti_camp")
	caster:RemoveModifierByName("modifier_ursa_fury_swipes_damage_increase")
	caster:RemoveModifierByName("modifier_item_skadi_slow")
	caster:RemoveModifierByName("modifier_scadi_2_slow")

	--[[
	if caster:GetUnitName() == "npc_dota_custom_guardian" then
		for i = 0, caster:GetModifierCount() do
			print(caster:GetModifierNameByIndex(i))
		end
	end]]
	
	if _G.Bosses.deaths then
		if _G.Bosses.deaths[self:GetCaster():GetUnitName()] then
			addiditional_attack = _G.Bosses.deaths[self:GetCaster():GetUnitName()]*200
		end
	end

	return math.pow(time/100,2) / 2 + addiditional_attack
end

function modifier_boss_power:IsPurgable()
	return false
end

function modifier_boss_power:GetModifierPhysicalArmorBonus(params)
	local time = GameRules:GetGameTime()
	local armor_multipler = time / 800

	return 10*armor_multipler
end

function modifier_boss_power:OnCreated(event)
	if IsServer() then
		self.health_bonus = 10000;
		self.attack_bonus = 220;
		self.armor_bonus = 10;
	end
end

function modifier_boss_power:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY]	= true,
	}
	return state
end