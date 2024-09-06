using Documenter, JSUrl

makedocs(
    sitename="JSUrl.jl Documentation",
    format=Documenter.HTML(
        prettyurls = false,
        edit_link="main",
    ),
    modules=[JSUrl],
    pages = ["index.md"],
)

deploydocs(repo = "github.com/bluesmoon/JSUrl.jl.git")
