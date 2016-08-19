require('lib/teleport')
require('lib/timers') -- thanks, BMD!
DuelLibrary = class({})

local init
local duel_active = false
local duel_interval = 300
local duel_draw_time = 120
local duel_count = 0
local duel_radiant_warriors = {}
local duel_dire_warriors = {}
local duel_radiant_heroes = {}
local duel_dire_heroes = {}
local duel_end_callback
local duel_victory_team = 0

local duel_points = {
    radiant = {
        "RADIANT_DUEL_TELEPORT",
    },
    dire = {
        "DIRE_DUEL_TELEPORT",
    },
}

local tribune_points = {
    radiant = {
        "RADIANT_TRIBUNE",
        "RADIANT_TRIBUNE_1",
        "RADIANT_TRIBUNE_2",
        "RADIANT_TRIBUNE_3",
        "RADIANT_TRIBUNE_4",
        "RADIANT_TRIBUNE_5",
        "RADIANT_TRIBUNE_6",
        "RADIANT_TRIBUNE_7",
        "RADIANT_TRIBUNE_8",
        "RADIANT_TRIBUNE_9",
    },

    dire = {
        "DIRE_TRIBUNE",
        "DIRE_TRIBUNE_1",
        "DIRE_TRIBUNE_2",
        "DIRE_TRIBUNE_3",
        "DIRE_TRIBUNE_4",
        "DIRE_TRIBUNE_5",
        "DIRE_TRIBUNE_6",
        "DIRE_TRIBUNE_7",
        "DIRE_TRIBUNE_8",
        "DIRE_TRIBUNE_9",
    },
}

local base_points = {
    radiant = "RADIANT_BASE",
    dire = "DIRE_BASE",
}

local duel_trigger = "trigger_box_duel"

--/////////////////////////////////////////////////////////////////////////////////////////FUNCTIONS //////////////////////////////////////////////////////

function GetHeroesCount(radiant_heroes, dire_heroes)
    local rp = 0
    local dp = 0
    
    if not radiant_heroes or not dire_heroes then return end
    for _, x in pairs(radiant_heroes) do
        if x and x:IsRealHero() and IsConnected(x) then rp = rp + 1 end
    end
    
    for _, x in pairs(dire_heroes) do
        if x and x:IsRealHero() and IsConnected(x) then dp = dp + 1 end
    end

    return rp, dp
end

function ClearDuelFromHeroes(heroes_table) 
    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) and x:IsRealHero() then
            x.IsDueled = false
        end
    end
end

function GetAliveHeroesCount(heroes_table) 
    if not heroes_table then 
        print("[DS]ERROR in GetAliveHeroesCount, invalid table(nil table)")
        return 0
    end
    local lc = 0
    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) and x:IsRealHero() and x:IsAlive() and IsConnected(x) then
            lc = lc + 1
        end
    end
    return lc
end

function MoveHeroesToTribune(heroes_table, tribune_points_table)
    local cur = 1
    local max = #tribune_points_table
    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) and x:IsAlive() then
            if x:GetUnitName() == "npc_dota_hero_meepo" and not x:IsIllusion() then
                local meepo_duel_table = Entities:FindAllByName("npc_dota_hero_meepo")
                if meepo_duel_table then
                    for i = 1, #meepo_duel_table do
                        if not meepo_duel_table[i]:IsIllusion() then
                            meepo_duel_table[i].duel_old_point = x:GetAbsOrigin() 
                            meepo_duel_table[i]:Stop()
                            TeleportUnitToPointName(meepo_duel_table[i], tribune_points_table[cur], true, false)
                            meepo_duel_table[i]:Stop()
                            meepo_duel_table[i]:AddNewModifier(x, nil, "modifier_stun", {})
                        end
                    end
                end
            else
                x.duel_old_point = x:GetAbsOrigin()
                x:Stop() 
                TeleportUnitToPointName(x, tribune_points_table[cur], true, false)
                x:Stop() 
                x:AddNewModifier(x, nil, "modifier_stun", {})
            end

            cur = cur + 1
            cur = cur + 1
            if cur >= max then cur = 1 end
        end
    end
