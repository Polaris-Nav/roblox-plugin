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
	return e.Merged {
		element = e.TextLabel;
		default = {
			TextSize = 15;
			TextWrapped = true;
			Font = Enum.Font.SourceSans;
			TextColor3 = props.colors.MainText;
			BackgroundColor3 = props.colors.MainBackground;
			TextXAlignment = Enum.TextXAlignment.Left;
			BorderSizePixel = 0;
		};
		override = props;
	}
end

return e.connect(function(state, props)
	return {
		colors = state.colors
	}
end)(component)