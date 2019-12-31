World_view = {}
World_view.images = {
	sky = love.graphics.newImage("images/sky.png"),
	floor = love.graphics.newImage("images/floor.png"),
	bullet = love.graphics.newImage("images/bullet.png")
}

function World_view.draw(w, h, player, worldModel)
	-- draw sky and ground
	local pixelsPerDeg = World_view.images.sky:getWidth() / (math.pi * 2)
	local skyOffset = player.a * pixelsPerDeg
	love.graphics.draw(World_view.images.sky, -skyOffset, 0)
	love.graphics.draw(World_view.images.sky, -skyOffset + World_view.images.sky:getWidth())
	
	local xFactor = w / World_view.images.floor:getWidth()
	local yFactor = h / 2 / World_view.images.floor:getHeight()
	love.graphics.draw(World_view.images.floor, 0, h / 2, 0, xFactor, yFactor)

	obj, sw = worldModel:getObjectsInFOV(player.x, player.y, player.a, player.fov)

	-- draw switches
	for _, switch in pairs(sw) do
		local x1, y1 = World_view.project(player, switch.x, switch.y, w, h)
		local x2, y2 = World_view.project(player, switch.x + 1, switch.y, w, h)
		local x3, y3 = World_view.project(player, switch.x + 1, switch.y + 1, w, h)
		local x4, y4 = World_view.project(player, switch.x, switch.y + 1, w, h)
		love.graphics.setColor(World_view.adjustColorForDist(switch.color, switch.dist))
		love.graphics.polygon('fill', x1, y1, x2, y2, x3, y3, x4, y4)
	end

	-- draw walls, enemies
	for i = 1, #obj do
		if obj[i].type == "w" then
			o = obj[i]
			local x1, y1 = World_view.project(player, o.x1, o.y1, w, h)
			local x2, y2 = World_view.project(player, o.x2, o.y2, w, h)

			love.graphics.setColor(World_view.adjustColorForDist(o.color, o.dist))
			love.graphics.polygon('fill', x1, y1, x1, y1 - (y1 - h / 2) / 2, x2, y2 - (y2 - h / 2) / 2, x2, y2)
		end
		if obj[i].type == "e" then
			o = obj[i]
			local x, y = World_view.project(player, o.x, o.y, w, h)

			love.graphics.setColor(World_view.adjustColorForDist(0, 0, 0, o.dist))
			love.graphics.draw(World_view.images.enemy, x, y)
		end
		if obj[i].type == "s" then
			o = obj[i]
			local x1, y1 = World_view.project(player, o.x, o.y, w, h)
			local x2, y2 = World_view.project(player, o.x + 1, o.y, w, h)
			local x3, y3 = World_view.project(player, o.x + 1, o.y + 1, w, h)
			local x4, y4 = World_view.project(player, o.x, o.y + 1, w, h)

			love.graphics.setColor(World_view.adjustColorForDist(o.color, o.dist))
			love.graphics.polygon('fill', x1, y1, x2, y2, x3, y3, x4, y4)
		end
	end

	-- draw hud
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Number of objects: " .. #obj .. "\n\z
						 Number of switches: " .. #sw .. "\n\z
	                     Position: " .. player.x .. ", " .. player.y .. "\n", 10, 10)
end

function World_view.project(player, x, y, w, h)
	local px = math.cos(player.a)
	local py = math.sin(player.a)

	local ox = x - player.x
	local oy = y - player.y
	local dist = math.sqrt(ox^2 + oy^2)
	ox = ox / dist
	oy = oy / dist

	local ah = math.acos(px * ox + py * oy)
	local d = 0
	if px * oy - py * ox < 0 then
		d = -1
	else
		d = 1
	end

	local av = math.atan(1 / dist)

	local pixels_per_deg = w / player.fov 

	local pixels_x = (w / 2) + pixels_per_deg * ah * d
	local pixels_y = (h / 2) + pixels_per_deg * av

	return pixels_x, pixels_y
end

function World_view.adjustColorForDist(color, dist)
	local f = 0
	if dist <= 50 then
		f = (50 - dist) / 50
	end
	return color.r * f, color.g * f, color.b * f
end
