function roulette(event)
local caster = event.caster
local ability = event.ability
caster:RemoveModifierByName("modifier_inc")
caster:RemoveModifierByName("modifier_dec")
if RollPercentage(50) then ability:ApplyDataDrivenModifier(caster, caster, "modifier_inc", {}) else ability:ApplyDataDrivenModifier(caster, caster, "modifier_dec", {})
end
end