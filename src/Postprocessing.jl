function get_node_u(model::Model, id::Int)
    idx = findfirst(x -> x == id, model._n_ids)

    return model.n[idx].state.u
end

function get_node_r(model::Model, id::Int)
    idx = findfirst(x -> x == id, model._n_ids)

    return model.n[idx].state.r
end

function get_element_u_l(model::Model, id::Int)
    idx = findfirst(x -> x == id, model._e_ids)

    return model.e[idx].state.u_l
end

function get_element_f_l(model::Model, id::Int)
    idx = findfirst(x -> x == id, model._e_ids)

    return model.e[idx].state.f_l
end