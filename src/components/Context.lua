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

local component = e.Roact.Component:extend(script.Name)

function component:init()
	self.x_goal = 0
	self.x_motor = e.Otter.createSingleMotor(self.x_goal)
	self.x, self.set_x = e.Roact.createBinding(self.x_goal)
	self.x_motor:onStep(self.set_x)
end

function component:render()
	local x
	local show = self.props.mode == self.props.Name
	if show then
		-- print('showing ' .. self.props.Name)
		x = 0
	else
		x = 1
	end

	if x ~= self.x_goal then
		self.x_goal = x
		self.x_motor:setGoal(e.Otter.spring(self.x_goal))
	end
	return e.Pane({
		Size = UDim2.new(1, 0, 1, 0);
		Position = self.x:map(function(cur_x)
            return UDim2.new(cur_x, 0, 0, 0)
        end);
	}, self.props[e.Roact.Children])
end

function component:willUnmount()
	self.x_motor:stop()
end

return e.connect(function(state, props)
	return {
		mode = state.mode;
	}
end)(component)