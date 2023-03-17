local e = _G.PolarisNav

return function ()
	e.go.auth_login_clear()
	e.go.mode_set 'Welcome'
	return new
end