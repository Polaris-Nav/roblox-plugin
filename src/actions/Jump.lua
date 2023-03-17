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

local Jump = {
	type = 'Jump';
}
Jump.MT = {__index = Jump}
local Action_MT = {}

local empty = {}

function Action_MT:__call(connection)
	local to = next(connection.to)
	local at = next(connection.at)
	local v = to.v3 - at.v3
	connection.x_distance = math.sqrt(v.X * v.X + v.Z * v.Z)
	connection.y_distance = v.Y
	return setmetatable(connection, Jump.MT)
end

function Jump.MT:__tostring()
	return '<Action type=' .. Jump.type .. '>'
end

function Jump:consider(agent, at, at_t_min, at_t_opt)
	if not (self.at[at] or self.bidirectional and self.to[at]) then
		return empty
	end

	local to = next(self.to)
	local cost = (at.v3 - to.v3).Magnitude
	local dt = cost / agent.speed
	return {
		{
			perform = self.perform;
			cost = dt;
			to = next(self.to);
			to_t = at_t_min + dt
		}
	}
end

function Jump.perform(choice, agent)
	local human = agent.humanoid
	human.Jump = true
	human:MoveTo(choice.to.v3)
	human.MoveToFinished:Wait()
end

function Jump:create(parent)
	if self.line then
		return
	end
	local at = next(self.at).v3
	local to = next(self.to).v3
	self.line = e.util.create_line(at, to - at, parent)
end

function Jump:update()
	local at = next(self.at).v3
	local to = next(self.to).v3
	self.line.Size = Vector3.new(0.05, 0.05, (to - at).Magnitude)
	self.line.CFrame = CFrame.new((at + to) / 2, to)
end

function Jump:destroy()
	if not self.line then
		return
	end
	if self.line.Parent ~= nil then
		self.line:Destroy()
	end
	self.line = nil
end

return setmetatable(Jump, Action_MT)