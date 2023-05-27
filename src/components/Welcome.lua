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
		Name = script.Name;
	}, {
		e.Pane({
			Position = UDim2.new(0.5, 0, 0.5, 0);
			AnchorPoint = Vector2.new(0.5, 0.5);
			Size = UDim2.new(1, 0, 1, -120);
		}, {
			e.UISizeConstraint {
				MaxSize = Vector2.new(420, 420);
				MinSize = Vector2.new(0, 0);
			};
			e.ImageLabel({
				Image = 'rbxassetid://9037064588';
				Size = UDim2.new(1, 0, 1, 0);
				Position = UDim2.new(0.5, 0, 0.5, 0);
				AnchorPoint = Vector2.new(0.5, 0.5);
				BackgroundTransparency = 1;
			}, {
				e.UIAspectRatioConstraint {
					AspectRatio = 1;
					AspectType = Enum.AspectType.ScaleWithParentSize;
				};
			});
			e.TButton {
				Text = 'Begin';
				Position = UDim2.new(0.5, 0, 1, 20);
				Size = UDim2.new(0, 100, 0, 40);
				AnchorPoint = Vector2.new(0.5, 0);
				[e.Roact.Event.Activated] = function(rbx)
					if self.props.has_token and self.props.has_id then
						if self.props.has_session then
							return e.op.refresh()
						else
							return e.op.login()
						end
					end
					e.go.mode_set 'Begin_Link'
				end
			};
		});
	})
end

return e.connect(function(state, props)
	return {
		has_token = state.auth.token and true or false;
		has_session = state.auth.session and true or false;
		has_id = state.auth.UserId and true or false;
	}
end)(component)