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
	return e.TButton {
		Text = props.Text;
		Size = UDim2.new(1, 0, 0, 27);
		BorderSizePixel = 0;
		TextSize = 15;
		TextTruncate = Enum.TextTruncate.AtEnd;
		Font = Enum.Font.SourceSans;
		TextXAlignment = Enum.TextXAlignment.Center;
		BackgroundColor3 = props.is_selected and props.hover or props.bg;
		BorderColor3 = props.border;
		AutoButtonColor = false;
		[e.Roact.Event.Activated] = props.onActivated;
		[e.Roact.Event.MouseEnter] = function(obj)
			obj.BackgroundColor3 = props.hover;
		end;
		[e.Roact.Event.MouseLeave] = function(obj)
			if props.is_selected then
				return
			end
			obj.BackgroundColor3 = props.bg;
		end;
		[e.Roact.Event.MouseButton1Down] = function(obj)
			obj.BackgroundColor3 = props.down;
		end;
		[e.Roact.Event.MouseButton1Up] = function(obj)
			if props.is_selected then
				obj.BackgroundColor3 = props.hover;
			else
				obj.BackgroundColor3 = props.bg;
			end
		end;
	};
end

return e.connect(function(state, props)
	local c = state.colors
	return {
		bg = c.MainBackground;
		border = c.Border;
		hover = c.Light;
		down = c.Dark;
	}
end)(component)