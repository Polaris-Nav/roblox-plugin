local e = _G.PolarisNav

return function(obj, input, clicks)
	local state = e.store:getState()

	local id = state.auth.UserId
	if id == nil then
		e.warn 'Missing UserId'
		return
	end

	local code = state.auth.Code
	if code == nil then
		e.warn 'Missing Code'
		return
	end

	local previous_mode = state.mode

	local http = e.http

	e.promise {
		id = id;
		code = code;
	}
	:Then(http.get_challenge)
	:Then(function(self, challenge)
		self.challenge = challenge
	end)
	:Then(e.mode_set 'Check_Link')
	:Then(function(self)
		self.solution = e.NanoPoW.calculate(self.challenge)
	end)
	:Then(http.link)
	:Then(function(self, results)
		e.go.auth_link(id, results.token, results.session)
		e.op.authorized()
	end)
	:Else(function(self)
		if self.msg then
			e.warn(self.msg)
		end
		e.go.mode_set(previous_mode)
	end)
	:Continue()
end