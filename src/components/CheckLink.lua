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

local component = e.Roact.PureComponent:extend(script.Name)

function component:render()
	return e.Context({
		Name = 'CheckLink'
	}, {
		e.Pane({
			Size = UDim2.new(1, 0, 0, 0);
			AutomaticSize = Enum.AutomaticSize.Y;
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
		}, {
			e.Title {
				Text = 'Linking . . .';
			};
			e.Subtitle {
				Text = 'Please wait while we solve a cryptographic challenge (proof of work) to link your account. You will have ~15 FPS until complete.';
			};
			e.UIPadding {
				PaddingLeft = UDim.new(0, 20);
				PaddingRight = UDim.new(0, 20);
			};
			e.UIListLayout {
				FillDirection = Enum.FillDirection.Vertical;
				Padding = UDim.new(0, 20);
			};
		})
	})
end

function e.reducers:attempt_link(old, new)
	new.mode = 'CheckLink'
	return new
end

function e.reducers:link_success(old, new)
	new.auth.token = self.token
	new.auth.session = self.session
	new.auth.Code = nil
	e.plugin:SetSetting('refresh-token', self.token)
	e.plugin:SetSetting('session', self.session)
	e.plugin:SetSetting('user-id', self.id)
	return e.reducers.authorized(self, old, new)
end

function e.reducers:authorized(old, new)
	if self.session then
		new.auth.session = self.session
		e.plugin:SetSetting('session', self.session)
	end
	new = e.reducers.loadMeshes({}, old, new)
	if #new.meshes == 0 then
		new.mode = 'Generate'
	else
		new.mode = 'Edit'
	end
	return new
end

return component