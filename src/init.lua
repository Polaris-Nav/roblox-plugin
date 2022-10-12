
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

local reducers = {}

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

	reducers = reducers;
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

		-- names with a lowercase first character are always reducers
		local first_char = name:sub(1, 1)
		if first_char == first_char:lower() then
			value = function(action)
				if type(action) ~= 'table' then
					action = {}
				end
				action.type = name
				return api.store:dispatch(action)
			end

		-- it may be a defined or atomic component
		else
			module = comps:FindFirstChild(name)
			if module then
				value = wrap(require(module))
			else
				value = wrap(name)
			end
		end

	end


	api[name] = value
	return value
end


local is_reducer = false
local state, new
function api.rootReducer(cur_state, action)
	-- print('Action = ', action, 'State = ', state)
	local r = reducers[action.type]
	if r then
		new = {}
		for k, v in next, cur_state do
	        new[k] = v
	    end
	    is_reducer = true
	    state = cur_state
		new = r(action, cur_state, new)
		is_reducer = false
		return new
	else
		return cur_state
	end
end

function api._info(text)
	return {
		delay = 2.5;
		message = {
			type = 'info';
			Text = text;
		}
	}
end

function api._warn(text)
	return {
		delay = 5;
		message = {
			type = 'warning';
			Text = text;
		}
	}
end

function api._error(text)
	return api.addMessage {
		delay = 5;
		message = {
			type = 'error';
			Text = text;
		}
	}
end



function api.info(text)
	print(text)

	if is_reducer then
		return api.reducers.addMessage(api._info(text), state, new)
	else
		return api.addMessage(api._info(text))
	end

end

function api.warn(text)
	warn(text)

	if is_reducer then
		return api.reducers.addMessage(api._warn(text), state, new)
	else
		return api.addMessage(api._warn(text))
	end

end

function api.error(text)
	warn(text)

	if is_reducer then
		return api.reducers.addMessage(api._error(text), state, new)
	else
		return api.addMessage(api._error(text))
	end

end

return setmetatable(api, {__index = api.load})