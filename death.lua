death = {
    init = function( self )
        self.text = love.graphics.newImage( "assets/death-screen.png" )
    end,

    update = function( self )
    end,

    mousepressed = function( self, x, y, button )
    end,

    mousereleased = function( self, x, y, button )
    end,

    draw = function( self )
        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.draw( self.text, 0, 0 )
    end,
}

bankrupt = {
    init = function( self )
        self.text = love.graphics.newImage( "assets/bankrupt-screen.png" )
    end,

    update = function( self )
    end,

    mousepressed = function( self, x, y, button )
    end,

    mousereleased = function( self, x, y, button )
    end,

    draw = function( self )
        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.draw( self.text, 0, 0 )
    end,
}

notime = {
    init = function( self )
        self.text = love.graphics.newImage( "assets/terminate-screen.png" )
    end,

    update = function( self )
    end,

    mousepressed = function( self, x, y, button )
    end,

    mousereleased = function( self, x, y, button )
    end,

    draw = function( self )
        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.draw( self.text, 0, 0 )
    end,
}

win = {
    init = function( self )
        self.text = love.graphics.newImage( "assets/democracy-screen.png" )
    end,

    update = function( self )
    end,

    mousepressed = function( self, x, y, button )
    end,

    mousereleased = function( self, x, y, button )
    end,

    draw = function( self )
        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.draw( self.text, 0, 0 )
    end,
}

uhhh = {
    init = function( self )
        self.text = love.graphics.newImage( "assets/commie-screen.png" )
    end,

    update = function( self )
    end,

    mousepressed = function( self, x, y, button )
    end,

    mousereleased = function( self, x, y, button )
    end,

    draw = function( self )
        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.draw( self.text, 0, 0 )
    end,
}
