function Teleport( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	if not point then return end


	local friendly_units = FindUnitsInRadius(caster:GetTeamNumber(),
                              Vector(0, 0, 0),
                              nil,
                              FIND_UNITS_EVERYWHERE,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                              FIND_ANY_ORDER,
                              false)

	local min_distance = 100000;
	local curr_unit = nil;

	for i, x in pairs(friendly_units) do
		if x then
			if min_distance > FindDistance(point, x:GetAbsOrigin()) then
				min_distance = FindDistance(point, x:GetAbsOrigin())
				curr_unit = x;
			end
		end
	end

	Timers:CreateTimer("teleport_" .. caster:GetPlayerOwnerID() ,{ --таймер следующей дуэльки
             	endTime = 1.0,
                callback = function()
                	point = curr_unit:GetAbsOrigin()
                	FindClearSpaceForUnit(caster, point, false)
					caster:Stop()
                    return nil
                end})

end

function FindDistance(vec1, vec2)
	return math.sqrt(math.abs(vec1.x - vec2.x)^2 + math.abs(vec1.y - vec2.y)^2 + math.abs(vec1.z - vec2.z)^2 )
end