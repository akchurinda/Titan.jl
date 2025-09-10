module TitanMakieExtension
using Makie
using Titan
import Titan: plotundeformed, plotundeformed!, plotdeformed, plotdeformed!

Makie.@recipe PlotUndeformed (titan_model, ) begin
    n_color = :red
    n_strokecolor = :black
    n_strokewidth = 1
    n_label_color = :red
    n_label_visible = true
    e_linecolor = :black
    e_linestyle = :solid
    e_label_color = :black
    e_label_visible = true
end

Makie.@recipe PlotDeformed (titan_model, ) begin
    scale = 1
    num_inter_points = 10
    n_color = :red
    n_strokecolor = :black
    n_strokewidth = 1
    n_label_color = :red
    n_label_visible = true
    e_linecolor = :black
    e_linestyle = :dash
    e_label_color = :black
    e_label_visible = true
end

function Makie.plot!(p::PlotUndeformed)
    model = p.titan_model[]
    
    ns = model.n
    es = model.e

    n_ids = model._n_ids
    e_ids = model._e_ids

    for (e_id, e) in zip(e_ids, es)
        n_i = e.n_i
        n_j = e.n_j

        x_i, y_i = n_i.x, n_i.y
        x_j, y_j = n_j.x, n_j.y

        lines!(p, [x_i, x_j], [y_i, y_j], 
            color = p.e_linecolor,
            linestyle = p.e_linestyle)

        if p.e_label_visible[]
            x_m = (x_i + x_j) / 2
            y_m = (y_i + y_j) / 2

            text!(p, (x_m, y_m), text = string(e_id), color = p.e_label_color)
        end
    end

    for (n_id, n) in zip(n_ids, ns)
        scatter!(p, n.x, n.y, 
            color = p.n_color,
            strokecolor = p.n_strokecolor,
            strokewidth = p.n_strokewidth)

        if p.n_label_visible[]
            text!(p, (n.x, n.y), text = string(n_id), color = p.n_label_color)
        end
    end

    return p
end

function Makie.plot!(p::PlotDeformed)
    model = p.titan_model[]
    
    ns = model.n
    es = model.e

    n_ids = model._n_ids
    e_ids = model._e_ids

    for (e_id, e) in zip(e_ids, es)
        n_i = e.n_i
        n_j = e.n_j

        u_i = n_i.state.u
        u_j = n_j.state.u

        x_i_def = n_i.x + p.scale[] * u_i[1]
        y_i_def = n_i.y + p.scale[] * u_i[2]

        x_j_def = n_j.x + p.scale[] * u_j[1]
        y_j_def = n_j.y + p.scale[] * u_j[2]

        L = e.state.L
        Γ = e.state.Γ

        u_l = get_element_u_l(model, e_id)
        u_l_i = u_l[1:3]
        u_l_j = u_l[4:6]

        x_l_ip = range(0, L, p.num_inter_points[])
        y_l_ip = range(0, 0, p.num_inter_points[])
        
        u_x_l_i = N_a_i.(x_l_ip, L) * u_l_i[1] .+ N_a_j.(x_l_ip, L) * u_l_j[1]
        u_y_l_i = N_b_w_1.(x_l_ip, L) .* u_l_i[2] .+ N_b_w_2.(x_l_ip, L) .* u_l_j[2] .+ N_b_w_3.(x_l_ip, L) .* u_l_i[3] .+ N_b_w_4.(x_l_ip, L) .* u_l_j[3]
        
        x_l_ip_def = x_l_ip + p.scale[] * u_x_l_i
        y_l_ip_def = y_l_ip + p.scale[] * u_y_l_i

        γ = Γ'[1:2, 1:2]
        x_g_ip_def = [x_i_def + γ[1, 1] * x + γ[1, 2] * y for (x, y) in zip(x_l_ip_def, y_l_ip_def)]
        y_g_ip_def = [y_i_def + γ[2, 1] * x + γ[2, 2] * y for (x, y) in zip(x_l_ip_def, y_l_ip_def)]

        lines!(p, x_g_ip_def, y_g_ip_def,
            color = p.e_linecolor,
            linestyle = p.e_linestyle)

        if p.e_label_visible[]
            x_m = (x_i_def + x_j_def) / 2
            y_m = (y_i_def + y_j_def) / 2

            text!(p, (x_m, y_m), text = string(e_id), color = p.e_label_color)
        end
    end

    for (n_id, n) in zip(n_ids, ns)
        u = n.state.u

        x_def = n.x + p.scale[] * u[1]
        y_def = n.y + p.scale[] * u[2]

        scatter!(p, x_def, y_def, 
            color = p.n_color,
            strokecolor = p.n_strokecolor,
            strokewidth = p.n_strokewidth)

        if p.n_label_visible[]
            text!(p, (x_def, y_def), text = string(n_id), color = p.n_label_color)
        end
    end

    return p
end

N_a_i(x, L) = 1 - x / L
N_a_j(x, L) = x / L
N_b_w_1(x, L) = 1 - 3 * (x / L) ^ 2 + 2 * (x / L) ^ 3
N_b_w_2(x, L) = 3 * (x / L) ^ 2 - 2 * (x / L) ^ 3
N_b_w_3(x, L) = x * (1 - x / L) ^ 2
N_b_w_4(x, L) = x * ((x / L) ^ 2 - x / L)
end