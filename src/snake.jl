mutable struct Snake
    head::Point
    body::Vector{Point}
    last_move::Direction

    function Snake(head::Point=Point(WIDTH ÷ 2, HEIGHT ÷ 2))

        # Create the initial body
        body = [
            head,
            Point(head.x - BLOCK_SIZE, head.y),
            Point(head.x - 2 * BLOCK_SIZE, head.y)
        ]

        return new(head, body, RIGHT)
    end
end

function Base.show(io::IO, s::Snake)
    print("$(s.head)[HEAD]")
    for p in s.body[2:end]
        print(" <- ", p)
    end
end

function move!(s::Snake, d::Direction)
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

    # Adding the new head to the snake
    head = Point(x, y)
    s.head = head
    pushfirst!(s.body, head)

    # Updating the last move of the snake
    s.last_move = d

    # Return the old tail
    return pop!(s.body)
end

function is_collision(s::Snake, p::Union{Point, Nothing}=nothing)
    # Defaults to the snake's head if no point is given
    if p === nothing
        p = s.head
    end
    
    # Hits screen edges
    if p.x > WIDTH - BLOCK_SIZE ||
       p.x < 0 ||
       p.y > HEIGHT - BLOCK_SIZE ||
       p.y < 0

        return true
    end

    # Check if snake hits itself
    return p in s.body[2:end]
end
