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

function component(props)
	return e.Pane({
		Size = UDim2.new(1, 0, 0, 0);
		AutomaticSize = Enum.AutomaticSize.Y;
		BorderSizePixel = 1;
		BackgroundColor3 = props.colors[
			props.is_selected and 'Light' or 'MainBackground'];
	}, {
		e.TButton {
			Text = props.Text;
			Font = Enum.Font.SourceSans;
			Position = UDim2.new(0, 26, 0, 0);
			Size = UDim2.new(1, -27, 0, 27);
			AutoButtonColor = false;
			BackgroundTransparency = 1;
			TextSize = 15;
			TextXAlignment = Enum.TextXAlignment.Left;
			[e.Roact.Event.Activated] = props.onActivated;
			[e.Roact.Event.MouseEnter] = function(obj)
				obj.Parent.BackgroundColor3 = props.colors.Light;
			end;
			[e.Roact.Event.MouseLeave] = function(obj)
				if props.is_selected then
					return
				end
				obj.Parent.BackgroundColor3 = props.colors.MainBackground;
			end;
			[e.Roact.Event.MouseButton1Down] = function(obj)
				obj.Parent.BackgroundColor3 = props.colors.Dark;
			end;
			[e.Roact.Event.MouseButton1Up] = function(obj)
				if props.is_selected then
					obj.Parent.BackgroundColor3 = props.colors.Light;
				else
					obj.Parent.BackgroundColor3 = props.colors.MainBackground;
				end
			end;
		};
	});
end

return e.connect(function(state, props)
	return {
		colors = state.colors;
	}
end)(component)