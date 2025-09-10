using Documenter
using Titan

makedocs(
    modules = [Titan],
    sitename = "Titan.jl",
    authors = "Damir Akchurin <akchurinda@gmail.com>",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://damirakchurin.github.io/Titan.jl"),
    pages = ["Home" => "index.md"])

deploydocs(
    repo = "github.com/damirakchurin/Titan.jl.git",
    push_preview = true)