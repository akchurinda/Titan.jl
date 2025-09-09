module Titan
using StaticArrays

export Model
export node!, material!, section!, element!
export support!
export cload!, dload!
export assemble_K_e, assemble_K_g, assemble_F
export partition_idx
export partition
export departition
export analyze

include("Nodes.jl")
include("Materials.jl")
include("Sections.jl")
include("Elements.jl")
include("Models.jl")
include("Utilities.jl")

function assemble_K_e(model)
    nn  = length(model.n)
    T   = promote_type([get_K_e_eltype(e) for e in model.e]...)
    K_e = zeros(T, 3 * nn, 3 * nn)

    for e in model.e
        k_e_g = e.k_e_g

        idx_i = findfirst(x -> x === e.n_i, model.n)
        idx_j = findfirst(x -> x === e.n_j, model.n)

        @inbounds K_e[(3 * idx_i - 2):(3 * idx_i), (3 * idx_i - 2):(3 * idx_i)] += k_e_g[1:3, 1:3]
        @inbounds K_e[(3 * idx_i - 2):(3 * idx_i), (3 * idx_j - 2):(3 * idx_j)] += k_e_g[1:3, 4:6]
        @inbounds K_e[(3 * idx_j - 2):(3 * idx_j), (3 * idx_i - 2):(3 * idx_i)] += k_e_g[4:6, 1:3]
        @inbounds K_e[(3 * idx_j - 2):(3 * idx_j), (3 * idx_j - 2):(3 * idx_j)] += k_e_g[4:6, 4:6]
    end

    return K_e
end

function assemble_K_g(model)
    nn  = length(model.n)
    T   = promote_type([get_K_g_eltype(e) for e in model.e]...)
    K_g = zeros(T, 3 * nn, 3 * nn)

    for e in model.e
        k_g_g = e.k_g_g

        idx_i = findfirst(x -> x === e.n_i, model.n)
        idx_j = findfirst(x -> x === e.n_j, model.n)

        @inbounds K_g[(3 * idx_i - 2):(3 * idx_i), (3 * idx_i - 2):(3 * idx_i)] += k_g_g[1:3, 1:3]
        @inbounds K_g[(3 * idx_i - 2):(3 * idx_i), (3 * idx_j - 2):(3 * idx_j)] += k_g_g[1:3, 4:6]
        @inbounds K_g[(3 * idx_j - 2):(3 * idx_j), (3 * idx_i - 2):(3 * idx_i)] += k_g_g[4:6, 1:3]
        @inbounds K_g[(3 * idx_j - 2):(3 * idx_j), (3 * idx_j - 2):(3 * idx_j)] += k_g_g[4:6, 4:6]
    end

    return K_g
end

function assemble_F(model)
    nn = length(model.n)
    T  = promote_type([get_F_eltype(n) for n in model.n]...)
    F  = zeros(T, 3 * nn)

    for (i, n) in enumerate(model.n)
        @inbounds F[3 * i - 1] = n.F_y
        @inbounds F[3 * i - 2] = n.F_x
        @inbounds F[3 * i    ] = n.M_z
    end

    return F
end

function partition_idx(model)
    nn = length(model.n)

    f_dofs = BitVector(undef, 3 * nn)
    s_dots = BitVector(undef, 3 * nn)
    for (i, n) in enumerate(model.n)
        u_x_supp, u_y_supp, θ_z_supp = n.u_x_supp, n.u_y_supp, n.θ_z_supp

        if u_x_supp
            f_dofs[3 * i - 2] = false
            s_dots[3 * i - 2] = true
        else
            f_dofs[3 * i - 2] = true
            s_dots[3 * i - 2] = false
        end

        if u_y_supp
            f_dofs[3 * i - 1] = false
            s_dots[3 * i - 1] = true
        else
            f_dofs[3 * i - 1] = true
            s_dots[3 * i - 1] = false
        end

        if θ_z_supp
            f_dofs[3 * i    ] = false
            s_dots[3 * i    ] = true
        else
            f_dofs[3 * i    ] = true
            s_dots[3 * i    ] = false
        end
    end

    return f_dofs, s_dots
end

function partition(M::AbstractMatrix, f_dofs::BitVector, s_dots::BitVector)
    M_ff = M[f_dofs, f_dofs]
    M_fs = M[f_dofs, s_dots]
    M_sf = M[s_dots, f_dofs]
    M_ss = M[s_dots, s_dots]

    return M_ff, M_fs, M_sf, M_ss
end

function partition(V::AbstractVector, f_dofs::BitVector, s_dots::BitVector)
    V_f = V[f_dofs]
    V_s = V[s_dots]

    return V_f, V_s
end

function departition(M_ff::AbstractMatrix, M_fs::AbstractMatrix, M_sf::AbstractMatrix, M_ss::AbstractMatrix, f_dofs::BitVector, s_dots::BitVector)
    n = length(f_dofs)
    T = promote_type(eltype(M_ff), eltype(M_fs), eltype(M_sf), eltype(M_ss))
    M = zeros(T, n, n)

    M[f_dofs, f_dofs] = M_ff
    M[f_dofs, s_dots] = M_fs
    M[s_dots, f_dofs] = M_sf
    M[s_dots, s_dots] = M_ss

    return M
end

function departition(V_f::AbstractVector, V_s::AbstractVector, f_dofs::BitVector, s_dots::BitVector)
    n = length(f_dofs)
    T = promote_type(eltype(V_f), eltype(V_s))
    V = zeros(T, n)

    V[f_dofs] = V_f
    V[s_dots] = V_s

    return V
end

function analyze(model::Model)
    K_e = assemble_K_e(model)
    K_g = assemble_K_g(model)
    F   = assemble_F(model)

    f_dofs, s_dofs = partition_idx(model)

    K_e_ff, K_e_fs, K_e_sf, K_e_ss = partition(K_e, f_dofs, s_dofs)
    K_g_ff, K_g_fs, K_g_sf, K_g_ss = partition(K_g, f_dofs, s_dofs)
    F_f, F_s = partition(F, f_dofs, s_dofs)

    U_s = zero(F_s)

    U_f = (K_e_ff + K_g_ff) \ (F_f - (K_e_fs + K_g_fs) * U_s)
    F_s = (K_e_sf + K_g_sf) * U_f + (K_e_ss + K_g_ss) * U_s

    U = departition(U_f, U_s, f_dofs, s_dofs)
    F = departition(F_f, F_s, f_dofs, s_dofs)

    return U, F
end
end