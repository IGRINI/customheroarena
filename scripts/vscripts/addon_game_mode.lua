--[[
-----------------------------------------
Creator: CryDeS
If somebody read this, KILL ME PLEASE
-----------------------------------------
]]

require('timers')
require('spawners')
require('tp_s')
require('change_hero')
require('items/shop')
require('lib/teleport')
require('lib/duel_lib')
require('chat_listener')
require('teleports/teleport')
require('spell_shop_UI')
require('util')

local Constants 			= require('consts') 					-- XP TABLE
local armor_table 			= require('creeps/armor_table_summon') 	-- armor to units
local items_cost 			= require('lib/test') 

MAX_LEVEL 					= 100

RESPAWN_MODIFER 			= 0.1

DUEL_WINNER_GOLD_MULTIPLER 	= 200
DUEL_WINNER_EXP_MULTIPLER	= 200
DUEL_GOLD_PER_MINUTE 		= 80
DUEL_INTERVAL 				= 300
DUEL_NOBODY_WINS 			= 90
duel_start_flag 			= false

nPlayers 					= 0

_G.killLimit 				= 20 
_G.CREEPS_LIMIT 			= 700

_G.nCOUNTDOWNTIMER 			= DUEL_INTERVAL

_G.tPlayers 				= {}
_G.tHeroesRadiant 			= {}
_G.tHeroesDire 				= {}
_G.Kills 					= {}

_G.gold_per_tick			= 0

local KillLimit_Vote = {
	["50"] 	= 0,
	["100"] = 0,
	["150"] = 0,
	["200"] = 0,
}

local meepo_boots = {
	"item_snake_boots",	
	"item_dead_boots",
	"item_angels_greaves",
}

local forbidden_ability_boss = {
	["life_stealer_infest"] 		= 1,
	["death_prophet_spirit_siphon"] = 1,
	["chen_holy_persuasion"] 		= 1,
	["zuus_arc_lightning"] 			= 1,
	["huskar_life_break"]			= 1,
	
}


if AngelArena == nil then
	_G.AngelArena = class({})
	AngelArena.DeltaTime = 0.5
end

function Activate()
	GameRules.AngelArena = AngelArena()
	GameRules.AngelArena:InitGameMode()
end

function Precache( context )
	--PrecacheResource("soundfile", "soundevents/game_sounds_custom.vsndevts", context)
	PrecacheUnitByNameAsync("Croco_level_1", 		function() end)
	PrecacheUnitByNameAsync("Croco_level_40", 		function() end)
	PrecacheUnitByNameAsync("Croco_level_60", 		function() end)
	PrecacheUnitByNameAsync("Croco_level_80", 		function() end)
	PrecacheUnitByNameAsync("Croco_level_100", 		function() end)
	PrecacheUnitByNameAsync("Centaur_level_40", 	function() end)
	PrecacheUnitByNameAsync("Centaur_level_60", 	function() end)
	PrecacheUnitByNameAsync("Centaur_level_80", 	function() end)
	PrecacheUnitByNameAsync("Centaur_level_100", 	function() end)
	PrecacheUnitByNameAsync("Salamander_level_40", 	function() end)
	PrecacheUnitByNameAsync("Salamander_level_60", 	function() end)
	PrecacheUnitByNameAsync("Salamander_level_80", 	function() end)
	PrecacheUnitByNameAsync("Salamander_level_100", function() end)
	PrecacheUnitByNameAsync("Dragon_level_40", 		function() end)
	PrecacheUnitByNameAsync("Dragon_level_60", 		function() end)
	PrecacheUnitByNameAsync("Dragon_level_80", 		function() end)
	PrecacheUnitByNameAsync("Dragon_level_100", 	function() end)
	PrecacheUnitByNameAsync("Golem_level_40", 		function() end)
	PrecacheUnitByNameAsync("Golem_level_60", 		function() end)
	PrecacheUnitByNameAsync("Golem_level_80", 		function() end)
	PrecacheUnitByNameAsync("Golem_level_100", 		function() end)
	PrecacheUnitByNameAsync("Wildwing_level_40", 	function() end)
	PrecacheUnitByNameAsync("Wildwing_level_60", 	function() end)
	PrecacheUnitByNameAsync("Wildwing_level_80", 	function() end)
	PrecacheUnitByNameAsync("Wildwing_level_100", 	function() end)
	PrecacheUnitByNameAsync("Troll_level_40", 		function() end)
	PrecacheUnitByNameAsync("Troll_level_60", 		function() end)
	PrecacheUnitByNameAsync("Troll_level_80", 		function() end)
	PrecacheUnitByNameAsync("Troll_level_100", 		function() end)
	PrecacheUnitByNameAsync("Ursa_level_40", 		function() end)
	PrecacheUnitByNameAsync("Ursa_level_60", 		function() end)
	PrecacheUnitByNameAsync("Ursa_level_80", 		function() end)
	PrecacheUnitByNameAsync("Ursa_level_100", 		function() end)
	PrecacheItemByNameAsync("item_eclipse_amphora", function() end) 
end