end

function MoveToDuel(duel_heroes, team_heroes, duel_points_table)
    local cur = 1
    local max = #duel_points_table 
    local first_time = false
    for _, x in pairs(duel_heroes) do
        x:Stop() 
        TeleportUnitToPointName(x, duel_points_table[cur], true, false)
        x:Stop() 
        x:RemoveModifierByName('modifier_stun')
        x:AddNewModifier(x, nil, "modifier_godmode", { duration = 5 })

        x.duel_gem = CreateItem("item_gem", x, x)
        x:AddNewModifier(x, x.duel_gem, "modifier_item_gem_of_true_sight", {})
        x.duel_cooldowns = SaveAbilitiesCooldowns(x)
        ResetAllAbilitiesCooldown(x, x.duel_cooldowns)
        x:SetHealth(9999999)
        x:SetMana(9999999)
        x:Purge(true, true, false, true, true )
        local timer_info = {
            endTime = 1,
            callback = function()
                IsHeroOnDuel(x)
            return 1
        end
        }
        Timers:CreateTimer("duel_check_id" .. x:GetPlayerOwnerID(), timer_info);
        local duel_info = {
        endTime = draw_time,
        callback = function()
            EndDuel(radiant_heroes, dire_heroes, radiant_warriors, dire_warriors, end_duel_callback, 0)
            return nil
        end
    }

    Timers:CreateTimer("DS_DRAW_ITERNAL",duel_info)
        cur = cur + 1
        if cur >= max then cur = 1 end

        if first_time == false then
            for _, y in pairs(team_heroes) do
                SetPlayerCameraToEntity(y:GetPlayerOwnerID(), x)
            end
            first_time = true
        end
    end
end

function MoveToDuelHero(hero)
    if not hero or not IsValidEntity(hero) or not hero:IsRealHero() then
        print("[DS] Duel system error, this unit is not hero or not valid entity(iternal func MoveToDuelHero)");
        return
    end

    TeleportUnitToPointName(hero, "DUEL_ARENA_CENTER", true, true)
    hero:RemoveModifierByName("modifier_stun")
end

function IsHeroOnDuel(hero) 
    if not hero then return false end
    
    local point = hero:GetAbsOrigin() 
    local flag = false
    for _,thing in pairs(Entities:FindAllInSphere(point, 10) )  do
        if (thing:GetName() == duel_trigger) then
            flag = true
        end
    end

    if not flag then MoveToDuelHero(hero) end
end

