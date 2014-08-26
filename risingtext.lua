RisingText = {
    instances = {},
    color = { 255, 255, 255 },
    shadow = { 0, 0, 0 },

    new = function( self, text, x, y, font )
        local o = {}
        self.__index = self
        setmetatable( o, self )

        o.text = text
        o.startx = x
        o.starty = y
        o.curx = x
        o.cury = y
        o.alpha = 1
        o.font = font

        self.instances[#self.instances + 1] = o

        return o
    end,

    is_dead = function( self )
        return self.alpha <= 0
    end,

    update = function( self, dt )
        self.alpha = self.alpha - dt
        self.cury = self.cury - dt * 50
    end,

    draw = function( self )
        local da = self.alpha * 255
        if da < 0 then da = 0 end

        local col = { self.color[1], self.color[2], self.color[3], da }
        local shad = { self.shadow[1], self.shadow[2], self.shadow[3], da }

        love.graphics.printshadow( self.text, self.curx, self.cury, 2, self.font, col, shad )
    end,

}
