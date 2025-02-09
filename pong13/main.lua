Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 700

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest','nearest')

    love.window.setTitle('Pong')

    smallFont = love.graphics.newFont('font.ttf',8)
    scoreFont = love.graphics.newFont('font.ttf',32)
    victoryFont = love.graphics.newFont('font.ttf',24)


    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['score_hit'] = love.audio.newSource('score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static'),
    }

    player1Score = 0
    player2Score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2
    winningPlayer = 0

    player1 = Paddle(5,20,5,20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30,5,20)
    
    ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT/2 - 2,5,5)

    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end

    gameState = 'start'

    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })
end

function love.resize(w,h)
    push:resize(w,h)
end

function love.update(dt)
    if gameState == 'play' then

        if ball.x <= 0 then
            player2Score = player2Score + 1
            servingPlayer = 1
            ball:reset()
            ball.dx = 100

            sounds['score_hit']:play()

            if player2Score >= 3 then
                gameState = 'victory'
                winningPlayer = 2
            else
                gameState = 'serve'
            end
        end

        if ball.x >= VIRTUAL_WIDTH-4 then
            player1Score = player1Score + 1
            servingPlayer = 2
            ball:reset()
            ball.dx = -100

            sounds['score_hit']:play()

            if player1Score >= 3 then
                gameState = 'victory'
                winningPlayer = 1
            else
                gameState = 'serve'
            end
        end
    

        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            
            sounds['paddle_hit']:play()

            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4
            
            sounds['paddle_hit']:play()
            
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy

            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy

            sounds['wall_hit']:play()

        end
    end

--adding the AI to player1
    if gameState == 'play' then
        if ball.dx < 0 then
            if ball.y > (player1.y + player1.height/2) then
                player1.dy = PADDLE_SPEED
            elseif ball.y < (player1.y + player1.height/2) then
                player1.dy = -PADDLE_SPEED
            end
            player2.dy = 0 
        end
    end

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'

        elseif gameState == 'victory' then
            gameState = 'start'
            player1Score = 0
            player2Score = 0

        elseif gameState == 'serve' then
            gameState = 'play'
            ball:reset()
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40/225,45/225,52/255,255/255)

    love.graphics.setFont(smallFont)

    displayScore()
    
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Welcome to Pong!",0,10,VIRTUAL_WIDTH,'center')
        love.graphics.printf("Press Enter to Play!",0,20,VIRTUAL_WIDTH,'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn!",0,10,VIRTUAL_WIDTH,'center')
        love.graphics.printf("Press Enter to Serve!",0,20,VIRTUAL_WIDTH,'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!",0,10,VIRTUAL_WIDTH,'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Serve!",0,42,VIRTUAL_WIDTH,'center')

    end

    player1:render()
    player2:render()
    ball:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0,1,0,1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()),40,20)
    love.graphics.setColor(1,1,1,1)
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/2-50,
        VIRTUAL_HEIGHT/3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH/2+30,
        VIRTUAL_HEIGHT/3)
end