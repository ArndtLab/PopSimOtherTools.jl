module PopSimOtherTools
using Reexport


@reexport using PopSimBase

export SLiM, Msprime

using Random

include("slim.jl")
include("msprime.jl")


end
