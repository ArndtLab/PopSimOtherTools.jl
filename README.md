# PopSimOtherTools

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ArndtLab.github.io/PopSimOtherTools.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ArndtLab.github.io/PopSimOtherTools.jl/dev/)
[![Build Status](https://github.com/ArndtLab/PopSimOtherTools.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ArndtLab/PopSimOtherTools.jl/actions/workflows/CI.yml?query=branch%3Amain)



## Installation

### msprime

Configure PyCall to use a Julia-specific Python
distribution via the Conda.jl package (which installs a private Anaconda
Python distribution), which has the advantage that packages can be installed
and kept up-to-date via Julia.  As explained in the PyCall documentation,
set ENV["PYTHON"]="", run Pkg.build("PyCall"), and re-launch Julia. Then,
To install the msprime module, you can use `pyimport_conda("msprime", PKG)`,
where PKG is the Anaconda package that contains the module msprime,
or alternatively you can use the Conda package directly (via
`using Conda` followed by `Conda.add` etcetera)

```julia
using Conda
Conda.add_channel("conda-forge")

Conda.add("msprime")
```

### SLiM

Install SLiM as described on int the manula on their [webpage](https://messerlab.org/slim/).

The excutable is supposed to be in the `PATH` - otherwise specify `SLiM.slim_exec = "/path/to/excutable/slim".