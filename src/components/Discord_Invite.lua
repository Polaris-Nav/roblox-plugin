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

local component = e.Roact.PureComponent:extend(script.Name)

function component:render()
	return e.Context({
		Name = script.Name
	}, {
		e.Line {
			e.HeaderLabel {
				Text = "Discord Invite";
				TextXAlignment = Enum.TextXAlignment.Center;
			}
		};
		e.Line {
			e.TLabel {
				Text = "Oops! Looks like you don't have the Discord Client installed or open! Copy the invite link to our Discord Server instead:";
				TextWrapped = true;
				Size = UDim2.new(1, 0, 0, 0);
				AutomaticSize = Enum.AutomaticSize.Y;
			};
			e.TBox {
				Text = 'https://discord.gg/edT28dw7';
				TextEditable = false;
				TextTruncate = Enum.TextTruncate.None;
				TextWrapped = true;
				Size = UDim2.new(1, 0, 0, 0);
				Position = UDim2.new(0,0,1,10);
				AutomaticSize = Enum.AutomaticSize.Y;
			};
		};
		e.Line {
			e.TButton {
				Size = UDim2.new(0, 70, 0, 24);
				Position = UDim2.new(1, -70, 0, 0);
				TextSize = 10;
				Text = 'Back';
				[e.Roact.Event.Activated] = e.bind(e.go.mode_set, 'Edit');
			};
		};
		e.UIPadding {
			PaddingTop = UDim.new(0, 20);
			PaddingBottom = UDim.new(0, 20);
			PaddingLeft = UDim.new(0, 20);
			PaddingRight = UDim.new(0, 20);
		};
		e.UIListLayout {
			FillDirection = Enum.FillDirection.Vertical;
			Padding = UDim.new(0, 20);
		};
	})
end

return component