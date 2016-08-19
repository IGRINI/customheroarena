local init = false

local blocked_abilities = {
	["item_power_treads"] = 1,
	["item_power_treads_2"] = 1,
	["item_power_treads_3"] = 1,
	["item_ward_sentry"] = 1,
	["item_ward_observer"] = 1,
	["obsidian_destroyer_arcane_orb"] = 1,
	["tinker_rearm"] = 1,
	["keeper_of_the_light_illuminate_end"] = 1,
	["keeper_of_the_light_spirit_form_illuminate"] = 1,
	["keeper_of_the_light_spirit_form_illuminate_end"] = 1,
	["sniper_shrapnel"] = 1,
	["storm_spirit_ball_lightning"] = 1,
	["treant_natures_guise"] = 1,
	["earth_spirit_stone_caller"] = 1,
	["spectre_reality"] = 1,
	["item_shadow_amulet"] = 1,
	["courier_return_to_base"] = 1,
	["courier_go_to_secretshop"] = 1,
	["courier_transfer_items"] = 1,
	["courier_return_stash_items"] = 1,
	["courier_take_stash_items"] = 1,
	["courier_take_stash_and_transfer_items"] = 1,
	["courier_shield"] = 1,
	["courier_burst"] = 1,
	["riki_blink_strike"] = 1,
	["courier_morph"] = 1,
	["item_bottle"] = 1,
	["item_clarity"] = 1,
	["item_moon_shard"] = 1,
	["item_flask"] = 1,
	["item_ward_dispenser"] = 1,
	["item_smoke_of_deceit"] = 1,
	["rubick_spell_steal"] = 1,
	["ogre_magi_bloodlust"] = 1,
	["rubick_telekinesis_land"] = 1,
	["item_enchanted_mango"] = 1,
	["skywrath_mage_mystic_flare"] = 1,
	["elder_titan_return_spirit"] = 1,
	["broodmother_spin_web"] = 1,
	["shredder_return_chakram_2"] = 1,
	["shredder_return_chakram"] = 1,
	["phoenix_sun_ray_toggle_move"] = 1,
	["phoenix_sun_ray_stop"] = 1,
	["phoenix_icarus_dive_stop"] = 1,
	["ember_spirit_activate_fire_remnant"] = 1,
	["ember_spirit_fire_remnant"] = 1,
	["nyx_assassin_unburrow"] = 1,
	["lone_druid_true_form_druid"] = 1,
	["lone_druid_true_form"] = 1,
	["invoker_exort"] = 1,
	["invoker_wex"] = 1,
	["invoker_quas"] = 1,
	["enchantress_impetus"] = 1,
	["templar_assassin_self_trap"] = 1,
	["sniper_shrapnel"] = 1,
	["riki_blink_strike"] = 1,
	["witch_doctor_voodoo_restoration"] = 1,
	["morphling_morph_str"] = 1,
	["morphling_morph_agi"] = 1,
	["item_tome_agi_3"] = 1,
	["item_tome_agi_6"] = 1,
	["item_tome_agi_60"] = 1,
	["item_tome_str_3"] = 1,
	["item_tome_str_6"] = 1,
	["item_tome_str_60"] = 1,
	["item_tome_int_3"] = 1,
	["item_tome_int_6"] = 1,
	["item_tome_int_60"] = 1,
	["item_tome_lvlup"] = 1,
	["item_tome_med"] = 1,
	["item_branches"] = 1,
	["item_tome_un_3"] = 1,
	["item_tome_un_6"] = 1,
	["item_tome_un_60"] = 1,
	["invoker_quas"] = 1,
	["invoker_wex"] = 1,
	["invoker_exort"] = 1,
	["invoker_invoke"] = 1,
	["death_prophet_spirit_siphon"] = 1,
	["pugna_life_drain"] = 1,
	["item_tango"] = 1,
	["item_diffusal_blade"] = 1,
	["item_diffusal_blade_2"] = 1,
	["phoenix_launch_fire_spirit"] = 1,
	["shadow_demon_shadow_poison_release"] = 1,
	["shadow_demon_demonic_purge"] = 1,
	["item_mystic_amulet"]	= 1,
	["nyx_assassin_burrow"] = 1,
	["bristleback_viscous_nasal_goo"] = 1,
	["techies_focused_detonate"] = 1,

}
function static_check( keys )
	if init then return end
	init = true

	ListenToGameEvent( "dota_player_used_ability", function( event )
			local ply = PlayerResource:GetPlayer( event.PlayerID )
			local ability_name = event.abilityname
			--print("ability_name=", ability_name)
			if blocked_abilities[ability_name] then return end
			-- Check if player existed
			if ply and IsValidEntity(ply) and ply:GetClassname() == "player" then
				local hero = PlayerResource:GetSelectedHeroEntity(ply:GetPlayerID())
				if hero:HasItemInInventory("item_slice_amulet") then
					DealDamageAroundCaster(hero, 0.06, 200, 100)
				end
				if hero:HasItemInInventory("item_static_amulet") then
					DealDamageAroundCaster(hero, 0.16, 600, 275)
				end
			end
		end, nil
	)
end

function DealDamageAroundCaster(caster, multiplier, damage_add, manacost)
	if not caster then end
	local hero_name = caster:GetUnitName()

	if caster:GetMana() < manacost then return end

	local pos = caster:GetAbsOrigin()
	local team = caster:GetTeamNumber()
	local radius = 800
	
	local damage_int_pct_add = 1
	
	if caster:IsRealHero() then
		damage_int_pct_add = caster:GetIntellect()
		damage_int_pct_add = damage_int_pct_add / 16 / 100 + 1
	end 
	
	local units = FindUnitsInRadius(team, pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, 0, false) 

	caster:SpendMana(manacost, nil)

	for _, x in pairs(units) do
		if x and caster and x:GetTeamNumber() ~= caster:GetTeamNumber() and IsValidEntity(x) and x:IsAlive() then
			local damage_pre = x:GetHealth()*multiplier + damage_add
			local damage = damage_pre/damage_int_pct_add
			--print("apply damage to", x:GetUnitName(), " damage=", damage)
			ApplyDamage({ victim = x, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
		end
	end

end