Graph = {
    new = function( self )
        local o = {}
        self.__index = self
        setmetatable( o, self)

        o.vertices = {} -- vertex list
        o.edges = {}    -- edge list

        return o
    end,

    find_vertex = function( self, x, y )
        for i, vert in ipairs( self.vertices ) do
            if vert:is_point_inside( x, y ) then return vert end
        end

        return nil
    end,

    can_add_vertex = function( self, x, y )
        for i, vert in ipairs( self.vertices ) do
            if utils.circle_intersect( x, y, Vertex.space, vert.x, vert.y, Vertex.space ) then
                return false
            end

        end

        return true
    end,

    add_vertex = function( self, vert )
        self.vertices[#self.vertices + 1] = vert
    end,

    add_edge = function( self, edge )
        self.edges[#self.edges + 1] = edge
    end,

    update = function( self, dt )
        for i, edge in ipairs( self.edges ) do
            edge:update( dt )
        end

        for i, vert in ipairs( self.vertices ) do
            vert:update( dt )
        end
    end,

    draw = function( self )
        for i, edge in ipairs( self.edges ) do
            edge:draw()
        end

        for i, vert in ipairs( self.vertices ) do
            vert:draw()
        end
    end,

    recalculate_power = function( self )
        self:reset_power()

        print( "RECALCULATE POWER" )

        local queue = self:get_sources()
        if queue == nil then return end

        local seen = {}

        while #queue ~= 0 do
            -- get the last element of the queue and remove it (fast)
            local last = queue[#queue]
            queue[#queue] = nil

            -- check if the vert has already been visited
            local inseen = false
            for i, vert in ipairs( seen ) do
                if last == vert then
                    inseen = true
                    break
                end
            end

            if not inseen and last.progress == 1 then
                -- we found it so it must have power
                last.has_power = true

                -- give all the adjacent edges power then add their vertices to list
                for i, edge in ipairs( last.edges ) do
                    if edge.progress == 1 then
                        edge.has_power = true

                        queue[#queue+1] = edge.verend
                        queue[#queue+1] = edge.verstart
                    end
                end

                -- add to seen list
                seen[#seen+1] = last
            end


        end
    end,

    reset_power = function( self )
        for i, edge in ipairs( self.edges ) do
            edge.has_power = false
        end

        for i, vert in ipairs( self.vertices ) do
            if vert.type == 'source' and vert.progress == 1 then
                vert.has_power = true
            else
                vert.has_power = false
            end
        end
    end,

    get_sources = function( self )
        local ret = {}

        for i, vert in ipairs( self.vertices ) do
            if vert.type == 'source' and vert.progress == 1 then
                ret[#ret+1] = vert
            end
        end

        return ret
    end
}

-- *****************************************************************************
--     VERTEX
-- *****************************************************************************

Vertex = {
    types = { 'perm', 'temp', 'source' },
    radius = 5,
    cost = 100, -- FIX: tweak
    space = 10,
    upgrade = 500; -- FIX: tweak
    buildtime = 1; -- FIX: tweak
    upgradetime = 2; -- FIX: tweak

    new = function( self, graph, x, y, countryobj, type )
        if type == nil then type = 'perm' end

        local o = {}
        self.__index = self
        setmetatable( o, self)

        o.graph = graph
        o.x = x
        o.y = y
        o.country = countryobj
        o.type = type
        o.edges = {} -- adjacent edges
        o.has_power = false
        o.progress = 0
        o.starttime = game.time.time
        o.endtime = o.starttime + self.buildtime

        if not ( countryobj == nil ) then
            o.country.vertices[#o.country.vertices+1] = o
        end

        o.graph:add_vertex( o )

        return o
    end,

    update = function( self, dt )
        if self.progress == 1 then return end

        local buildtime = self.endtime - self.starttime
        local curtime = game.time.time - self.starttime
        self.progress = curtime / buildtime
        if self.progress > 1 then
            self.progress = 1
            self.graph:recalculate_power()
        end
    end,

    is_point_inside = function( self, x, y )
        local lx = x - self.x
        local ly = y - self.y

        return lx >= self.radius*-1 and ly >= self.radius*-1 and lx <= self.radius and ly <= self.radius
    end,

    is_linked = function( self )
        for i, edge in ipairs( self.edges ) do
            if edge.progress == 1 then return true end
        end

        return false
    end,

    add_adjacent_edge = function( self, edge )
        self.edges[#self.edges+1] = edge
    end,

    try_to_upgrade = function( self, game )
        if self.type == 'perm' then
            if self.progress == 1 then
                if game.bank:has_funds( self.upgrade ) then
                    if self:is_linked() then
                        self.type = 'source'
                        self.radius = self.radius * 1.5
                        self.starttime = game.time.time
                        self.endtime = self.starttime + self.upgradetime
                        self.progress = 0
                        self.graph:recalculate_power()
                        game.bank:take( self.upgrade )
                        RisingText:new( "-"..tostring(self.upgrade), self.x, self.y, game.gui_font )
                    else
                        RisingText:new( "Needs to be linked to upgrade!", self.x, self.y, game.gui_font )
                    end
                else
                    RisingText:new( "Need $"..tostring(self.upgrade), self.x, self.y, game.gui_font )
                end
            else
                RisingText:new( "Still building!", self.x, self.y, game.gui_font )
            end
        else
            RisingText:new( "Can't upgrade this joint!", self.x, self.y, game.gui_font )
        end
    end,

    draw = function( self )
        if self.type == 'perm' then
            if self.progress < 1 then
                love.graphics.setColor( 255, 0, 0, 255 )
            elseif not self.has_power then
                love.graphics.setColor( 128, 128, 128, 255 )
            else
                love.graphics.setColor( 0, 255, 255, 255 )
            end
            love.graphics.circle( 'fill', self.x, self.y, self.radius * self.progress, 20 )
        elseif self.type == 'temp' then
            if self.has_power then
                love.graphics.setColor( 192, 192, 192, 255 )
            else
                love.graphics.setColor( 128, 128, 128, 255 )
            end
            love.graphics.rectangle( 'fill', self.x - self.radius, self.y - self.radius, self.radius*2, self.radius*2 )
        elseif self.type == 'source' then
            if self.progress < 1 then
                love.graphics.setColor( 255, 0, 0, 255 )
            else
                love.graphics.setColor( 0, 0, 255, 255 )
            end
            love.graphics.circle( 'fill', self.x, self.y, self.radius * self.progress, 20 )
        else
            error( "INVALID VERTEX TYPE "..self.type )
        end
    end,

    get_rate = function( self )
        if self.progress < 1 then
            return 0
        elseif not self.has_power then
            return 0
        elseif self.type == 'source' then
            return -20
        elseif self.type == 'perm' then
            return 5
        else
            return 0
        end
    end,
}

-- *****************************************************************************
--     EDGE
-- *****************************************************************************

Edge = {
    cost = 1, -- FIX: tweak
    buildtime = 0.05, -- FIX: tweak

    new = function( self, graph, startnode, endnode )
        local o = {}
        self.__index = self
        setmetatable( o, self )

        o.graph = graph
        -- and edge is a line segment; it starts at one vertex and ends at another
        o.verstart = startnode
        o.verend = endnode
        o.progress = 0
        o.length = utils.eucdist( o.verstart.x, o.verstart.y, o.verend.x, o.verend.y )
        o.starttime = game.time.time
        o.endtime = o.starttime + ( o.length * o.buildtime )
        o.has_power = false

        if o.verstart.has_power or o.verend.has_power then
            o.has_power = true
        end

        o.verstart:add_adjacent_edge( o )
        o.verend:add_adjacent_edge( o )
        o.graph:add_edge( o )

        return o
    end,

    update = function( self, dt )
        if self.progress == 1 then return end

        local buildtime = self.endtime - self.starttime
        local curtime = game.time.time - self.starttime
        self.progress = curtime / buildtime
        if self.progress > 1 then
            self.progress = 1
            self.graph:recalculate_power()
        end
    end,

    draw = function( self )
        local xdiff = self.verend.x - self.verstart.x
        local ydiff = self.verend.y - self.verstart.y

        love.graphics.setLineWidth( 3 )

        -- draw line background
        if self.progress < 1 then
            love.graphics.setColor( 255, 0, 0, 128 )
            love.graphics.line( self.verstart.x, self.verstart.y, self.verend.x, self.verend.y )
        end

        -- draw what has actually been built
        if self.progress < 1 then
            love.graphics.setColor( 255, 0, 0, 255 )
        elseif self.has_power then
            love.graphics.setColor( 0, 255, 0, 255 )
        else
            love.graphics.setColor( 128, 128, 128, 255 )
        end
        love.graphics.line( self.verstart.x, self.verstart.y, self.verstart.x + xdiff * self.progress, self.verstart.y + ydiff * self.progress )
    end,

    -- STATIC FUNCTION
    get_cost = function( self, length )
        if self ~= Edge then error( "THIS FUNCTION IS STATIC" ) end

        return length * self.cost
    end,
}
