CreditInfoView = Class(View, function(view, model, parent_view, ...)
    view._base.init(view, model)

    view.parent_view = parent_view
    
    local Info = {
        DRIVER_INSTRUCTIONS = 1,
        PASSWORD = 2,
        NAME = 3,
        PHONE = 4,
        EMAIL = 5,
        CARD_TYPE = 6,
        CARD_NUMBER = 7,
        CARD_EXPIRATION = 8,
        BILL_STREET = 9,
        BILL_CITY = 10
    }

    
    --driverInstructionsTextBox
    local driverInstructionsTextBox = TextBox(1020, 120, 1760-1040)
    --entry for instructions for the driver
    local driverInstructionsEntry = Text{
        position = {1030, 135},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "Note to the driver?",
        max_length = 24,
        wants_enter = false
    }
    local driverInstructionsTable = {{driverInstructionsEntry, driverInstructionsTextBox}}

    --password TextBox
    local passwordTextBox = TextBox(1460, 260, 1740-1460)
    --password entry place
    local passwordEntry = Text{
        position = {1475, 280},
        font = CUSTOMIZE_TINIER_FONT,
        color = Colors.BLACK,
        text = "Password?",
        max_length = 14,
        wants_enter = false
    }
    local passwordTable = {{passwordEntry, passwordTextBox}}

    --credit card textboxs
    local firstNameTextBox = TextBox(1140, 400, 1420-1140)
    local lastNameTextBox = TextBox(1440, 400, 1440-1140)
    --name entry places
    local firstName = Text{
        position = {1150, 415},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "First",
        max_length = 10,
        wants_enter = false
    }
    local lastName = Text{
        position = {1450, 415},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "Last",
        max_length = 10,
        wants_enter = false
    }
    local nameTable = {{firstName,firstNameTextBox}, {lastName,lastNameTextBox}}

    --more credit textbox stuff for entering phone number
    local phoneTextBox1 = TextBox(1140, 460, THREE_CHARACTERS)
    local phoneTextBox2 = TextBox(1230, 460, THREE_CHARACTERS)
    local phoneTextBox3 = TextBox(1320, 460, FOUR_CHARACTERS)
    local phoneTextBox4 = TextBox(1460, 460, THREE_CHARACTERS)
    --phone entry places
    local areaCode = Text{
        position = {1150, 475},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "###",
        max_length = 3,
        wants_enter = false
    }
    local firstThreeDigits = Text{
        position = {1240, 475},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "###",
        max_length = 3,
        wants_enter = false
    }
    local lastFourDigits = Text{
        position = {1330, 475},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "####",
        max_length = 4,
        wants_enter = false
    }
    local extension = Text{
        position = {1470, 480},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "###",
        max_lengt = 3,
        wants_enter = false
    }
    local phoneTable = {
        {areaCode, phoneTextBox1},
        {firstThreeDigits, phoneTextBox2},
        {lastFourDigits, phoneTextBox3},
        {extension, phoneTextBox4}
    }

    --email
    local emailNameTextBox = TextBox(1140, 520, 1420-1140)
    local emailAtTextBox = TextBox(1460, 520, 1420-1140)
    --email entry stuff
    local emailHandle = Text{
        position = {1150, 535},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "email",
        max_length = 20,
        wants_enter = false
    }
    local emailAt = Text{
        position = {1470, 535},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "trickplay.com",
        max_length = 20,
        wants_enter = false
    }
    local emailTable = {{emailHandle,emailNameTextBox}, {emailAt,emailAtTextBox}}

    --credit type
    local dottedSquare1 = Image{
        src = "assets/credit_stuff/PaymentHighlight.png",
        position = {990,600}
    }
    local dottedSquare2 = Clone{source = dottedSquare1}
    dottedSquare2.position = {1140, 600}
    local dottedSquare3 = Clone{source = dottedSquare1}
    dottedSquare3.position = {1300, 600}
    local dottedSquare4 = Clone{source = dottedSquare1}
    dottedSquare4.position = {1450, 600}
    local dottedSquare5 = Clone{source = dottedSquare1}
    dottedSquare5.position = {1590, 600}
    local dottedSquareTable = {
        {dottedSquare1}, {dottedSquare2}, {dottedSquare3}, {dottedSquare4}, {dottedSquare5}
    }

    --card number entry textboxs
    local cardTextBox1 = TextBox(1140, 720, FOUR_CHARACTERS)
    local cardTextBox2 = TextBox(1250, 720, FOUR_CHARACTERS)
    local cardTextBox3 = TextBox(1360, 720, FOUR_CHARACTERS)
    local cardTextBox4 = TextBox(1470, 720, FOUR_CHARACTERS)
    --credit number
    local credit1 = Text{
        position = {1150, 740},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "####",
        max_length = 4,
        wants_enter = false
    }
    local credit2 = Text{
        position = {1260, 740},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "####",
        max_length = 4,
        wants_enter = false
    }
    local credit3 = Text{
        position = {1370, 740},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "####",
        max_length = 4,
        wants_enter = false
    }
    local credit4 = Text{
        position = {1480, 740},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "####",
        max_length = 4,
        wants_enter = false

    }
    local creditTable = {
        {credit1, cardTextBox1}, {credit2, cardTextBox2},
        {credit3, cardTextBox3}, {credit4, cardTextBox4}
    }

    --card expiration textboxs
    local expirationMonthTextBox = TextBox(1140, 780, TWO_CHARACTERS)
    local expirationYearTextBox = TextBox(1220, 780, FOUR_CHARACTERS)
    --expiration date
    local expMonth = Text{
        position = {1150, 800},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "MM",
        max_length = 2,
        wants_enter = false
    }
    local expYear = Text{
        position = {1240, 800},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "YYYY",
        max_length = 4,
        wants_enter = 2
    }
    --CVC
    local secretCodeTextBox = TextBox(1490, 780, THREE_CHARACTERS)
    --card code junk
    local cardCode = Text{
        position = {1500, 795},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "###",
        max_length = 3,
        wants_enter = false
    }
    local expirationTable = {
        {expMonth, expirationMonthTextBox}, {expYear, expirationYearTextBox},
        {cardCode, secretCodeTextBox}
    }
    
    --Street Address TextBox
    local streetBillingTextBox = TextBox(1140, 840, 1750-1140)
    --Street Billing Address
    local streetBilling = Text{
        position = {1150, 855},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "Enter Street/Apt.",
        max_length = 22,
        wants_enter = false
    }
    local streetBillingTable = {{streetBilling, streetBillingTextBox}}
    --City
    local cityBillingTextBox = TextBox(1140, 900, 1540-1150)
    local stateBillingTextBox = TextBox(1540, 900, TWO_CHARACTERS)
    local zipBillingTextBox = TextBox(1620, 900, 1760-1630)
    local cityBilling = Text{
        position = {1150, 915},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "Enter City",
        max_length = 13,
        wants_enter = false
    }
    local stateBilling = Text{
        position = {1545, 915},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "CA",
        max_length = 2,
        wants_enter = false
    }
    local zipBilling = Text{
        position = {1630, 915},
        font = CUSTOMIZE_ENTRY_FONT,
        color = Colors.BLACK,
        text = "#####",
        max_length = 5,
        wants_enter = false
    }
    local cityStateZipBillingTable = {
        {cityBilling, cityBillingTextBox},
        {stateBilling, stateBillingTextBox}, {zipBilling, zipBillingTextBox}
    }

    view.info = {
        driverInstructionsTable, passwordTable, nameTable, phoneTable, emailTable,
        dottedSquareTable, creditTable, expirationTable, streetBillingTable,
        cityStateZipBillingTable
    }

    view.textBoxes_ui = Group{name="textBoxes_ui", position = {0,0}}
    view.textElements_ui = Group{name="textElements_ui", position = {0,0}}
    view.ui = Group{name="creditInfo_ui", position={0, 0}, opacity=255}
    for i,t in ipairs(view.info) do
        for j,sub_t in ipairs(t) do
            view.textElements_ui:add(sub_t[1])
            if(sub_t[2]) then
                view.textBoxes_ui:add(sub_t[2].group)
            end
        end
    end
    view.ui:add(view.textBoxes_ui, view.textElements_ui)
    view.ui:raise_to_top()

    function view:initialize()
        self:set_controller(CreditInfoController(self))
    end

    function view:update()
        screen:grab_key_focus()
        local controller = self:get_controller()
        local comp = model:get_active_component()
        if comp == Components.CHECKOUT then
            assert(controller:get_selected_index())
            assert(controller:get_sub_selection_index())
            print("Showing CreditInfoView UI")
            for i,t in ipairs(self.info) do
                for j,item in ipairs(t) do
                    if(i == controller:get_selected_index()) and 
                      (j == controller:get_sub_selection_index()) then
                        item[1]:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                        if(item[2]) then
                            item[2]:on_focus()
                        end
                    elseif(Info.CARD_TYPE == i) then
                        if(model:selected_card() == j) then
                            item[1]:animate{duration=CHANGE_VIEW_TIME, opacity=255}
                        else
                            item[1]:animate{duration=CHANGE_VIEW_TIME, opacity=0}
                        end
                    else
                        item[1]:animate{duration=CHANGE_VIEW_TIME, opacity=100}
                        if(item[2]) then
                            item[2]:out_focus()
                        end
                    end
                end
            end
        else
            print("Hiding CreditInfoView UI")
            self.ui:complete_animation()
            self.ui.opacity = 0
        end
    end

end)
