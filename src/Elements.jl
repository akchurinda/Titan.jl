mutable struct Element
    const n_i::Node
    const n_j::Node
    const m::Material
    const s::Section

    L    ::Real
    Γ    ::AbstractMatrix{<:Real}
    k_e_l::AbstractMatrix{<:Real}
    k_g_l::AbstractMatrix{<:Real}
    k_e_g::AbstractMatrix{<:Real}
    k_g_g::AbstractMatrix{<:Real}

    function Element(n_i::Node, n_j::Node, m::Material, s::Section)
        x_i, y_i = n_i.x, n_i.y
        x_j, y_j = n_j.x, n_j.y
        E        = m.E
        A, I     = s.A, s.I

        L = compute_L(x_i, y_i, x_j, y_j)

        Γ = compute_Γ(x_i, y_i, x_j, y_j, L)

        k_e_l = compute_k_e_l(E, A, I, L)
        k_g_l = zero(k_e_l)

        k_e_g = transform_l_to_g(k_e_l, Γ)
        k_g_g = transform_l_to_g(k_g_l, Γ)

        return new(n_i, n_j, m, s, L, Γ, k_e_l, k_g_l, k_e_g, k_g_g)
    end
end

compute_L(x_i::Real, y_i::Real, x_j::Real, y_j::Real) = sqrt((x_j - x_i) ^ 2 + (y_j - y_i) ^ 2)

function compute_Γ(x_i::Real, y_i::Real, x_j::Real, y_j::Real, L::Real)
    c = (x_j - x_i) / L
    s = (y_j - y_i) / L

    Γ = @SMatrix [
        +c +s  0  0  0  0;
        -s +c  0  0  0  0;
         0  0 +1  0  0  0;
         0  0  0 +c +s  0;
         0  0  0 -s +c  0;
         0  0  0  0  0 +1]

    return Γ
end

function compute_k_e_l(E, A, I, L)
    k_e_l = E * @SMatrix [
        +A / L 0 0 -A / L 0 0;
        0 +12 * I / L ^ 3 +6 * I / L ^ 2 0 -12 * I / L ^ 3 +6 * I / L ^ 2;
        0 +6 * I / L ^ 2 +4 * I / L 0 -6 * I / L ^ 2 +2 * I / L;
        -A / L 0 0 +A / L 0 0;
        0 -12 * I / L ^ 3 -6 * I / L ^ 2 0 +12 * I / L ^ 3 -6 * I / L ^ 2;
        0 +6 * I / L ^ 2 +2 * I / L 0 -6 * I / L ^ 2 +4 * I / L]

    return k_e_l
end

function compute_k_g_l(P, L)
    k_g_l = P / L * @SMatrix [
        +1 0 0 -1 0 0;
        0 +6 / 5 +L / 10 0 -6 / 5 +L / 10;
        0 +L / 10 +2 * L ^ 2 / 15 0 -L / 10 -L ^ 2 / 30;
        -1 0 0 +1 0 0;
        0 -6 / 5 -L / 10 0 +6 / 5 -L / 10;
        0 +L / 10 -L ^ 2 / 30 0 -L / 10 +2 * L ^ 2 / 15]

    return k_g_l
end

transform_l_to_g(v::AbstractVector, Γ::AbstractMatrix) = Γ' * v
transform_l_to_g(m::AbstractMatrix, Γ::AbstractMatrix) = Γ' * m * Γ

transform_g_to_l(v::AbstractVector, Γ::AbstractMatrix) = Γ * v
transform_g_to_l(m::AbstractMatrix, Γ::AbstractMatrix) = Γ * m * Γ'