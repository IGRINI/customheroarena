function CheckIllusion(keys)
	local caster = keys.caster

	if caster:IsIllusion() then
		while caster:HasModifier("modifier_time_lock_datadriven") do
			caster:RemoveModifierByName("modifier_time_lock_datadriven")
		end
	end
	
end