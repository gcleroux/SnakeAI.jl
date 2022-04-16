struct Point{T <: Integer}
    x::T
    y::T
end

function Base.:(==)(p1::Point, p2::Point)
    return p1.x == p2.x && p1.y == p2.y
end


function Base.show(io::IO, p::Point{T}) where {T}
    print("Point{$T}(x=$(p.x), y=$(p.y))")    
end