return function(from, to)
	for k, v in next, from do
		to[k] = v
	end
	return to
end