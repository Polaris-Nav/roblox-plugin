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

--[[
Connection:
	[method] consider(agent, at, at_t_min, at_t_opt) -> {
		{
			cost
			to_t
			to
		}
	}
	[method] perform(agent, choice) -> nil
	[method] create(parent) -> nil
	[method] destroy() -> nil
	[method] update() -> nil
	[method] save() -> string
	[method] load(str) -> nil
	[property: array] at = {}
	[property: array] to = {}
	[property: boolean] bidirectional
	[property: string] type
	[property: table] MT
]]

return {
	Jump = require(script.Jump);
}