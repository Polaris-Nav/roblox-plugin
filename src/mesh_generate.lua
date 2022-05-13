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

local util = e.util
local Mesh = e.Mesh

local signature = 'Polaris-Nav'

function Mesh.generate(token, params, parts)
	e:load 'mesh_from_parts'
	local mesh = Mesh.from_parts(parts)

	e:load 'mesh_to_save'
	local F = e.format
	local data = {}
	util.save(data, {
		params = params;
		mesh = mesh;
	}, F.MeshReq, {})
	local msg = signature .. util.encode(table.concat(data))

	local response = e.http.req {
		path = 'v1/mesh/generate';
		msg = msg;
		token = token;
		accept_late = true;
		handler = function(res, node)
			if res then
				e.info 'Generation job submitted.'

				if res.StatusCode == 200 then
					if not res.Body or res.Body == '' then
						e.warn 'Did not receive a response body. This is likely a bug.'
						return
					end

					local data = res.Body
					if data:sub(1, #signature) ~= signature then
						e.warn 'The received file is not a mesh'
						return
					end

					e:load 'mesh_from_save'
					data = util.decode(data:sub(#signature + 1, -1))
					if data == nil then
						e.warn 'Unable to load the received mesh. This is likely a bug.'
						return
					end

					e.info 'Mesh Received.'
					e:load 'mesh_from_save'
					local save = util.load(data, 1, F.MeshSave, {})
					local v = save.version
					if v < F._VERSION then
						return e.warn(
							'The received mesh is in an older version format.'
								.. ' Server is v' .. v
								.. ' while client is v' .. F._VERSION)
					elseif v > F._VERSION then
						return e.warn(
							'The received mesh is in a newer version format.'
								.. ' Server is v' .. v
								.. ' while client is v' .. F._VERSION)
					end

					save.mesh.Visible = true
					e.addMesh {
						mesh = save.mesh;
					}
				else
					e.warn(('Failed to generate mesh: %s %s %s')
						:format(res.StatusCode, res.StatusMessage, res.Body))
				end
			end
		end
	}
end

return true