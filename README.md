# SnakeAI

This is a small personal project which goal is to make a reinforcement learning agent learn how to play snake effectively.
The code is strongly inspired by the tutorial videos of [Python Engineer](https://www.youtube.com/watch?v=PJl4iabBEz0&list=PLqnslRFeH2UrDh7vUmJ60YrmWd64mTTKV).

## Get Started
To install and run this project, follow theses instructions:

1. Clone the repository
```
$ git clone https://github.com/gcleroux/SnakeAI.jl
```

2. cd into the project
```
$ cd SnakeAI.jl/
```

3. Installing deps
```julia
julia> using Pkg

julia> Pkg.activate(".")

julia> Pkg.instantiate()
```

## Using the package
There are two ways of using this package currently. You can play Snake yourself or train an agent to play.

To play a game of Snake yourself, enter the follwing commands in the REPL:
```julia
julia> using SnakeAI

julia> play_snake()
```

To train an agent, enter the follwing commands in the REPL:
```julia
julia> using SnakeAI

julia> train_agent()
```
