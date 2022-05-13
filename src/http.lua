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

local http = game:GetService 'HttpService'

local api = {}

local timeout = 120
local inf = math.huge

local LL = {}
LL.prev = LL
LL.next = LL

local function exec(node)
	local args = node.args
	
	node.start_t = tick()
	local success, response = pcall(http.RequestAsync, http, {
		Url = e.CFG.url .. args.path;
		Method = 'POST';
		Headers = {
			token = args.token;
		};
		Body = args.msg;
	})
	node.finish_t = tick()

	if node.is_active then
		node.prev.next = node.next
		node.next.prev = node.prev
	elseif not args.accept_late then
		return
	end

	if success and response.Success then
		if not node.is_active then
			local err_msg = 'Recieved response timed out after %d seconds.'
			e.warn(err_msg:format(node.finish_t - node.start_t))
			if not args.accept_late then
				return
			end		
		end
		return args.handler(response, node)
	elseif success then
		local err_msg = 'Request failed; (HTTP %d %s) "%s"'
		e.warn(err_msg:format(
			response.StatusCode,
			response.StatusMessage,
			response.Body
		))
	else
		local err_msg = 'Request failed; (ROBLOX ERROR) "%s"'
		e.warn(err_msg:format(
			response
		))
	end

	return args.handler(nil)
end

function api.req(args)
	local node = {
		args = args;
		next = LL;
		prev = LL.prev;
		start_t = inf;
		is_active = true;
	}
	node.next.prev = node
	node.prev.next = node
	task.spawn(exec, node)
end

local function main()
	-- Event loop for timing out requests
	while true do
		local t = tick()
		local cur = LL.next
		while cur ~= LL and t - cur.start_t > timeout do
			e.warn 'Request timed out.'
			cur.is_active = false
			task.spawn(cur.args.handler, nil)
			cur = cur.next
		end
		LL.next = cur
		cur.prev = LL

		wait()
	end
end

task.spawn(main)

return api
