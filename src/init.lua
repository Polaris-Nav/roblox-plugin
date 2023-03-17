
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



local comps = script.components

local lib = script.Parent.lib
local Rodux 		= require(lib.Rodux)
local RoactRodux 	= require(lib.RoactRodux)
local Otter 		= require(lib.Otter)
local Roact 		= require(lib.Roact)

local create = Roact.createElement

Roact.setGlobalConfig({
    typeChecks = false;
    propValidation = true;
    elementTracing = false;
})

local function wrap(component)
	return function(...)
		return create(component, ...)
	end
end

local api = {
	Roact = Roact;
	Rodux = Rodux;
	Otter = Otter;
	connect = RoactRodux.connect;
	StoreProvider = wrap(RoactRodux.StoreProvider);
}




function api:load(name)
	if rawget(api, name) ~= nil then
		return
	end

	-- By default, search for the module in the root
	local module = script:FindFirstChild(name)

		or script.actions:FindFirstChild(name)

	local value
	if module then
		value = require(module)


	-- Otherwise it is a component / reducer
	else
		module = comps:FindFirstChild(name)
		if module then
			value = wrap(require(module))
		else
			value = wrap(name)
		end

	end


	api[name] = value
	return value
end


local is_reducer = false
function api.dispatch(action)

	if is_reducer then
		return task.spawn(api.store.dispatch, api.store, action)
	else
		is_reducer = true
		api.store:dispatch(action)
		is_reducer = false
	end
end

api.go = setmetatable({}, {
	__index = function(self, name)
		local action = api:load(name)
		local v = function(...)
			api.dispatch(action(...))
		end
		self[name] = v
		return v
	end
})

local log = api.go.messages_add


function api.bind(f, state)
	return function(...)
		return f(state, ...)
	end
end

function api.info(text)
	print(text)

	return log('info', text)

end

function api.warn(text)
	warn(text)

	return log('warning', text)

end

function api.error(text)
	warn(text)

	return log('error', text)

end

_G.PolarisNav = setmetatable(api, {__index = api.load})


local cacts = {}
api.context_actions = cacts
for i, module in ipairs(script.context_actions:GetChildren()) do
	cacts[module.Name] = require(module)
end


return api