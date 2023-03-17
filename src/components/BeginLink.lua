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
		Name = 'BeginLink'
	}, {
		e.Pane({
			Size = UDim2.new(1, 0, 0, 0);
			AutomaticSize = Enum.AutomaticSize.Y;
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
		}, {
			e.Title {
				Text = 'Link Your Roblox Account';
			};
			e.Subtitle {
				Text = 'Visit the Polaris-Nav Center and enter your user id and authentication code here.';
			};
			e.Pane({
				Size = UDim2.new(1, 0, 0, 27);
				AutomaticSize = Enum.AutomaticSize.Y;
			}, {
				e.TLabel {
					Text = 'Polaris-Nav Center:';
					Size = UDim2.new(0, 150, 1, 0);
				};
				e.TBox {
					Text = 'https://roblox.com/games/9860827919';
					TextEditable = false;
					TextTruncate = Enum.TextTruncate.None;
					TextWrapped = true;
					Size = UDim2.new(1, -150, 0, 0);
					Position = UDim2.new(0, 150, 0, 0);
					AutomaticSize = Enum.AutomaticSize.Y;
				};
			});
			e.Rows {
				Name = 'One-time Pass';
				rows = {
					{'UserId', 1234, nil, {'auth', 'UserId'}};
					{'Code', 123456789, nil, {'auth', 'Code'}};
				};
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
								'If you do not link your account, you will not be able to automatically generate a mesh. Instead, you will have to manually create your mesh.',
								e.op.authorized
							)
						end;
					};
					e.MainTButton {
						Text = 'Continue';
						Size = UDim2.new(0, 100, 1, 0);
						[e.Roact.Event.Activated] = e.op.link
					};
					e.UIListLayout {
						FillDirection = Enum.FillDirection.Horizontal;
						Padding = UDim.new(0, 20);
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