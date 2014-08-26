require "lovefuncs"
require "countries"
require "menu"
require "time"
require "button"
require "map"
require "mousestate"
require "bank"
require "game"
require "mainmenu"
require "info"
require "utils"
require "risingtext"
require "graph"
require "death"

-- -----------------------------------------------------------------------------
--     GLOBALS
-- -----------------------------------------------------------------------------

-- which screen we are on (e.g. menu, game, etc)
-- valid screens so far are;
--     mainmenu for title screen
--     info for game info
--     game for actual game
--     death for assasination
screen = mainmenu

music = nil

-- -----------------------------------------------------------------------------
--     LOVE FUNCTIONS
-- -----------------------------------------------------------------------------

function love.load()
    -- set up window properties, store the necessary ones
    love.window.setTitle( "LD30" )
    love.window.setMode( 1024, 768, nil )

    math.randomseed( os.time() )

    music = love.audio.newSource( "assets/Mining by Moonlight.mp3", 'stream' )
    music:setLooping( true )

    game:init()
    mainmenu:init()
    info:init()
    death:init()
    bankrupt:init()
    win:init()
    uhhh:init()
    notime:init()
end


function love.update( dt )
    screen:update( dt )
end


function love.draw()
    screen:draw()
end


function love.mousepressed( x, y, button )
    screen:mousepressed( x, y, button )
end


function love.mousereleased( x, y, button )
    screen:mousereleased( x, y, button )
end


function love.keypressed( k )
    -- quit when escaped is pushed (from LOVE wiki)
    if k == 'escape' then
        love.event.push( 'quit' )
    end
end
