local g = ... 

local bg3 = Clone
	{
		source = b5,
		clip = {0,0,1920,360},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "bg3",
		position = {0,720,0},
		size = {1920,360},
		opacity = 255,
		reactive = true,
	}

bg3.extra.focus = {}

function bg3:on_key_down(key)
	if bg3.focus[key] then
		if type(bg3.focus[key]) == "function" then
			bg3.focus[key]()
		elseif screen:find_child(bg3.focus[key]) then
			if bg3.on_focus_out then
				bg3.on_focus_out()
			end
			screen:find_child(bg3.focus[key]):grab_key_focus()
			if screen:find_child(bg3.focus[key]).on_focus_in then
				screen:find_child(bg3.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

bg3.extra.reactive = true


local bg2 = Clone
	{
		source = b4,
		clip = {0,0,1920,360},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "bg2",
		position = {0,360,0},
		size = {1920,360},
		opacity = 255,
		reactive = true,
	}

bg2.extra.focus = {}

function bg2:on_key_down(key)
	if bg2.focus[key] then
		if type(bg2.focus[key]) == "function" then
			bg2.focus[key]()
		elseif screen:find_child(bg2.focus[key]) then
			if bg2.on_focus_out then
				bg2.on_focus_out()
			end
			screen:find_child(bg2.focus[key]):grab_key_focus()
			if screen:find_child(bg2.focus[key]).on_focus_in then
				screen:find_child(bg2.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

bg2.extra.reactive = true


local bg1 = Clone
	{
		source = b2,
		clip = {0,0,1920,360},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "bg1",
		position = {0,0,0},
		size = {1920,360},
		opacity = 255,
		reactive = true,
	}

bg1.extra.focus = {}

function bg1:on_key_down(key)
	if bg1.focus[key] then
		if type(bg1.focus[key]) == "function" then
			bg1.focus[key]()
		elseif screen:find_child(bg1.focus[key]) then
			if bg1.on_focus_out then
				bg1.on_focus_out()
			end
			screen:find_child(bg1.focus[key]):grab_key_focus()
			if screen:find_child(bg1.focus[key]).on_focus_in then
				screen:find_child(bg1.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

bg1.extra.reactive = true


local player = Clone
	{
		source = pspeed,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "player",
		position = {0,315,0},
		size = {45,45},
		opacity = 255,
		reactive = true,
	}

player.extra.focus = {}

function player:on_key_down(key)
	if player.focus[key] then
		if type(player.focus[key]) == "function" then
			player.focus[key]()
		elseif screen:find_child(player.focus[key]) then
			if player.on_focus_out then
				player.on_focus_out()
			end
			screen:find_child(player.focus[key]):grab_key_focus()
			if screen:find_child(player.focus[key]).on_focus_in then
				screen:find_child(player.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

player.extra.reactive = true


local image3 = Image
	{
		src = "/assets/igloo.png",
		clip = {0,0,151,88},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image3",
		position = {1845,273,0},
		size = {151,88},
		opacity = 255,
		reactive = true,
	}

image3.extra.focus = {}

function image3:on_key_down(key)
	if image3.focus[key] then
		if type(image3.focus[key]) == "function" then
			image3.focus[key]()
		elseif screen:find_child(image3.focus[key]) then
			if image3.on_focus_out then
				image3.on_focus_out()
			end
			screen:find_child(image3.focus[key]):grab_key_focus()
			if screen:find_child(image3.focus[key]).on_focus_in then
				screen:find_child(image3.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

image3.extra.reactive = true


local clone4 = Clone
	{
		scale = {1,1,0,0},
		source = image3,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone4",
		position = {1845,992,0},
		size = {151,88},
		opacity = 255,
		reactive = true,
	}

clone4.extra.focus = {}

function clone4:on_key_down(key)
	if clone4.focus[key] then
		if type(clone4.focus[key]) == "function" then
			clone4.focus[key]()
		elseif screen:find_child(clone4.focus[key]) then
			if clone4.on_focus_out then
				clone4.on_focus_out()
			end
			screen:find_child(clone4.focus[key]):grab_key_focus()
			if screen:find_child(clone4.focus[key]).on_focus_in then
				screen:find_child(clone4.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone4.extra.reactive = true


local clone6 = Clone
	{
		scale = {1,1,0,0},
		source = image3,
		x_rotation = {0,0,0},
		y_rotation = {180,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone6",
		position = {75,634,0},
		size = {151,88},
		opacity = 255,
		reactive = true,
	}

clone6.extra.focus = {}

function clone6:on_key_down(key)
	if clone6.focus[key] then
		if type(clone6.focus[key]) == "function" then
			clone6.focus[key]()
		elseif screen:find_child(clone6.focus[key]) then
			if clone6.on_focus_out then
				clone6.on_focus_out()
			end
			screen:find_child(clone6.focus[key]):grab_key_focus()
			if screen:find_child(clone6.focus[key]).on_focus_in then
				screen:find_child(clone6.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone6.extra.reactive = true


local fish1 = Image
	{
		src = "/assets/collect_white.png",
		clip = {0,0,64,49},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish1",
		position = {724,252,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish1.extra.focus = {}

function fish1:on_key_down(key)
	if fish1.focus[key] then
		if type(fish1.focus[key]) == "function" then
			fish1.focus[key]()
		elseif screen:find_child(fish1.focus[key]) then
			if fish1.on_focus_out then
				fish1.on_focus_out()
			end
			screen:find_child(fish1.focus[key]):grab_key_focus()
			if screen:find_child(fish1.focus[key]).on_focus_in then
				screen:find_child(fish1.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish1.extra.reactive = true


local fish2 = Clone
	{
		scale = {1,1,0,0},
		source = fish1,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish2",
		position = {1308,606,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish2.extra.focus = {}

function fish2:on_key_down(key)
	if fish2.focus[key] then
		if type(fish2.focus[key]) == "function" then
			fish2.focus[key]()
		elseif screen:find_child(fish2.focus[key]) then
			if fish2.on_focus_out then
				fish2.on_focus_out()
			end
			screen:find_child(fish2.focus[key]):grab_key_focus()
			if screen:find_child(fish2.focus[key]).on_focus_in then
				screen:find_child(fish2.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish2.extra.reactive = true


local image9 = Image
	{
		src = "/assets/obstacle_1.png",
		clip = {0,0,65,62},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "image9",
		position = {838,655,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

image9.extra.focus = {}

function image9:on_key_down(key)
	if image9.focus[key] then
		if type(image9.focus[key]) == "function" then
			image9.focus[key]()
		elseif screen:find_child(image9.focus[key]) then
			if image9.on_focus_out then
				image9.on_focus_out()
			end
			screen:find_child(image9.focus[key]):grab_key_focus()
			if screen:find_child(image9.focus[key]).on_focus_in then
				screen:find_child(image9.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

image9.extra.reactive = true


local gate = Clone
	{
		scale = {1,3,0,0},
		source = image9,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "gate",
		position = {1366,174,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

gate.extra.focus = {}

function gate:on_key_down(key)
	if gate.focus[key] then
		if type(gate.focus[key]) == "function" then
			gate.focus[key]()
		elseif screen:find_child(gate.focus[key]) then
			if gate.on_focus_out then
				gate.on_focus_out()
			end
			screen:find_child(gate.focus[key]):grab_key_focus()
			if screen:find_child(gate.focus[key]).on_focus_in then
				screen:find_child(gate.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

gate.extra.reactive = true


local clone11 = Clone
	{
		scale = {1,1,0,0},
		source = image9,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone11",
		position = {414,655,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone11.extra.focus = {}

function clone11:on_key_down(key)
	if clone11.focus[key] then
		if type(clone11.focus[key]) == "function" then
			clone11.focus[key]()
		elseif screen:find_child(clone11.focus[key]) then
			if clone11.on_focus_out then
				clone11.on_focus_out()
			end
			screen:find_child(clone11.focus[key]):grab_key_focus()
			if screen:find_child(clone11.focus[key]).on_focus_in then
				screen:find_child(clone11.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone11.extra.reactive = true


local door2 = Clone
	{
		scale = {1,3,0,0},
		source = clone11,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "door2",
		position = {414,475,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

door2.extra.focus = {}

function door2:on_key_down(key)
	if door2.focus[key] then
		if type(door2.focus[key]) == "function" then
			door2.focus[key]()
		elseif screen:find_child(door2.focus[key]) then
			if door2.on_focus_out then
				door2.on_focus_out()
			end
			screen:find_child(door2.focus[key]):grab_key_focus()
			if screen:find_child(door2.focus[key]).on_focus_in then
				screen:find_child(door2.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

door2.extra.reactive = true


local fish3 = Clone
	{
		scale = {1,1,0,0},
		source = fish2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish3",
		position = {840,600,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish3.extra.focus = {}

function fish3:on_key_down(key)
	if fish3.focus[key] then
		if type(fish3.focus[key]) == "function" then
			fish3.focus[key]()
		elseif screen:find_child(fish3.focus[key]) then
			if fish3.on_focus_out then
				fish3.on_focus_out()
			end
			screen:find_child(fish3.focus[key]):grab_key_focus()
			if screen:find_child(fish3.focus[key]).on_focus_in then
				screen:find_child(fish3.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish3.extra.reactive = true


local door1 = Clone
	{
		scale = {1,3,0,0},
		source = door2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "door1",
		position = {838,475,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

door1.extra.focus = {}

function door1:on_key_down(key)
	if door1.focus[key] then
		if type(door1.focus[key]) == "function" then
			door1.focus[key]()
		elseif screen:find_child(door1.focus[key]) then
			if door1.on_focus_out then
				door1.on_focus_out()
			end
			screen:find_child(door1.focus[key]):grab_key_focus()
			if screen:find_child(door1.focus[key]).on_focus_in then
				screen:find_child(door1.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

door1.extra.reactive = true


local clone14 = Clone
	{
		scale = {2,1,0,0},
		source = door1,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone14",
		position = {415,415,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone14.extra.focus = {}

function clone14:on_key_down(key)
	if clone14.focus[key] then
		if type(clone14.focus[key]) == "function" then
			clone14.focus[key]()
		elseif screen:find_child(clone14.focus[key]) then
			if clone14.on_focus_out then
				clone14.on_focus_out()
			end
			screen:find_child(clone14.focus[key]):grab_key_focus()
			if screen:find_child(clone14.focus[key]).on_focus_in then
				screen:find_child(clone14.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone14.extra.reactive = true


local clone15 = Clone
	{
		scale = {2,1,0,0},
		source = clone14,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone15",
		position = {535,415,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone15.extra.focus = {}

function clone15:on_key_down(key)
	if clone15.focus[key] then
		if type(clone15.focus[key]) == "function" then
			clone15.focus[key]()
		elseif screen:find_child(clone15.focus[key]) then
			if clone15.on_focus_out then
				clone15.on_focus_out()
			end
			screen:find_child(clone15.focus[key]):grab_key_focus()
			if screen:find_child(clone15.focus[key]).on_focus_in then
				screen:find_child(clone15.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone15.extra.reactive = true


local clone16 = Clone
	{
		scale = {2,1,0,0},
		source = clone15,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone16",
		position = {655,415,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone16.extra.focus = {}

function clone16:on_key_down(key)
	if clone16.focus[key] then
		if type(clone16.focus[key]) == "function" then
			clone16.focus[key]()
		elseif screen:find_child(clone16.focus[key]) then
			if clone16.on_focus_out then
				clone16.on_focus_out()
			end
			screen:find_child(clone16.focus[key]):grab_key_focus()
			if screen:find_child(clone16.focus[key]).on_focus_in then
				screen:find_child(clone16.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone16.extra.reactive = true


local clone17 = Clone
	{
		scale = {2,1,0,0},
		source = clone16,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone17",
		position = {775,415,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone17.extra.focus = {}

function clone17:on_key_down(key)
	if clone17.focus[key] then
		if type(clone17.focus[key]) == "function" then
			clone17.focus[key]()
		elseif screen:find_child(clone17.focus[key]) then
			if clone17.on_focus_out then
				clone17.on_focus_out()
			end
			screen:find_child(clone17.focus[key]):grab_key_focus()
			if screen:find_child(clone17.focus[key]).on_focus_in then
				screen:find_child(clone17.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone17.extra.reactive = true


local fish5 = Clone
	{
		scale = {1,1,0,0},
		source = fish2,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish5",
		position = {1134,960,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish5.extra.focus = {}

function fish5:on_key_down(key)
	if fish5.focus[key] then
		if type(fish5.focus[key]) == "function" then
			fish5.focus[key]()
		elseif screen:find_child(fish5.focus[key]) then
			if fish5.on_focus_out then
				fish5.on_focus_out()
			end
			screen:find_child(fish5.focus[key]):grab_key_focus()
			if screen:find_child(fish5.focus[key]).on_focus_in then
				screen:find_child(fish5.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish5.extra.reactive = true


local fish4 = Clone
	{
		scale = {1,1,0,0},
		source = fish5,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish4",
		position = {1038,1030,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish4.extra.focus = {}

function fish4:on_key_down(key)
	if fish4.focus[key] then
		if type(fish4.focus[key]) == "function" then
			fish4.focus[key]()
		elseif screen:find_child(fish4.focus[key]) then
			if fish4.on_focus_out then
				fish4.on_focus_out()
			end
			screen:find_child(fish4.focus[key]):grab_key_focus()
			if screen:find_child(fish4.focus[key]).on_focus_in then
				screen:find_child(fish4.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish4.extra.reactive = true


local lift3 = Clone
	{
		scale = {1,2,0,0},
		source = image9,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "lift3",
		position = {1494,958,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

lift3.extra.focus = {}

function lift3:on_key_down(key)
	if lift3.focus[key] then
		if type(lift3.focus[key]) == "function" then
			lift3.focus[key]()
		elseif screen:find_child(lift3.focus[key]) then
			if lift3.on_focus_out then
				lift3.on_focus_out()
			end
			screen:find_child(lift3.focus[key]):grab_key_focus()
			if screen:find_child(lift3.focus[key]).on_focus_in then
				screen:find_child(lift3.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

lift3.extra.reactive = true


local clone23 = Clone
	{
		scale = {2,1,0,0},
		source = door1,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone23",
		position = {1368,1017,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone23.extra.focus = {}

function clone23:on_key_down(key)
	if clone23.focus[key] then
		if type(clone23.focus[key]) == "function" then
			clone23.focus[key]()
		elseif screen:find_child(clone23.focus[key]) then
			if clone23.on_focus_out then
				clone23.on_focus_out()
			end
			screen:find_child(clone23.focus[key]):grab_key_focus()
			if screen:find_child(clone23.focus[key]).on_focus_in then
				screen:find_child(clone23.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone23.extra.reactive = true


local clone24 = Clone
	{
		scale = {1,2,0,0},
		source = door1,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "clone24",
		position = {1306,955,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

clone24.extra.focus = {}

function clone24:on_key_down(key)
	if clone24.focus[key] then
		if type(clone24.focus[key]) == "function" then
			clone24.focus[key]()
		elseif screen:find_child(clone24.focus[key]) then
			if clone24.on_focus_out then
				clone24.on_focus_out()
			end
			screen:find_child(clone24.focus[key]):grab_key_focus()
			if screen:find_child(clone24.focus[key]).on_focus_in then
				screen:find_child(clone24.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

clone24.extra.reactive = true


local lift2 = Clone
	{
		scale = {1,2,0,0},
		source = clone24,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "lift2",
		position = {1432,893,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

lift2.extra.focus = {}

function lift2:on_key_down(key)
	if lift2.focus[key] then
		if type(lift2.focus[key]) == "function" then
			lift2.focus[key]()
		elseif screen:find_child(lift2.focus[key]) then
			if lift2.on_focus_out then
				lift2.on_focus_out()
			end
			screen:find_child(lift2.focus[key]):grab_key_focus()
			if screen:find_child(lift2.focus[key]).on_focus_in then
				screen:find_child(lift2.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

lift2.extra.reactive = true


local lift1 = Clone
	{
		scale = {2,1,0,0},
		source = door1,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "lift1",
		position = {1306,897,0},
		size = {65,62},
		opacity = 255,
		reactive = true,
	}

lift1.extra.focus = {}

function lift1:on_key_down(key)
	if lift1.focus[key] then
		if type(lift1.focus[key]) == "function" then
			lift1.focus[key]()
		elseif screen:find_child(lift1.focus[key]) then
			if lift1.on_focus_out then
				lift1.on_focus_out()
			end
			screen:find_child(lift1.focus[key]):grab_key_focus()
			if screen:find_child(lift1.focus[key]).on_focus_in then
				screen:find_child(lift1.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

lift1.extra.reactive = true


local fish6 = Clone
	{
		scale = {1,1,0,0},
		source = fish5,
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "fish6",
		position = {1236,910,0},
		size = {64,49},
		opacity = 255,
		reactive = true,
	}

fish6.extra.focus = {}

function fish6:on_key_down(key)
	if fish6.focus[key] then
		if type(fish6.focus[key]) == "function" then
			fish6.focus[key]()
		elseif screen:find_child(fish6.focus[key]) then
			if fish6.on_focus_out then
				fish6.on_focus_out()
			end
			screen:find_child(fish6.focus[key]):grab_key_focus()
			if screen:find_child(fish6.focus[key]).on_focus_in then
				screen:find_child(fish6.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

fish6.extra.reactive = true

local deaths = Text
	{
		color = {0,0,0,255},
		font = "Soup of Justice 50px",
		text = "0",
		editable = false,
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "deaths",
		position = {20,20,0},
		size = {150,64},
		opacity = 255,
		reactive = true,
		cursor_visible = false,
	}

deaths.extra.focus = {}

function deaths:on_key_down(key)
	if deaths.focus[key] then
		if type(deaths.focus[key]) == "function" then
			deaths.focus[key]()
		elseif screen:find_child(deaths.focus[key]) then
			if deaths.on_focus_out then
				deaths.on_focus_out()
			end
			screen:find_child(deaths.focus[key]):grab_key_focus()
			if screen:find_child(deaths.focus[key]).on_focus_in then
				screen:find_child(deaths.focus[key]).on_focus_in(key)
			end
			end
	end
	return true
end

deaths.extra.reactive = true

g:add(bg3,bg2,bg1,player,image3,clone4,clone6,fish1,image9,gate,clone11,door2,fish3,door1,clone14,clone15,
clone16,clone17,fish2,fish5,fish4,lift3,clone23,clone24,lift2,lift1,fish6,deaths)

local colliders = {fish1,image9,gate,clone11,door2,fish3,door1,clone14,clone15,clone16,
clone17,fish2,fish5,fish4,lift3,clone23,clone24,lift2,lift1,fish6}


fish1.extra.event = {event_type = "move", ui = gate, position = {1366,120}, original = {1366, 174},}

fish2.extra.event = {event_type = "move", ui = door1, position = {655,365}, original = {836, 475},}

fish3.extra.event = {event_type = "move", ui = door2, position = {595,365}, original = {414, 475},}

fish4.extra.event = {event_type = "move", ui = lift1, position = {1306,737}, original = {1306, 897},}

fish5.extra.event = {event_type = "move", ui = lift2, position = {1432,733}, original = {1432, 893},}

fish6.extra.event = {event_type = "move", ui = lift3, position = {1494,798}, original = {1494, 958},}

return colliders, {}