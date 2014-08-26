-- object representing the on-screen map (most loaded in love.load)
Map = {
    new = function( self, image, mask, x, y )
        local o = {}
        self.__index = self
        setmetatable( o, self )

        o.image = love.graphics.newImage( image )
        o.mask = love.graphics.newImage( mask )
        o.data = o.mask:getData()
        o.x = x
        o.y = y
        o.graph = Graph:new()

        return o
    end,

    get_country = function( self, x, y, cntmap )
        -- using global map mask data get country color
        local r, g, b, a = self.data:getPixel( x, y )
        -- DBG: print color to console so we know what happened if we crash
        --print( tostring(r)..","..tostring(g)..","..tostring(b) )
        -- use R, G, B of pixel along with table to translate
        return cntmap[r][g][b]
    end,

    draw = function( self )
        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.draw( self.image, self.x, self.y )
        love.graphics.setColor( 255, 255, 255, 128 )
        love.graphics.draw( self.mask, self.x, self.y )

        self.graph:draw()
    end,
}
