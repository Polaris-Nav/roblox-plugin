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

local use_local = false
local use_dev = false
local use_test = true
local mode = use_dev and 'dev' or use_test and 'test' or 'api'
local url = use_local and 'http://192.168.1.158' or ('https://' .. mode .. '.Polaris-Nav.com')

return {
	DEFAULT_COLOR = Color3.new(0.6, 1, 0.6);
	DEFAULT_TRANS = 0.5;

	SELECTED_COLOR = Color3.new(1, 0.6, 0.6);
	SELECTED_TRANS = 0;

	HOVERED_COLOR = Color3.new(0.6, 0.6, 1);

	DEFAULT_CONN_COLOR = Color3.new(0.6, 0.6, 1);

	DIST_SAME_VERT = 0.01;

	url = url;
}