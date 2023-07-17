using Documenter, Twitch

makedocs(;
    modules = [Twitch],
    authors = "Johannes Schumann",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets = ["assets/logo.ico"],
    ),
    pages=[
        "Introduction" => "index.md",
        # "API" => "api.md",
    ],
    repo="https://github.com/8me/Twitch.jl/blob/{commit}{path}#L{line}",
    sitename="Twitch.jl",
)

deploydocs(;
    repo="github.com/8me/Twitch.jl",
   )
