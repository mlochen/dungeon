Switch = {}

Switch.x = 0
Switch.y = 0
Switch.cx = 0
Switch.cy = 0
Switch.active = false
Switch.color = 0xf00

function Switch:new()
	s = {}
	setmetatable(s, self)
	return s
end

function Switch:update(dt, player)
	if math.floor(player.x) == self.x and
	   math.floor(player.y) == self.y then
		self.active = true
	end
end

function Switch:draw(world)
	local x1, y1 = world:project(self.x, self.y)
	local x2, y2 = world:project(self.x + 1, self.y)
	local x3, y3 = world:project(self.x + 1, self.y + 1)
	local x4, y4 = world:project(self.x, self.y + 1)

	love.graphics.setColor(r, g, b)
	love.graphics.polygon('fill', x1, y1, x2, y2, x3, y3, x4, y4)
end

