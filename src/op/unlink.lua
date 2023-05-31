local e = _G.PolarisNav



return function ()
    e.go.confirm_show(
		'If you unlink your account, you will have to relink it to use our mesh generation.',
		function()
            e.go.auth_link_clear()
	        e.go.mode_set 'Welcome'
        end
	)
	return new
end