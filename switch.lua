-- Copyright (C) 2019 Marco Lochen

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 2 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

Switch = {}

Switch.active = false
Switch.pushed = false
Switch.original_color = {r = 0.5, g = 0, b = 0}
Switch.color = {r = 0.5, g = 0, b = 0}
Switch.sounds = {
	push = love.audio.newSource("sounds/switch.ogg", 'static')
}

function Switch:new(pos)
	s = {}
	setmetatable(s, self)
	self.__index = self
	s.pos = pos
	return s
end

function Switch:update(dt, player)
	if self.active == false then
		self.color = {r = 0.3, g = 0.3, b = 0.3}
	else
		if self.pushed == true then
			self.color = self.original_color
		else
			local factor = (math.sin(love.timer.getTime() * 10) + 1) / 2
			local r = self.original_color.r * factor
			local g = self.original_color.g * factor
			local b = self.original_color.b * factor
			self.color = {r = r, g = g, b = b}
		end
	end

	if math.floor(player.pos.x) == self.pos.x and
	   math.floor(player.pos.y) == self.pos.y and
	   self.active == true and
	   self.pushed == false then
		self.sounds.push:play()
		self.pushed = true
	end
end
