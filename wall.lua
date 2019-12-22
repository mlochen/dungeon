function createWall(x, y, direction)
	w = {}
	w.x1 = x
	w.y1 = y

	if direction == "n" or direction == "s" then
		w.x2 = x + 1
		w.y2 = y
		w.cx = x + 0.5
		w.cy = y
	elseif direction == "w" or direction == "e" then
		w.x2 = x
		w.y2 = y + 1
		w.cx = x
		w.cy = y + 0.5
	end

	w.height = 1.4
	w.face = direction

	if direction == "n" then
		w.color = {r = 0.6, g = 0.1, b = 0}
	elseif direction == "w" then
		w.color = {r = 0.8, g = 0.3, b = 0.2}
	elseif direction == "e" then
		w.color = {r = 0.7, g = 0.2, b = 0.1}
	elseif direction == "s" then
		w.color = {r = 0.9, g = 0.4, b = 0.3}
	end

	w.type = "w"
	return w
end

