-- The Country object
Country = {
    -- a table of all countries; country name is mapped to country object
    instances = {},
    -- mapping of rgb to country
    rgb = {},
    governments = { 'communist', "democracy" },

    new = function( self, name, col )
        local o = {}
        self.__index = self
        setmetatable( o, self )

        o.name = name
        o.pop = 100
        o.favor = 100
        o.neighbors = {}
        o.government = 'communist'
        o.r = col[1]
        o.g = col[2]
        o.b = col[3]
        o.growth = math.random() / 10
        o.vertices = {}
        o.point = {}
        --o.connect

        o:add_to_color_map()

        self.instances[name] = o

        return o
    end,

    spread_politics = function( self )
        for key, val in pairs( Country.instances ) do
            if self.pop > val.pop then
                if self:is_connected_to( val.name ) then
                    val.government = self.government
                    RisingText:new( "Changed to "..self.government, val.point[1], val.point[2], game.gui_font_bold )
                end
            end
        end
    end,

    add_to_color_map = function( self )
        if Country.rgb[self.r] == nil then
            Country.rgb[self.r] = {}
        end

        if Country.rgb[self.r][self.g] == nil then
            Country.rgb[self.r][self.g] = {}
        end

        Country.rgb[self.r][self.g][self.b] = self.name

        --error( Country.rgb[ self.r ][ self.g ][ self.b ] )
    end,

    get_mood = function( self )
        if self.favor < 10 then
            return "murderous intent"
        elseif self.favor < 30 then
            return "steaming with anger"
        elseif self.favor < 50 then
            return "unhappy"
        elseif self.favor < 90 then
            return "content"
        else
            return "very happy"
        end
    end,

    get_stats = function( self )
        local stats = {}

        stats[#stats+1] = "POPULATION: " .. math.floor( self.pop )
        stats[#stats+1] = "MOOD: " .. self:get_mood()
        stats[#stats+1] = "GOVERNMENT: " .. self.government

        return stats
    end,

    draw_stats = function( self, dx, dy, fnt, bldfnt )
        local stats = self:get_stats()
        local pad = 4
        local lineh = 16
        local dh = pad * 2 + ( #stats + 1 ) * lineh
        local offy = dh * -1

        love.graphics.setLineWidth( 2 )
        love.graphics.setColor( 128, 128, 128, 255 )
        love.graphics.rectangle( 'fill', dx, dy + offy, 256, dh )

        love.graphics.setColor( 64, 64, 64, 255 )
        love.graphics.rectangle( 'line', dx, dy + offy, 256, dh )

        love.graphics.setColor( 255, 255, 255, 255 )
        love.graphics.setFont( bldfnt )
        love.graphics.print( self.name, dx + pad, dy + pad + offy )
        love.graphics.setFont( fnt )

        for i, line in ipairs( stats ) do
            love.graphics.print( line, dx + pad, dy + pad + lineh * i + offy )
        end
    end,

    update = function( self, dt )
        local timeobj = game.time
        local delta = timeobj:get_delta()
        local growth = self.growth + #self.vertices / 200
        print( #self.vertices)
        local increase = self.pop * growth

        self.pop = self.pop + increase * delta

        local nopower = 0
        for i, vertex in ipairs( self.vertices ) do
            if not vertex.has_power then
                nopower = nopower + 1
            end
        end

        self.favor = self.favor - nopower * delta * 2

        --if self.favor > 100 then self.favor = 100 end
    end,

    is_connected_to = function( self, countryname )
        for i, vertex in ipairs( self.vertices ) do
            for ii, edge in ipairs( vertex.edges ) do
                if edge.verstart.country.name == countryname then
                    return true
                elseif edge.verend.country.name == countryname then
                    return true
                end
            end
        end

        return false
    end,
}

Country.rgb[0] = {}
Country.rgb[0][0] = {}
Country.rgb[0][0][0] = "None"

-- create all countries
Country:new( "Ibar", {255, 255, 255} )
Country:new( "Ebini", {0, 255, 0} )
Country:new( "Malietaia", {255, 0, 0} )
Country:new( "Albymna", {255, 255, 0} )
Country:new( "Afria", {0, 0, 255} )
Country:new( "Uguanini", {0, 128, 0} )
Country:new( "Zeeladul", {255, 0, 255} )
Country:new( "Casadaia", {0, 255, 255} )
Country:new( "Arcya", {0, 0, 128} )
Country:new( "Egycano", {128, 0, 255} )
Country:new( "Trysana", {128, 0 ,0} )

-- set neighbours to assemble some sort of graph
--[[Country.instances["Zeeladul"].neighbors[1] = Country.instances["Albymna"]
Country.instances["Zeeladul"].neighbors[2] = Country.instances["Casadaia"]
Country.instances["Zeeladul"].neighbors[3] = Country.instances["Ebini"]

Country.instances["Albymna"].neighbors[1] = Country.instances["Zeeladul"]
Country.instances["Albymna"].neighbors[2] = Country.instances["Trysana"]
Country.instances["Albymna"].neighbors[2] = Country.instances["Afria"]

Country.instances["Trysana"].neighbors[1] = Country.instances["Albymna"]
Country.instances["Trysana"].neighbors[2] = Country.instances["Afria"]

Country.instances["Afria"].neighbors[1] = Country.instances["Trysana"]
Country.instances["Afria"].neighbors[4] = Country.instances["Uguanini"]

Country.instances["Casadaia"].neighbors[1] = Country.instances["Zeeladul"]
Country.instances["Casadaia"].neighbors[2] = Country.instances["Egycano"]
Country.instances["Casadaia"].neighbors[3] = Country.instances["Uguanini"]
Country.instances["Casadaia"].neighbors[4] = Country.instances["Ibar"]

Country.instances["Egycano"].neighbors[1] = Country.instances["Casadaia"]
Country.instances["Egycano"].neighbors[2] = Country.instances["Uguanini"]
Country.instances["Egycano"].neighbors[3] = Country.instances["Arcya"]

Country.instances["Arcya"].neighbors[1] = Country.instances["Egycano"]

Country.instances["Uguanini"].neighbors[1] = Country.instances["Egycano"]
Country.instances["Uguanini"].neighbors[2] = Country.instances["Casadaia"]
Country.instances["Uguanini"].neighbors[3] = Country.instances["Ibar"]
Country.instances["Uguanini"].neighbors[4] = Country.instances["Afria"]

Country.instances["Ibar"].neighbors[1] = Country.instances["Uguanini"]
Country.instances["Ibar"].neighbors[1] = Country.instances["Casadaia"]

Country.instances["Ebini"].neighbors = {}
Country.instances["Ibar"].neighbors = {}
Country.instances["Malietaia"].neighbors = {}]]

Country.instances["Zeeladul"].point = { 441, 560 }
Country.instances["Albymna"].point = { 174, 661 }
Country.instances["Trysana"].point = { 130, 439 }
Country.instances["Afria"].point = { 972, 470 }
Country.instances["Casadaia"].point = { 529, 265 }
Country.instances["Egycano"].point = { 316, 102 }
Country.instances["Arcya"].point = { 301, 148 }
Country.instances["Uguanini"].point = { 807, 194 }
Country.instances["Ibar"].point = { 731, 297 }
Country.instances["Ebini"].point = { 637, 636 }
Country.instances["Malietaia"].point = { 336, 322}

Country.instances["Casadaia"].government = 'democracy'
