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

local function component(props)
	local msgs = {}
	for i, msg in ipairs(props.messages) do
		msgs[i] = e.Message(msg)
	end
	msgs[#msgs + 1] = e.UIListLayout {
		FillDirection = Enum.FillDirection.Vertical;
	}
	return e.Pane({
		Size = UDim2.new(1, 0, 0, 0);
		AutomaticSize = Enum.AutomaticSize.Y;
		BackgroundTransparency = 0.5;
	}, msgs)
end

function e.reducers.addMessage(action, old, new)
	local messages = {}
	for i, v in ipairs(old.messages) do
		messages[i] = v
	end
	messages[#messages + 1] = action.message

	-- Automatic message removal
	task.delay(action.delay, function()
		e.store:dispatch {
			type = 'rmvMessage';
			message = action.message;
		}
	end)

	new.messages = messages
	return new
end

function e.reducers.rmvMessage(action, old, new)
	local messages = {}
	for i, v in ipairs(old.messages) do
		if v ~= action.message then
			messages[#messages + 1] = v
		end
	end
	new.messages = messages
	return new
end

return e.connect(function(state, props)
	return {
		messages = state.messages
	}
end)(component)