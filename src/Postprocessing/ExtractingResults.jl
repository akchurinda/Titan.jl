get_node_u(model::Model, id::Int) = model.n[id].state.u
get_node_r(model::Model, id::Int) = model.n[id].state.r
get_element_u_l(model::Model, id::Int) = model.e[id].state.u_l
get_element_f_l(model::Model, id::Int) = model.e[id].state.f_l