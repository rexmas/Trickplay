dofile("ferris.lua")

screen:show_all()

local color_scheme = "blue"
local oem_vendor = "samsung"

local bar_off_image = Image { src = "assets/bar-"..color_scheme.."-off.png", opacity = 0 }
local bar_on_image  = Image { src = "assets/bar-"..color_scheme.."-on.png", opacity = 0 }

-- Load the generic app image once and clone it 

local generic_app_image = Image { src = "assets/generic-app-icon.png", opacity = 0 }

screen:add(bar_off_image,bar_on_image,generic_app_image)

my_id = app.id

local items = {}
local items2 = {}

-- Cache the app icons

icons = {}

local make_tile = function(id,name)
	
	local item = Group { }

	-- See if we already have one in our cache 
	
	local image = icons[ id ]
	
	
	if not image then
	
		-- If not, create it and put it in the cache

		image = Image()
	
		if not image:load_app_icon( id, "launcher-icon.png" ) then
		
			image = Clone{ source = generic_app_image, opacity = 255 }
			
		end
		
		icons[ id ] = image
		
	else
	
		-- If it exists in the cache, clone it
		
		image = Clone{ source = image }
	
	end
	
	image:set { x = 14/2, y = 14/2, z = 0, scale = { 0.5, 0.5 } }
	
	
	item:add(image)

	local my_bar_off = Clone { source = bar_off_image, opacity = 255, z = 0, scale = { 0.5, 0.5 } }
	local my_bar_on  = Clone { source = bar_on_image, opacity = 0, z = 0, scale = { 0.5, 0.5 } }
	item:add(my_bar_off)
	item:add(my_bar_on)

	local label= Text { text = name, font="Graublau Web,DejaVu Sans,Sans 24px", color="FFFFFF", z = 1 }
	label.x = (my_bar_off.w/2 - label.w) - 20
	label.y = (my_bar_off.h/2 - label.h) / 2

	item.extra.id = id
	item.extra.label = label
	item.extra.off = my_bar_off
	item.extra.on = my_bar_on
	item:add(label)

	return item
end

local app
for i = 1,5 do
	for _,app in pairs(apps:get_all()) do
		if(app.id ~= "com.trickplay.launcher") then
			table.insert(items, make_tile(app.id,app.name))
			table.insert(items2, make_tile(app.id,app.name) )
		end
	end
end

