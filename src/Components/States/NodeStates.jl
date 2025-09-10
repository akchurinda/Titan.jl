@kwdef mutable struct NodeState
    supports::AbstractVector{Bool} = @SVector [false, false, false]
    f::AbstractVector{<:Real} = @SVector zeros(3)
    u::AbstractVector{<:Real} = @SVector zeros(3)
    r::AbstractVector{<:Real} = @SVector zeros(3)
end
