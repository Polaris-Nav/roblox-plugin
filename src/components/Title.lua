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
	return e.Pane({
		BackgroundColor3 = props.colors.Background;
		Size = UDim2.new(1, 0, 0, 27);
	}, {
		e.TLabel({
			Text = props.Text;
			TextSize = 19;
			TextColor3 = props.colors.BrightText;
			Size = UDim2.new(0, 0, 1, 0);
			Position = UDim2.new(0.5, 0, 0, 1);
			AnchorPoint = Vector2.new(0.5, 0);
			BackgroundTransparency = 1;
			AutomaticSize = Enum.AutomaticSize.X;
		})
	})
end

return e.connect(function(state)
	return {
		colors = state.colors
	}
end)(component)