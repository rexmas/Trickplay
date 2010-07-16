dofile ("Square.lua")

Board = {}

function Board:new(args)
	local w = BOARD_WIDTH
	local h = BOARD_HEIGHT
	local squareGrid = {}
	local squaresWithTowers = {}
	local theme = args.theme
	for i = 1, h do
      squareGrid[i] = {}
	end
	
	for i = 1, h do
		for j = 1, w do
			squareGrid[i][j] = Square:new {x = j, y = i}
			if (i <= 2 or j <= 2 or i > h - 2 or j > w - 2) then
				squareGrid[i][j].state = FULL
			else
				squareGrid[i][j].state = EMPTY
			end
			if (i >= 6 and i <= 13 and (j <=2 or j > w-2)) then
				squareGrid[i][j].state = WALKABLE
			end
	   end
	end
	
	local object = {
		w = w,
		h = h,
		squareGrid = squareGrid,
		squaresWithTowers = squaresWithTowers,
		theme = theme
   }
   setmetatable(object, self)
   self.__index = self
   return object
end

function Board:init()
	for i = 1, self.h do
		local total = ""
		for j = 1, self.w do
			total = total..self.squareGrid[i][j].state
		end
		print(total)
	end
end

function Board:render()
	
end

function Board:createBoard()

	local groups = {}
	
	for i = 1, self.h do
		groups[i] = {}
		local g = groups[i]
		local s = self.squareGrid[i]
		for j = 1, self.w do
			g[j] = Group{w=SPW, h=SPH, name=s[j].state}
	   end
	end
	backgroundImage = Image {src = self.theme.boardBackground }

	local b = Group{}
	screen:add(backgroundImage, b)
	
	local hl = Rectangle{h=70, w=70, color="FF00CC"}

	BoardMenu = Menu.create(b, groups, hl)
	BoardMenu:create_key_functions()
	BoardMenu:button_directions()
	BoardMenu:create_buttons(0, "Sans 34px")
	BoardMenu:apply_color_change("FFFFFF", "000000")
	BoardMenu.buttons:grab_key_focus()
	BoardMenu:update_cursor_position()
	BoardMenu.hl.opacity = 255
	BoardMenu.container.opacity=255
	
	BoardMenu.buttons.extra.r = function()
		if (self.squareGrid[BoardMenu.y][BoardMenu.x].state == EMPTY) then
			self.squareGrid[BoardMenu.y][BoardMenu.x].tower = Tower:new(self.theme.towers.normalTower)
			self.squareGrid[BoardMenu.y][BoardMenu.x]:render()
		end
	end
end
