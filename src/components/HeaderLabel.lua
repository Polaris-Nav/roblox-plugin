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
	return e.TLabel({
		Text = props.Text;
		Font = Enum.Font.SourceSansSemibold;
		TextColor3 = props.color;
		Size = UDim2.new(1, -27, 1, -2);
		Position = UDim2.new(0, 26, 0, 1);
		BackgroundTransparency = 1;
	})
end

return e.connect(function(state)
	return {
		color = state.colors.BrightText;
	}
end)(component)