local e = _G.PolarisNav

return function ()
	e.go.auth_link_clear()
	e.go.mode_set 'Welcome'
	return new
end