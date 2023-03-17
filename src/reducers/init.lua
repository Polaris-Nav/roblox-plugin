local e = _G.PolarisNav

local subreducers = {}
for i, child in ipairs(script:GetChildren()) do
	subreducers[child.Name] = require(child)
end

return function (old, action)
	if action.type == '@@INIT' then
		local new = {}
		for name, r in next, subreducers do
			r(action, old, new)
		end
		return new
	end

	local nxt = action.type:gmatch '[^_]+'
	local name = nxt()
	local r = name and subreducers[name]
	if r then
		local new = table.clone(old)
		r(action, old, new, nxt)
		return new
	else
		return old
	end
end