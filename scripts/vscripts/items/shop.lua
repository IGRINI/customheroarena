require('change_hero')
local items_cost = require('lib/test')

local items = {}

if CustomShop == nil then
  print ( 'Init custom shop' )
  CustomShop = {}
  CustomShop.__index = CustomShop
end


local non_change_ability_heroes_table = {
	["npc_dota_hero_elder_titan"] = 1,
}


CustomShop.Table = {
	["item_book_med"] 		= "item_tome_med",
	["item_book_agi3"] 		= "item_tome_agi_3",
	["item_book_agi6"] 		= "item_tome_agi_6",
	["item_book_agi60"] 	= "item_tome_agi_60",
	["item_book_str3"] 		= "item_tome_str_3",
	["item_book_str6"] 		= "item_tome_str_6",
	["item_book_str60"] 	= "item_tome_str_60",
	["item_book_int3"] 		= "item_tome_int_3",
	["item_book_int6"] 		= "item_tome_int_6",
	["item_book_int60"] 	= "item_tome_int_60",
	["item_book_un3"] 		= "item_tome_un_3",
	["item_book_un6"] 		= "item_tome_un_6",
	["item_book_un60"]		= "item_tome_un_60",
	["item_book_lvlup"] 	= "item_tome_lvlup",
	["item_pet_hulk"]		= "item_pet_hulk",
	["item_pet_mage"]		= "item_pet_mage",
	["item_pet_wolf"]		= "item_pet_wolf",
	["item_reborn_hero"] 	= "item_reborn_hero",
}

CustomShop.TableHeroes = {
	"npc_dota_hero_abaddon",
	"npc_dota_hero_ancient_apparition",
	"npc_dota_hero_antimage",
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_axe",
	"npc_dota_hero_bane",
	"npc_dota_hero_batrider",
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
	"npc_dota_hero_gyrocopter",
	"npc_dota_hero_huskar",
	"npc_dota_hero_invoker",
	"npc_dota_hero_jakiro",
	"npc_dota_hero_juggernaut",
	"npc_dota_hero_legion_commander",
	"npc_dota_hero_leshrac",
	"npc_dota_hero_lich",
	"npc_dota_hero_life_stealer",
	"npc_dota_hero_lina",
	"npc_dota_hero_lion",
	"npc_dota_hero_lone_druid",
	"npc_dota_hero_luna",
	"npc_dota_hero_lycan",
	"npc_dota_hero_mirana",
	"npc_dota_hero_morphling",
	"npc_dota_hero_magnataur",
	"npc_dota_hero_meepo",
	"npc_dota_hero_naga_siren",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_night_stalker",
	"npc_dota_hero_nyx_assassin",
	"npc_dota_hero_furion",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_oracle",
	"npc_dota_hero_obsidian_destroyer",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_phantom_lancer",
	"npc_dota_hero_phoenix",
	"npc_dota_hero_puck",
	"npc_dota_hero_pudge",
	"npc_dota_hero_pugna",
	"npc_dota_hero_queenofpain",
	"npc_dota_hero_riki",
	"npc_dota_hero_rubick",
	"npc_dota_hero_sand_king",
	"npc_dota_hero_shadow_demon",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_shadow_shaman",
	"npc_dota_hero_silencer",
	"npc_dota_hero_spectre",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_slardar",
	"npc_dota_hero_slark",
	"npc_dota_hero_sniper",
	"npc_dota_hero_spirit_breaker",
	"npc_dota_hero_storm_spirit",
	"npc_dota_hero_techies",
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_terrorblade",
	"npc_dota_hero_tidehunter",
	"npc_dota_hero_shredder",
	"npc_dota_hero_treant",
	"npc_dota_hero_tinker",
	"npc_dota_hero_troll_warlord",
	"npc_dota_hero_tusk",
	"npc_dota_hero_undying",
	"npc_dota_hero_ursa",
	"npc_dota_hero_venomancer",
	"npc_dota_hero_viper",
	"npc_dota_hero_visage",
	"npc_dota_hero_warlock",
	"npc_dota_hero_weaver",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_winter_wyvern",
	"npc_dota_hero_wisp",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_zuus",
}


function PushItemIntoTable(itemname, itemcost, itemlist)
	temp = {
		itemname = itemname,
		itemcost = itemcost,
		list = itemlist,
	}
	table.insert(items.item, temp)
end

