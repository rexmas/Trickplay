
local img_path = "assets/bg/"

local graveyard = Image{src = img_path.."graveyard.png" }
graveyard.y = screen_h-graveyard.h

local gallows = Image{src = img_path.."gallows.png", x = 1300, y = screen_h }
local logo = Image{src = img_path.."logo.png", x = 1250, y = 180, opacity = 0, scale = { 2,2} }
logo:move_anchor_point(logo.w*2/3,logo.h*2/3)
local victim_pieces = {
    Group{opacity = 0},
    Image{src = img_path.."victim-2-torso.png",    x =   0, y = 280, opacity = 0 },
    Image{src = img_path.."victim-3-leftarm.png",  x = -30, y = 305, opacity = 0 },
    Image{src = img_path.."victim-4-rightarm.png", x = 176, y = 290, opacity = 0 },
    Image{src = img_path.."victim-5-leftleg.png",  x =  52, y = 600, opacity = 0 },
    Image{src = img_path.."victim-6-rightleg.png", x = 130, y = 560, opacity = 0 },
}
local victim_pieces_i = 1

local head = Image{src = img_path.."rope-victim-head.png",  x =   0, y = 151 }
local rope_top = Image{src = img_path.."rope-top.png", x = 100-12}
local rope_mid = Image{src = img_path.."rope-repeat.png", x =rope_top.x+16,y = rope_top.y + rope_top.h,tile = {false,true}, h = 200 }

victim_pieces[1]:add(rope_top,rope_mid,head)

local victim = Group{x = 1250}
victim:add(
    victim_pieces[6],
    victim_pieces[5],
    victim_pieces[4],
    victim_pieces[3],
    victim_pieces[2],
    victim_pieces[1]
)



local hm_body     = Image{ src = img_path.."hangman-body.png",          x = 13, y =   0}
local hm_bicep    = Image{ src = img_path.."hangman-bicep.png",         x =  8, y = 157}
local hm_shoulder = Image{ src = img_path.."hangman-shoulder-cape.png", x = 47, y = 130}
local hm_handle   = Image{ src = img_path.."hangman-arm-lever.png",     x =  0, y = 226}
hm_bicep:move_anchor_point(40,15)
hm_handle:move_anchor_point(326,475)

local hangman = Group{x = screen_w,y = 387 }
hangman:add(hm_body,hm_bicep,hm_handle,hm_shoulder)

--hm_handle.z_rotation = {7,0,0}
--hm_bicep.z_rotation = {-20,0,0}
local bg = Group{ name = "background" }


local drop_dist = 400

victim:move_anchor_point(rope_mid.x,-drop_dist)

local hangman_kill = Animator{
    duration   = 1500,
    properties = {
        {
            source = hm_handle,
            name = "z_rotation",
            
            keys = {
                {0.0,  "LINEAR",  0},
                {0.3, "LINEAR", 16},
                {0.5, "LINEAR", 16},
                {0.6,  "LINEAR",  0},
            }
        },
        {
            source = hm_bicep,
            name = "z_rotation",
            
            keys = {
                {0.0,  "LINEAR",   0},
                {0.3, "LINEAR", -45},
                {0.5, "LINEAR", -45},
                {0.6,  "LINEAR",   0},
            }
        },
        {
            source = victim,
            name = "y",
            
            keys = {
                {0.0, "LINEAR",  victim.y},
                {0.6, "LINEAR",  victim.y},
                {0.8, "LINEAR", victim.y+drop_dist},
                {1.0, "LINEAR", victim.y+drop_dist},
            }
        },
        {
            source = rope_top,
            name = "y",
            
            keys = {
                {0.0, "LINEAR", rope_top.y},
                {0.6, "LINEAR", rope_top.y},
                {0.8, "LINEAR", rope_top.y-drop_dist},
                {1.0, "LINEAR", rope_top.y-drop_dist},
            }
        },
        {
            source = rope_mid,
            name = "y",
            
            keys = {
                {0.0, "LINEAR", rope_mid.y},
                {0.6, "LINEAR", rope_mid.y},
                {0.8, "LINEAR", rope_mid.y-drop_dist},
                {1.0, "LINEAR", rope_mid.y-drop_dist},
            }
        },
        {
            source = rope_mid,
            name = "height",
            
            keys = {
                {0.0, "LINEAR", rope_mid.h},
                {0.6, "LINEAR", rope_mid.h},
                {0.8, "LINEAR", rope_mid.h+drop_dist},
                {1.0, "LINEAR", rope_mid.h+drop_dist},
            }
        },
        {
            source = victim,
            name = "z_rotation",
            
            keys = {
                {0.0,  "LINEAR",  0},
                {0.8,  "LINEAR",  0},
                {0.85, "LINEAR",  1},
                {0.9,  "LINEAR", -1},
                {0.95, "LINEAR",  1},
                {1.0,  "LINEAR",  0},
            }
        },
        --]]
    }
}


