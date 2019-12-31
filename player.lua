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
Player.sounds = {
	reload = love.audio.newSource("sounds/reload.ogg", 'static'),
	shot = love.audio.newSource("sounds/shot.ogg", 'static'),
	steps = love.audio.newSource("sounds/steps.ogg", 'static')
}

function Player:new(x, y, worldModel)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.x = x
	o.y = y
	o.worldModel = worldModel
	return o
end

function Player:update(dt, mouseDelta)
	local vx, vy = 0, 0
	if love.keyboard.isDown("up") then
		vx = vx + 1
	end
	if love.keyboard.isDown("down") then
		vx = vx - 1
	end
	if love.keyboard.isDown("left") then
		vy = vy - 1
	end
	if love.keyboard.isDown("right") then
		vy = vy + 1
	end
	local vLen = math.sqrt(vx^2 + vy^2)
	if vLen ~= 0 then
		vx = vx / vLen
		vy = vy / vLen
	end
	local mx = math.cos(self.a) * vx - math.sin(self.a) * vy
	local my = math.sin(self.a) * vx + math.cos(self.a) * vy
	self.x = self.x + mx * (self.speed * dt)
	self.y = self.y + my * (self.speed * dt)

	if vx == 0 and vy == 0 then
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

function Player:recDamage(d)
	if self.alive == true then
		self.health = self.health - d
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

		-- check target
	end
end

function Player:reload()
	if self.reloading == false then
		self.reloading = true
		self.sounds.reload:play()
		self.reloadStart = love.timer.getTime()
	end
end