function RemoveHeroesFromDuel(heroes_table)
    if not heroes_table or type(heroes_table) ~= type({}) then
        print("[DS]Error, removeheroesfromduel, invalid heroes table!")
        return
    end

    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) then
            if x:GetUnitName() == "npc_dota_hero_meepo" then
                local meepo_return_table = Entities:FindAllByName("npc_dota_hero_meepo")
                if meepo_return_table then
                    for i = 1, #meepo_return_table do
                        if not meepo_return_table[i]:IsIllusion() then
                            meepo_return_table[i]:Purge(true, true, false, true, true ) 

                            local point = meepo_return_table[i].duel_old_point
                            if not point then
                                point = Entities:FindByName(nil,  GetTeamPointNameByTeamNumber(base_points, meepo_return_table[i]:GetTeamNumber())):GetAbsOrigin()
                            end      

                            if meepo_return_table[i].duel_cooldowns then
                                SetAbilitiesCooldowns(meepo_return_table[i], meepo_return_table[i].duel_cooldowns)
                                meepo_return_table[i].duel_cooldowns = nil
                            end

                            if meepo_return_table[i]:IsAlive() then
                                meepo_return_table[i]:RemoveModifierByName('modifier_stun')
                            end

                            if meepo_return_table[i] then
                                meepo_return_table[i]:RemoveModifierByName("modifier_item_gem_of_true_sight")
                            end

                            if meepo_return_table[i].item_gem then 
                                meepo_return_table[i]:AddNewModifier(meepo_return_table[i], meepo_return_table[i].item_gem, "modifier_item_gem_of_true_sight", {})
                            end
                            if meepo_return_table[i].duel_gem then
                                meepo_return_table[i].duel_gem:RemoveSelf()
                                meepo_return_table[i].duel_gem = nil 
                            end

                            if point then
                                if meepo_return_table[i]:IsAlive() then 
                                    TeleportUnitToVector(meepo_return_table[i], point, true, true)
                                end
                                meepo_return_table[i].duel_old_point = nil
                            else
                                print("[DS] Duel system error, base points not found!")
                            end
                        end
                    end
                end
            else
                x:Purge(true, true, false, true, true )
                local point = x.duel_old_point
                if not point then
                    point = Entities:FindByName(nil,  GetTeamPointNameByTeamNumber(base_points, x:GetTeamNumber())):GetAbsOrigin()
                end

                if x.duel_cooldowns then
                    SetAbilitiesCooldowns(x, x.duel_cooldowns)
                    x.duel_cooldowns = nil
                end

                if x:IsAlive() then
                    x:RemoveModifierByName('modifier_stun')
                end

                x:RemoveModifierByName("modifier_item_gem_of_true_sight")

                if x.item_gem then 
                    x:AddNewModifier(x, x.item_gem, "modifier_item_gem_of_true_sight", {})
                end
                if x.duel_gem then
                    x.duel_gem:RemoveSelf()
                    x.duel_gem = nil 
                end
                if point then
                    if x:IsAlive() then 
                        TeleportUnitToVector(x, point, true, true)
                    end
                    x.duel_old_point = nil
                else
                    print("[DS] Duel system error, base points not found!")
                end
            end
        end
    end
end

function GetHeroesToDuelFromTeamTable(heroes_table, hero_count)
    if GetAliveHeroesCount(heroes_table) < hero_count then
        print("[DS] Duel system error, alive heroes < hero count. Fix it!")
        return
    end

    local counter_local = 0;
    local output_table = {}
    for _, x in pairs(heroes_table) do
        if x and IsValidEntity(x) and x:IsRealHero() and x:IsAlive() and x.IsDueled == false and IsConnected(x) then --x.IsDisconnect == false then
            if x:GetUnitName() == "npc_dota_hero_meepo" then
                local meepo_duel_table = Entities:FindAllByName("npc_dota_hero_meepo")
                if meepo_duel_table then
                    for i = 1, #meepo_duel_table do
                        if not meepo_duel_table[i]:IsIllusion() then
                            meepo_duel_table[i].IsDueled = true
                            table.insert(output_table, meepo_duel_table[i])
                        end
                    end
                end
                counter_local = counter_local + 1
                if counter_local == hero_count then
                    return output_table
                end
            else
                x.IsDueled = true
                table.insert(output_table, x)
                counter_local = counter_local + 1
                if counter_local == hero_count then 
                    return output_table 
                end
            end
        end
    end

    if counter_local < hero_count then -- if some heroes already dueled
        ClearDuelFromHeroes(heroes_table) 
        return GetHeroesToDuelFromTeamTable(heroes_table, hero_count)
    end
end

function DuelLibrary:IsDuelActive()
    return duel_active
end

function DuelLibrary:ToTribune(hero)
    if not hero or not IsValidEntity(hero) or not hero:IsRealHero() then 
        print("[DS]Duel system error, invalid unit, expected hero (global func ToTribune)")
        return
    end
    local team = hero:GetTeamNumber()
    if team == DOTA_TEAM_GOODGUYS then
        for _, x in pairs(tribune_points.radiant) do
            TeleportUnitToPointName(hero, x, true, true)
            hero:AddNewModifier(hero, nil, "modifier_stun", {})
            return
        end
    else
        for _, x in pairs(tribune_points.dire) do
            TeleportUnitToPointName(hero, x, true, true)
            hero:AddNewModifier(hero, nil, "modifier_stun", {})
            return
        end
    end