function AngelArena:InitGameMode()
	SpellShopUI:InitGameMode();
	GameRules:GetGameModeEntity():SetThink( "OnGameStateChange", self, "GlobalThink", 2 )
	print( "Fucked Angel Arena. Yeah bitches!" )
	local GameMode = GameRules:GetGameModeEntity()
    self.vUserIds = {}
    
    GameRules:SetCustomVictoryMessage("Victory. For the bless of gods")

	GameRules:SetSafeToLeave(true)
	GameRules:SetHeroSelectionTime(60)
	GameRules:SetPreGameTime(0)
    GameRules:SetPostGameTime(30)
	GameRules:SetHeroRespawnEnabled(true)
	GameRules:SetGoldTickTime(1)
	GameRules:SetTreeRegrowTime(180)
	GameRules:SetUseBaseGoldBountyOnHeroes(true)
    GameRules:SetCustomGameEndDelay(1)
	GameRules:GetGameModeEntity():SetFountainPercentageHealthRegen( 10 )
	GameRules:GetGameModeEntity():SetFountainPercentageManaRegen( 10 )
	GameRules:GetGameModeEntity():SetFountainConstantManaRegen( 20 )
	--GameMode:SetCustomHeroMaxLevel(MAX_LEVEL) 
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)  
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(Constants.XP_PER_LEVEL_TABLE)
    --GameMode:SetTopBarTeamValuesVisible(false)
    GameMode:SetBuybackEnabled(true)
    GameMode:SetStashPurchasingDisabled(false)
    GameMode:SetLoseGoldOnDeath(true)
    --GameMode:SetTopBarTeamValuesOverride ( true )
    --GameMode:SetTopBarTeamValuesVisible( true )
    GameRules:SetUseUniversalShopMode(true)
    GameRules:SetSameHeroSelectionEnabled(false)

    
    if GetMapName() == "map_10x10" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 10 )
	else
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
	end

	--################################## BASE LISTENERS ############################################### --
    ListenToGameEvent("dota_player_pick_hero", 			Dynamic_Wrap(AngelArena, "OnHeroPicked"), self)
    ListenToGameEvent("entity_killed", 					Dynamic_Wrap(AngelArena, "OnEntityKilled"), self)
    ListenToGameEvent('game_rules_state_change', 		Dynamic_Wrap(AngelArena, 'OnGameStateChange'), self)
    ListenToGameEvent('player_connect_full', 			Dynamic_Wrap(AngelArena, 'OnConnectFull'), self)
    --ListenToGameEvent('player_disconnect',				Dynamic_Wrap(AngelArena, 'OnPlayerDisconnect'), self)
    ListenToGameEvent('npc_spawned', 					Dynamic_Wrap(AngelArena, 'OnNPCSpawned'), self )
    ListenToGameEvent('dota_item_picked_up',			Dynamic_Wrap(AngelArena, 'OnPickUpItem'), self )
    ListenToGameEvent('dota_rune_activated_server',		Dynamic_Wrap(AngelArena, 'OnRuneActivate'), self )
    ListenToGameEvent('dota_player_used_ability',		Dynamic_Wrap(AngelArena, 'OnPlayerUsedAbility'), self)
    ListenToGameEvent('dota_item_purchased',			Dynamic_Wrap(AngelArena, 'OnPlayerBuyItem'), self)

    --################################## CUSTOM LISTENERS ############################################### --
   	CustomGameEventManager:RegisterListener("hc_menu_button_pressed", 	Dynamic_Wrap(AngelArena, 'OnPlayerPressButton_change_hero'))
    CustomGameEventManager:RegisterListener("hero_next_page", 			Dynamic_Wrap(AngelArena, 'OnPlayerRequestNextPage_change_hero'))
    CustomGameEventManager:RegisterListener("hero_last_page", 			Dynamic_Wrap(AngelArena, 'OnPlayerRequestLastPage_change_hero'))
    CustomGameEventManager:RegisterListener("tp_menu_button_pressed", 	Dynamic_Wrap(AngelArena, 'OnPlayerPressButton_teleport'))
    CustomGameEventManager:RegisterListener("custom_shop_buy_item", 	Dynamic_Wrap(AngelArena, 'OnPlayerBuyItemCustom'))
    CustomGameEventManager:RegisterListener("PlayerVoteKills", 			Dynamic_Wrap(AngelArena, 'OnVoteForKillLimit'))

    --################################## BASE MODIFIERS ############################################### --
    LinkLuaModifier( "modifier_stun",				'modifiers/modifier_stun', 				LUA_MODIFIER_MOTION_NONE )
    LinkLuaModifier( "modifier_stop",				'modifiers/modifier_stop', 				LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_medical_tractate",	'modifiers/modifier_medical_tractate', 	LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_boss_power",			'modifiers/modifier_boss_power', 		LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_yarik",				'modifiers/modifier_yarik', 			LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_reflect",			'modifiers/modifier_reflect', 			LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_grin",				'modifiers/modifier_grin', 				LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_crydes",				'modifiers/modifier_crydes', 			LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_godmode",			'modifiers/modifier_godmode', 			LUA_MODIFIER_MOTION_NONE )

	--################################## RUNES MODIFIERS ############################################### --
	LinkLuaModifier( "modifier_rune_dd_one",	 	'modifiers/modifier_rune_dd_one',  		LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_rune_dd_two", 		'modifiers/modifier_rune_dd_two',  		LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_rune_dd_three", 		'modifiers/modifier_rune_dd_three',  	LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_rune_haster_max", 	'modifiers/modifier_rune_haster_max',  	LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_rune_illusion_one", 	'modifiers/modifier_rune_illusion_one', LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_rune_illusion_two", 	'modifiers/modifier_rune_illusion_two', LUA_MODIFIER_MOTION_NONE )

	--################################## SUMMON MODIFIERS ############################################### --
	LinkLuaModifier( "modifier_brewmaster_spirits_lua",'modifiers/heroes/modifier_brewmaster_spirits_lua', LUA_MODIFIER_MOTION_NONE )

	--################################## ITEMS MODIFIERS ############################################### --
	LinkLuaModifier( "modifier_octarine_ultimate_cooldown_lua", 'modifiers/items/modifier_octarine_ultimate_cooldown_lua',  LUA_MODIFIER_MOTION_NONE )

	--################################### END MODIFIERS ################################################ --
	Convars:RegisterCommand( "radiant_list", function(...) return PrintPlayers( tHeroesRadiant ) end, "Function Call 2", 0 )
	Convars:RegisterCommand( "dire_list", function(...) return PrintPlayers( tHeroesDire ) end, "Function Call 3", 0 )

	--########################################## FILTERS ############################################### --
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(AngelArena, "OrderFilter"), self)
	GameRules:GetGameModeEntity():SetModifyGoldFilter  (Dynamic_Wrap(AngelArena, "GoldFilter"), self)

	_G.Kills[DOTA_TEAM_GOODGUYS] 	= _G.Kills[DOTA_TEAM_GOODGUYS] 	or 0
	_G.Kills[DOTA_TEAM_BADGUYS]		= _G.Kills[DOTA_TEAM_BADGUYS]	or 0
	_G.KillLimit 					= _G.KillLimit 					or 0

	--########################################## START FUNCS ########################################### --
	StartAntiCampSystem()

	--[[
	--typical parsion of idiotto master :3
	local tst = LoadKeyValues('scripts/npc/items.txt')
	for i,x in pairs(tst) do 
		if i and x and type(x) == "table" then

			if x['ItemCost'] then
				print('["' .. i .. '"] = '..  x['ItemCost'] .. "," ) 
			else
				print('["' .. i .. '"] = '..  0 .. "," ) 
			end
		end
	end
	]]
end

function AngelArena:GoldFilter(event)
	local reason_const 	= event.reason_const
	local reliable 		= event.reliable
	local player_id 	= event.player_id_const
	local gold 			= event.gold
	local hero
	for _,x in pairs(tHeroesRadiant) do
		if x:GetPlayerOwnerID() == player_id then hero = x end
	end
	
	for _,x in pairs(tHeroesDire) do
		if x:GetPlayerOwnerID() == player_id then hero = x end
	end

	if not hero then 
		print("NO HERO FOR GOLD FILTER");
		return
	end

	_G.tPlayers[player_id] = _G.tPlayers[player_id] or {} -- nil error exception
	_G.tPlayers[player_id].filter_gold = _G.tPlayers[player_id].filter_gold or 0
	_G.tPlayers[player_id].filter_gold = _G.tPlayers[player_id].filter_gold + gold
	
	hero.gold = hero.gold or 0
	hero.gold = hero.gold + gold

	return true
end

function AngelArena:OrderFilter(event)
	local orged_type = event.order_type
    if orged_type == DOTA_UNIT_ORDER_CAST_TARGET then
    	local caster
    	for i,x in pairs(event.units) do 
    		if x then
    			caster = EntIndexToHScript(x)
    		end
    	end
    	
    	local ability = EntIndexToHScript( event.entindex_ability)
    	local target = EntIndexToHScript( event.entindex_target)

    	if forbidden_ability_boss[ability:GetName()] and IsUnitBossGlobal(target) then
    		ForceStopUnit(caster)  		
    	end
    end

    return true
end

function ForceStopUnit(unit)
	if not unit then return end
	unit:AddNewModifier(unit, nil, "modifier_stop", {duration = 0.01})
end

function AngelArena:OnPlayerBuyItem(event)
	local playerid = event.PlayerID 
	local item_name = event.itemname
	local itemcost = event.itemcost
	local player = PlayerResource:GetPlayer(playerid)
	local hero = player:GetAssignedHero()

	local item = CreateItem(item_name, hero, hero)

	if AC:GetItemCost(item_name) ~= itemcost then
		hero:SetGold(0, true)
		hero:SetGold(0, false)

		if tPlayers[playerid] and tPlayers[playerid].gold  then
			tPlayers[playerid].gold = 0
		end
		UTIL_Remove(item)
		local temp_item
		for i = 0, 11 do
			temp_item = hero:GetItemInSlot(i)
			if temp_item and temp_item:GetName() == item_name then
				UTIL_Remove(temp_item)
			end
		end
		if hero:GetUnitName() == "npc_dota_hero_lone_druid" then
			local bears = Entities:FindAllByName("npc_dota_lone_druid_bear") 
			if bears then
				for i,x in pairs(bears) do
					for i = 0, 5 do
						temp_item = x:GetItemInSlot(i)
						if temp_item and temp_item:GetName() == item_name then
							UTIL_Remove(temp_item)
						end
					end
				end
			end
		end
	else
		UTIL_Remove(item)
	end
	
end

function AngelArena:OnPlayerUsedAbility(event)
	local player = PlayerResource:GetPlayer( event.PlayerID )
	local ability_name = event.abilityname
	if not player or not ability_name or not IsValidEntity(player) then return	end
	local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)

	if not hero then return end


