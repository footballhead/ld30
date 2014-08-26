
MainMenuButton = {
    new = function( self )
    end
}

mainmenu = {
    init = function( self )
        local winw, winh = love.graphics.getDimensions()

        self.bg = love.graphics.newImage( "assets/menu-bg.jpg" )
        self.title = love.graphics.newImage( "assets/title.png" )
        self.title_text = love.graphics.newImage( "assets/title-text.png" )
        self.time = 0
    end,

    update = function( self, dt )
        self.time = self.time + dt

    end,

    mousepressed = function( self, x, y, button )
        if button == 'l' or button == 'r' or button == 'm' then
            screen = info
        end
    end,

    mousereleased = function( self, x, y, button )
    end,

    draw = function( self )
        local winw, winh = love.graphics.getDimensions()

        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.draw( self.bg, 0, 0 )

        local derp = self.time / 0.5
        if derp > 1 then derp = 1 end

        local titlex = winw / 2 - self.title:getWidth() / 2
        local titley = -64 - self.title:getHeight() / 2 + 192 * derp


        local dx = winw / 2 - self.title:getWidth() / 2
        local dy = 128 - self.title:getHeight() / 2
        love.graphics.draw( self.title, titlex, titley )

        dx = winw / 2 - self.title_text:getWidth() / 2
        dy = winh / 2 - self.title_text:getHeight() / 2 + 128
        love.graphics.draw( self.title_text, dx, dy )
    end,
}
