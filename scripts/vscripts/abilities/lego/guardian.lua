function check(event)
local caster = event.caster
local ability = event.ability
local dmg = caster:GetAverageTrueAttackDamage()
local GG = ability:GetLevelSpecialValueFor("dmg", ability:GetLevel())
local def = math.ceil(dmg/GG)
caster:SetModifierStackCount("modifier_legion_guardian", caster, def)
end