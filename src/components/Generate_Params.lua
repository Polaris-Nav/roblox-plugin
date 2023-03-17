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

local util = e.util
local Mesh = e.Mesh

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
			rows = {
				{'Gravity', 	nil, '(studs/sec²)',{'params', 'Gravity'}};
				{'JumpPower', 	nil, '(studs/sec)', {'params', 'JumpPower'}};
				{'WalkSpeed', 	nil, '(studs/sec)', {'params', 'WalkSpeed'}};
				{'Radius', 		nil, '(studs)', 	{'params', 'Radius'}};
				{'Height', 		nil, '(studs)', 	{'params', 'Height'}};
			};
		});

		e.Centered {
			e.TButton {
				Text = 'Cancel';
				Size = UDim2.new(0, 100, 0, 30);
				[e.Roact.Event.Activated] = e.bind(e.go.mode_set, 'Edit')
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
					e.go.mode_set 'Edit'
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

return e.connect(function(state, props)
	return {
		session = state.auth.session;
		parts = state.objects;
		params = state.params;
	}
end)(component)