@kwdef mutable struct NodeState
    supports::AbstractVector{Bool} = @SVector [false, false, false]
    f::AbstractVector{<:Real} = @SVector zeros(3)
    u::AbstractVector{<:Real} = @SVector zeros(3)
    r::AbstractVector{<:Real} = @SVector zeros(3)
end

@kwdef mutable struct ElementState
    L::Real = 0
    Γ::AbstractMatrix{<:Real} = @SMatrix zeros(6, 6)
    u_l::AbstractVector{<:Real} = @SVector zeros(6)
    f_l::AbstractVector{<:Real} = @SVector zeros(6)
    k_e_l::AbstractMatrix{<:Real} = @SMatrix zeros(6, 6)
    k_g_l::AbstractMatrix{<:Real} = @SMatrix zeros(6, 6)
    k_e_g::AbstractMatrix{<:Real} = @SMatrix zeros(6, 6)
    k_g_g::AbstractMatrix{<:Real} = @SMatrix zeros(6, 6)
end