end

function AngelArena:OnVoteForKillLimit(keys)
	local select_limit = keys.SelectedValue;
	if not select_limit then return end
	KillLimit_Vote[select_limit] = KillLimit_Vote[select_limit] or 0
	KillLimit_Vote[select_limit] = KillLimit_Vote[select_limit] + 1
end

function PrintPlayers(tbl)
	for i,x in pairs(tbl) do
		if x then
			print("i=" .. i .. " player=" .. x:GetUnitName())
		else
			print("i=" .. i .. " player=" .. x)
		end
	end
end

function StartAntiCampSystem()
	local skills_to_add = {
 			ursa_fury_swipes = 4;
            templar_assassin_psi_blades = 1;
            angel_arena_fountain = 1;
        }

    local fountains = Entities:FindAllByClassname('ent_dota_fountain')
	    for k,fountain in pairs(fountains) do
            for skillName,skillLevel in pairs(skills_to_add) do
                fountain:AddAbility(skillName)
                local ab = fountain:FindAbilityByName(skillName)
                if ab then
                    ab:SetLevel(skillLevel)
                end
            end

            local item = CreateItem('item_monkey_king_bar', fountain, fountain)
            if item then
                fountain:AddItem(item)
            end
        end
end

function AngelArena:OnRuneActivate(event)
	local runeid = event.rune
	local playerid = event.PlayerID
	local hero = PlayerResource:GetPlayer(playerid):GetAssignedHero() 
	if not hero then return end
	if runeid == DOTA_RUNE_DOUBLEDAMAGE then
		if hero:HasItemInInventory("item_kings_bar") or hero:HasItemInInventory("item_rapier") then -- +60% damage
			hero:AddNewModifier(hero, nil, "modifier_rune_dd_one", {duration = 30})
		end

		if RollPercentage(10) then -- +400% damage
			hero:AddNewModifier(hero, nil, "modifier_rune_dd_two",  {duration = 30} )
		end

		if RollPercentage(10) then -- +20% damage resist
			hero:AddNewModifier(hero, nil, "modifier_rune_dd_three",  {duration = 30} )
		end
	end

	if runeid == DOTA_RUNE_BOUNTY then
		local multiplier = 1

		local constant_gold_for_minute = 50
		local constant_gold_double_midas = 1200 + constant_gold_for_minute*GameRules:GetGameTime()/60
		local constant_gold_one_midas = 600 + constant_gold_for_minute*GameRules:GetGameTime()/120


		if hero:GetUnitName() == "npc_dota_hero_alchemist" then multiplier = 2 end
		if hero:HasItemInInventory("item_advanced_midas") then
			hero:ModifyGold(constant_gold_double_midas*multiplier, false, 0) 
			if RollPercentage(20) then
				hero:ModifyGold(constant_gold_double_midas*multiplier, false, 0) 
			end
		end
		if hero:HasItemInInventory("item_hand_of_midas") then
			hero:ModifyGold(constant_gold_one_midas*multiplier, false, 0) 
		end

		if RollPercentage(20) then
			local level = hero:GetLevel()
			local need_exp = Constants.XP_PER_LEVEL_TABLE[level+1]
			local old_exp = Constants.XP_PER_LEVEL_TABLE[level]
			if not need_exp then need_exp = 0 end
			if not old_exp then old_exp = 0 end
			hero:HeroLevelUp(true)
			hero:AddExperience(need_exp - old_exp,  true, true)
		end
	end

	if runeid == DOTA_RUNE_ILLUSION then
		hero:AddNewModifier(hero, nil, "modifier_rune_illusion_one", { duration = 30 }) -- 30%dmg, +20mvspd
		if RollPercentage(40) then
			hero:AddNewModifier(hero, nil, "modifier_rune_illusion_two", { duration = 30 }) --+15dmg resist
		end
	end

	if runeid == DOTA_RUNE_HASTE then
		if RollPercentage(20) then
			hero:AddNewModifier(hero, nil, "modifier_rune_haster_max", {duration = 40}) --glimmers cape modifier
		end
	end

	if runeid == DOTA_RUNE_INVISIBILITY then
		if RollPercentage(20) then
			hero:AddNewModifier(hero, nil, "modifier_rune_haste", {duration = 40}) --glimmers cape modifier
		end
	end

	local item
	for i = 0, 5 do
		item = hero:GetItemInSlot(i)
		if item and (item:GetName() == "item_power_amulet" or item:GetName() == "item_mystic_amulet" or item:GetName() == "item_strange_amulet" )then
			if item:GetCurrentCharges() < 8 then
				item:SetCurrentCharges(item:GetCurrentCharges() + 2)
			else
				item:SetCurrentCharges(item:GetCurrentCharges() + 1)
			end
			--item:Set
			return
		end
	end
end

function AngelArena:OnPickUpItem(event)
	if not event.ItemEntityIndex then return end
	local unit
	if event.HeroEntityIndex then unit = EntIndexToHScript(event.HeroEntityIndex) end
	if event.UnitEntityIndex then unit = EntIndexToHScript(event.UnitEntityIndex) end
	local item = EntIndexToHScript(event.ItemEntityIndex)
	
	if not unit or not item then return end

	if unit:IsCourier() then
		print("ITS A COUR!")
		if item:GetOwnerEntity() == unit and item:GetPurchaser() == unit then
			UTIL_Remove(item)
		end
	end

	if unit then
		if IsUnitBear(unit) then
			if item:GetPurchaser() == unit then
				local hero_owner = unit:GetOwnerEntity() 
				item:SetPurchaser(hero_owner)
			end
		end
	end

