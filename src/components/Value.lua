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

local component = e.Roact.Component:extend(script.Name)

function component:init(props)
	self.onChanged = e.util.bind(self.onChanged, self)
	self.onFocused = e.util.bind(self.onFocused, self)
	self.onActivated = e.util.bind(self.onActivated, self)

	local initial = props[props.name]
	if initial == nil then
		initial = props.hint
	end
	self.state = {
		focused = false;
		value = initial;
	}
end

function component:set(value)
	return self.props.onChanged {
		values = {
			{self.props.name, value};
		}
	}
end

function component:onActivated(obj)
	local v = not self.state.value
	self:set(v);
	self:setState {
		value = v;
	}
end

function component:onChanged(obj)
	local v = obj.Text

	local ty = type(self.state.value)
	if v == '' then
		self:set(nil)
		v = self.props.hint
		if v == nil then
			if ty == 'string' then
				v = ''
			elseif ty == 'number' then
				v = 0
			end
		end
	else
		if ty == 'number' then
			v = tonumber(v)
		end

		if v ~= nil then
			self:set(v)
		else
			v = self.state.value
		end
	end

	-- Since the value was changed from outside Roact,
	-- We need to manually change it.
	obj.Text = ty == 'number' and tostring(v) or v

	-- When rendering, we'll have to handle this
	-- manually from now on
	self.obj = obj

	self:setState {
		focused = false;
		value = v;
	}
end

function component:onFocused(obj)
	self:setState {
		focused = true;
	}
end

-- If the current value or hint get updated, update the state
function component:willUpdate(newProps, newState)
	-- If the current value is updated and should be shown
	local old = self.props[self.props.name]
	local new = newProps[newProps.name]
	if new ~= nil then
		if new ~= old then
			newState.value = new
		end
		return
	end

	-- If the hint is updated and the current value shouldn't be shown
	old = self.props.hint
	new = newProps.hint
	if new ~= old then
		newState.value = new
	end
end

function component:render()
	local colors = self.props.colors
	local name = self.props.name

	local clear = false
	local color = colors.MainText
	if not self.state.focused and self.props[name] == nil then
		clear = true
		color = colors.DimmedText
	end

	local value = self.state.value
	local ty = type(value)
	if ty == 'boolean' then
		return e.Checkbox {
			Position = UDim2.new(0, 2, 0, 1);
			Size = UDim2.new(1, -4, 1, -2);
			value = value;
			[e.Roact.Event.Activated] = self.onActivated;
		};
	end

	return e.TBox {
		Position = UDim2.new(0, 2, 0, 1);
		Size = UDim2.new(1, -4, 1, -2);
		Text = value;
		TextColor3 = color;
		ClearTextOnFocus = clear;
		[e.Roact.Event.FocusLost] = self.onChanged;
		[e.Roact.Event.Focused] = self.onFocused;
	};
end

return component