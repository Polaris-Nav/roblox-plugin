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
					return e.begin {}
				end
			};
		});
	})
end

function e.reducers.begin(action, old, new)
	if not old.mode == 'Welcome' then
		return old
	elseif not old.token then
		new.mode = 'Auth'
	elseif #old.meshes == 0 then
		new.mode = 'Generate'
	else
		new.mode = 'Edit'
	end
	return new
end

return component