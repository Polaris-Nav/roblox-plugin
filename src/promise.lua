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

-- A new promise implementation is born!
--
-- Designed to act like continuations, it gives more control over program
-- execution to handlers. Each handler can:
--   - access promise state given at initialization
--   - return to execute the rest of the promise
--   - call Yield() and return to stop executing other handlers
--   - return another promise which is automatically executed before continuing
--     - injects callbacks to return execution back to the parent promise and escalate errors
--   - make other calls and just never return
local e = _G.PolarisNav

local OP = {
	NONE = {};
	CONTINUE = {}; -- continues current promise
	THROW = {}; -- continues error promise if exists, or warns
	REPEAT = {}; -- calls the same handler again
	RESUME = {}; -- resume parent promise execution after waiting on a promise returned from a handler
}

local function get_trace(err)
	return debug.traceback(err, 2)
end

local Static = {}
local Promise = {
	-- Indexing the promise can return values from the promise state
	__index = function(self, key)
		local value = Static[key]
		if value then
			return value
		end

		local s = rawget(self, 'state')
		return s and s[key]
	end;

	-- Trying to set undefined keys on the promise instead modifies state
	__newindex = function(self, key, value)
		self.state[key] = value
	end;

	-- Calling the promise continues it
	__call = function(self, ...)
		return self:Continue(...)
	end;
}

-- Construct a promise with the given state and callbacks
function Promise.__ctor(state, ...)
	return setmetatable({
		i = 1;
		state = state;
		is_running = false;
		after = OP.NONE;
		after_args = false;
		...
	}, Promise)
end

function Static:Then(callback)
	rawset(self, #self + 1, callback)
	return self
end

function Static:Else(callback)
	self:OnError():Then(callback)
	return self
end

function Static:OnError()
	local on_error = rawget(self, 'on_error')
	if not on_error then
		on_error = Promise.__ctor(self.state)
		rawset(self, 'on_error', on_error)
		rawset(on_error, 'predecessor', self)
	end
	return on_error
end

function Static:Silent()
	rawset(self, 'silent', true)
	return self
end

function Static:_Dispatch(op, args, msg)
	if msg ~= nil then
		rawset(self, 'msg', msg)
	end
	if self.is_running then
		self.after = op
		rawset(self, 'after_args', args)
		return
	elseif op == OP.RESUME then
		op = self.after
		local old_args = rawget(self, 'after_args')
		if old_args ~= nil then
			args = old_args
		end
	end

	local success
	while op ~= OP.NONE do
		self.after = OP.CONTINUE
		rawset(self, 'after_args', nil)

		if op == OP.NONE then
			return
		end

		if op == OP.THROW then
			local on_error = rawget(self, 'on_error')
			if not on_error then
				print 'An unhandled error occured.'
			end
			if not rawget(self, 'silent') and type(msg) == 'string' then
				warn(msg)
			end
			if on_error then
				return on_error:_Dispatch(OP.CONTINUE, args, msg)
			end
		end

		local i
		if op == OP.REPEAT then
			i = self.i - 1
		else
			i = self.i
			self.i = i + 1
		end

		-- Get the next action
		local action = rawget(self, i)
		if action then
			-- There is an action
			if type(action) == 'function' then
				-- The action can be called
				self.is_running = true
				local value
				success, value = xpcall(function()
					return action(self, args)
				end, get_trace)
				self.is_running = false
				if not success then
					self.after = OP.THROW
					rawset(self, 'after_args', args)
					msg = value
					rawset(self, 'msg', msg)
				elseif type(value) == 'table' and getmetatable(value) == Promise then
					rawset(value, 'caller', self)
					return value:_Dispatch(OP.CONTINUE)
				end
			else
				-- The action needs to be dispatched
				if action.type == nil then
					error 'Table is not an action to be dispatched'
				end
				e.dispatch(action)
			end
		else
			-- There are no more actions
			self.i = 1
			self.after = OP.NONE
			if self.predecessor then
				local caller = self.predecessor.caller
				if caller then
					caller:ThrowAsync(args, self.msg)
				end
			end
			if self.caller then
				self.caller:ResumeAsync(args)
			end
			return args
		end

		op = self.after
		args = rawget(self, 'after_args')
	end
end

function Static:ReturnAsync(...)
	return self.caller:ResumeAsync(...)
end

function Static:EscalateAsync(args)
	return self.predecessor.caller:ThrowAsync(args, rawget(self, 'msg'))
end

function Static:Continue(...)
	return self:_Dispatch(OP.CONTINUE, ...)
end

function Static:Yield()
	self.after = OP.NONE
end

function Static:ContinueAsync(...)
	return task.spawn(self._Dispatch, self, OP.CONTINUE, ...)
end

function Static:Throw(...)
	return self:_Dispatch(OP.THROW, ...)
end

function Static:ThrowAsync(...)
	return task.spawn(self._Dispatch, self, OP.THROW, ...)
end

function Static:Repeat(...)
	return self:_Dispatch(OP.REPEAT, ...)
end

function Static:RepeatAsync(...)
	return task.spawn(self._Dispatch, self, OP.REPEAT, ...)
end

function Static:Resume(...)
	return self:_Dispatch(OP.RESUME, ...)
end

function Static:ResumeAsync(...)
	return task.spawn(self._Dispatch, self, OP.RESUME, ...)
end

function Static:Reset()
	self.i = 1
end

function Static:Stop()
	self:Yield()
	self:Reset()
end

function Static:RetryAsync(...)
	self.predecessor:Reset()
	self.predecessor:ContinueAsync(...)
end

return Promise.__ctor