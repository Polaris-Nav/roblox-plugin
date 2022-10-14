-- Polaris-Nav, advanced pathfinding as a library and service
-- Copyright (C) 2021 Tyler R. Herman-Hoyer
-- tyler@hoyerz.com
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <https://www.gnu.org/licenses/>.

local e = require(script.Parent)

local http = game:GetService 'HttpService'

local api = {}

local timeout = 120
local inf = math.huge

local ERR_TIMED_OUT = 'Request timed out at %d seconds.'
local ERR_LATE = 'Response arrived late (after %d seconds).'
local ERR_HTTP = 'Request received HTTP %d %s "%s"'
local ERR_RBX = 'Request received an error: "%s"'

local LL = {}
LL.prev = LL
LL.next = LL

local Request = {}

-- Default error handler. May be called multiple times as errors happen.
function Request:default_throw(args)
	-- Emit if late
	if not self.is_active then
		local flight_time = self.finish_t - self.start_t
		if self.success == nil then
			e.warn(ERR_TIMED_OUT:format(flight_time))
		else
			e.warn(ERR_LATE:format(flight_time))
		end
	end

	-- Emit if there was an error response
	local r = self.response
	if self.success then
		-- lua error after request completed
		if r.Success then
			e.warn(self.msg)
		-- HTTP network error
		elseif r.StatusCode == 401 and r.Body == "Session has expired" then
			local auth = e.store:getState().auth
			return api.refresh {
				token = auth.token;
				id = auth.UserId;
				session = auth.session;
			}:Then(function (p, session)
				e.set_session {
					session = session;
				}
				self:Stop()
				return self.predecessor:RepeatAsync()
			end)
		else
			e.warn(ERR_HTTP:format(
				r.StatusCode,
				r.StatusMessage,
				r.Body
			))
		end
	-- Roblox network error
	elseif self.success == false then
		e.warn(ERR_RBX:format(r))

	-- lua errors before request was sent
	else
		e.warn(self.msg)
	end

	-- Emit where the request was made
	print(self.traceback)

	-- Continue additional error handlers
	return self:Continue(args, self.msg)
end

-- Sends a request and waits for the response
function Request:exec()
	-- enqueue the request
	self.next = LL
	self.prev = LL.prev
	self.next.prev = self
	self.prev.next = self

	-- send the request
	self.start_t = tick()

	self.success, self.response = pcall(http.RequestAsync, http, self.args)
	self.finish_t = tick()



	if self.is_active then
		self.prev.next = self.next
		self.next.prev = self.prev
	elseif not self.args.accept_late then
		return self:Throw()
	end

	if self.success and self.response.Success then
		return self:Continue()
	else
		return self:Throw()
	end
end

local function encode_solution(s)
	e:load 'save_data'

	local s_buf = {}
	e.util.save(s_buf, s, e.format.Solution, {})
	s = e.base64.encode_str(table.concat(s_buf))

	return s
end

local function decode_challenge(c)
	e:load 'load_data'
	return e.util.load(e.base64.decode_str(c),
		1, e.format.Challenge, {}
	)
end

-- Create, enqueue, and send a new request
local function req(args)
	local req = setmetatable({
		promise = nil;
		success = nil;
		response = nil;
		args = args;
		next = nil;
		prev = nil;
		start_t = inf;
		is_active = true;
		traceback = debug.traceback(nil, 2);
	}, Request)

	-- Promise for handling errors / responses
	req.promise = e.promise(req)
	:Then(Request.exec)
	:Else(Request.default_throw)

	return req.promise
end

function api:get_challenge()
	return req {
		Url = e.CFG.url .. '/v1/challenge';
		Method = 'GET';
	}
	:Then(function(self)
		local body = http:JSONDecode(self.response.Body)
		local challenge = decode_challenge(body.challenge)
		return self:Continue(challenge)
	end)
end

function api:create_account()
	return req {
		Url = e.CFG.url .. '/v1/account';
		Method = 'POST';
		Headers = {
			session = self.session;
		};
		Body = http:JSONEncode {
			name = self.name;
		};
	}:Then(function(self)
		local body = http:JSONDecode(self.response.Body)
		return self:Continue(body.id)
	end)
end

function api:link()
	self.solution = encode_solution(self.solution)
	return req {
		Url = e.CFG.url .. '/v1/account/' .. self.id .. '/link';
		Method = 'POST';
		Headers = {
			solution = self.solution;
		};
		Body = http:JSONEncode {
			code = self.code;
		};
	}:Then(function(self)
		local body = http:JSONDecode(self.response.Body)
		return self:Continue {
			token = body.token;
			session = body.session;
		}
	end)
end