function OpenShop(player)
	items = {
		item = {},
		lists = {
			"Items", -- 0 list
			"Heroes", -- 1 list
			--"Items(DROP)", -- 2 list
		}
	}

	PushItemIntoTable("item_book_agi3", 1000, 0)
	PushItemIntoTable("item_book_agi6", 1800, 0)
	PushItemIntoTable("item_book_agi60", 18000, 0)
	PushItemIntoTable("item_book_str3", 1000, 0)
	PushItemIntoTable("item_book_str6",	1800, 0)
	PushItemIntoTable("item_book_str60",	18000, 0)
	PushItemIntoTable("item_book_int3",	1000, 0)
	PushItemIntoTable("item_book_int6",	1800, 0)
	PushItemIntoTable("item_book_int60",	18000, 0)
	PushItemIntoTable("item_book_un3", 	2000, 0)
	PushItemIntoTable("item_book_un6",	2800, 0)
	PushItemIntoTable("item_book_un60",	28000, 0)
	PushItemIntoTable("item_book_lvlup",1000, 0)
	PushItemIntoTable("item_book_med", 	4000, 0)
	
	PushItemIntoTable("item_pet_hulk", 10000, 0)
	PushItemIntoTable("item_pet_mage", 12000, 0)
	PushItemIntoTable("item_pet_wolf", 12000, 0)
	PushItemIntoTable("item_reborn_hero", 1, 0)
	PushItemIntoTable("item_change_team", 5000, 0)

	for _, x in pairs(CustomShop.TableHeroes) do
		if x then
			PushItemIntoTable(x, 0, 1)
		end
	end


	CustomGameEventManager:Send_ServerToPlayer(player, "custom_shop_open_menu", items) 
end

function CloseShop(player)
	CustomGameEventManager:Send_ServerToPlayer(player, "custom_shop_close_menu", items) 
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

function GetPlayersCount()
	local i = 0
	local j = 0
	for _, x in pairs(tHeroesRadiant) do
		if IsConnected(x) then
			i = i + 1
		end
	end

	for _, x in pairs(tHeroesDire) do
		if IsConnected(x) then
			j = j + 1
		end
	end
	return i, j
end

function print_d(text)
	CustomGameEventManager:Send_ServerToAllClients("DebugMessage", { msg = text})
end

function CustomShop:BuyItem(playerid, item_name, item_cost)
	if IsServer() then
		local player = PlayerResource:GetPlayer(playerid)
		local hero = player:GetAssignedHero()
		local player_gold = hero:GetGold() 

		if (item_cost > player_gold) and (item_cost ~= 0) then
			return
		end

		if CustomShop.Table[item_name] then
			item_name = CustomShop.Table[item_name]
			if AC:GetItemCost(item_name) then
				local item = CreateItem(item_name, hero, hero)
				if AC:GetItemCost(item_name) < player_gold then
					hero:AddItem(item)
					PlayerResource:SpendGold(playerid, AC:GetItemCost(item_name), 0)
					return
				else
					UTIL_Remove(item) 
				end
			end
		end

		for _, x in pairs(CustomShop.TableHeroes) do
			if x == item_name then
				ChangeHero(playerid, x)
				CloseShop(player)
				return
			end
		end

		if item_name == "item_change_team" then
			local radiant_heroes, dire_heroes = GetPlayersCount()
			CustomGameEventManager:Send_ServerToAllClients("custom_player_change_team", { playerid = playerid})

			CloseShop(player)
			ChangeHeroTeam(playerid, player, hero)
			return
		end
	end
end

function SetPlayerGold(playerid, gold)
	if IsServer() then
		PlayerResource:SetGold(playerid, 0, false)
		PlayerResource:SetGold(playerid, 0, true)

		PlayerResource:ModifyGold( playerid, gold, false, 0 )
	end
end

