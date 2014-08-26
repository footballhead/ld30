-- draw an outlined rectangle
function love.graphics.outlinedrect( x, y, width, height, col, bordcol, thickness )
    love.graphics.setColor( col[1], col[2], col[3], col[4] )
    love.graphics.rectangle( 'fill', x, y, width, height )

    love.graphics.setLineWidth( thickness )
    love.graphics.setColor( bordcol[1], bordcol[2], bordcol[3], bordcol[4] )
    love.graphics.rectangle( 'line', x, y, width, height )
end

function love.graphics.printshadow( text, x, y, dist, font, col, shadow )
    if col == nil then col = { 255, 255, 255, 255 } end
    if shadow == nil then shadow = { 0, 0, 0, 255 } end

    love.graphics.setFont( font )

    love.graphics.setColor( shadow[1], shadow[2], shadow[3], shadow[4] )
    love.graphics.print( text, x + dist, y + dist )

    love.graphics.setColor( col[1], col[2], col[3], col[4] )
    love.graphics.print( text, x, y )
end
