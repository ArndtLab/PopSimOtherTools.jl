using PopSimOtherTools
using Documenter

DocMeta.setdocmeta!(PopSimOtherTools, :DocTestSetup, :(using PopSimOtherTools); recursive=true)

makedocs(;
    modules=[PopSimOtherTools],
    authors="Peter Arndt <arndt@molgen.mpg.de> and contributors",
    sitename="PopSimOtherTools.jl",
    format=Documenter.HTML(;
        canonical="https://ArndtLab.github.io/PopSimOtherTools.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
    warnonly=[:missing_docs],
)

deploydocs(;
    repo="github.com/ArndtLab/PopSimOtherTools.jl",
    devbranch="main",
)
