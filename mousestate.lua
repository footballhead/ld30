
MouseState = {
    new = function( self )
        local o = {}
        self.__index = self
        setmetatable( o, self )

        o.down = false
        o.click = false
        o.clickx = 0
        o.clicky = 0

        return o
    end
}