function ChangeHeroTeam(playerid, player, hero)

	if not hero then return end

	local radiant_heroes, dire_heroes = GetPlayersCount()
	local old_hero = nil
	
	if _G.nCOUNTDOWNTIMER < 10 then return end

	local gold = hero:GetGold()

	if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		if dire_heroes >= radiant_heroes then return end
		hero:RemoveModifierByName("modifier_rubick_spell_steal")
		player:SetTeam(DOTA_TEAM_BADGUYS)
		hero:SetTeam(DOTA_TEAM_BADGUYS)
		SetPlayerGold(playerid, gold)
		local point = Entities:FindByName( nil, "DIRE_BASE")
		TeleportUnitToEntity(hero, point , true, true)
		PlayerResource:UpdateTeamSlot(playerid, DOTA_TEAM_BADGUYS, 1)
		PlayerResource:SetCustomTeamAssignment(playerid, DOTA_TEAM_BADGUYS)
		
		if hero:GetUnitName() == "npc_dota_hero_lone_druid" then
			local bear = Entities:FindAllByName("npc_dota_lone_druid_bear")
			if bear then
				for i,x in pairs(bear) do
					x:SetTeam(DOTA_TEAM_BADGUYS)
					TeleportUnitToEntity(x, point , true, true)
				end
			end
		end

		if hero:GetUnitName() == "npc_dota_hero_broodmother" then
			local webs = Entities:FindAllByName("npc_dota_broodmother_web")
			if webs then 
				for i = 1, #webs do
					if webs[i] then webs[i]:SetTeam(DOTA_TEAM_BADGUYS) end

				end
			end
		end

		if non_change_ability_heroes_table[hero:GetUnitName()] then
			for i = 0, hero:GetAbilityCount() - 1 do
				local ability = hero:GetAbilityByIndex(i)
				if ability then
					local ability_name = ability:GetName() 
					local ability_level = ability:GetLevel() 
					
					hero:RemoveAbility(ability_name)
					ability = hero:AddAbility(ability_name)
					ability:SetLevel(ability_level)
				end
			end
		end

		print("SET TO BADGUY")
		local cour = Entities:FindAllByName("npc_dota_courier") 
		if cour then
			for i,x in pairs(cour) do
				--print("COUR:",x:GetUnitName(),"TEAM:", x:GetTeamNumber())
				if x and x:GetTeamNumber() == DOTA_TEAM_BADGUYS then
					print("SetControl to", x:GetUnitName())
					x:SetControllableByPlayer(playerid, true)
				end
			end
		end
	elseif hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then 
		if dire_heroes <= radiant_heroes then return end
		hero:RemoveModifierByName("modifier_rubick_spell_steal")
		player:SetTeam(DOTA_TEAM_GOODGUYS)
		hero:SetTeam(DOTA_TEAM_GOODGUYS)
		SetPlayerGold(playerid, gold)
		local point = Entities:FindByName( nil, "RADIANT_BASE") 
		TeleportUnitToEntity(hero, point , true, true)
		print("SET TO GOODGUY")
		PlayerResource:UpdateTeamSlot(playerid, DOTA_TEAM_GOODGUYS, 1)
		PlayerResource:SetCustomTeamAssignment(playerid, DOTA_TEAM_GOODGUYS)
		
		if hero:GetUnitName() == "npc_dota_hero_lone_druid" then
			local bear = Entities:FindAllByName("npc_dota_lone_druid_bear")
			if bear then
				for i,x in pairs(bear) do
					x:SetTeam(DOTA_TEAM_GOODGUYS)
					TeleportUnitToEntity(x, point , true, true)
				end
			end
		end

		if hero:GetUnitName() == "npc_dota_hero_broodmother" then
			local webs = Entities:FindAllByName("npc_dota_broodmother_web")
			if webs then 
				for i = 1, #webs do
					if webs[i] then webs[i]:SetTeam(DOTA_TEAM_BADGUYS) end

				end
			end
		end

		if non_change_ability_heroes_table[hero:GetUnitName()] then
			for i = 0, hero:GetAbilityCount() - 1 do
				local ability = hero:GetAbilityByIndex(i)
				if ability then
					local ability_name = ability:GetName() 
					local ability_level = ability:GetLevel() 
					
					hero:RemoveAbility(ability_name)
					ability = hero:AddAbility(ability_name)
					ability:SetLevel(ability_level)
				end
			end
		end

		local cour = Entities:FindAllByName("npc_dota_courier") 
		if cour then
			for i,x in pairs(cour) do
				--print("COUR:",x:GetUnitName(),"TEAM:", x:GetTeamNumber())
				if x and x:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
					print("SetControl to", x:GetUnitName())
					x:SetControllableByPlayer(playerid, true)
				end
			end
		end
	end


	for i,x in pairs(tHeroesRadiant) do
		if x == hero then
			table.insert(tHeroesDire, x)
			table.remove(tHeroesRadiant, i)
			return
		end
	end

	if old_hero == nil then
		for i,x in pairs(tHeroesDire) do
			if x == hero then
				table.insert(tHeroesRadiant, x)
				table.remove(tHeroesDire, i)
				return
			end
		end
	end
end

function UpdateAllTeamSlots()
	for i = 0, 23 do
		PlayerResource:UpdateTeamSlot(i, DOTA_TEAM_GOODGUYS, true)
		PlayerResource:UpdateTeamSlot(i, DOTA_TEAM_BADGUYS)
	end
end

