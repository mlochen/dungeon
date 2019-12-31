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

Enemy = {}

Enemy.height = 1.5
Enemy.radius = 0.3
Enemy.speed = 1
Enemy.health = 100
Enemy.attackDelay = 0.5
Enemy.attackDistance = 10
Enemy.spottedPlayer = false
Enemy.spottedPlayerTime = nil
Enemy.killTime = nil
Enemy.alive = true
Enemy.type = "e"
Enemy.sprites = {
	alive = love.graphics.newImage("images/enemy.png"),
	dying = love.graphics.newImage("images/enemy_dying.png"),
	dead = love.graphics.newImage("images/enemy_dead.png")
}
Enemy.sprite = Enemy.sprites.alive
Enemy.sounds = {
	shot = love.audio.newSource("sounds/shot.ogg", 'static')
}
Enemy.imageWidth = 100
Enemy.imageHeight = 200

function Enemy:new(pos, world)
	e = {}
	setmetatable(e, self)
	self.__index = self
	e.pos = pos
	e.world = world
	return e
end

function Enemy:update(dt, player, world)
	if self.alive == true then
		--[[
		-- move towards the player
		local x_delta = player.x - self.x
		local y_delta = player.y - self.y
		local dist = math.sqrt((x_delta ^ 2) + (y_delta ^ 2))
		self.x = self.x + (x_delta / dist) * (self.speed * dt)
		self.y = self.y + (y_delta / dist) * (self.speed * dt)
		world.correctPosition(self)

		if world:checkLineOfSight(player.x, player.y) == true and
			world:getDistance(player.x, player.y) <= self.attackDistance then
			if self.spottedPlayer == false then
				self.spottedPlayer = true
				self.spottedPlayerTime = love.timer.getTime()
			else
				if love.timer.getTime() - self.spottedPlayerTime > self.attackDelay then
					self.sounds.shot:stop()
					self.sounds.shot:play()
					player:recDamage(5)
					self.spottedPlayer = false
				end
			end
		else
			self.spottedPlayer = false
		end
		]]
	end
end

function Enemy:recDamage(damage)
	if self.alive == true then
		self.health = self.health - damage
		if self.health <= 0 then
			self.alive = false
			self.kill_time = love.timer.getTime()
		end
	end
end
