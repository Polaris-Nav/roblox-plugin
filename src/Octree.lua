
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




--Tyler R. Hoyer
--August 22, 2014
--Volumetric AABB Octree with Intersection Test and Commenting
--TylerRichardHoyer@gmail.com

local Octree = {}
local Octree_metatable = {__index = Octree}

--The smallest size of a cell
local MINIMUM_SIZE = 1

--Create a new Octree
--Returns a table
function Octree.Octree(x, y, z, size) 
	return setmetatable({
		x, y, z; --The center (1, 2, 3)
		
		size; --The size of the cell as power of 2 (4)
		
		{}; --The list of values inside of the cell (5)
		
		--The eight sub-cells (xyz sorted, lowest first)
		false, false, false, false; --(6, 7, 8, 9)
		false, false, false, false; --(10, 11, 12, 13)
	}, Octree_metatable)
end

--Get the index of a child
--Returns an integer or false
function Octree:child(aabb)

	--The size of the cell's children
	local children_size = 2^(self[4] - 1)
	
	--Check that the children are big enough
	if children_size < MINIMUM_SIZE then
		return false
	end

	--The cell's center point
	local x = self[1]
	local y = self[2]
	local z = self[3]

	--The min point's octant relative to the center point of the cell
	local lesser_x = aabb.min.X <= x
	local lesser_y = aabb.min.Y <= y
	local lesser_z = aabb.min.Z <= z
	
	--Check if the max and min points are in the same child
	if lesser_x == (aabb.max.X <= x) 
		and lesser_y == (aabb.max.Y <= y) 
		and lesser_z == (aabb.max.Z <= z) then
		
		--Return the child's index
		return 6 
			+ (lesser_x and 0 or 4) 
			+ (lesser_y and 0 or 2) 
			+ (lesser_z and 0 or 1)
	end

	--Return false, in multiple children
	return false
end

--Remove a value
--Returns a boolean
function Octree:remove(aabb, value)

	--If the value is in a child, get it's index
	local child_index = self:child(aabb)
	
	--Check if the value belongs in a child
	if child_index then
		local child = self[child_index]

		if not child then
			--Value's container does not exist, return cell not changed
			return false, false
		end

		--Remove the value from the child cell
		local success, child_updated = child:remove(aabb, value)

		--Check if the child can be deleted
		--Must have been updated, have no values, and have no children
		if child_updated and not next(child[5]) and not (
			child[6] or child[7] or child[8] or child[9] 
			or child[10] or child[11] or child[12] or child[13]) then
			self[child_index] = false

			--Value removed, return cell changed
			return true, true
		end

		--Value removed, return cell not changed
		return true, false
	end

	--Search the cell's values
	local values = self[5]
	for k, v in next, values do

		--Check if the value is the value that needs to be deleted
		if v == value then
			values[k] = nil

			--Value removed, return cell changed
			return true, true
		end
	end
	
	--Value not found, return cell not changed
	return false, false
end

--Add a value
--Returns nil
function Octree:add(aabb, value)

	--If the value is in a child, get it's index
	local child_index = self:child(aabb)
	
	--Check if the value belongs in a child
	if child_index then
		local child = self[child_index]

		--Create the child if it does not exist
		if not child then
			local offset = 2 ^ (self[4] - 2)
			local child_x = self[1] + (aabb.min.X <= self[1] and -offset or offset)
			local child_y = self[2] + (aabb.min.Y <= self[2] and -offset or offset)
			local child_z = self[3] + (aabb.min.Z <= self[3] and -offset or offset)
			child = Octree.Octree(child_x, child_y, child_z, self[4] - 1)
			self[child_index] = child
		end
		
		--Add the value to the child (tail call for speed, returns nil)
		return child:add(aabb, value)
	end
	
	--Add the value to this cell
	local values = self[5]
	values[aabb] = value
end

--Get values intersecting an AABB
--Returns nil, result argument contains resultant values
--Beware: this recursive function calls itself in a sub-recursive function
function Octree:intersection(aabb, result)

	--Append the values in the cell to the result
	local values = self[5]
	for key, value in next, values do
		if aabb:intersection(key) then
			result[#result + 1] = value
		end
	end

	--The center point of the cell
	local x = self[1]
	local y = self[2]
	local z = self[3]

	--The min point's octant relative to the center of the cell
	local lesser = {
		aabb.min.Z <= z,
		aabb.min.Y <= y,
		aabb.min.X <= x}

	--The true if the min and max points are in different octants
	local split = {
		lesser[1] ~= (aabb.max.Z <= z),
		lesser[2] ~= (aabb.max.Y <= y),
		lesser[3] ~= (aabb.max.X <= x)}

	--This is very complex on multiple levels. The goal is to find out what octants contain
	--the AABB defined by the min and max points. It does this by checking each axis. For each
	--axis, the min and max points can be less than, greater than, or split around the center
	--offset. Once one axis is determined, then it checks the next axis. Once all three are
	--checked, it checks the current point defined by them. If an axis is split, it checks the
	--first side for the rest of the axises, then checks the other side. It is simplest, fastest,
	--and easiest to write in a recursive function.
	local function check(current, i)

		--If the checks are done
		if i == 0 then
			local child = self[current]
			--Check if the child exists

			if child then
				--Add values contained in the child
				return child:intersection(aabb, result)
			end
			
			return result

		--Check if split
		elseif split[i] then
			--Add lesser side
			check(current, i - 1)
			--Add greater side
			return check(current + 2^(i - 1), i - 1)

		--Check if on lesser side
		elseif lesser[i] then
			--Add lesser side
			return check(current, i - 1)

		else
			--Add greater side
			return check(current + 2^(i - 1), i - 1)
		end
	end

	--Start the checks. Returns nil
	return check(6, 3)
end

return Octree