end

function AngelArena:OnNPCSpawned(event)
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit then return end
	
	if spawnedUnit:IsRealHero() then
		OnHeroRespawn(spawnedUnit)
	end

	local unitname = spawnedUnit:GetUnitName()

	local unit_owner = spawnedUnit:GetOwnerEntity() 

	if unit_owner and not unitname == "npc_dota_courier" then
		local owner_team = unit_owner:GetTeamNumber() 

		if owner_team then spawnedUnit:SetTeam(owner_team) end
	end

	if unitname == "npc_dota_invoker_forged_spirit" then
		spawnedUnit:SetHealth(9999999) -- full heal
	end

	if IsUnitBear(spawnedUnit) then
		local hero_owner = Entities:FindByName(nil, "npc_dota_hero_lone_druid")

		spawnedUnit:SetTeam(hero_owner:GetTeamNumber())

		local ability

		for i = 0, spawnedUnit:GetAbilityCount() - 1 do
			ability = spawnedUnit:GetAbilityByIndex(i)
			if ability and ability:GetName() == "separation_of_souls_bear" then
				ability:SetLevel(1)
			end
		end

	end

	if (armor_table[unitname]) then -- see file creeps/armor_table_summon.lua for details
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_brewmaster_spirits_lua", {})
	end

	if (unitname == "npc_dota_techies_land_mine" or unitname == "npc_dota_techies_remote_mine" or unitname == "npc_dota_techies_stasis_trap" or unitname == "npc_dota_thinker") and not DuelLibrary:IsDuelActive() then
		local pos = spawnedUnit:GetAbsOrigin() 
		local duel_pos1 = Entities:FindByName(nil, "RADIANT_DUEL_TELEPORT"):GetAbsOrigin();
		local duel_pos2 = Entities:FindByName(nil, "DIRE_DUEL_TELEPORT"):GetAbsOrigin();

		if math.abs((pos - duel_pos1):Length2D()) < 700 or (math.abs((pos - duel_pos2):Length2D() )  < 700 ) then
			UTIL_Remove(spawnedUnit)

		end
	end

	if spawnedUnit:IsIllusion() and spawnedUnit:IsHero() then -- is that hero or hero illusion? & is illusion
		local originals = Entities:FindAllByName(unitname )
		local done = false
		for i,original_hero in pairs(originals) do

			if original_hero~=spawnedUnit and not original_hero:IsIllusion() then
				local ability
				for i = 0, spawnedUnit:GetAbilityCount() - 1 do
					ability = spawnedUnit:GetAbilityByIndex(i)
					if ability then spawnedUnit:RemoveAbility(ability:GetAbilityName()) end
				end

				for i = 0, original_hero:GetAbilityCount() - 1 do
					ability = original_hero:GetAbilityByIndex(i)
					if ability then spawnedUnit:AddAbility(ability:GetAbilityName()) end
				end

				local str = original_hero:GetBaseStrength() - (original_hero:GetLevel() - 1)*original_hero:GetStrengthGain() 
				local agi = original_hero:GetBaseAgility()  - (original_hero:GetLevel() - 1)*original_hero:GetAgilityGain()
				local int = original_hero:GetBaseIntellect()  - (original_hero:GetLevel() - 1)*original_hero:GetIntellectGain()
				spawnedUnit:SetBaseStrength(str)
				spawnedUnit:SetBaseIntellect(int)
				spawnedUnit:SetBaseAgility(agi)

				if original_hero.medical_tractates then
					spawnedUnit.medical_tractates = original_hero.medical_tractates
					spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_medical_tractate", null)
				end

				break
			end

		end
	end

	if spawnedUnit:IsRealHero() then --print(spawnedUnit:GetUnitName())
	Timers:CreateTimer(0.15, function()
		if not spawnedUnit or not IsValidEntity(spawnedUnit) or not spawnedUnit:IsRealHero() then return nil end
    	if spawnedUnit:GetUnitName() == "npc_dota_hero_arc_warden" then 
			if spawnedUnit:HasModifier("modifier_arc_warden_tempest_double") then

				if not spawnedUnit:HasModifier("modifier_kill") then
						UTIL_Remove(spawnedUnit)
				else

					local real_hero = spawnedUnit:GetPlayerOwner():GetAssignedHero()
					
					if not spawnedUnit:HasModifier("modifier_kill") then
						UTIL_Remove(spawnedUnit)

					end

					if real_hero then
						local att = real_hero:GetBaseStrength() 
						spawnedUnit:SetBaseStrength(att)
						att = real_hero:GetBaseAgility() 
						spawnedUnit:SetBaseAgility(att)
						att = real_hero:GetBaseIntellect() 
						spawnedUnit:SetBaseIntellect(att)

						local owner_team = real_hero:GetTeamNumber() 

						if owner_team then spawnedUnit:SetTeam(owner_team) end

						for i = 0, 5 do
							if spawnedUnit:GetItemInSlot(i) then
								spawnedUnit:GetItemInSlot(i):Enpooldown() 
							end

							if spawnedUnit:GetItemInSlot(i) and (spawnedUnit:GetItemInSlot(i):GetName() == "item_pet_hulk" or spawnedUnit:GetItemInSlot(i):GetName() == "item_pet_mage" or spawnedUnit:GetItemInSlot(i):GetName() == "item_pet_wolf") then
								spawnedUnit:RemoveItem(spawnedUnit:GetItemInSlot(i))
							end
						end

						if real_hero.medical_tractates then
							spawnedUnit.medical_tractates = real_hero.medical_tractates
							spawnedUnit:RemoveModifierByName("modifier_medical_tractate")
							spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_medical_tractate", null)
						end
					end
				end
			end
		end
      return nil
    end
  	)
	end

	if spawnedUnit then
		if spawnedUnit.medical_tractates then
			spawnedUnit:RemoveModifierByName("modifier_medical_tractate")
			spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_medical_tractate", null)
		end
	end
end

function OnHeroRespawn(spawned_hero)
	local hero = spawned_hero
	local steam_id = PlayerResource:GetSteamAccountID(hero:GetPlayerOwnerID())
	
	if not steam_id then return end

end

function AngelArena:OnConnectFull(event)
    local entIndex = event.index+1
    local player = EntIndexToHScript(entIndex)
    local playerID =player:GetPlayerID()
   	local hero = player:GetAssignedHero()
   	if not player or not playerID then return end

   	self.vUserIds[event.userid] = player
    nPlayers = nPlayers + 1  

    if not hero then return end
    UpdateKillLimit()
    CustomGameEventManager:Send_ServerToAllClients("TopBarUpdate", { radiant = _G.Kills[DOTA_TEAM_GOODGUYS] .. "/" .. _G.KillLimit, dire = _G.Kills[DOTA_TEAM_BADGUYS]  .. "/" .. _G.KillLimit})
    GameRules:SetGoldPerTick(1+nPlayers/2)
    _G.gold_per_tick = 1+nPlayers/2
