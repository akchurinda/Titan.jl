get_F_eltype(n::Node)      = eltype(n.state.f)
get_K_e_eltype(e::Element) = eltype(e.state.k_e_g)
get_K_g_eltype(e::Element) = eltype(e.state.k_g_g)

function Base.show(io::IO, ::MIME"text/plain", model::Model)
    if length(model.n) == 0 && length(model.m) == 0 && length(model.s) == 0 && length(model.e) == 0
        print(io, "Empty Model")
    else
        nn = length(model.n)
        nm = length(model.m)
        ns = length(model.s)
        ne = length(model.e)

        print(io, """
            Model with:
            ├─ Nodes:     $(length(model.n))
            ├─ Materials: $(length(model.m))
            ├─ Sections:  $(length(model.s))
            └─ Elements:  $(length(model.e))""")
    end
end