local ferris = Ferris.new( 11*#items, items, -30 )
local ferris2 = Ferris.new( 11*#items, items2, -30 )

-- Move a bit more than double the radius off-screen
ferris.offscreen = {
					x = -25*#items,
					y = screen.h/2
				}
ferris.onscreen = {
					x = 9*#items,
					y = screen.h/2
				}
ferris.fullscreen = {
					x = screen.w - 9*#items,
					y = screen.h/2 + 70
				}

ferris.ferris.x = ferris.offscreen.x
ferris.ferris.y = ferris.offscreen.y


ferris2.onscreen = {
					x = ferris.onscreen.x,
					y = ferris.onscreen.y
				}
ferris2.fullscreen = {
						x = screen.w/2 + 200,
						y = ferris.fullscreen.y
					}

ferris2.ferris.x = ferris2.onscreen.x
ferris2.ferris.y = ferris2.onscreen.y
-- Initially hide the 2nd wheel, and disable highlighting on it
ferris2.ferris.opacity = 0
ferris2.highlight = function () end

-- These two are "fake" groups, to ensure that these elements are in front of the backdrop,
-- regardless of their z-depth within these fake groups; the group itself stays above the background
local ferris_group = Group { children = { ferris.ferris }, z = 1 }
local ferris2_group = Group { children = { ferris2.ferris }, z = 2 }

local storeMockup = Image { src = "assets/store_mock_poker.jpg", z = 0, opacity = 0 }

local backdrop1 = Image { src = "assets/background-"..color_scheme.."-1.jpg", z = -1,  size = { screen.w, screen.h}, opacity = 0 }
local backdrop2 = Image { src = "assets/background-"..color_scheme.."-2.jpg", z = 0,  size = { screen.w, screen.h}, opacity = 0 }

local playLabel = Text { text = "play", font="Graublau Web,DejaVu Sans,Sans 72px", color="FFFFFF", opacity = 0, x = 10, y = screen.h/16, z=1 }
local getLabel  = Text { text = "get",  font="Graublau Web,DejaVu Sans,Sans 72px", color="FFFFFF", opacity = 0, x = 10, y = screen.h/16, z=1 }
local OEMLabel = Group
						{
							children =
							{
								Image { src = "assets/"..oem_vendor.."-oem-1.png", z = 1, x = screen.h/32, y = 2*screen.h/32 },
								Image { src = "assets/"..oem_vendor.."-oem-2.png", z = 1, x = screen.h/32, y = 11*screen.h/32 },
								Image { src = "assets/"..oem_vendor.."-oem-3.png", z = 1, x = screen.h/32, y = 20*screen.h/32 },
							},
							x = 10,
							z = 1,
							opacity = 0,
							y_rotation = { 90, 0 ,0 },
						}

screen:add(backdrop1)
screen:add(backdrop2)
screen:add(OEMLabel)

local swap_tile = function(image, new_src, delay)
	Timer { interval = delay, on_timer = function(timer)
		image:move_anchor_point(image.w/2, image.h/2)
		image:animate({ duration = 250, y_rotation = -90, mode = "EASE_IN_SINE", on_completed = function()
			image.src = new_src
			image:animate({ duration = 250, y_rotation = 0, mode = "EASE_OUT_SINE" })
		timer:stop()
		end})
	end }
end

Timer { interval = 15, on_timer = function(timer)
	local first = OEMLabel.children[1].src
	swap_tile(OEMLabel.children[1], OEMLabel.children[2].src, .5)
	swap_tile(OEMLabel.children[2], OEMLabel.children[3].src, 1)
	swap_tile(OEMLabel.children[3], first, 1.5)
end }

screen:add(getLabel)
screen:add(ferris2_group)
screen:add(playLabel)
screen:add(ferris_group)

screen:add(storeMockup)
storeMockup:raise_to_top()

mediaplayer.on_loaded = function( self ) self:play() end
mediaplayer.on_end_of_stream = function ( self ) self:seek(0) self:play() end
mediaplayer:load('jeopardy.mp4')

-- 1 is forward, -1 is backward
local direction = 1

local state = "offscreen"

if( settings.active ) then
	ferris:goto( settings.active - 1)
end

backdrop_fade_wobble = function(backdrop)
	backdrop:animate({
					duration = 2500,
					opacity = 255,
					mode = "EASE_IN_OUT_SINE",
					on_completed = function ()
						backdrop:animate({
											duration = 2500,
											opacity = 0,
											mode = "EASE_IN_OUT_SINE",
											on_completed = function()
												backdrop_fade_wobble(backdrop)
											end
										})
					end })
end

local backdrop_stop_wobble = function(backdrop)
	backdrop:animate({ duration = 10, opacity = 0 })
end

function screen.on_key_down(screen, key)

	if ( keys.s == key ) then
		storeMockup:animate({duration = 500, opacity = 255-storeMockup.opacity, mode = "EASE_IN_OUT_SINE" })
		return
	end

	-- Stuff to rotate the wheel and choose items
	if( state == "onscreen" or state == "fullscreen" ) then
		if key >= keys["1"] and key <= keys["9"] then
			ferris:rotate( direction * (key - keys["0"]) )
		elseif key == keys["minus"] then
			direction = -direction
		elseif key == keys["CHAN_UP"] then
			ferris:rotate( 3 )
		elseif key == keys["CHAN_DOWN"] then
			ferris:rotate( -3 )
		elseif key == keys["Up"] then
			ferris:rotate( 1 )
		elseif key == keys["Down"] then
			ferris:rotate( -1 )
		elseif key == keys["Return"] then
			local active = ferris:get_active()
			-- Would launch the app here!
			settings.active = active
			apps:launch(items[active].extra.id)
		end
	end


	-- Stuff to transition between states
	if( state == "onscreen") then
		if key == keys["Left"] or key == keys["Exit"] then
			ferris.highlight_on = false
			ferris:highlight()
			ferris.ferris:animate(
									{
										duration = 500,
										x = ferris.offscreen.x,
										mode = "EASE_IN_SINE",
										on_completed = function() ferris:highlight() end,
									}
								)
			state = "offscreen"
		elseif key == keys["Right"] then
			ferris.highlight_on = false
			ferris:highlight()
			ferris.ferris:animate(
									{
										duration = 1000,
										y_rotation = -90,
										x = ferris.fullscreen.x,
										y = ferris.fullscreen.y,
										scale = { 1.4, 1.4 },
										mode = "EASE_IN_OUT_SINE",
										on_completed = function() mediaplayer:pause() end,
									}
								)
			ferris2.ferris:animate(
								{
										duration = 1000,
										y_rotation = -90,
										x = ferris2.fullscreen.x,
										y = ferris2.fullscreen.y,
										scale = { 1.4, 1.4 },
										opacity = 255,
										mode = "EASE_IN_OUT_SINE",
								}
							)
			ferris:rotate(#items)
			ferris2:rotate(math.random(#items/2,#items))
			backdrop1:animate(
								{
									duration = 1000,
									opacity = 255,
									mode = "EASE_OUT_SINE",
									on_completed = function () backdrop2:show() backdrop_fade_wobble(backdrop2) end,
								}
							)
			OEMLabel:animate(
								{
									duration = 1000,
									opacity = 255,
									x = 50,
									mode = "EASE_OUT_SINE",
									y_rotation = 0,
								}
							)
			playLabel:animate(
								{
									duration = 1000,
									opacity = 255,
									x = (screen.w-playLabel.w) - 250,
									mode = "EASE_OUT_SINE",
								}
							)
			getLabel:animate(
								{
									duration = 1000,
									opacity = 255,
									x = (screen.w-getLabel.w)/2,
									mode = "EASE_OUT_SINE",
								}
							)
			state = "fullscreen"
		end

	elseif (state == "offscreen") then
		if key == keys["Left"] or key == keys["Right"] then
			ferris.highlight_on = true
			ferris.ferris:animate(
									{
										duration = 500,
										x = ferris.onscreen.x,
										mode = "EASE_OUT_SINE",
										on_completed = function() ferris:highlight() end,
									}
								)
			state = "onscreen"
		end

	elseif (state == "fullscreen") then
		if key == keys["Left"] then
			ferris.highlight_on = true
			ferris.ferris:animate(
									{
										duration = 1000,
										y_rotation = -30,
										x = ferris.onscreen.x,
										y = ferris.onscreen.y,
										scale = { 1.0, 1.0 },
										mode = "EASE_IN_OUT_SINE",
										on_completed = function() ferris:highlight() mediaplayer:play() end,
									}
								)
			ferris2.ferris:animate(
									{
										duration = 1000,
										y_rotation = -30,
										x = ferris2.onscreen.x,
										y = ferris2.onscreen.y,
										scale = { 1.0, 1.0 },
										opacity = 0,
										mode = "EASE_IN_OUT_SINE",
										on_completed = function() ferris:highlight() mediaplayer:play() end,
									}
								)
			backdrop1:animate(
								{
									duration = 1000,
									opacity = 0,
									mode = "EASE_IN_SINE",
								}
							)
			backdrop2:hide()
			OEMLabel:animate(
								{
									duration = 1000,
									opacity = 0,
									x = 10,
									mode = "EASE_IN_SINE",
									y_rotation = 90,
								}
							)
			playLabel:animate(
								{
									duration = 1000,
									opacity = 0,
									x = 10,
									mode = "EASE_IN_SINE",
								}
							)
			getLabel:animate(
								{
									duration = 1000,
									opacity = 0,
									x = 10,
									mode = "EASE_IN_SINE",
								}
							)
			state = "onscreen"
		end
	end

end
