module Agent

import ..SnakeAI

import DataStructures: CircularBuffer
import Flux
import StatsBase: sample
import Zygote: Buffer

export SnakeAgent,
    train!,
    CircularBufferMemory

include("memory.jl")
include("agents.jl")
include("functions.jl")

end # module