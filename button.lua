Button = {
    -- add all buttons to this list kthnxbai
    instances = {},

    new = function( self, x, y, img, press_img, callback )
        local o = {}
        self.__index = self
        setmetatable( o, self )

        o.x = x
        o.y = y

        o.pushed = false

        o.img = {}
        o.img[1] = love.graphics.newImage( img )
        o.img[2] = love.graphics.newImage( press_img )
        o.callback = callback

        self.instances[#self.instances + 1] = o

        return o
    end,

    update = function( self )
        local mx, my = love.mouse.getPosition()

        local lx = mx - self.x
        local ly = my - self.y
        local img = self.img[1]

        if lx > 0 and lx < img:getWidth() and ly > 0 and ly < img:getHeight() then
            if game.lmb.click then
                self:click()
            end
        end
    end,

    click = function( self )
        for i, but in ipairs( Button.instances ) do
            but.pushed = false
        end

        self.pushed = true
        game.lmb.click = false

        self.callback()
    end,

    draw = function( self )
        local frame = 1

        if self.pushed then frame = 2 end

        love.graphics.draw( self.img[frame], self.x, self.y )
    end,
}
