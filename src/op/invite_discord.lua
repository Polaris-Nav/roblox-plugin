local e = _G.PolarisNav
local httpService = game:GetService("HttpService")

return function ()
	local Url = "http://127.0.0.1:6463/rpc?v=1"
	local Headers = {
		Origin = 'https://discord.com'
	}
	local Body = httpService:JSONEncode({
		cmd = 'INVITE_BROWSER',
		nonce = httpService:GenerateGUID(false),
		args = {code = "edT28dw7"}
	})

	httpService:PostAsync(Url, Body, Enum.HttpContentType.ApplicationJson, false, Headers)
end