@kwdef mutable struct ElementState
    L    ::Real = 0
    Γ    ::AbstractMatrix{<:Real} = @SMatrix zeros(6, 6)
    u_l  ::AbstractVector{<:Real} = @SVector zeros(6)
    f_l  ::AbstractVector{<:Real} = @SVector zeros(6)
    k_e_l::AbstractMatrix{<:Real} = @SMatrix zeros(6, 6)
    k_g_l::AbstractMatrix{<:Real} = @SMatrix zeros(6, 6)
    k_e_g::AbstractMatrix{<:Real} = @SMatrix zeros(6, 6)
    k_g_g::AbstractMatrix{<:Real} = @SMatrix zeros(6, 6)
end