end


function GetPlayersCount()
	local i = 0
	local j = 0
	for _, x in pairs(tHeroesRadiant) do
		if not IsAbadoned(x) then
			i = i + 1
		end
	end

	for _, x in pairs(tHeroesDire) do
		if not IsAbadoned(x) then
			j = j + 1
		end
	end
	return i, j
end

function ShareGold()
	local gold = 0
	local gold_to_player = 0
	local radiant_players, dire_players = GetPlayersCount()
	if radiant_players == 0 and dire_players == 0 then
		return
	end

	gold = 0
	gold_to_player = 0

	for _, x in pairs(tHeroesRadiant) do
		if IsAbadoned(x) then
			gold = gold + x:GetGold()
			PlayerResource:SetGold(x:GetPlayerID(), 0, false)
			PlayerResource:SetGold(x:GetPlayerID(), 0, true)
		end
	end

	gold_to_player = gold / radiant_players
	for _, x in pairs(tHeroesRadiant) do
		if IsConnected(x) then
			PlayerResource:ModifyGold( x:GetPlayerID(), gold_to_player, true, 0 )
		end
	end

	gold = 0
	gold_to_player = 0

	for _, x in pairs(tHeroesDire) do
		if IsAbadoned(x) then
			gold = gold + x:GetGold()
			PlayerResource:SetGold(x:GetPlayerID(), 0, false)
			PlayerResource:SetGold(x:GetPlayerID(), 0, true)
		end
	end

	gold_to_player = gold / dire_players
	--print_d("gold to player dire = " .. gold_to_player)
	for _, x in pairs(tHeroesDire) do
		if IsConnected(x) then
			PlayerResource:ModifyGold( x:GetPlayerID(), gold_to_player, true, 0 )
		end
	end
end

function GiveGoldToTeam(team_table, gold, exp)
	for _, x in pairs(team_table) do
		if x then
			PlayerResource:ModifyGold( x:GetPlayerID(), gold, true, 0)
			x:AddExperience(1000,  true, true)
		end
	end
end

function UpdatePlayersCount()
	local pc = 0

	for i, x in pairs(tHeroesRadiant) do
		pc = pc + 1
	end
	for i, x in pairs(tHeroesDire) do
		pc = pc + 1
	end
	nPlayers = pc

end

function AngelArena:OnGameStateChange()  

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    	UpdateKillLimit()
    	GameRules:SetGoldPerTick(1+nPlayers/2)
    	_G.gold_per_tick = 1 + nPlayers/2

    	if not duel_start_flag then
    		Timers:CreateTimer(1, function() -- таймер для отображения на экране дуэли
      							PopUpTimert()
      							CheckHeroesPosition()
				      			return 1.0
  								end )

    		Timers:CreateTimer(1, function() -- таймер для спавна нейтралов
      							SpawnNeutrals()
      							Balance()
				      			return 60.0
  								end )

    		Timers:CreateTimer(10, function() -- таймер для шаринга голды
      							ShareGold()
      							UpdatePlayersCount()
				      			return 10
  								end )
			Timers:CreateTimer(0.5, function () 
					SaveGold()

					return 0.5
				end)
   			Timers:CreateTimer(DUEL_INTERVAL-1, function()
                	--StartDuel()
                	local max_alives = DuelLibrary:GetMaximumAliveHeroes(tHeroesRadiant, tHeroesDire)
                	if max_alives < 1 then 
                		max_alives = 1 
                	end

                	local c = RandomInt(1, max_alives)
                	nCOUNTDOWNTIMER = DUEL_NOBODY_WINS-1
                	DuelLibrary:StartDuel(tHeroesRadiant, tHeroesDire, c, DUEL_NOBODY_WINS-1, function(err_arg) DeepPrintTable(err_arg) end, function(winner_side)
                		OnDuelEnd(winner_side)
               		end)
                    return nil
                end)
   			duel_start_flag = true;       
   		end
    end
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function OnDuelEnd( winner_side)
	nCOUNTDOWNTIMER = DUEL_INTERVAL-1
	
	if nCOUNTDOWNTIMER < -10 then
		nCOUNTDOWNTIMER = DUEL_INTERVAL
	end

    local duel_count = DuelLibrary:GetDuelCount() 
    if duel_count == 5 then 
		DUEL_INTERVAL = DUEL_INTERVAL - 60
	elseif duel_count == 10 then
		DUEL_INTERVAL = DUEL_INTERVAL - 60
	end
	if winner_side == DOTA_TEAM_GOODGUYS then
		GiveGoldToTeam(tHeroesRadiant, DUEL_WINNER_GOLD_MULTIPLER*duel_count + DUEL_GOLD_PER_MINUTE*GameRules:GetGameTime()/60, DUEL_WINNER_EXP_MULTIPLER*GameRules:GetGameTime()/60)
		GameRules:SendCustomMessage("#duel_end_win_radiant", 0, 0) 
	elseif winner_side == DOTA_TEAM_BADGUYS then
		GiveGoldToTeam(tHeroesDire, DUEL_WINNER_GOLD_MULTIPLER*duel_count + DUEL_GOLD_PER_MINUTE*GameRules:GetGameTime()/60, DUEL_WINNER_EXP_MULTIPLER*GameRules:GetGameTime()/60)
		GameRules:SendCustomMessage("#duel_end_win_demons", 0, 0) 
	end

	Timers:CreateTimer(DUEL_INTERVAL-1, function ()
		nCOUNTDOWNTIMER = DUEL_NOBODY_WINS-1
		local max_alives = DuelLibrary:GetMaximumAliveHeroes(tHeroesRadiant, tHeroesDire)
      	if max_alives < 1 then max_alives = 1 end
      	local c = RandomInt(1, max_alives)
        DuelLibrary:StartDuel(tHeroesRadiant, tHeroesDire, c, DUEL_NOBODY_WINS-1, function(err_arg) DeepPrintTable(err_arg) end, function(win_side)
         	OnDuelEnd(win_side)
        end)
        return nil
	end)
	print("End of OnDuelEnd")
end

function CheckHeroesPosition()
	for _, x in pairs(tHeroesRadiant) do
		if x then
			CheckUnitPosition(x)
			--[[local playerid = x:GetPlayerOwnerID() 
			if PlayerResource:GetConnectionState(playerid)==DOTA_CONNECTION_STATE_ABANDONED then
				DisconnectPlayer(playerid, x)
			end]]
		end
	end
	for _, x in pairs(tHeroesDire) do
		if x then
			CheckUnitPosition(x)
			--[[local playerid = x:GetPlayerOwnerID() 
			if PlayerResource:GetConnectionState(playerid)==DOTA_CONNECTION_STATE_ABANDONED then
				DisconnectPlayer(playerid, x)
			end]]
		end
	end
end

