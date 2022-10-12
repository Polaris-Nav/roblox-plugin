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

local function selectParams(state, props, fields)
	local result = {}
	for i, key in ipairs(fields) do
		result[key] = state.params[key]
	end
	return result
end

local component = e.Roact.PureComponent:extend(script.Name)

function component:render()
	return e.Context({
		Name = script.Name;
	}, {
		e.Line {
			e.TLabel {
				Text = 'Review and edit the environment and agent variables.';
				Size = UDim2.new(1, 0, 0, 0);
				AutomaticSize = Enum.AutomaticSize.Y;
			};

			e.UIPadding {
				PaddingTop = UDim.new(0, 20);
				PaddingRight = UDim.new(0, 20);
				PaddingLeft = UDim.new(0, 20);
			};
		};
		
		e.Rows({
			Name = 'Properties';
			select = selectParams;
			onChanged = e.setParams;
			rows = {
				{'Gravity', nil, '(studs/sec²)'};
				{'JumpPower', nil, '(studs/sec)'};
				{'WalkSpeed', nil, '(studs/sec)'};
				{'Radius', nil, '(studs)'};
				{'Height', nil, '(studs)'};
			};
		});

		e.Centered {
			e.TButton {
				Text = 'Cancel';
				Size = UDim2.new(0, 100, 0, 30);
				[e.Roact.Event.Activated] = function(obj, input, clicks)
					e.cancelGeneration {}
				end;
			};

			e.MainTButton {
				Text = 'Continue';
				Size = UDim2.new(0, 100, 0, 30);
				[e.Roact.Event.Activated] = function(obj, input, clicks)
					e:load 'mesh_from_parts'
					e.promise {
						session = self.props.session;
						mesh = Mesh.from_parts(self.props.parts);
						params = self.props.params;
					}
					:Then(e.http.generate)
					:Continue()
					e.finishGeneration {}
				end;
			};

			e.UIListLayout {
				FillDirection = Enum.FillDirection.Horizontal;
				Padding = UDim.new(0, 20);
			};
		};

		e.UIListLayout {
			FillDirection = Enum.FillDirection.Vertical;
			Padding = UDim.new(0, 20);
		};
	})
end

function e.reducers.finishGeneration(action, old, new)
	new.mode = 'Edit'
	return new
end

function e.reducers:setParams(old, new)
	local t = {}
	for k, v in next, old.params do
		t[k] = v
	end
	for i, v in ipairs(self.values) do
		t[v[1]] = v[2]
	end
	new.params = t
	return new
end

return e.connect(function(state, props)
	return {
		session = state.auth.session;
		parts = state.generation_objects;
		params = state.params;
	}
end)(component)