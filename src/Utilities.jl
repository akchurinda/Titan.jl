get_F_eltype(n::Node) = promote_type(typeof(n.F_x), typeof(n.F_y), typeof(n.M_z))
get_K_e_eltype(e::Element) = eltype(e.k_e_g)
get_K_g_eltype(e::Element) = eltype(e.k_g_g)