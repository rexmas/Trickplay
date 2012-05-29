SLIDER = true

local default_parameters = {
    direction = "horizontal",
    grip  = {w =  80, h = 40,color="666666",border_width=2, border_color="ffffff"},
    track = {w = 500, h = 40,color="000000",border_width=2, border_color="ffffff"},
}
Slider = function(parameters)
    
	--input is either nil or a table
	parameters = is_table_or_nil("Slider",parameters) -- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
    
	----------------------------------------------------------------------------
	--The Slider Object inherits from Widget
	
	local instance = Widget(parameters)
    
    local grip, track
    local direction, direction_pos, direction_dim, direction_num 
	----------------------------------------------------------------------------
    local position_grabbed_from, p, delta--upvals
    local drag = function(...)
        
        delta = position_grabbed_from + ({...})[direction_num] - position_grabbed_from
        
        p = (delta-track[direction_pos])/(track[direction_dim]-grip[direction_dim])
        
        p = p > 1 and 1 or p > 0 and p or 0
        instance.progress = p
        
    end 
    
    grip   = Widget_Rectangle{
        reactive = true,
        on_button_down = function(self,...)
            
            position_grabbed_from = ({...})[direction_num]
            
            --this function is called by screen_on_motion
            g_dragging = drag
            grip:grab_pointer()
            
        end,
        on_motion = function(self,...)
            return g_dragging and g_dragging(...)
        end,
        on_button_up = function(self,...)
            grip:ungrab_pointer()
            g_dragging = nil
        end,
    }
	override_property(instance,"grip",
		function(oldf) return   grip     end,
		function(oldf,self,v) 
            if type(v) ~= "table" then
                error("Expected table. Received "..type(v),2)
            end
            grip:set(v)
        end
    )
    local progress = 0
	override_property(instance,"progress",
		function(oldf) return   progress     end,
		function(oldf,self,v) 
            
            if type(v) ~= "number" then
                error("Expected number. Received ".. type(v),2)
            elseif v > 1 or v < 0 then 
                error("Must be between [0,1]. Received ".. v,2)
            end
            grip[direction_pos] = v*(track[direction_dim]-grip[direction_dim]) +track[direction_pos]
            
            progress = v 
        end
    )
	----------------------------------------------------------------------------
    track  = Widget_Rectangle{
        reactive = true,
        on_button_down = function(self,...)
            
            position_grabbed_from =
                --the transformed position of the grip
                grip.transformed_position[direction_num]*
                --transformed position value has to be converted to the 1920x1080 scale
                screen[direction_dim]/screen.transformed_size[direction_num]+
                -- transformed position doesn't take anchor point into account
                grip[direction_dim]/2 
            
            drag(...)
        end,
    }
	override_property(instance,"track",
		function(oldf) return   track     end,
		function(oldf,self,v) 
            if type(v) ~= "table" then
                error("Expected table. Received "..type(v),2)
            end
            track:set(v)
        end
    )
    ----------------------------------------------------------------------------
	override_property(instance,"direction",
		function(oldf) return   direction     end,
		function(oldf,self,v)   
            
            if v == "horizontal" then
                direction_pos = "x"
                direction_num =  1 
                direction_dim = "w"
            elseif v == "vertical" then
                direction_pos = "y"
                direction_num =  2 
                direction_dim = "h"
            else
                error("Expected 'horizontal' or 'vertical'. Received "..v,2)
            end
            direction = v 
        end
    )
    
    instance:subscribe_to(
        {"direction","track","grip"},
        function()
            grip.position = track.position
        end
    )
    
	----------------------------------------------------------------------------
	
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.direction = self.direction
            t.progress  = self.progress
            t.grip  = {w = grip.w, h = grip.h, }
            t.track = {w = track.w,h = track.h,}
            
            t.type = "Slider"
            
            return t
        end
    )
    
    
	----------------------------------------------------------------------------
    instance:add(track,grip)
    instance:set(parameters)
    
    return instance
end