function GetMaxLevelInTeam(team)
	local max_level = 0
	local player_count = 0;

	if team == DOTA_TEAM_GOODGUYS then
		for _, x in pairs(tHeroesRadiant) do
			if x and not IsAbadoned(x) then
				max_level = max_level + x:GetLevel()
				player_count = player_count + 1
			end
		end
	elseif team == DOTA_TEAM_BADGUYS then
		for _, x in pairs(tHeroesDire) do
			if x and not IsAbadoned(x) then
				max_level = max_level + x:GetLevel()
				player_count = player_count + 1
			end
		end
	end
	return max_level/player_count
end

function Balance()
	local max_lvl_radiant = GetMaxLevelInTeam(DOTA_TEAM_GOODGUYS)
	local max_lvl_dire = GetMaxLevelInTeam(DOTA_TEAM_BADGUYS)
	local lose_team
	
	if max_lvl_dire > max_lvl_radiant then
		lose_team = DOTA_TEAM_GOODGUYS
	elseif max_lvl_radiant > max_lvl_dire then
		lose_team = DOTA_TEAM_BADGUYS
	end

	if math.abs(max_lvl_radiant - max_lvl_dire) >= 5 then
		BalanceDrop(math.abs(max_lvl_radiant - max_lvl_dire), lose_team)
	end
end

function AngelArena:OnEntityKilled(event)
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killedTeam = killedUnit:GetTeam()
	local hero = EntIndexToHScript( event.entindex_attacker )
	local heroTeam = hero:GetTeam()

	_G.Kills[heroTeam]  			= _G.Kills[heroTeam] 			or 0
	_G.Kills[DOTA_TEAM_BADGUYS] 	= _G.Kills[DOTA_TEAM_BADGUYS] 	or 0
	_G.Kills[DOTA_TEAM_GOODGUYS]	= _G.Kills[DOTA_TEAM_GOODGUYS]	or 0

	if not killedUnit or not IsValidEntity(killedUnit) then return end

	DropItem(killedUnit)

	if IsUnitCreep(killedUnit:GetUnitName()) then
		OnCreepDeathGlobal(killedUnit)
	end

	if IsUnitBossGlobal(killedUnit) then
		OnBossDeathGlobal(killedUnit)
	end

	if IsValidEntity(killedUnit) and not killedUnit:IsAlive() and killedUnit:IsRealHero() then
		local timeLeft = killedUnit:GetRespawnTime()

		if killedUnit:IsReincarnating() == false then
			if killedUnit:GetUnitName() == "npc_dota_hero_meepo" then
				local meepo_table = Entities:FindAllByName("npc_dota_hero_meepo")
				if meepo_table then
					for i = 1, #meepo_table do
						meepo_table[i]:SetTimeUntilRespawn(timeLeft*RESPAWN_MODIFER)
					end
				end
			else
				killedUnit:SetTimeUntilRespawn(timeLeft*RESPAWN_MODIFER)
			end
		end
    end

    if killedUnit:IsRealHero() and not killedUnit:IsReincarnating() and heroTeam and heroTeam ~= killedTeam and _G.Kills[heroTeam] then
       	_G.Kills[heroTeam] = _G.Kills[heroTeam]  + 1
    end

	if _G.Kills[DOTA_TEAM_GOODGUYS] >= _G.killLimit then
    	GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
   	end

	if _G.Kills[DOTA_TEAM_BADGUYS] >= _G.killLimit then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
	end

	if killedUnit:IsRealHero() and not killedUnit:IsReincarnating() then 
		OnHeroDeath(killedUnit, hero) 
	end
end

function OnHeroDeath(dead_hero, killer)
	if dead_hero and killer and killer:IsRealHero() and dead_hero ~= killer then 
		local dead_hero_cost = GetTotalPr(dead_hero:GetPlayerOwnerID() )
		local killer_cost = GetTotalPr(killer:GetPlayerOwnerID())
		local total_gold_get = 0
		print("killer is real hero!")
		print("kille cost = ", killer_cost)
		print("dead cost = ", dead_hero_cost)
		if dead_hero_cost > killer_cost then
			total_gold_get = dead_hero_cost - killer_cost
			print("gold per kill:",total_gold_get)
			if total_gold_get > 20000 then
				total_gold_get = 20000 + RandomInt(1, 50)
			end

			GameRules:SendCustomMessage( "#ANGEL_ARENA_ON_KILL", killer:GetPlayerID(), total_gold_get) 
			PlayerResource:ModifyGold( killer:GetPlayerOwnerID(), total_gold_get, false, 0)
		end
	end

	if dead_hero.item_gem then
		while dead_hero:HasModifier("modifier_item_gem_of_true_sight") do
			dead_hero:RemoveModifierByName("modifier_item_gem_of_true_sight")
		end
		dead_hero.item_gem:RemoveSelf()
		dead_hero.item_gem = nil
	end

	local item
	for i = 0, 5 do
		item = dead_hero:GetItemInSlot(i)
		if item and (item:GetName() == "item_power_amulet" or item:GetName() == "item_mystic_amulet" or item:GetName() == "item_strange_amulet" )then
			if item:GetCurrentCharges() > 8 then
				item:SetCurrentCharges(item:GetCurrentCharges() - (item:GetCurrentCharges() / 2) )
			else
				item:SetCurrentCharges(item:GetCurrentCharges() - (item:GetCurrentCharges() / 4) )
			end
		end
	end
end

