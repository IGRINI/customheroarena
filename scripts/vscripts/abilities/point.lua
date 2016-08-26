function point(event)
local caster = event.caster
if caster:GetAbilityPoints() > 0 then caster:SetAbilityPoints(0) end
end