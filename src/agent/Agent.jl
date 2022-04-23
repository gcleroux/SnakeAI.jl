module Agent

export AbstractAgent, 
    SnakeAgent, 
    train!

include("agents.jl")
include("functions.jl")
# include("linear_agent.jl")

end # module