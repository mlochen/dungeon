require("wall")

World_model = {}

World_model.player = nil
World_model.walls = {}
World_model.enemies = {}
World_model.switches = {}

function World_model:new()
	w = {}
	setmetatable(w, self)
	self.__index = self
	return w
end

function World_model:init(worldString, width)
	local w = width
	local h = #worldString / width

	-- find walls
	for y = 0, h - 2 do
		for x = 0, w - 2 do
			local i = x + y * w
			local c1 = string.sub(worldString, i + 1, i + 1)
			local c2 = string.sub(worldString, i + 2, i + 2)
			local c3 = string.sub(worldString, i + 1 + w, i + 1 + w)

			if c1 ~= "#" and c2 == "#" then
				--local wallID = (x * 2^16) + (y * 2^8) + 0
				--self.walls[wallID] = createWall(x, y, "w")
				table.insert(self.walls, createWall(x + 1, y, "w"))
			elseif c1 == "#" and c2 ~= "#" then
				--local wallID = (x * 2^16) + (y * 2^8) + 1
				--self.walls[wallID] = createWall(x, y, "e")
				table.insert(self.walls, createWall(x + 1, y, "e"))
			end
			if c1 ~= "#" and c3 == "#" then
				--local wallID = (x * 2^16) + (y * 2^8) + 2
				--self.walls[wallID] = createWall(x, y, "n")
				table.insert(self.walls, createWall(x, y + 1, "n"))
			elseif c1 == "#" and c3 ~= "#" then
				--local wallID = 5
				--self.walls[wallID] = {r = 5} --createWall(x, y, "s")
				table.insert(self.walls, createWall(x, y + 1, "s"))
			end
		end
	end

	-- find player, enemies and switches
	for y = 0, h - 1 do
		for x = 0, w - 1 do
			local i = x + y * w
			local c = string.sub(worldString, i + 1, i + 1)

			if c == "p" then
				self.player = Player:new(x + 0.5, y + 0.5)
			elseif c == "e" then
				--table.insert(self.enemies, enemy:new(x, y))
			elseif c == "s" then
				--table.insert(self.switches, switch:new(x, y))
			end
		end
	end

	return self.player
end

function World_model:update(dt, mouseDelta)
	self.player:update(dt, mouseDelta)
	for i = 1, #self.enemies do
		--self.enemies[i]:update(dt)
	end
	for i = 1, #self.switches do
		--self.switches[i]:update(dt)
	end
end

function World_model:getObjectsInFOV(x, y, a, fov)
	local obj = {}
	local nx1, ny1 = math.cos(a + fov / 2), math.sin(a + fov / 2)
	local nx2, ny2 = math.cos(a - fov / 2), math.sin(a - fov / 2)

	for i = 1, #self.walls do
		local vx1, vy1 = self.walls[i].x1 - x, self.walls[i].y1 - y
		local vx2, vy2 = self.walls[i].x2 - x, self.walls[i].y2 - y

		if ((nx1 * vy1 - ny1 * vx1) < 0 and
		   (nx2 * vy1 - ny2 * vx1) > 0) or
		   ((nx1 * vy2 - ny1 * vx2) < 0 and
		   (nx2 * vy2 - ny2 * vx2) > 0) then
			local delta_x = x - self.walls[i].cx
			local delta_y = y - self.walls[i].cy
			self.walls[i].dist = math.sqrt(delta_x ^ 2 + delta_y ^ 2)
			table.insert(obj, self.walls[i])
		end
	end

	for i = 1, #self.switches do

	end

	for i = 1, #self.enemies do

	end

	table.sort(obj, function(o1, o2) return o1.dist > o2.dist end)
	return obj
end