function AngelArena:OnHeroPicked (event)
   	local hero = EntIndexToHScript(event.heroindex)
	if hero then  
   		if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then 
	   		table.insert(tHeroesRadiant, hero)
	   		tHeroesRadiant[#tHeroesRadiant].medical_tractates = 0;
	   	end

	    if hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then 
	   		table.insert(tHeroesDire, hero)
	   		tHeroesDire[#tHeroesDire].medical_tractates = 0;
	   	end
	end

	for i=0,23 do
    	if PlayerResource:IsValidPlayer(i) then
    		local color = Constants.CustomPlayerColors[i+1]
    		if not color then
    			color = {}
    			color[1] = 255
    			color[2] = 255
    			color[3] = 255
    		end
        	PlayerResource:SetCustomPlayerColor(i, color[1], color[2], color[3])
    	end
    end

	print("Hero picked, hero:" .. hero:GetUnitName())
	PrecacheUnitByNameAsync(hero:GetUnitName(), function() end) 
		Timers:CreateTimer(8+RandomFloat(2.0, 6.0) , function() 

			for i,x in pairs(tHeroesRadiant) do
				if x and IsValidEntity(x) and x:GetUnitName() == hero:GetUnitName() and x ~= hero and not IsAbadoned(x) then
					ChangeHeroToRandomHero(hero)
				end
			end
		
			for i,x in pairs(tHeroesDire) do
				if x and not x:IsNull() and IsValidEntity(x) and x:GetUnitName() == hero:GetUnitName() and x ~= hero and not IsAbadoned(x) then
					ChangeHeroToRandomHero(hero)
				end
			end

			return 8
		end)
end

function CustomAttension(text, time)
	local data = {
		string = text
	}
	CustomGameEventManager:Send_ServerToAllClients( "attension_text", data )
	
	Timers:CreateTimer(time, 
	function()
    	CustomGameEventManager:Send_ServerToAllClients( "attension_close", nil )
		return nil 
  	end )
end

function SendEventTimer(text, time)
	local t = time
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local timer_text = m10 .. m01 .. ":" .. s10 .. s01

    local text_color = "#FFFFFF"
    if time < 16 then
    	text_color = "#FF0000"
    end

    local data = 
    {
    	string = text,
    	time_string = timer_text,
    	color = text_color,
	}
    --CustomGameEventManager:Send_ServerToAllClients( "duel_text_update", data )
    CustomGameEventManager:Send_ServerToTeam( DOTA_TEAM_GOODGUYS, "duel_text_update", data )
    CustomGameEventManager:Send_ServerToTeam( DOTA_TEAM_BADGUYS, "duel_text_update", data )

end

function SetKillLimitPanorama()
	CustomGameEventManager:Send_ServerToAllClients( "SetKillLimit", { string = _G.killLimit} )
end

function PopUpTimert()
	local tduel_active = DuelLibrary:IsDuelActive()
	_G.nCOUNTDOWNTIMER = nCOUNTDOWNTIMER
	if nCOUNTDOWNTIMER == 0 then
		if tduel_active == true then 
			nCOUNTDOWNTIMER = DUEL_NOBODY_WINS
		end
		if tduel_active == false then 
			nCOUNTDOWNTIMER = DUEL_INTERVAL
		end
	end

	if nCOUNTDOWNTIMER == 11 then
		if tduel_active == false then
			CustomAttension("#duel_10_sec_to_begin", 5)
		end
		if tduel_active == true then
			CustomAttension("#duel_10_sec_to_end", 5)
		end
	end

	nCOUNTDOWNTIMER = nCOUNTDOWNTIMER - 1
    if tduel_active == true then 
		SendEventTimer( "#duel_nobody_wins", nCOUNTDOWNTIMER)
	else 
		SendEventTimer( "#duel_next_duel", nCOUNTDOWNTIMER)
	end
	--SetKillLimitPanorama()
end

function AngelArena:OnPlayerPressButton_change_hero(event)
	local playerid,button, list
	playerid = tonumber(event["playerID"])
	button = tonumber(event["playerBt"])
	list = tonumber(event["list_number"])

	if list == 1 then
		if button == 1 then
			ChangeHero(playerid, "npc_dota_hero_sven")

		elseif button == 2 then
			ChangeHero(playerid, "npc_dota_hero_alchemist")

		elseif button == 3 then
			ChangeHero(playerid, "npc_dota_hero_vengefulspirit")

		elseif button == 4 then
			ChangeHero(playerid, "npc_dota_hero_medusa")

		elseif button == 5 then
			ChangeHero(playerid, "npc_dota_hero_tiny")

		elseif button == 6 then
			ChangeHero(playerid, "npc_dota_hero_ember_spirit")

		elseif button == 7 then
			ChangeHero(playerid, "npc_dota_hero_doom_bringer")

		elseif button == 8 then
			ChangeHero(playerid, "npc_dota_hero_keeper_of_the_light")
		end
		
	elseif list == 2 then
		if button == 1 then
			ChangeHero(playerid, "npc_dota_hero_kunkka")
		elseif	button == 2 then
			ChangeHero(playerid, "npc_dota_hero_razor")
		end
	end
end


function AngelArena:OnPlayerRequestNextPage_change_hero(event)
    local playerid, page
    playerid = tonumber(event["playerID"])
    page = tonumber(event["page"])
    menu_next_page(PlayerResource:GetPlayer(playerid) , page)
end

function AngelArena:OnPlayerRequestLastPage_change_hero(event)
    local playerid, page
    playerid = tonumber(event["playerID"])
    page = tonumber(event["page"])
    menu_last_page(PlayerResource:GetPlayer(playerid) , page)
end


function TeleportUnitToTarget(unit, target, playerid)
	local target = Entities:FindByName( nil, target )
	TeleportUnitToEntity(unit, target, true, true)
end

function RemoveWearables(eHero)
    local wearables = {}
    local cur = eHero:FirstMoveChild()

    while cur ~= nil do
        cur = cur:NextMovePeer()
        if cur ~= nil then
   	end
        if cur ~= nil and cur:GetClassname() ~= "" and cur:GetClassname() == "dota_item_wearable" then
            table.insert(wearables, cur)
        end
    end
    for i = 1, #wearables do
        UTIL_Remove(wearables[i])
    end
end

function AngelArena:OnPlayerBuyItemCustom(keys)
	local playerid = tonumber(keys["playerID"])
	local item_name = keys.item_name
	local item_cost = tonumber(keys["item_cost"])

	CustomShop:BuyItem(playerid, item_name, item_cost)
end

function UpdateKillLimit()
	local mxi = 0
	local count = 0
	for i, x in pairs(KillLimit_Vote) do
		if x~=0 then
			mxi = mxi + x*tonumber(i)
			count = count + x
		end
	end
	if count ~= 0 then
		mxi = math.ceil(mxi/count)
	end

	if mxi < 25 then mxi = 100 end

	_G.killLimit = mxi or 20

	print_d("killimit=" .. _G.killLimit)
end


function IsConnected(unit)
    return not IsDisconnected(unit)
end

function IsDisconnected(unit)
    if not unit or not IsValidEntity(unit) then
        return false
    end

    local playerid = unit:GetPlayerOwnerID()
    if not playerid then 
        return false
    end

    local connection_state = PlayerResource:GetConnectionState(playerid) 
    if connection_state == DOTA_CONNECTION_STATE_ABANDONED or connection_state == DOTA_CONNECTION_STATE_DISCONNECTED then
        return true
    else
        return false
    end
end

function IsAlreadyOccupedHero(hero_name)
	for _, x in pairs(tHeroesRadiant) do
		if x and x:GetUnitName() == hero_name and not IsAbadoned(x) then return true end
	end

	for _, x in pairs(tHeroesDire) do
		if x and x:GetUnitName() == hero_name and not IsAbadoned(x) then return true end
	end

	return false
end

function IsAbadoned(unit)
    if not unit or not IsValidEntity(unit) then
    	return false 
    end

    local playerid = unit:GetPlayerOwnerID()
    if not playerid then 
    	return false 
    end

    local connection_state = PlayerResource:GetConnectionState(playerid) 

    if connection_state == DOTA_CONNECTION_STATE_ABANDONED then 
        return true 
    else 
        return false
    end
end


function print_d(text)
	CustomGameEventManager:Send_ServerToAllClients("DebugMessage", { msg = text})
end


function ChangeHeroToRandomHero(hero)
	
	if DuelLibrary:IsDuelActive() then return end
	
	if not hero then return end

	local hero_table = {
		"npc_dota_hero_beastmaster",
		"npc_dota_hero_bloodseeker",
		"npc_dota_hero_bounty_hunter",
		"npc_dota_hero_brewmaster",
		"npc_dota_hero_broodmother",
		"npc_dota_hero_centaur",
		"npc_dota_hero_chaos_knight",
		"npc_dota_hero_chen",
		"npc_dota_hero_clinkz",
		"npc_dota_hero_rattletrap",
		"npc_dota_hero_crystal_maiden",
		"npc_dota_hero_dark_seer",
		"npc_dota_hero_dazzle",
		"npc_dota_hero_death_prophet",
		"npc_dota_hero_disruptor",
		"npc_dota_hero_dragon_knight",
		"npc_dota_hero_drow_ranger",
		"npc_dota_hero_earth_spirit",
		"npc_dota_hero_earthshaker",
		"npc_dota_hero_enigma",
		"npc_dota_hero_enchantress",
		"npc_dota_hero_elder_titan",
		"npc_dota_hero_faceless_void",
	}

	if not IsConnected(hero) then return end

	for i,x in pairs(hero_table) do
		if not IsAlreadyOccupedHero(x) then
			PrecacheUnitByNameAsync(x, function() 
				
				if not IsConnected(hero) then return end
				
				local playerid = hero:GetPlayerOwnerID()
				
				if not playerid then return end

				local gold = hero:GetGold() 
				local team = hero:GetTeamNumber() 

				for j,y in pairs(tHeroesRadiant) do
					if y:GetPlayerOwnerID() == playerid then
						table.remove(tHeroesRadiant, j)
					end
				end

				for j,y in pairs(tHeroesDire) do
					if y:GetPlayerOwnerID() == playerid then
						table.remove(tHeroesDire, j)
					end
				end

				local need_add_flag = false
				if hero:GetUnitName() == "npc_dota_hero_meepo" then
					need_add_flag = true
				end
				
				local meepos = Entities:FindAllByName("npc_dota_hero_meepo") 
        		if meepos and need_add_flag then
        			for i,x in pairs(meepos) do
        				x:RemoveSelf() 
        			end
        		end

        		if not IsConnected(hero) then return end
				PlayerResource:ReplaceHeroWith( playerid, x, gold, 0 )

				end)
			break;
		end
	end
end

function SaveGold()
	local player

	for playerid = 0, 19 do
		if not IsAbadonedPlayerID(playerid) then 
			player = PlayerResource:GetPlayer(playerid)

			if player then
				FixDoombringer(player)

				GiveMeepoFuckedBoots(player)
				local player_gold = PlayerResource:GetGold(playerid)
				tPlayers[playerid] = tPlayers[playerid] or {} -- nil error exception
				tPlayers[playerid].gold = tPlayers[playerid].gold or 0 -- nil error exception
				
				if player_gold > 80000 then
					local gold_to_save = player_gold - 80000
					tPlayers[playerid].gold = tPlayers[playerid].gold + gold_to_save
					PlayerResource:SpendGold( playerid, gold_to_save, 0)
				end

				if player_gold < 80000 then
					local free_gold = 80000 - player_gold
					local total_saved_gold = tPlayers[playerid].gold
					if total_saved_gold > free_gold then
						tPlayers[playerid].gold = tPlayers[playerid].gold - free_gold
						PlayerResource:ModifyGold( playerid, free_gold, true, 0) 
					else
						PlayerResource:ModifyGold( playerid, total_saved_gold, true, 0)
						tPlayers[playerid].gold = 0
					end
				end

			end
		end
	end

	CustomGameEventManager:Send_ServerToAllClients("TopBarUpdate", { radiant = _G.Kills[DOTA_TEAM_GOODGUYS], dire = _G.Kills[DOTA_TEAM_BADGUYS]})


end

function FixDoombringer(player)
	local hero = player:GetAssignedHero() 
	if not hero then return end

	if hero:GetUnitName() =="npc_dota_hero_doom_bringer" then
		hero:RemoveModifierByName("modifier_doom_bringer_devour") 
	end
end
function GiveMeepoFuckedBoots(player)
	local hero = player:GetAssignedHero() 
	if not hero then return end
	local hero_name = hero:GetUnitName() 

	if hero_name == "npc_dota_hero_meepo" then
		for i = 1, #meepo_boots do
			if hero:HasItemInInventory(meepo_boots[i]) then
				local all_meepo = Entities:FindAllByName("npc_dota_hero_meepo") 
				for _,x in pairs(all_meepo) do
					if x:GetPlayerOwner() == hero:GetPlayerOwner() then
						if not x:HasItemInInventory(meepo_boots[i]) and x~=hero and GetItemsCount(x) == 0 then 
							local item = CreateItem(meepo_boots[i], x, x) 
							item:SetPurchaseTime(0)
							x:AddItem(item)
						end
					end
				end
			end
		end
	end
end

function GetItemsCount(hero)
	if not hero then return end
	local counter = 0

	for i = 0, 5 do
		local item = hero:GetItemInSlot(i)
		if item then
			counter = counter + 1
		end
	end
	return counter
end

function IsAbadonedPlayerID(playerid)
    if not playerid then return false end

    local connection_state = PlayerResource:GetConnectionState(playerid) 

    if connection_state == DOTA_CONNECTION_STATE_ABANDONED then 
        return true 
    else 
        return false
    end
end

function IsUnitBear(unit)
	if not unit or not IsValidEntity(unit) then return false end
	local unit_name = unit:GetUnitName() 
	if unit_name == "npc_dota_lone_druid_bear1" or unit_name == "npc_dota_lone_druid_bear2"
	or unit_name == "npc_dota_lone_druid_bear3" or unit_name == "npc_dota_lone_druid_bear4" then
		return true
	end

	return false
end
--[[
function GetItemCost(item_name)
	if items_cost[item_name] then
		return items_cost[item_name] - items_cost.sol
	end
end]]

function GetTotalPr(playerid)
	local streak = PlayerResource:GetStreak(playerid)
	local gold_per_streak = 1000;
	local gold_per_level  = 100;
	local minute = GameRules:GetGameTime() / 60
	if 		minute < 10 then
		gold_per_streak = 250 + (RandomInt(-1, 1)) * RandomInt(0, 100)
	elseif 	minute < 20 then
		gold_per_streak = 600 + (RandomInt(-1, 1)) * RandomInt(0, 100)
	elseif 	minute < 30 then	
		gold_per_streak = 1000 + (RandomInt(-1, 1)) * RandomInt(0, 110)
	elseif 	minute < 50 then
		gold_per_streak = 3000 + (RandomInt(-1, 1)) * RandomInt(0, 220)
	elseif 	minute > 50 then
		gold_per_streak = 5000 + (RandomInt(-1, 1)) * RandomInt(0, 250)
	end

	--print("GOLD PER STREAKS:", gold_per_streak*streak)
	_G.tPlayers[playerid] 				= _G.tPlayers[playerid] or {}
	_G.tPlayers[playerid].filter_gold 	= _G.tPlayers[playerid].filter_gold or 0
	_G.tPlayers[playerid].books 		= _G.tPlayers[playerid].books or 0

	--print("FILTER GOLD:", _G.tPlayers[playerid].filter_gold)
	--print("BOOKS GOLD:", _G.tPlayers[playerid].books);
	local total_gold = gold_per_streak*streak--_G.tPlayers[playerid].filter_gold + gold_per_streak*streak + _G.tPlayers[playerid].books
	--print("TOTAL GOLD = ", total_gold)
	return total_gold
end