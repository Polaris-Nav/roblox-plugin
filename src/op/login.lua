local e = _G.PolarisNav

return function ()
	e.go.mode_set 'Login'

	local state = e.store:getState()

	e.promise {
		id = state.auth.UserId;
		token = state.auth.token;
	}
	:Then(e.http.get_challenge)
	:Then(function(self, challenge)
		self.challenge = challenge
		self.solution = e.NanoPoW.calculate(self.challenge)
	end)
	:Then(e.http.login)
	:Then(function(self, session)
		e.go.auth_login(session)
	end)
	:Then(e.op.authorized)
	:Else(function()
		e.go.auth_login_fail()
		e.go.mode_set 'BeginLink'
		e.warn 'Login failed'
	end)
	:ContinueAsync()

	return new
end