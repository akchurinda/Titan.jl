using Documenter
using Titan

makedocs(
    modules = [Titan],
    sitename = "Titan.jl",
    authors = "Damir Akchurin <akchurinda@gmail.com>",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://akchurinda.github.io/Titan.jl"),
    pages = [
        "Home" => "index.md",
        "Tutorial" => "Tutorial.md"])

deploydocs(
    repo = "github.com/akchurinda/Titan.jl.git",
    push_preview = true)
