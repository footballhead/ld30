utils = {
    -- Compute and return the Euclidean distance between two points
    eucdist = function( x1, y1, x2, y2 )
        local a = x2 - x1
        local b = y2 - y1
        return math.sqrt( a * a + b * b )
    end,

    circle_intersect = function( x1, y1, r1, x2, y2, r2 )
        local dist = utils.eucdist( x1, y1, x2, y2 )
        local gooddist = r1 + r2
        return dist <= gooddist
    end,

}
