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
		Name = 'Refresh'
	}, {
		e.Pane({
			Size = UDim2.new(1, 0, 0, 0);
			AutomaticSize = Enum.AutomaticSize.Y;
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
		}, {
			e.Title {
				Text = 'Session Refresh';
			};
			e.Subtitle {
				Text = 'Attempting to refresh your session . . .';
			};
			e.Pane({
				Size = UDim2.new(1, 0, 0, 27);
			}, {
				e.Pane({
					Size = UDim2.new(0, 0, 1, 0);
					AutomaticSize = Enum.AutomaticSize.X;
					AnchorPoint = Vector2.new(0.5, 0);
					Position = UDim2.new(0.5, 0, 0, 0);
				}, {
					e.TButton {
						Text = 'Skip';
						Size = UDim2.new(0, 100, 1, 0);
						[e.Roact.Event.Activated] = function(obj, input, clicks)
							e.go.confirm_show(
								'If you do not login, you will not be able to automatically generate a mesh. Instead, you will have to manually create your mesh.',
								e.op.authorized
							)
						end;
					};
				});
			});
			e.UIPadding {
				PaddingLeft = UDim.new(0, 20);
				PaddingRight = UDim.new(0, 20);
			};
			e.UIListLayout {
				FillDirection = Enum.FillDirection.Vertical;
				Padding = UDim.new(0, 20);
			};
		})
	})
end

return component