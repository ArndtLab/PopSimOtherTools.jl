module Msprime


using PyCall
using PopSimBase


function __init__()
    py"""
    import msprime

    def generate_alleles(N, model, pop_size, seq_length, recombination_rate, mutation_rate, seed):
        if model == "StandardCoalescent" :
            coalescent_model = msprime.StandardCoalescent()
        elif model == "SmcApproxCoalescent" :
            coalescent_model = msprime.SmcApproxCoalescent()
        elif model == "SmcPrimeApproxCoalescent" :
            coalescent_model = msprime.SmcPrimeApproxCoalescent()
        else:
            raise ValueError("Unknown model: {}".format(model))

        ts = msprime.sim_ancestry(
            N,
            model=coalescent_model,
            population_size=pop_size,
            sequence_length=seq_length,
            recombination_rate=recombination_rate,
            random_seed=seed,  # only needed for repeatabilty
            )
        # Optionally add finite-site mutations to the ts using the Jukes & Cantor model, creating SNPs
        ts = msprime.sim_mutations(ts, rate=mutation_rate, random_seed=seed)
        return(ts)

    """
end

function get_rs(ts)
    p = map(v -> Int(v.site.position) , ts.variants())
    
    if length(p) < 2
        return([ Int(ts.sequence_length) ])
    end
        
    rs = p[2:end] .- p[1:end-1]
    rwrap = ts.sequence_length - sum(rs)
    push!(rs, rwrap)
    return(rs)
end

function IBS_segment_lengths(anc::StationaryPopulation; kwargs...)
    seed = get(kwargs, :seed, rand(Int))
    model = get(kwargs, :model, "StandardCoalescent")

    ts = py"generate_alleles"(1, model, anc.population_size, anc.genome_length, 
        anc.recombination_rate, anc.mutation_rate, 
        seed);

    get_rs(ts)
end

end # module