function api:login()
	self.solution = encode_solution(self.solution)
	return req {
		Url = e.CFG.url .. '/v1/account/' .. self.id;
		Method = 'POST';
		Headers = {
			solution = self.solution;
		};
		Body = http:JSONEncode {
			token = self.token;
		};
	}:Then(function(self)
		local body = http:JSONDecode(self.response.Body)
		return self:Continue(body.session)
	end)
end

function api:refresh()
	return req {
		Url = e.CFG.url .. '/v1/account/' .. self.id .. '/refresh';
		Method = 'POST';
		Headers = {
			session = self.session;
		};
		Body = http:JSONEncode {
			token = self.token;
		};
	}:Then(function(self)
		local body = http:JSONDecode(self.response.Body)
		return self:Continue(body.session)
	end)
end

function api:generate()
	e:load 'mesh_save'
	local F = e.format
	local util = e.util
	local data = {}
	util.save(data, {
		params = self.params;
		mesh = self.mesh;
	}, F.MeshReq, {})
	local signature = 'Polaris-Nav'
	return req(setmetatable({
		Url = e.CFG.url .. '/v1/generate';
		Method = 'POST';
		Headers = {
			session = self.session;
		};
		Body = signature .. util.encode(table.concat(data));
	}, {
		__index = {
			accept_late = true;
		}
	}))
	:Then(function(self)
		e.info 'Generation job submitted.'

		local res = self.response
		local data = res.Body
		if data:sub(1, #signature) ~= signature then
			e.warn 'The received file is not a mesh'
			return
		end

		e:load 'mesh_load'
		data = util.decode(data:sub(#signature + 1, -1))
		if data == nil then
			e.warn 'Unable to load the received mesh. This is likely a bug.'
			return
		end

		e.info 'Mesh Received.'
		local save = util.load(data, 1, F.MeshSave, {})
		local v = save.version
		if v < F._VERSION then
			return e.warn(
				'The received mesh is in an older version format.'
					.. ' Server is v' .. v
					.. ' while client is v' .. F._VERSION)
		elseif v > F._VERSION then
			return e.warn(
				'The received mesh is in a newer version format.'
					.. ' Server is v' .. v
					.. ' while client is v' .. F._VERSION)
		end

		local nonconvex = {}
		for i, surface in ipairs(save.mesh.surfaces) do
			if not surface:is_convex() then
				nonconvex[#nonconvex + 1] = i
			end
		end
		if #nonconvex > 0 then
			e.warn('Received mesh contains non-convex surfaces. Left unfixed, these will cause errors while finding the ground, and some connections to not exist and pathfinding to silently fail. These surfaces will appear red until fixed. The nonconvex surfaces\' IDs are: ' .. table.concat(nonconvex, ', '))
		end

		save.mesh.Visible = true
		e.addMesh {
			mesh = save.mesh;
		}
	end)
end

function api:get_credits()
	return req {
		Url = e.CFG.url .. '/v1/account/' .. self.id .. '/credits';
		Method = 'GET';
		Headers = {
			session = self.session;
		};
	}:Then(function(self)
		local body = http:JSONDecode(self.response.Body)
		return self:Continue(body.credits)
	end)
end

function api:add_credits()
	return req {
		Url = e.CFG.url .. '/v1/account/' .. self.id .. '/credits';
		Method = 'PATCH';
		Headers = {
			session = self.session;
		};
		Body = http:JSONEncode {
			credits = self.credits
		}
	}:Then(function(self)
		local body = http:JSONDecode(self.response.Body)
		return self:Continue(body.credits)
	end)
end

function api:get_account()
	return req {
		Url = e.CFG.url .. '/v1/roblox/' .. self.rbx_id;
		Method = 'GET';
		Headers = {
			session = self.session;
		};
	}:Then(function(self)
		local body = http:JSONDecode(self.response.Body)
		return self:Continue(body.id)
	end)
end

function api:add_roblox()
	return req {
		Url = e.CFG.url .. '/v1/account/' .. self.id .. '/roblox';
		Method = 'PUT';
		Headers = {
			session = self.session;
		};
		Body = http:JSONEncode {
			rbx_id = tostring(self.rbx_id)
		};
	}
end

function api:begin_link()
	return req {
		Url = e.CFG.url .. '/v1/account/' .. self.id .. '/link';
		Method = 'GET';
		Headers = {
			session = self.session;
		};
	}:Then(function(self)
		local body = http:JSONDecode(self.response.Body)
		return self:Continue(body.code)
	end)
end

-- Event loop for timing out requests
task.spawn(function()
	while true do
		local t = tick()
		local cur = LL.next
		while cur ~= LL and t - cur.start_t > timeout do
			cur.is_active = false
			cur.promise:ThrowAsync()
			cur = cur.next
		end
		LL.next = cur
		cur.prev = LL

		wait()
	end
end)

return api
