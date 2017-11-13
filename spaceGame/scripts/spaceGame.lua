------------------------------------------------------------------------------
-- constants
------------------------------------------------------------------------------
SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080

------------------------------------------------------------------------------
-- includes
------------------------------------------------------------------------------
dofile("spaceGame/scripts/stats.lua")
dofile("spaceGame/scripts/state.lua")
dofile("spaceGame/scripts/splashState.lua")
dofile("spaceGame/scripts/gameState.lua")
dofile("spaceGame/scripts/pauseState.lua")
dofile("spaceGame/scripts/defeatState.lua")

------------------------------------------------------------------------------
-- core functions
------------------------------------------------------------------------------
function Start()
    CreateWindow(SCREEN_WIDTH, SCREEN_HEIGHT, true)
    SetWindowTitle("Space Game")
    SetDrawLogicalSize(1920, 1080)
    
    SplashState_Start()
end

function Update()
    if state == SPLASH_STATE then SplashState_Update()
    elseif state == GAME_STATE then GameState_Update()
    elseif state == PAUSE_STATE then PauseState_Update()
    elseif state == DEFEAT_STATE then DefeatState_Update()    
    end
end

function Draw()
    if state == SPLASH_STATE then SplashState_Draw()
    elseif state == GAME_STATE then GameState_Draw()
    elseif state == PAUSE_STATE then PauseState_Draw()
    elseif state == DEFEAT_STATE then DefeatState_Draw()
    end
end