end

function DuelLibrary:IsHeroDuelWarrior(hero)
    if not hero or not IsValidEntity(hero) or not hero:IsRealHero() then 
        return false
    end
    for _, x in pairs(duel_radiant_warriors) do
        if x == hero then return true end
    end
    for _, x in pairs(duel_dire_warriors) do
        if x == hero then return true end
    end
    return false
end

function EndDuel(radiant_heroes, dire_heroes, radiant_warriors, dire_warriors, end_duel_callback, duel_victory_team)
    duel_active = false
    if radiant_heroes and dire_heroes then
        if duel_victory_team ~= -1 then
            RemoveHeroesFromDuel(radiant_heroes)
            RemoveHeroesFromDuel(dire_heroes)
            for _, x in pairs(radiant_warriors) do
                Timers:RemoveTimer("duel_check_id".. x:GetPlayerOwnerID())
            end

            for _, x in pairs(dire_warriors) do
                Timers:RemoveTimer("duel_check_id".. x:GetPlayerOwnerID())
            end
            duel_radiant_warriors = {}
            duel_dire_warriors = {}
            duel_radiant_heroes = {}
            duel_dire_heroes = {}
        end
        if type(end_duel_callback) == "function" then
            end_duel_callback(duel_victory_team)
        end
    else
        print("[DS] ERROR, INVALID HEROES TABLE(EndDuel(...))")
    end
    GameRules:SendCustomMessage("#duel_end", 0, 0) 
    Timers:RemoveTimer("DS_DRAW_ITERNAL")

end

function DuelLibrary:GetDuelCount()
    return duel_count
end

