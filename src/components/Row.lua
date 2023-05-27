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

local e = _G.PolarisNav

local function component(props)
	local name = props.name
	local hint = props.hint
	local v
	if props.path then
		v = props.value
	else
		v = props.data[name]
	end

	if v == nil then
		if hint ~= nil then
			v = hint
		end
	end

	local ty = type(v)
	if hint ~= nil and ty ~= type(hint) then
		error ('value and hint type mismatch,' .. type(hint) .. ", " .. ty .. ", " .. name)
	end

	if props.units then
		name = name .. ' ' .. props.units
	end

	return e.Pane({
		Name = name;
		Size = UDim2.new(1, 0, 0, 23);
	}, {
		e.Pane({
			Size = UDim2.new(0.5, 0, 1, 0);
			BorderSizePixel = 1;
		}, {
			e.TLabel {
				Text = name;
				Position = UDim2.new(0, 26, 0, 1);
				Size = UDim2.new(1, -27, 1, -2);
			};
		});
		e.Pane({
			Position = UDim2.new(0.5, 0, 0, 0);
			Size = UDim2.new(0.5, 0, 1, 0);
			BorderSizePixel = 1;
		}, {
			props.path and e.ConnectedValue(props) or e.Value(props);
		});
	});
end

return e.connect(function(state, props)
	local cur
	if props.path then
		cur = state
		for i, key in ipairs(props.path) do
			cur = cur[key]
		end
	end
	return {
		colors = state.colors;
		value = cur;
	}
end)(component)