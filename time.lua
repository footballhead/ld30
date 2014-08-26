

-- object which represents and controls game time
GameTime = {
    month_names = { "Blevesh", "Slym", "Stidol", "Elih", "Zyh", "Gliup", "Yninn", "Zask", "Wynocius", "Jugorf" },
    days_in_month = 30,
    months_in_year = 10,
    start_year = 100,

    new = function( self )
        local o = {}
        self.__index = self
        setmetatable( o, self )

        -- if time = n then n days have passed
        self.time = 0
        self.lasttime = 0
        -- 2 seconds = 1 day when factor == 1
        self.factor = 1

        return o
    end,

    -- use the delta time and factor to update the clock and trigger events
    update = function( self, dt )
        self.lasttime = self.time
        self.time = self.time + dt * self.factor / 2

        local month = math.floor( self.time / self.days_in_month  )
        local lastmonth = math.floor( self.lasttime / self.days_in_month  )
        if month ~= lastmonth then
            game:new_month( month )
        end
    end,

    get_date = function( self )
        -- 30 days in a month
        local elapsed_days = math.floor( self.time )
        local elapsed_months = math.floor( elapsed_days / self.days_in_month  )
        local elapsed_years = math.floor( elapsed_months / self.months_in_year )

        -- +1 because calendar goes from 1-30 not 0-29
        local day = ( elapsed_days % self.days_in_month ) + 1
        -- +1 because lists start at 1 in Lua
        local month = ( elapsed_months % self.months_in_year ) + 1
        -- +100 so we start in year 100
        local year = elapsed_years + self.start_year

        return self.month_names[month] .. " " .. tostring( day ) ..", Year " .. tostring( year )
    end,

    get_delta = function( self )
        return self.time - self.lasttime
    end,
}
