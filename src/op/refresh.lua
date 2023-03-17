local e = _G.PolarisNav

return function ()
	local auth = e.store:getState().auth

	e.go.mode_set 'Refresh'
	e.promise {
		id = auth.UserId;
		token = auth.token;
		session = auth.session;
	}
	:Then(e.http.refresh)
	:Then(function(action, session)
		e.go.auth_login(session)
	end)
	:Then(e.op.authorized)
	:Else(e.op.login)
	:ContinueAsync()
	return new
end