
test_description = "Offset the x, y coordinates with negative numbers."
test_group = "acceptance"
test_area = "canvas"
test_api = "translate"


function generate_test_image ()
	local test_image = Canvas (screen.w, screen.h)

	test_image:translate (-1200, -600 )
	test_image:rectangle (screen.w/2 - 200, screen.h/4, 600, 400)
	test_image:set_source_color({120, 200, 300 , 255})

	test_image:fill()

	return test_image:Image ()

end















