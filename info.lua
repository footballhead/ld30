info = {
    init = function( self )
        self.text = love.graphics.newImage( "assets/info-screen.png" )
        controls:init()
    end,

    update = function( self )
    end,

    mousepressed = function( self, x, y, button )
        if button == 'l' or button == 'r' or button == 'm' then
            screen = controls
        end
    end,

    mousereleased = function( self, x, y, button )
    end,

    draw = function( self )
        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.draw( self.text, 0, 0 )
    end,
}

controls = {
    init = function( self )
        self.text = love.graphics.newImage( "assets/controls.png" )
    end,

    update = function( self )
    end,

    mousepressed = function( self, x, y, button )
        if button == 'l' or button == 'r' or button == 'm' then
            screen = game
        end
    end,

    mousereleased = function( self, x, y, button )
    end,

    draw = function( self )
        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.draw( self.text, 0, 0 )
    end,
}
