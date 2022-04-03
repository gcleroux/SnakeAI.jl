using Colors

WIDTH = 640
HEIGHT = 480
BACKGROUND = colorant"black"
BLOCK_SIZE = 20
SPEED = 6

@enum Direction begin
    UP = 1
    DOWN = 2
    LEFT = 3
    RIGHT = 4
end

mutable struct Point{T <: Integer}
    x::T
    y::T
end

function Base.:(==)(p1::Point, p2::Point)
    return p1.x == p2.x && p1.y == p2.y
end

mutable struct Snake
    head::Point
    body::Vector{Point}
    last_move::Direction

    function Snake(head::Point = Point(WIDTH ÷ 2, HEIGHT ÷ 2))
        
        # Create the initial body
        body = [
            head,
            Point(head.x - BLOCK_SIZE, head.y),
            Point(head.x - 2*BLOCK_SIZE, head.y)
        ]

        return new(head, body, RIGHT)
    end
end

function move(s::Snake, d::Direction)
    x = s.head.x
    y = s.head.y

    # Move the head
    if d == UP
        y -= BLOCK_SIZE
    elseif d == DOWN
        y += BLOCK_SIZE
    elseif d == LEFT
        x -= BLOCK_SIZE
    elseif d == RIGHT
        x += BLOCK_SIZE
    end

    # Updating the last move of the snake
    s.last_move = d

    # Return the new head
    return Point(x, y)
end

function place_food()
    global food

    x = rand(0:(WIDTH - BLOCK_SIZE) ÷ BLOCK_SIZE) * BLOCK_SIZE
    y = rand(0:(HEIGHT - BLOCK_SIZE) ÷ BLOCK_SIZE) * BLOCK_SIZE

    # Create new food
    food = Point(x, y)

    # Look if food is inside the snake
    if food in snake.body
        place_food()
    end
end

function collide(s::Snake)
    # Hits screen edges
    if s.head.x > WIDTH - BLOCK_SIZE ||
        s.head.x < 0 ||
        s.head.y > HEIGHT - BLOCK_SIZE ||
        s.head.y < 0

        return true
    end

    # Check if snake hits itself
    return s.head in snake.body[2:end]
end

function reset_game()
    global direction, score, snake, step

    snake = Snake()
    place_food()
    direction = RIGHT
    score = 0
    step = 0

end

function draw()

    # Drawing the snake
    for p in snake.body
        r = Rect(p.x, p.y, BLOCK_SIZE, BLOCK_SIZE)
        draw(r, colorant"blue", fill=true)
    end

    # Drawing the food
    f = Rect(food.x, food.y, BLOCK_SIZE, BLOCK_SIZE)
    draw(f, colorant"red", fill=true)

end

function update(g::Game)
    global direction, step

    # Movement keys
    if g.keyboard.UP && snake.last_move != DOWN
        direction = UP
    elseif g.keyboard.DOWN && snake.last_move != UP
        direction = DOWN
    elseif g.keyboard.LEFT && snake.last_move != RIGHT
        direction = LEFT
    elseif g.keyboard.RIGHT && snake.last_move != LEFT
        direction = RIGHT
    end

    if step == SPEED
        step = 0
        update_step(snake, direction)
    else
        step += 1
    end
end

function update_step(s::Snake, d::Direction)
    global score

    # Move the head
    head = move(s, d)
    s.head = head
    pushfirst!(s.body, head)

    # Look for collisions
    if collide(s)
        println(
            """
            ==================
            GAME OVER!
            Final Score: $score
            ==================\n""")
        reset_game()
    end

    # Place new food or move the snake
    if s.head == food
        score += 1
        place_food()
    else
        pop!(s.body)
    end

end

# Initializing the game state
reset_game()