function bg:killing()
    
    return hangman_kill.timeline.duration - hangman_kill.timeline.elapsed
    
end
function bg:fade_in_victim(i)
    
    victim_pieces[i]:animate{
        duration = 200,
        opacity  = 255
    }
    
end

function bg:reset()
            for i,child in ipairs(victim.children) do
                
                child.opacity = 0
                
            end
            
            victim.opacity = 255
            print(victim.y)
            victim.y = victim.anchor_point[2]
            print(victim.y)
            rope_top.y = 0
            rope_mid.y = rope_top.y + rope_top.h
            rope_mid.h = 200
end
function bg:fade_out_vic()
    
    victim:animate{
        duration = 200,
        opacity  = 0,
        on_completed = function()
            
            bg:reset()
            
        end
    }
    
end

function bg:kill()
    print("kill")
    hangman_kill:start()
    
end

local gallow_y = AnimationState{
    duration = 300,
    transitions = {
        {
            source = "*",          target = "VISIBLE", duration = 300,
            keys = {
                {gallows, "y", 0},
            }
        },
        {
            source = "*",        target = "HIDDEN", duration = 300,
            keys = {
                {gallows, "y", screen_h},
            }
        },
    }
}
function bg:slide_in_gallows()
    
    gallow_y.state = "VISIBLE"
    
end

function bg:slide_out_gallows()
    
    gallow_y.state = "HIDDEN"
    
end

local hangman_x = AnimationState{
    duration = 700,
    transitions = {
        {
            source = "*",          target = "VISIBLE", duration = 300,
            keys = {
                {hangman, "x", 1463},
            }
        },
        {
            source = "*",        target = "HIDDEN", duration = 300,
            keys = {
                {hangman, "x", screen_w},
            }
        },
    }
}
hangman_x.on_completed = function()
    
    if hangman_x.state == "VISIBLE" then
        bg:kill()
    end
    
end

function bg:slide_in_hangman(on_c,p)
    hangman_x.state = "VISIBLE"
    print("fukker")
    hangman_kill.on_completed = function() print("meee") if on_c then on_c(p) end end
end

function bg:slide_out_hangman()
    hangman_x.state = "HIDDEN"
    hangman_kill.on_completed = nil
end
local logo_anim = Animator{
    duration   = 500,
    properties = {
        {
            source = logo,
            name = "scale",
            
            keys = {
                {0.0, "LINEAR",  {0,0}},
                {1.0, "LINEAR",  {1.0,1.0}},
            }
        },
        {
            source = logo,
            name = "opacity",
            
            keys = {
                {0.0, "LINEAR",   0},
                {1.0, "LINEAR", 255},
            }
        },
    }
}
function bg:scale_in_logo()

    logo_anim:start()
    
end

bg:add(graveyard,gallows,victim,hangman,logo)


return bg, logo