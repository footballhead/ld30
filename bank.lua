Bank = {
    new = function( self, initialamnt )
        local o = {}
        self.__index = self
        setmetatable( o, self )

        self.total = initialamnt

        return o
    end,

    has_funds = function( self, amount )
        return self.total >= amount
    end,

    take = function( self, amount )
        self.total = self.total - amount
    end,

    draw = function( self, x, y, bldfnt )
        love.graphics.setFont( bldfnt )
        love.graphics.print( "BANK: "..tostring(self.total), x, y )
    end,
}
