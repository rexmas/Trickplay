TabView = Class(View, function(view, model,parent, ...)
    view._base.init(view,model)
    view.parent = parent
    view.ui=Group{name="Tab ui", position={425,80}, opacity=255}
    view.menu_items = {}
    view.selector = Image{
        position={-70,0},
        src = "assets/OptionHighlight.png"
    }

    function view:Create_Menu_Items()
        view.menu_items = {}
        --gut the UI
        view.ui:clear()
        view.ui:add(view.selector)
        view.menu_items = view.parent.sub_group_items
        for i, t in ipairs(view.menu_items) do
            view.ui:add(unpack(view.menu_items[i]))
        end
    end

    screen:add(view.ui)

    function view:initialize()
        view:set_controller(TabController(self))
    end

    function view:leave_sub_group()
        --view.parent.menu_items[view.parent:get_controller():get_selected_index()]:animate{duration= 100, opacity = 255}
        --view.parent.sub_group[view.parent:get_controller():get_selected_index()]:animate{duration = 100, opacity = 100}
       model:set_active_component(Components.CUSTOMIZE)
       view:get_controller():reset_selected_index()
       view.selector.y = 0
       local sel = view.parent:get_controller():get_selected_index()
       view.parent.sub_group[sel].y = 80
       local sub_group_items = view.parent.sub_group_items
       for i=1,#sub_group_items[sel] do
          if i <= CUSTOMIZE_SCROLL_THRESHOLD then
             for _, item in ipairs(sub_group_items[sel][i]) do
                item.opacity = 255
             end
          else
             for _, item in ipairs(sub_group_items[sel][i]) do
                item.opacity = 0
             end
          end
       end
       self:get_model():notify()
    end

    function view:move_selector_up(i)

        local bound = #view.menu_items[view.parent:get_controller():get_selected_index()]
        print("\n\nbound",bound,"i",i)
        --if bound > 13 then bound = 13 end
        if view.selector.y ~= 0 then 
           view.selector.y = view.parent.sub_group[view.parent:get_controller():get_selected_index()].y- view.ui.y + view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i][1].y-10---view.selector.y-60
           --view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i][4]:on_focus()
           --view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i+1][4]:out_focus()
        elseif bound > CUSTOMIZE_SCROLL_THRESHOLD then
             print("\n\n1",view.parent.sub_group[view.parent:get_controller():get_selected_index()].y)
             view.parent.sub_group[view.parent:get_controller():get_selected_index()].y = -60*(i-2)+20

             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i][1].opacity = 255
             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i][2].opacity = 255
             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i][3].opacity = 255
             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i][4].group.opacity = 255
             
             if view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i+CUSTOMIZE_SCROLL_THRESHOLD] ~= nil then
             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i+CUSTOMIZE_SCROLL_THRESHOLD][1].opacity= 0
             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i+CUSTOMIZE_SCROLL_THRESHOLD][2].opacity= 0
             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i+CUSTOMIZE_SCROLL_THRESHOLD][3].opacity= 0
             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i+CUSTOMIZE_SCROLL_THRESHOLD][4].group.opacity= 0
             end

        end
    end

    function view:move_selector_down(i)
        local bound = #view.menu_items[view.parent:get_controller():get_selected_index()]
        print("\n\nbound",bound,"i",i)
        local edge = CUSTOMIZE_SCROLL_THRESHOLD
        if bound < edge then edge = bound end
        if i <= CUSTOMIZE_SCROLL_THRESHOLD then
           view.selector.y = view.parent.sub_group[view.parent:get_controller():get_selected_index()].y - view.ui.y + view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i][1].y-10
           --view.selector.y+60
           --view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i][4]:on_focus()
           --view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i-1][4]:out_focus()
        elseif bound > CUSTOMIZE_SCROLL_THRESHOLD then
             print("\n\n2",view.parent.sub_group[view.parent:get_controller():get_selected_index()].y)
             view.parent.sub_group[view.parent:get_controller():get_selected_index()].y = -60*(i-1-CUSTOMIZE_SCROLL_THRESHOLD)+20

             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i][1].opacity = 255
             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i][2].opacity = 255
             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i][3].opacity = 255
             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i][4].group.opacity = 255

             if view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i-edge] ~= nil then
             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i-edge][1].opacity= 0
             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i-edge][2].opacity= 0
             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i-edge][3].opacity= 0
             view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i-edge][4].group.opacity= 0
             end

        end
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.TAB then
            print("Showing TabView UI")
            view.ui.opacity = 255
            view.selector.opacity = 255
            for i,option in ipairs(view.menu_items[view.parent:get_controller():get_selected_index()]) do
                for j,item in ipairs(option) do
                    if i == controller:get_selected_index() then

           view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i][4]:on_focus()
                    else
                        --item:animate{duration=100, opacity = 100}
           view.parent.sub_group_items[view.parent:get_controller():get_selected_index()][i][4]:out_focus()
                    end
                end
            end
        elseif comp == Components.CUSTOMIZE_ITEM then
            print("Greying TabView UI")
            --view.ui.opacity = 100
        else
            print("Hiding TabView UI")
            view.ui.opacity = 0
            view.selector.opacity = 0
        end
    end
    

   end)
