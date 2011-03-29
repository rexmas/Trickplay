--[[
Filename: 0001_rectangle_basic.lua
Author: Peter von dem Hagen
Date: January 19, 2011
Test type: Manual GUI Test
Description: Create several rectangles and verify that they display as expected
--]]

-- Test Set up --


function generate_test_image ()

	 local g = Group
	 {
	        size = { screen.w , screen.h },
	        children = {
	            Rectangle {
	            	color = "FFFFFF",
	            	size = { screen.w, screen.h }
	            },
	            Rectangle {
	            	color = { 153, 51, 85 },
	            	border_width = 5,
	            	border_color = "FF0066",
	            	size = { 400, 400 },
					position = { screen.w/2 , screen.h/2 }
	            },
	             Rectangle {
	            	color = "F5B800",
	            	size = { 100, 100 },
	            	position = { 100,100 }
	            }
	         }
		}
	return g
end











