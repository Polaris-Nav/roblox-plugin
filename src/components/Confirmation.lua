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

local component = e.Roact.Component:extend(script.Name)

function component:init(props)
	self.y_goal = 0
	self.a_goal = 1
	self.t_goal = 1
	self.y, self.set_y = e.Roact.createBinding(self.y_goal)
	self.a, self.set_a = e.Roact.createBinding(self.a_goal)
	self.t, self.set_t = e.Roact.createBinding(self.t_goal)
	self.motor = e.Otter.createGroupMotor {
		y = self.y_goal;
		a = self.a_goal;
		t = self.t_goal;
	}
	self.motor:onStep(function(values)
		self.set_y(values.y)
		self.set_a(values.a)
		self.set_t(values.t)
	end)
end

function component:render()
	local y, a, t
	if self.props.show then
		if self.y_goal == 0 then
			y = 0.5
			a = 0.5
			t = 0.5
		end
	elseif self.y_goal == 0.5 then
		y = 0
		a = 1
		t = 1
	end
	if y and y ~= self.y_goal then
		self.y_goal = y
		self.a_goal = a
		self.t_goal = t
		self.motor:setGoal{
			y = e.Otter.spring(self.y_goal);
			a = e.Otter.spring(self.a_goal);
			t = e.Otter.spring(self.t_goal);
		}
	end
	return e.Pane({
		BackgroundColor3 = Color3.new(0, 0, 0);
		BackgroundTransparency = self.a;
		Size = self.a:map(function(cur_a)
			return UDim2.new(1, 0, cur_a < 1 and 1 or 0, 0);
		end);
	}, {
		e.Pane({
			Position = self.y:map(function(cur_y)
				return UDim2.new(0.5, 0, cur_y, 0);
			end);
			AnchorPoint = self.a:map(function(cur_a)
				return Vector2.new(0.5, cur_a);
			end);
			Size = UDim2.new(1, 0, 0, 0);
			AutomaticSize = Enum.AutomaticSize.Y;
		}, {
			e.Header {
				Text = 'Confirmation';
				Size = UDim2.new(1, 0, 0, 27);
				TextXAlignment = Enum.TextXAlignment.Center;
			};
			e.TLabel {
				Text = self.props.text or '';
				Size = UDim2.new(1, 0, 0, 0);
				AutomaticSize = Enum.AutomaticSize.Y;
				TextXAlignment = Enum.TextXAlignment.Center;
			};
			e.Pane({
				Size = UDim2.new(1, 0, 0, 27);
			}, {
				e.Pane({
					AutomaticSize = Enum.AutomaticSize.X;
					AnchorPoint = Vector2.new(0.5, 0);
					Position = UDim2.new(0.5, 0, 0, 0);
					Size = UDim2.new(0, 0, 0, 0);
				}, {
					e.MainTButton {
						Text = 'Cancel';
						Size = UDim2.new(0, 100, 0, 27);
						[e.Roact.Event.Activated] = function()
							e.cancel {}
						end
					};
					e.TButton {
						Text = 'Okay';
						Size = UDim2.new(0, 100, 0, 27);
						[e.Roact.Event.Activated] = function()
							e.confirm {}
						end
					};
					e.UIListLayout {
						FillDirection = Enum.FillDirection.Horizontal;
						Padding = UDim.new(0, 20);
					};
				});
			});
			e.UIListLayout {
				FillDirection = Enum.FillDirection.Vertical;
				Padding = UDim.new(0, 20);
			};
			e.UIPadding {
				PaddingBottom = UDim.new(0, 20);
			};
		});
	})
end

local function on(name, old, new)
	local action = old.confirm and old.confirm[name]
	if action then
		return e.reducers[action.type](action, old, new)
	else
		return new
	end
end

function e.reducers.requireConfirm(action, old, new)
	new.confirm = {
		text = action.text;
		onConfirm = action.onConfirm;
		show = true;
	}
	return on('onCancel', old, new)
end

function e.reducers.confirm(action, old, new)
	new.confirm = {
		text = old.confirm.text;
		onConfirm = old.confirm.onConfirm;
		show = false;
	}
	return on('onConfirm', old, new)
end

function e.reducers.cancel(action, old, new)
	new.confirm = {
		text = old.confirm.text;
		onConfirm = old.confirm.onConfirm;
		show = false;
	}
	return on('onCancel', old, new)
end

return e.connect(function(state, props)
	return state.confirm
end)(component)