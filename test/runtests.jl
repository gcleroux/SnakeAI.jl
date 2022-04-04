using SnakeAI
using Test

# @testset "SnakeAI.jl" begin
#     # Write your tests here.
# end

@testset "Points.jl" begin

    p1 = Point(100, 200)
    p2 = Point(300, 400)
    p3 = Point(300, 400)

    @test p1.x == 100 && p1.y == 200
    @test p1 != p2
    @test p2 == p3

end
