module Agent

export SnakeAgent, 
    train!,
    CircularBufferMemory

include("memory.jl")
include("agents.jl")
include("functions.jl")

end # module