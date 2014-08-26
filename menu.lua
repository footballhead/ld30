-- the click menu for the country we are hovering over
Menu = {
    new = function( self, master, actions, font, bldfont, callback )
        local o = {}
        self.__index = self
        setmetatable( o, self )

        -- whether the menu is open
        o.opened = false
        -- location to draw menu
        o.x = 0
        o.y = 0
        -- menu dimensions, set by rescan method
        o.w = 256
        o.h = 256
        -- amount of internal padding
        o.pad = 4
        -- how tall lines of text are
        o.line_h = 16
        -- which country this menu is representing
        o.country = nil
        -- list of actions which the menu can perform
        o.actions = actions
        -- which index of action is being hovered over
        o.highlight = 0
        o.fnt = font
        o.bldfnt = bldfont
        o.master = master
        o.callback = callback

        return o
    end,

    -- reset dimensions based on actions
    rescan = function( self )
        -- determine width based on longest action name
        local max = 0

        for i, act in ipairs( self.actions ) do
            local dim = self.fnt:getWidth( act )
            if dim > max then max = dim end
        end

        self.w = max + self.pad * 2

        -- get the height of a line of text
        self.line_h = self.fnt:getHeight()
        -- set height based on number of things in menu and add a bit to the bottom
        self.h = ( #self.actions + 1 ) * self.line_h + self.pad * 3
    end,

    -- open the menu so user can see / interact
    open = function( self, x, y )
        local count = self.master.map:get_country( x, y, Country.rgb )
        if count == "None" then return end

        self.master.mode = 'menu'

        self.x = x
        self.y = y
        self.country = count
        self.country = Country.instances[count]
        self.opened = true
        self.highlight = 0
        self:rescan()
    end,

    close = function( self )
        self.master.mode = 'stats'
        self.opened = false
    end,

    -- recalculate which option is highlighted, perform option clicking
    update = function( self )
        if not self.opened then return end

        local mx, my = love.mouse.getPosition()

        -- get local offset
        local lx = mx - self.x
        local ly = my - self.y

        -- make sure mouse is inside menu
        if lx > 0 and lx < self.w and ly > 0 and ly < self.h then
            -- determine the height of an option
            local cell_h = math.floor( self.h / ( #self.actions + 1 ) )
            -- divide the local offset by the height then remove fraction
            -- abuses the fact that lists in Lua start at 1
            self.highlight = math.floor( ly / cell_h )

            -- if we click the lmb then perform the action related to the highlighted option

            if self.master.lmb.click and self.highlight ~= 0 then
                self.callback( self.country.name, self.actions[ self.highlight ] )
                -- so if over top of gui buttons we don't accidently click one of them
                self.master.lmb.click = false
                -- close the menu
                self:close()
            end
        end

    end,

    -- draw the menu to the screen (if open)
    draw = function( self )
        if not self.opened then return end

        -- draw actual box
        love.graphics.outlinedrect( self.x, self.y, self.w, self.h, { 128, 128, 128, 255 }, { 64, 64, 64, 255 }, 2 )

        -- draw actions
        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.setFont( self.bldfnt )
        love.graphics.print( self.country.name, self.x + self.pad, self.y + self.pad )
        love.graphics.setFont( self.fnt )

        for i, act in ipairs( self.actions ) do
            if self.highlight == i then love.graphics.setColor( 255, 0, 0, 255 ) end
            love.graphics.print( act, self.x + self.pad, self.y + 16 * i + self.pad )
            if self.highlight == i then love.graphics.setColor( 255, 255, 255, 255 ) end
        end
    end,

    --clicked = function( self, act )
        -- DBG: Test transfer pot
    --    self.master.transfer:add_funds( 200, self.country.name )
    --end
}
