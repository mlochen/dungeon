require("wall")
require("switch")

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
				local wallID = (x * 2^16) + (y * 2^8) + 0
				self.walls[wallID] = createWall(x + 1, y, "w")
			elseif c1 == "#" and c2 ~= "#" then
				local wallID = (x * 2^16) + (y * 2^8) + 1
				self.walls[wallID] = createWall(x + 1, y, "e")
			end
			if c1 ~= "#" and c3 == "#" then
				local wallID = (x * 2^16) + (y * 2^8) + 2
				self.walls[wallID] = createWall(x, y + 1, "n")
			elseif c1 == "#" and c3 ~= "#" then
				local wallID = (x * 2^16) + (y * 2^8) + 3
				self.walls[wallID] = createWall(x, y + 1, "s")
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
				local switch = Switch:new(x, y)
				switch.type = "s"
				switch.active = true
				table.insert(self.switches, switch)
			elseif c == "g" then
				local switch = Switch:new(x, y)
				switch.type = "g"
				switch.original_color = {r = 0, g = 0, b = 1}
				table.insert(self.switches, switch)
			end
		end
	end

	return self.player
end

function World_model:update(dt, mouseDelta)
	self.player:update(dt, mouseDelta)
	local px = math.floor(self.player.x)
	local py = math.floor(self.player.y)
	for wx = px - 1, px + 1 do
		for wy = py - 1, py + 1 do
			for wf = 0, 3 do
				wallID = (wx * 2^16) + (wy * 2^8) + wf
				if self.walls[wallID] ~= nil then
					self.player.x, self.player.y = World_model.wallCollision(self.player, self.walls[wallID])
				end
			end
		end
	end
	for i = 1, #self.enemies do
		--self.enemies[i]:update(dt)
	end

	local goal_active = true
	for _, switch in pairs(self.switches) do
		switch:update(dt, self.player)
		if switch.type == "s" and switch.pushed == false then
			goal_active = false
		end
	end
	if goal_active == true then
		for _, switch in pairs(self.switches) do
			if switch.type == "g" then
				switch.active = true
			end
		end
	end
end

function World_model:getObjectsInFOV(x, y, a, fov)
	local obj = {}
	for _, wall in pairs(self.walls) do
		if self:pointInFOV(wall.x1, wall.y1) or
		   self:pointInFOV(wall.cx, wall.cy) or
		   self:pointInFOV(wall.x2, wall.y2) then
			local delta_x = x - wall.cx
			local delta_y = y - wall.cy
			wall.dist = math.sqrt(delta_x ^ 2 + delta_y ^ 2)
			table.insert(obj, wall)
		end
	end

	sw = {}
	for _, switch in pairs(self.switches) do
		if self:pointInFOV(switch.x, switch.y) or
		   self:pointInFOV(switch.x + 1, switch.y) or
		   self:pointInFOV(switch.x, switch.y + 1) or
		   self:pointInFOV(switch.x + 1, switch.y + 1) then
			local delta_x = x - switch.x + 0.5
			local delta_y = y - switch.y + 0.5
			switch.dist = math.sqrt(delta_x ^ 2 + delta_y ^ 2)
			table.insert(sw, switch)
		end
	end

	for i = 1, #self.enemies do

	end

	table.sort(obj, function(o1, o2) return o1.dist > o2.dist end)
	return obj, sw
end

function World_model:pointInFOV(x, y)
	local vx, vy = x - self.player.x, y - self.player.y
	local vlx = math.cos(self.player.a + self.player.fov / 2)
	local vly = math.sin(self.player.a + self.player.fov / 2)
	local vrx = math.cos(self.player.a - self.player.fov / 2)
	local vry = math.sin(self.player.a - self.player.fov / 2)

	return (vlx * vy - vly * vx) < 0 and (vrx * vy - vry * vx) > 0
end

function World_model.wallCollision(character, wall)
	local wallFaceDist = 0
	local parallelOffset = 0
	if wall.face == "n" then
		wallFaceDist = wall.cy - character.y
		parallelOffset = wall.cx - character.x
	elseif wall.face == "s" then
		wallFaceDist = character.y - wall.cy
		parallelOffset = character.x - wall.cx
	elseif wall.face == "w" then
		wallFaceDist = wall.cx - character.x
		parallelOffset = character.y - wall.cy
	elseif wall.face == "e" then
		wallFaceDist = character.x - wall.cx
		parallelOffset = wall.cy - character.y
	end

	local xCorr, yCorr = 0, 0
	if math.abs(parallelOffset) <= 0.5 then
		if math.abs(wallFaceDist) < character.radius then
			yCorr = character.radius - wallFaceDist
		end
	elseif parallelOffset < -0.5 and wallFaceDist >= 0 then
		local dx, dy = parallelOffset + 0.5, wallFaceDist
		local dist = math.sqrt(dx^2 + dy^2)
		if dist < character.radius then
			local f = character.radius / dist
			xCorr = (dx * f) - dx
			yCorr = (dy * f) - dy
		end
	elseif parallelOffset > 0.5 then
		local dx, dy = parallelOffset - 0.5, wallFaceDist
		local dist = math.sqrt(dx^2 + dy^2)
		if dist < character.radius then
			local f = character.radius / dist
			xCorr = (dx * f) - dx
			yCorr = (dy * f) - dy
		end
	end

	local pxn, pyn = character.x, character.y
	if wall.face == "n" then
		pxn = pxn - xCorr
		pyn = pyn - yCorr
	elseif wall.face == "s" then
		pxn = pxn + xCorr
		pyn = pyn + yCorr
	elseif wall.face == "w" then
		pxn = pxn - yCorr
		pyn = pyn - xCorr
	elseif wall.face == "e" then
		pxn = pxn + yCorr
		pyn = pyn + xCorr
	end

	return pxn, pyn
end

