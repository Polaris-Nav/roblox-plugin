local t = {}
for i, child in ipairs(script:GetChildren()) do
	t[child.Name] = require(child)
end
return t