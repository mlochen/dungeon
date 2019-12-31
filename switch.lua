Switch = {}

Switch.active = false
Switch.pushed = false
Switch.original_color = {r = 1, g = 0, b = 0}
Switch.color = {r = 1, g = 0, b = 0}
Switch.sounds = {
	push = love.audio.newSource("sounds/switch.ogg", 'static')
}

function Switch:new(x, y)
	s = {}
	setmetatable(s, self)
	self.__index = self
	s.x = x
	s.y = y
	return s
end

function Switch:update(dt, player)
	if self.active == false then
		self.color = {r = 0.5, g = 0.5, b = 0.5}
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

	if math.floor(player.x) == self.x and
	   math.floor(player.y) == self.y and
	   self.active == true and
	   self.pushed == false then
		self.sounds.push:play()
		self.pushed = true
	end
end

