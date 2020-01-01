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

require("vec2D")

Player = {}

Player.a = math.pi / 2
Player.radius = 0.3
Player.speed = 2
Player.alive = true
Player.health = 100
Player.reloading = false
Player.reloadStart = 0
Player.reloadDuration = 1
Player.mouseSensitivity = 0.2
Player.bullets = 8
Player.type = "p"
Player.sounds = {
	reload = love.audio.newSource("sounds/reload.ogg", 'static'),
	shot = love.audio.newSource("sounds/shot.ogg", 'static'),
	steps = love.audio.newSource("sounds/steps.ogg", 'static')
}

function Player:new(pos, worldModel)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.pos = pos
	o.worldModel = worldModel
	return o
end

function Player:update(dt, mouseDelta)
	local move = Vec2D.new(0, 0)
	if love.keyboard.isDown("up") then
		move = move + Vec2D.new(1, 0)
	end
	if love.keyboard.isDown("down") then
		move = move + Vec2D.new(-1, 0)
	end
	if love.keyboard.isDown("left") then
		move = move + Vec2D.new(0, -1)
	end
	if love.keyboard.isDown("right") then
		move = move + Vec2D.new(0, 1)
	end
	move = Vec2D.normalize(move)
	move = Vec2D.rotate(move, self.a)
	self.pos = self.pos + Vec2D.mul(move, self.speed * dt)

	if move.x == 0 and move.y == 0 then
		self.sounds.steps:stop()
	else
		self.sounds.steps:play()
	end

	self.a = self.a + mouseDelta * self.mouseSensitivity * dt
	self.a = self.a % (2 * math.pi)

	if self.reloading == true and
	   love.timer.getTime() - self.reloadStart > self.reloadDuration then
		self.reloading = false
		self.bullets = 8
	end
end

function Player:recDamage(damage)
	if self.alive == true then
		self.health = self.health - damage
		if self.health <= 0 then
			self.alive = false
		end
	end
end

function Player:fire()
	if self.reloading == false and self.bullets > 0 then
		self.bullets = self.bullets - 1
		self.sounds.shot:stop()
		self.sounds.shot:play()

		local direction = Vec2D.rotate(Vec2D.new(1, 0), self.a)
		local target = worldModel:getTarget(self.pos, direction)
		if target ~= nil and target.type == "e" then
			target:recDamage(50)
		end
	end
end

function Player:reload()
	if self.reloading == false then
		self.reloading = true
		self.sounds.reload:play()
		self.reloadStart = love.timer.getTime()
	end
end