function DuelLibrary:StartDuel(radiant_heroes, dire_heroes, hero_count, draw_time, error_callback, end_duel_callback)
    if not radiant_heroes or not dire_heroes then 
        local err ="[DS] Duel system error, {} tables of heroes! "
        print(err)
        return 
    end

    for i,x in pairs(radiant_heroes) do 
        if not x then
            table.remove(radiant_heroes, i)
        end
    end

    for i,x in pairs(dire_heroes) do 
        if not x then
            table.remove(dire_heroes, i)
        end
    end
    
    if duel_active == true then
        local err ="[DS] Duel system error, duel already started "
        print(err)
        if type(error_callback) == "function" then
            error_callback({ err_code = -1, err_string = err})
        end
        return
    end
    local radiant_count, dire_count = GetHeroesCount(radiant_heroes, dire_heroes)
    if (radiant_count < hero_count) or (dire_count < hero_count) or (hero_count <= 0) then 
        local err = "[DS] Duel system error, not enought players / invalid players count waiting for " .. hero_count .. " got rh = " .. radiant_count .. " dh = " .. dire_count
        print(err)
        print_d(err)
        GameRules:SendCustomMessage("#duel_error", 0, 0) 
        EndDuel(radiant_heroes, dire_heroes, {}, {}, end_duel_callback, -1)
        if type(error_callback) == "function" then
            error_callback({ err_code = -2, err_string = err})
        end
        return
    end


    local radiant_warriors = GetHeroesToDuelFromTeamTable(radiant_heroes, hero_count)
    local dire_warriors = GetHeroesToDuelFromTeamTable(dire_heroes, hero_count)

    if (not radiant_warriors) or (not dire_warriors) then 
        local err = "[DS] Duel system error, not enought heroes for duel[2]. waiting "
        print(err)
        print_d(err)
        GameRules:SendCustomMessage("#duel_error", 0, 0) 
        EndDuel(radiant_heroes, dire_heroes, {}, {}, end_duel_callback, -1)
        if type(error_callback) == "function" then
            error_callback({ err_code = -2, err_string = err})
        end
        return
    end

    GameRules:SendCustomMessage("#duel_start", 0, 0) 

    duel_radiant_warriors = radiant_warriors
    duel_dire_warriors = dire_warriors
    duel_end_callback = end_duel_callback
    duel_radiant_heroes = radiant_heroes
    duel_dire_heroes = dire_heroes

    duel_count = duel_count + 1
    duel_active = true

    MoveHeroesToTribune(radiant_heroes, tribune_points.radiant)
    MoveHeroesToTribune(dire_heroes, tribune_points.dire)
    MoveToDuel(radiant_warriors, radiant_heroes, duel_points.radiant)
    MoveToDuel(dire_warriors, dire_heroes, duel_points.dire)

    local duel_info = {
        endTime = draw_time,
        callback = function()
            EndDuel(radiant_heroes, dire_heroes, radiant_warriors, dire_warriors, end_duel_callback, 0)
            return nil
        end
    }

    Timers:CreateTimer("DS_DRAW_ITERNAL",duel_info)
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function _OnHeroDeathOnDuel(warriors_table, hero )
    for i, x in pairs(warriors_table) do
        if x == hero then
            table.remove(warriors_table, i)
            Timers:RemoveTimer("duel_check_id".. x:GetPlayerOwnerID())
            if hero:GetUnitName() == "npc_dota_hero_meepo" then
                for j, y in pairs(warriors_table) do
                    if y and y:GetUnitName() == "npc_dota_hero_meepo" then
                        table.remove(warriors_table, j)
                    end
                end
                for j, y in pairs(warriors_table) do
                    if y and y:GetUnitName() == "npc_dota_hero_meepo" then
                        table.remove(warriors_table, j)
                    end
                end
                for j, y in pairs(warriors_table) do
                    if y and y:GetUnitName() == "npc_dota_hero_meepo" then
                        table.remove(warriors_table, j)
                    end
                end
            end

            if #warriors_table == 0 then
                duel_victory_team = ((x:GetTeamNumber() == DOTA_TEAM_GOODGUYS) and DOTA_TEAM_BADGUYS) or ((x:GetTeamNumber() == DOTA_TEAM_BADGUYS) and DOTA_TEAM_GOODGUYS)
                EndDuel(duel_radiant_heroes, duel_dire_heroes, duel_radiant_warriors, duel_dire_warriors, duel_end_callback, duel_victory_team )
                print("team victory = " , duel_victory_team)
            end
            return
        end
    end
end

function DeathListener( event )
    if not duel_active then return end
    local killedUnit = EntIndexToHScript( event.entindex_killed )
    local killedTeam = killedUnit:GetTeam()
    local hero = EntIndexToHScript( event.entindex_attacker )
    local heroTeam = hero:GetTeam()
    
    if not killedUnit or not IsValidEntity(killedUnit) or not killedUnit:IsRealHero() then return end

    if DuelLibrary:IsDuelActive() and not killedUnit:IsReincarnating() then
       _OnHeroDeathOnDuel(duel_radiant_warriors, killedUnit )
       _OnHeroDeathOnDuel(duel_dire_warriors, killedUnit )
    end

end

function GetTeamPointNameByTeamNumber(table_of_points, teamnumber)
    if teamnumber == DOTA_TEAM_GOODGUYS then
        return table_of_points.radiant
    elseif teamnumber == DOTA_TEAM_BADGUYS then
        return table_of_points.dire
    else
    end
end

function SpawnListener(event)
    if not duel_active then return end
    local spawnedUnit = EntIndexToHScript( event.entindex )
    if not spawnedUnit or not IsValidEntity(spawnedUnit) or not spawnedUnit:IsRealHero() then
        return
    end

