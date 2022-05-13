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
	local txt
	if props.type == 'error' then
		txt = props.colors.ErrorText;
	elseif props.type == 'warning' then
		txt = props.colors.WarningText;
	else
		txt = props.colors.InfoText;
	end
	return e.Pane({
		Size = UDim2.new(1, 0, 0, 0);
		AutomaticSize = Enum.AutomaticSize.Y;
		BackgroundColor3 = props.colors.Dark;
	}, {
		e.TLabel {
			Text = props.Text;
			Size = UDim2.new(1, -40, 0, 0);
			Position = UDim2.new(0, 20, 0, 0);
			AutomaticSize = Enum.AutomaticSize.Y;
			TextColor3 = txt;
			BackgroundTransparency = 1;
		};
		e.UIPadding {
			PaddingTop = UDim.new(0, 10);
			PaddingBottom = UDim.new(0, 10);
		}
	});
end

return e.connect(function(state)
	return {
		colors = state.colors
	}
end)(component)