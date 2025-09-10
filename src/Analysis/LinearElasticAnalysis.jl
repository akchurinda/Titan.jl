struct LinearElasticAnalysis <: AbstractAnalysis end

function analyze!(model::Model, ::LinearElasticAnalysis)
    nn = length(model.n)

    f_dofs, s_dofs = partition_idx(model)

    K_e = assemble_K_e(model)
    K_e_ff, _, K_e_sf, _ = partition(K_e, f_dofs, s_dofs)

    if det(K_e_ff) == 0
        error("The global stiffness matrix is singular. The structure is unstable.")
    end
    
    F = assemble_F(model)
    F_f, _ = partition(F, f_dofs, s_dofs)

    # Compute the displacements at the free DOFs:
    U_f = K_e_ff \ F_f

    # Compute the reactions at the supported DOFs:
    R_s = K_e_sf * U_f

    # Assemble the full global displacement vector:
    U = zeros(eltype(U_f), 3 * nn)
    U[f_dofs] .= U_f
    U[s_dofs] .= 0

    # Assemble the full global reaction vector:
    R = zeros(eltype(R_s), 3 * nn)
    R[f_dofs] .= 0
    R[s_dofs] .= R_s

    # Update the nodal displacements and reactions:
    for (idx, n) in enumerate(values(model.n))
        n.state.u = @SVector [U[3 * idx - 2], U[3 * idx - 1], U[3 * idx]]
        n.state.r = @SVector [R[3 * idx - 2], R[3 * idx - 1], R[3 * idx]]
    end

    # Update the element displacements and forces:
    for e in values(model.e)
        u_g_i = e.n_i.state.u
        u_g_j = e.n_j.state.u
        u_g = vcat(u_g_i, u_g_j)
        u_l = transform_g_to_l(u_g, e.state.Γ)
        f_l = e.state.k_e_l * u_l

        e.state.u_l = u_l
        e.state.f_l = f_l
    end

    return model
end