--[[
    if spawnedUnit:IsRealHero() then
        if DuelLibrary:IsDuelActive() and not DuelLibrary:IsHeroDuelWarrior(spawnedUnit) then
            DuelLibrary:ToTribune(spawnedUnit)
        end
    end]]

    Timers:CreateTimer(0.15, function()
        if not spawnedUnit then return nil end

        if not spawnedUnit:HasModifier("modifier_arc_warden_tempest_double") then
            if spawnedUnit:IsRealHero() then
                if DuelLibrary:IsDuelActive() and not DuelLibrary:IsHeroDuelWarrior(spawnedUnit) then
                    DuelLibrary:ToTribune(spawnedUnit)
                end
            end
        end
        
      return nil
    end
    )


end

function SaveAbilitiesCooldowns(unit)
    if not unit then
        return
    end
    
    local savetable = {}
    local abilities = unit:GetAbilityCount() - 1
    for i = 0, abilities do
        if unit:GetAbilityByIndex(i) then
            savetable[i] = unit:GetAbilityByIndex(i):GetCooldownTimeRemaining()
            --print("Save Ability Cooldown abilityname='" .. unit:GetAbilityByIndex(i):GetAbilityName() .. "' cooldown = " .. savetable[i])
        end
    end

    savetable.items = {}

    for i = 0, 5 do
        if unit:GetItemInSlot(i) then
            savetable.items[unit:GetItemInSlot(i)] = unit:GetItemInSlot(i):GetCooldownTimeRemaining() 
        end
    end

    return savetable
end

function SetAbilitiesCooldowns(unit, settable)
    local abilities = unit:GetAbilityCount() - 1
    if not settable or not unit then
        return
    end
    for i = 0, abilities do
        if unit:GetAbilityByIndex(i) then
            unit:GetAbilityByIndex(i):StartCooldown(settable[i])
            if settable[i] == 0 then 
                unit:GetAbilityByIndex(i):EndCooldown() 
            end
        end
    end

    if settable.items then
        for item, cooldown in pairs(settable.items) do
            if item and IsValidEntity(item) then
                item:EndCooldown() 
                print("start cooldown for ", item:GetName(), item, cooldown)
                item:StartCooldown(cooldown) 
            end
        end
    end
end

function ResetAllAbilitiesCooldown(unit, item_table)

    if not unit then return end

    local abilities = unit:GetAbilityCount() - 1
    for i = 0, abilities do
        if unit:GetAbilityByIndex(i) then
            unit:GetAbilityByIndex(i):EndCooldown()
        end
    end

    if item_table then
        if item_table.items then
            for i,x in pairs(item_table.items) do
                i:EndCooldown()
            end
        end
    end
end

function DuelLibrary:GetMaximumAliveHeroes(hero_table1, hero_table2)
    local alive_max = 0
    for _, x in pairs(hero_table1) do
        if x and IsValidEntity(x) and x:IsRealHero() and x:IsAlive() and IsConnected(x) then alive_max = alive_max + 1 end
    end

    local al = alive_max
    alive_max = 0
    for _, x in pairs(hero_table2) do
        if x and IsValidEntity(x) and x:IsRealHero() and x:IsAlive() and IsConnected(x) then alive_max = alive_max + 1 end
    end
    if alive_max > al then 
        return al 
    else 
        return alive_max 
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

function IsAbadoned(unit)
    if not unit or not IsValidEntity(unit) then return false end

    local playerid = unit:GetPlayerOwnerID()
    if not playerid then return false end
    local connection_state = PlayerResource:GetConnectionState(playerid) 

    if connection_state == DOTA_CONNECTION_STATE_ABANDONED then 
        return true 
    else 
        return false
    end
end

ListenToGameEvent("entity_killed", DeathListener, nil)
ListenToGameEvent('npc_spawned', SpawnListener, nil )


function print_d(text)
    CustomGameEventManager:Send_ServerToAllClients("DebugMessage", { msg = text})
end
