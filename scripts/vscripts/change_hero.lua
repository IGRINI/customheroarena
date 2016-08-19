function IsAlreadyOccupedHero(hero_name)
	for _, x in pairs(tHeroesRadiant) do
		if x then
			print(x:GetUnitName())
		end
		if x and x:GetUnitName() == hero_name and not IsAbadoned(x) then return true end
	end

	for _, x in pairs(tHeroesDire) do
		if x then
			print(x:GetUnitName())
		end
		if x and x:GetUnitName() == hero_name and not IsAbadoned(x) then return true end
	end

	return false
end

function ChangeHero(playerid, hero)

	if _G.nCOUNTDOWNTIMER < 10 then return end

	local hero_temp = PlayerResource:GetPlayer(playerid):GetAssignedHero() 
	local delay_time = 1
	if not hero_temp then return end
	if not hero_temp:IsAlive()  then return end
	if DuelLibrary:IsDuelActive() then return end
	
	if IsAlreadyOccupedHero(hero) then
		GameRules:SendCustomMessage("#hero_occuped", 0, 0) 
		return
	end

	hero_temp:Stop()
	hero_temp:AddNewModifier(x, nil, "modifier_stun", {})
	hero_temp:AddNoDraw()

	if hero_temp:GetUnitName() == "npc_dota_hero_shredder" then
		if hero_temp:HasModifier("modifier_shredder_chakram_disarm") then 
			GameRules:SendCustomMessage("#cant_change", 0, 0)
			hero_temp:RemoveModifierByName("modifier_stun")
			hero_temp:RemoveNoDraw() 
			return 
		end
	end

	if hero_temp:GetUnitName() == "npc_dota_hero_arc_warden" then
		local all = Entities:FindAllByName("npc_dota_hero_arc_warden") 
		for i,x in pairs(all) do
			if x:HasModifier("modifier_arc_warden_tempest_double") then
				UTIL_Remove(x)
			end
		end
	end

	Timers:CreateTimer(delay_time, function() 
	PrecacheUnitByNameAsync(hero, function()
				if DuelLibrary:IsDuelActive() then return end

				local point
				local gold
				local old_hero = nil
	
				print("Try to change hero to " .. hero .. " playerid .. ".. playerid)

				if IsAlreadyOccupedHero(hero) then
					local player = PlayerResource:GetPlayer(playerid) 
					GameRules:SendCustomMessage("#hero_occuped", 0, 0) 
					hero_temp:RemoveModifierByName("modifier_stun")
					hero_temp:RemoveNoDraw() 
					return
				end

				for i,x in pairs(tHeroesRadiant) do
					if x:GetPlayerOwnerID() == playerid then

						if not IsConnected(x) then return end

						point =  Entities:FindByName( nil, "RADIANT_BASE" ):GetAbsOrigin()
						old_hero = x
						table.remove(tHeroesRadiant, i)
					end
				end

				if old_hero == nil then
					for i,x in pairs(tHeroesDire) do
						if x:GetPlayerOwnerID() == playerid then

							if not IsConnected(x) then return end

							point =  Entities:FindByName( nil, "DIRE_BASE" ):GetAbsOrigin()
							old_hero = x
							table.remove(tHeroesDire, i)
						end
					end
				end


				if not old_hero then
					local player = PlayerResource:GetPlayer(playerid)
					if not player then return end

					old_hero = player:GetAssignedHero() 

					if not old_hero then return end

					if not IsConnected(old_hero) then return end

					if old_hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
						point =  Entities:FindByName( nil, "RADIANT_BASE" ):GetAbsOrigin()

					end

					if old_hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
						point =  Entities:FindByName( nil, "DIRE_BASE" ):GetAbsOrigin()
					end
				end

				if not old_hero then return end

				if old_hero and old_hero:GetUnitName() == "npc_dota_hero_broodmother" then
					local webs = Entities:FindAllByName("npc_dota_broodmother_web")
					if webs then 
						for i = 1, #webs do
							if webs[i] then UTIL_Remove(webs[i]) end
						end
					end
				end

				gold = old_hero:GetGold() 

				if not IsConnected(old_hero) then return end

				local item_table = {}
				for i = 0, 12 do
					local item = old_hero:GetItemInSlot(i)
					if item then 
						local tbl = {
							item_name = item:GetName(),
							charges = item:GetCurrentCharges(),
							owner = item:GetPurchaser() 
						}
						--print("item:", tbl.item_name, "owner item:", tbl.owner:GetUnitName())
						if tbl.owner == old_hero then tbl.owner = nil end
						table.insert(item_table, tbl)
						UTIL_Remove(item)
					else
						table.insert(item_table, "null_item")
					end
				end

				old_hero:Stop()
				
				if not IsConnected(old_hero) then return end

				local need_add_flag = false
				if old_hero:GetUnitName() == "npc_dota_hero_meepo" then
					need_add_flag = true

				end

				if IsAlreadyOccupedHero(hero) then
					GameRules:SendCustomMessage("#hero_occuped", 0, 0) 
					hero_temp:RemoveModifierByName("modifier_stun")
					hero_temp:RemoveNoDraw() 
					return
				end

				if not IsConnected(old_hero) then return end

				if old_hero and old_hero:GetUnitName() == "npc_dota_hero_lone_druid" then
					local bears = Entities:FindAllByName("npc_dota_lone_druid_bear")
					for i,x in pairs(bears) do 
						if x then 
							UTIL_Remove(x) 
						end
					end
				end

				if not IsConnected(old_hero) then return end

        		PlayerResource:ReplaceHeroWith( playerid, hero, gold, 0 )

        		local meepos = Entities:FindAllByName("npc_dota_hero_meepo") 
        		if meepos and need_add_flag then
        			for i,x in pairs(meepos) do
        				x:RemoveSelf() 
        			end
        		end

        		if old_hero then
					UTIL_Remove(old_hero) 
				end

				pplayer = PlayerResource:GetPlayer(playerid)
				
        		local new_hero = pplayer:GetAssignedHero()
        		if need_add_flag then
        			if new_hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
        				table.insert(tHeroesRadiant, new_hero)
        			end

        			if new_hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
        				table.insert(tHeroesDire, new_hero)
        			end
        		end
        		FindClearSpaceForUnit(new_hero, point, false)

        		for i = 0, 12 do
        			if item_table[i] and item_table[i] ~= "null_item" then

        				local item
        				if item_table[i].owner then
        					item = CreateItem(item_table[i].item_name, item_table[i].owner, item_table[i].owner) 
        					item:SetPurchaser(item_table[i].owner)
        					item:SetOwner(item_table[i].owner)
        				else
        					item = CreateItem(item_table[i].item_name, new_hero, new_hero) 
        					item:SetPurchaser(new_hero)
        					item:SetOwner(new_hero)
        				end

        				item:SetPurchaseTime(0) 

        				if item_table[i].charges then
        					item:SetCurrentCharges(item_table[i].charges)
        				end

        				new_hero:AddItem(item) 

        				if item:GetName() == "item_hand_of_midas" or item:GetName() == "item_advanced_midas" then
        					item:StartCooldown(100)
        				end
        			end
        		end
     		end, playerid)
	end)
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