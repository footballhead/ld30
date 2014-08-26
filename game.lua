-- line used to preview where networks are built
-- FIX: this should not be a global object!!
preview_line = {
    -- location of start (endpoint is at mouse)
    -- if (-1,-1) then don't draw
    node = nil,
    master = nil,
    limit = 75,

    is_active = function( self )
        return self.node ~= nil
    end,

    enable = function( self, node )
        self.node = node
        self.master.mode = 'build'
    end,

    disable = function( self )
        self.node = nil
        self.master.mode = 'stats'
    end,

    draw = function( self, endx, endy )
        if not self:is_active() then return end

        local length = utils.eucdist( self.node.x, self.node.y, endx, endy )
        local cost = Edge:get_cost( length )

        if self.master.bank:has_funds( cost ) and length < self.limit then
            love.graphics.setColor( 0, 128, 0, 128 )
        else
            love.graphics.setColor( 255, 0, 0, 128 )
        end

        love.graphics.setLineWidth( 2 )
        love.graphics.line( self.node.x, self.node.y, endx, endy )

        if length > self.limit then
            love.graphics.printshadow( "Too long!", endx, endy - 16, 1, self.master.gui_font )
        else
            love.graphics.printshadow( tostring(cost), endx, endy - 16, 1, self.master.gui_font )
        end
    end,

    get_cost = function( self, endx, endy )
        local length = utils.eucdist( self.node.x, self.node.y, endx, endy )
        return Edge:get_cost( length )
    end,
}



