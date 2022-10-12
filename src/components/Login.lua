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
		Name = 'Login'
	}, {
		e.Pane({
			Size = UDim2.new(1, 0, 0, 0);
			AutomaticSize = Enum.AutomaticSize.Y;
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
		}, {
			e.Title {
				Text = 'Logging In . . .';
			};
			e.Subtitle {
				Text = 'Please wait while we solve a cryptographic challenge (proof of work) to login. You will have ~15 FPS until complete.';
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

function e.reducers:login(old, new)
	print 'login reducer'
	local attempts = old.auth.attempts + 1
	if attempts > 3 then
		new.auth.attempts = 0
		new.mode = 'BeginLink'
		new.auth.UserId = nil
		new.auth.session = nil
		new.auth.token = nil
		task.spawn(e.info, 'Unable to login. You must relink your account.')
		return new
	end

	new.mode = 'Login'
	new.auth.attempts = attempts

	e.promise {
		id = old.auth.UserId;
		token = old.auth.token;
	}
	:Then(e.http.get_challenge)
	:Then(function(self, challenge)
		self.challenge = challenge
		self.solution = e.NanoPoW.calculate(self.challenge)
	end)
	:Then(e.http.login)
	:Then(function(self, session)
		self.session = session
	end)
	:Then(e.authorized)
	:Else(function()
		e.info 'Login failed. Trying again in 3 seconds.'
		task.wait(3)
	end)
	:Else(e.login)
	:ContinueAsync()

	return new
end

function e.reducers:login_success(old, new)
	new.auth.attempts = 0
	return e.reducers.authorized(self, old, new)
end

return component