


water =
{
    speed  = 100, -- pixels per second
    strips = {},
    top_y  = 0,
    setup = function( self )
                
            local tile = assets.water
            tile:set{ w = screen.w , tile = { true  , false } }
            for i = 1 , math.ceil( screen.h / tile.h ) + 3 do
                table.insert( self.strips , Clone{ source = tile } )
            end
            local top = - ( tile.h * 2 )
            self.top_y = top
            for _ , strip in ipairs( self.strips ) do
                strip.position = { 0 , top }
                top = top + tile.h - 1
                screen:add( strip )
            end
    end,

	add_doodad = function( self, index, xxx, x_rot, y_rot, z_rot )


        local island =
            
            {
                speed = self.speed,
                image = Clone{ 
					source       = assets[ "island"..tostring( index ) ] , 
					x_rotation   = { x_rot , 0, 0},
					y_rotation   = { y_rot , 0, 0},
					z_rotation   = { z_rot , 0, 0},
					opacity      = 255 
				},
                setup = function( self )
                        screen:add( self.image )
						self.image:lower_to_bottom()
						self.image.anchor_point = {  self.image.w / 2 ,  self.image.h / 2 }
						self.image.position     = {               xxx , -self.image.h / 2 }

                        for _ , strip in ipairs( water.strips ) do
    				        strip:lower_to_bottom()
    					end
                end,
                    
                render = function( self , seconds )
                        self.image.y = self.image.y + self.speed * seconds
                        if self.image.y > (screen.h+self.image.h) then
                            remove_from_render_list( self )
                            screen:remove( self.image )
                        end
                        
                end,
            }
            
        add_to_render_list( island )
	end,
            
    render = function( self , seconds )
            -- reposition all the water strips
            local dy   = self.speed * seconds
            local maxy = screen.h
            self.top_y = self.top_y + dy    

            for _ , strip in ipairs( self.strips ) do
                strip.y = strip.y + dy
                if strip.y > maxy then
                    strip.y    = self.top_y - strip.h + 1   
                    self.top_y = strip.y
                end
            end
    end,        
}

