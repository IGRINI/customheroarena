require("items/shop")

local HeroesToChange = {
    [1] = {  -- 1 list
        "sven", -- 1
        "alchemist", -- 2
        "joe_black", -- 3
        "medusa", --4 
        "tiny", --5
        "ember", --6
        "satan", --7
        "hola", --8
    },

    [2] = {  -- 2 list
        "fisher", -- 1
        "razor", -- 2
        "-1", -- 3
        "-1", --4 
        "-1", --5
        "-1", --6
        "-1", --7
        "-1", --8
    },
}
local Teleports = {
    [1] = {
        "monk_love",
        "angel_love",
        "monk_hate",
        "angel_hate",
        "monk_life",
        "angel_life",
        "monk_death",
        "angel_death",
    }
}

function custom_shop_open(trigger)
    local hero = trigger.activator
    if hero:IsHero() then
        local player = hero:GetPlayerOwner()
        OpenShop(player)
    end
end


function custom_shop_close(trigger)
    local hero = trigger.activator
    if hero and hero:IsHero() then
        local player = hero:GetPlayerOwner()
        CloseShop(player)
    end
end

function hc_menu_open(trigger)
    print("[LUA]Trying open menu!")
    if IsServer() then
        
        _G.Bosses.deaths = _G.Bosses.deaths or {}
        _G.Bosses.deaths["npc_dota_custom_guardian"] = _G.Bosses.deaths["npc_dota_custom_guardian"] or 0

        if IsBossAliveGlobal("npc_dota_custom_guardian") or _G.Bosses.deaths["npc_dota_custom_guardian"] == 0 then 
            print("GUARDIAN ARE ALIVE!")
            return 
        end
    end
    if not trigger.activator:GetPlayerOwner() then 
        return
    end

    local event_data =
    {   
        list_number = "1",
        hero_numbers = HeroesToChange[1]
    }
   CustomGameEventManager:Send_ServerToPlayer( trigger.activator:GetPlayerOwner(), "change_hero_menu_open", event_data)
end

function hc_menu_close(trigger)
    print("[LUA]Trying close menu")
    if not trigger.activator then return end
    if not trigger.activator:GetPlayerOwner() then 
        return
    end
    CustomGameEventManager:Send_ServerToPlayer( trigger.activator:GetPlayerOwner(), "change_hero_menu_close", nil) --event_data)
end

function hc_menu_close_by_player(player)
    if not player then 
        return
    end
    print("[LUA]Trying close menu")
    CustomGameEventManager:Send_ServerToPlayer( player, "change_hero_menu_close", nil)
end

function hc_menu_open_by_player(player, page)
    if IsBossAliveGlobal("npc_dota_custom_guardian") then 
        print("GUARDIAN ARE ALIVE!")
        return 
    end
    if not player then 
        return
    end
    print("[LUA]Trying open menu by player!")
    print("page:" .. page)
 --   print(DeepPrintTable(HeroesToChange[page]))

    local event_data =
    {   
        list_number = page,
        hero_numbers = HeroesToChange[page],
    }
    CustomGameEventManager:Send_ServerToPlayer( player, "change_hero_menu_open", event_data)
end

function menu_next_page(player, cr_page)
    if HeroesToChange[cr_page+1] == nil then
        print("ERROR!")
        return 0
    end
    if not player then 
        return
    end
    hc_menu_close_by_player(player)
    print("[LUA][NEXTPAGE] cur page = " .. cr_page)
    hc_menu_open_by_player(player, cr_page + 1)
end

function menu_last_page(player, cr_page)
    if HeroesToChange[cr_page-1] == nil then
        print("ERROR!")
        return 0
    end
    if not player then 
        return
    end
    hc_menu_close_by_player(player)
    print("[LUA][LAST_PAGE] cur page = " .. cr_page)
    hc_menu_open_by_player(player, cr_page - 1)
end

function teleport_monc_init(trigger)
    if not trigger.activator:GetPlayerOwner() then 
        return
    end
    
     local event_data =
    {   
        list_number = "1",
        teleports = Teleports[1]
    }
    CustomGameEventManager:Send_ServerToPlayer( trigger.activator:GetPlayerOwner(), "teleport_menu_open", event_data)
end

function teleport_monc_init_off(trigger)
    if trigger.activator:GetPlayerOwner() then 
        return
    end
    teleport_monc_close(trigger.activator)
end

function teleport_monc_close(unit)
    if not unit:GetPlayerOwner() then 
        return
    end
    CustomGameEventManager:Send_ServerToPlayer( unit:GetPlayerOwner(), "teleport_menu_close", nil)
end

function IsInDuel(unit)
    local point = unit:GetAbsOrigin() 
    local flag = false
    for _,thing in pairs(Entities:FindAllInSphere(point, 10) )  do
        if (thing:GetName() == "trigger_box_duel") then
            flag = true
        end
    end
    if flag == false then
        local duel_center =  Entities:FindByName( nil, "DUEL_ARENA_CENTER" ):GetAbsOrigin()

        FindClearSpaceForUnit(unit, duel_center, false)
        unit:Stop()
    end
end


function CheckUnitPosition(unit)
    if not unit or not IsValidEntity(unit) or not unit:IsRealHero() or not unit:IsAlive() then return end

    local point = unit:GetAbsOrigin() 
      for _,thing in pairs(Entities:FindAllInSphere(point, 10) )  do
        if (thing:GetName() == "trigger_box_duel") and not DuelLibrary:IsDuelActive() then
            GetBackToMap(unit)
        end
    end

end

function GetBackToMap(unit)
    local point = Entities:FindByName( nil, "MAP_TELEPORT_1" ):GetAbsOrigin()

    if unit:GetUnitName() == "npc_dota_hero_meepo" then
        local meepo_table = Entities:FindAllByName("npc_dota_hero_meepo")
        if meepo_table then
            for i = 1, #meepo_table do
               FindClearSpaceForUnit(meepo_table[i], point, false)
               meepo_table[i]:Stop()
            end
        end
    else
        FindClearSpaceForUnit(unit, point, false)
        unit:Stop()
    end

end