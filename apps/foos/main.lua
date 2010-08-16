Directions = {
   RIGHT = { 1, 0},
   LEFT  = {-1, 0},
   DOWN  = { 0, 1},
   UP    = { 0,-1}
}
NUM_ROWS   = 2
NUM_VIS_COLS   = 3
PADDING_BORDER = 0
PADDING_MIDDLE = 0

PIC_DIR = "assets/thumbnails/"

PIC_W = (screen.width/(NUM_VIS_COLS+1)) 
PIC_H = (screen.height/NUM_ROWS)
SEL_W = 1.1*PIC_W
SEL_H = 1.1*PIC_H




dofile("Class.lua") -- Must be declared before any class definitions.
dofile("MVC.lua")
dofile("FrontPageView.lua")
dofile("FrontPageController.lua")
---[[
dofile("SlideshowView.lua")
dofile("SlideshowController.lua")
--]]
--[[
dofile("HelpMenuView.lua")
dofile("HelpMenuController.lua")
--]]

dofile("adapter/Adapter.lua")
--[[
dofile("ItemSelectedView.lua")
dofile("ItemSelectedController.lua")
--]]
dofile("Slideshow.lua")

dofile("Load.lua")

Components = {
   COMPONENTS_FIRST = 1,
   FRONT_PAGE       = 1,
   SLIDE_SHOW       = 2,
   COMPONENTS_LAST  = 2
}
model = Model()

Setup_Album_Covers()

local front_page_view = FrontPageView(model)
front_page_view:initialize()
---[[
local slide_show_view = SlideshowView(model)
slide_show_view:initialize()
--]]
--[[
local help_menu_view = HelpMenuView(model)
help_menu_view:initialize()
--]]
--[[
local item_selected_view = ItemSelectedView(model)
item_selected_view:initialize()
--]]
function screen:on_key_down(k)
    assert(model:get_active_controller())
    model:get_active_controller():on_key_down(k)
end

model:start_app(Components.FRONT_PAGE)