game = {
    init = function( self )
        local winw, winh = love.graphics.getDimensions()
        local tmp = nil
        local stoptime = function() self.time.factor = 0; music:pause() end
        local starttime = function() self.time.factor = 1; music:play(); music:setPitch( 1 ) end
        local fastforwardtime = function() self.time.factor = 5; music:play(); music:setPitch( 2 ) end
        local menu_action = function( country, action )
            --if action == "Take some funds" then
            --    self.bank:add_funds( 200, country )
            --elseif action == "Give back funds" then
            --    self.bank:take_country_all_funds( country )
            --end
        end

        preview_line.master = self

        -- load the map we will use
        self.map = Map:new( "assets/Map-790.png", "assets/Map-790-mask.png", 0, 0 )

        -- load font used for gui
        self.gui_font = love.graphics.newFont( "assets/LiberationSans-Regular.ttf" )
        self.gui_font_bold = love.graphics.newFont( "assets/LiberationSans-Bold.ttf" )

        self.lmb = MouseState:new()
        self.rmb = MouseState:new()
        self.mmb = MouseState:new()

        self.menu = Menu:new( self, { "Herpaderp", "foo bar baz" }, self.gui_font, self.gui_font_bold, menu_action )

        self.time = GameTime:new()

        self.bank = Bank:new( 1500 )
        self.earnings = 0

        -- valid modes are 'stats', 'menu', and 'build'
        self.mode = 'stats'

        -- load gui buttons
        Button:new( winw - 96, winh - 64 , "assets/pause.png", "assets/pause-press.png", stoptime )
        tmp = Button:new( winw - 64, winh - 64 , "assets/play.png", "assets/play-press.png", starttime )
        Button:new( winw - 32, winh - 64 , "assets/fast-forward.png", "assets/fast-forward-press.png", fastforwardtime )

        -- HCK to get play button properly highlighted
        tmp:click()
    end,

    try_to_make_node = function( self, x, y )
        local countryname = self.map:get_country( x, y, Country.rgb )

        -- make sure we are clicking on a country
        if countryname ~= "None" then
            -- make sure we have enough money
            if self.bank:has_funds( Vertex.cost ) then
                -- make sure the vertex isn't too close to something else
                if self.map.graph:can_add_vertex( x, y ) then
                    -- actually make the vertex and add to graph
                    local countryobj = Country.instances[countryname]
                    local newvert = Vertex:new( self.map.graph, x, y, countryobj )

                    self.bank:take( Vertex.cost )
                    RisingText:new( "-"..tostring(Vertex.cost), x, y, self.gui_font )
                else
                    RisingText:new( "Too close!", x, y, self.gui_font )
                end
            else
                RisingText:new( "Need $"..tostring(Vertex.cost), x, y, self.gui_font )
            end
        else
            RisingText:new( "Can only build hubs in countries!", x, y, self.gui_font )
        end
    end,


    new_month = function( self, month )
        if month == 20 then
            screen = notime
        end

        for key, val in pairs( Country.instances ) do
            print( key )
            val:spread_politics()
        end
    end,


    try_to_make_line = function( self, endx, endy )
        -- try to find an existing vertex; make one otherwise
        local node = self.map.graph:find_vertex( endx, endy )

        if node == nil then
            RisingText:new( "Must end on a hub!", endx, endy, self.gui_font )
        else
            if node == preview_line.node then
                RisingText:new( "Can't start and end on same hub!", endx, endy, self.gui_font )
            else
                local cost = preview_line:get_cost( node.x, node.y )
                if self.bank:has_funds( cost ) then
                    Edge:new( self.map.graph, preview_line.node, node )
                    RisingText:new( "-"..tostring(cost), endx, endy, self.gui_font )
                    self.bank:take( cost )
                else
                    RisingText:new( "Need $"..tostring(cost), endx, endy, self.gui_font )
                end
            end
        end

        -- disable build preview
        preview_line:disable()
    end,


    update = function( self, dt )
        local mx, my = love.mouse.getPosition()

        -- GAMEOVER BANKRUPT
        if self.bank.total <= 0 then
            screen = bankrupt
        end

        local demo = 0
        for key, val in pairs( Country.instances ) do
            -- GAMEOVER UNHAPPY COUNTRY
            if val.favor <= 0 then
                screen = death
            end

            if val.government == 'democracy' then
                demo = demo + 1
            end
        end

        -- WIN: DEMOCRACY AND COMMUNISM
        if demo == 11 then
            screen = win
        elseif demo == 0 then
            screen = uhhh
        end

        -- update countries
        for key, val in pairs( Country.instances ) do
            val:update( dt )
        end

        -- menu is updated before buttons to properly register input (menu appears overtop of buttons)
        self.menu:update()

        -- look for GUI button pushes next
        for i, but in ipairs( Button.instances ) do
            but:update()
        end

        -- update all built communication lines
        self.map.graph:update()

        -- update info text on HUD
        for i, txt in ipairs( RisingText.instances ) do
            txt:update( dt )
        end

        self.earnings = 0
        for i, vert in ipairs( self.map.graph.vertices ) do
            local rate = vert:get_rate()
            self.earnings = self.earnings + rate
            local delta = self.time:get_delta()
            self.bank.total = self.bank.total + rate * delta
        end

        if self.lmb.click then
            if self.mode == 'menu' then
                -- this happens if we click outside of the menu
                self.menu:close()
            elseif self.mode == 'build' then
                self:try_to_make_line( self.lmb.clickx, self.lmb.clicky )
            elseif self.mode == 'stats' then
                local x = self.lmb.clickx
                local y = self.lmb.clicky
                local node = self.map.graph:find_vertex( x, y )

                if node ~= nil then
                    preview_line:enable( node )
                else
                    RisingText:new( "Must start at a hub!", x, y, self.gui_font )
                end
            end
        end

        if self.rmb.click then
            if self.mode == 'menu' then
                self.menu:close()
            elseif self.mode == 'build' then
                preview_line:disable()
            elseif self.mode == 'stats' then
                local vert = self.map.graph:find_vertex( self.rmb.clickx, self.rmb.clicky )

                if vert == nil then
                    self:try_to_make_node( self.rmb.clickx, self.rmb.clicky )
                else
                    vert:try_to_upgrade( self )
                end
            end
        end

        -- always reset click status so only active for 1 frame
        self.lmb.click = false
        self.rmb.click = false
        self.mmb.click = false

        -- update internal clock to push things along
        self.time:update( dt )
    end,


    draw = function( self, dt )
        local mx, my = love.mouse.getPosition()

        -- draw map img
        self.map:draw()

        -- draw all momentary hud text
        for i, txt in ipairs( RisingText.instances ) do
            txt:draw()
        end


        -- draw date in bottom corner of screen
        local winw, winh = love.graphics.getDimensions()
        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.setFont( self.gui_font_bold )
        love.graphics.print( "DATE: " .. self.time:get_date(), winw - 192, winh - 32 )

        -- draw the gui buttons
        for i, but in ipairs( Button.instances ) do
            but:draw()
        end

        -- mode dependent drawing
        if self.mode == 'build' then
            -- draw preview line if we are building
            preview_line:draw( mx, my )
        elseif self.mode == 'stats' then
            -- draw stats menu if hovering over country
            local cntry = self.map:get_country( mx, my, Country.rgb )

            if cntry ~= "None" then
                Country.instances[cntry]:draw_stats( mx, my, self.gui_font, self.gui_font_bold )
            end
        elseif self.mode == 'menu' then
            -- draw menu if it is open
            self.menu:draw()
        end

        self.bank:draw( winw / 2, winh-32, self.gui_font_bold )
        love.graphics.setFont( self.gui_font )
        love.graphics.print( "Earnings: "..tostring(self.earnings), winw / 2, winh-16)

        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.setFont( self.gui_font_bold )
        love.graphics.print( love.timer.getFPS(), 128, 128 )
    end,

    mousepressed = function( self, x, y, button )
        if button == 'l' then
            self.lmb.down = true
        elseif button == 'r' then
            self.rmb.down = true
        elseif button == 'm' then
            self.mmb.down = true
        end
    end,

    mousereleased = function( self, x, y, button )
        if button == 'l' and self.lmb.down then
            self.lmb.down = false
            self.lmb.click = true
            self.lmb.clickx = x
            self.lmb.clicky = y
        elseif button == 'r' and self.rmb.down then
            self.rmb.click = true
            self.rmb.down = false
            self.rmb.clickx = x
            self.rmb.clicky = y
        elseif button == 'm' and self.mmb.down then
            self.mmb.click = true
            self.mmb.down = false
            self.mmb.clickx = x
            self.mmb.clicky = y
        end
    end,
}
