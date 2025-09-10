get_F_eltype(n::Node) = eltype(n.state.f)
get_K_e_eltype(e::Element) = eltype(e.state.k_e_g)
get_K_g_eltype(e::Element) = eltype(e.state.k_g_g)