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

local accountSections = {
	Linked = {
		e.HeaderBackground({}, {
			e.HeaderLabel {
				Text = 'Account';
			};
			e.TButton {
				Size = UDim2.new(0, 70, 1, -2);
				Position = UDim2.new(1, -70 -20 -70, 0, 1);
				TextSize = 10;
				Text = 'Unlink';
				[e.Roact.Event.Activated] = e.op.unlink;
			};
			e.TButton {
				Size = UDim2.new(0, 70, 1, -2);
				Position = UDim2.new(1, -70, 0, 1);
				TextSize = 10;
				Text = 'Logout';
				[e.Roact.Event.Activated] = e.op.logout;
			};
		});
		e.UIListLayout {
			FillDirection = Enum.FillDirection.Vertical;
		};
	};
	Guest = {
		e.HeaderBackground({}, {
			e.HeaderLabel {
				Text = 'Account';
			};
			e.TButton {
				Size = UDim2.new(0, 140, 1, -2);
				Position = UDim2.new(1, -70 -70, 0, 1);
				TextSize = 10;
				Text = 'Link Account';
				[e.Roact.Event.Activated] = e.bind(e.go.mode_set, "Begin_Link");
			};
		});
		e.UIListLayout {
			FillDirection = Enum.FillDirection.Vertical;
		};
	};
}

local function component(props)
	local accSect = props.is_guest and accountSections.Guest or accountSections.Linked

	return e.Context({
		Name = script.Name
	}, {
		e.Line(accSect);

		e.Line {
			e.TButton {
				Size = UDim2.new(0, 70, 0, 24);
				Position = UDim2.new(1, 0 -70, 0, 24);
				TextSize = 10;
				Text = 'Back';
				[e.Roact.Event.Activated] = e.bind(e.go.mode_set, props.previous_mode);
			};
		};

		e.UIPadding {
			PaddingTop = UDim.new(0, 20);
			PaddingBottom = UDim.new(0, 20);
		};

		e.UIListLayout {
			FillDirection = Enum.FillDirection.Vertical;
		};
	})
end

return e.connect(function(state)
	return {
		colors = state.colors;
		previous_mode = state.previous_mode;
		is_guest = state.auth.is_guest
	}
end)(component)