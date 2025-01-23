module SLiM


slim_exec = "slim"


using CSV, DataFrames
using PopSimBase

function check_slim(slim_exec::String)
    if Sys.which(slim_exec) === nothing
        error("SLiM executable not found")
    end
 
    # check version >= 4
    ioout = IOBuffer()
    run(pipeline(`$(slim_exec) -v`; stdout = ioout))
    seekstart(ioout)
    version = readline(ioout)
    m = match(r"SLiM version (\d+)\.\d+", version)
    if m === nothing
        error("SLiM version not found")
    end
    version = parse(Int, m.captures[1])
    if version < 3
        error("SLiM version $version is not supported")
    end
    true
end




function IBS_segment_lengths(anc::StationaryPopulation; kwargs...)

    check_slim(slim_exec)

    @assert anc.ploidy == 2
    T0 = get(kwargs, :T0, 20 * anc.ploidy * anc.population_size)
    TN = [T0, anc.population_size]
    seed = get(kwargs, :seed, rand(Int))
    Nsample = 1


    mktempdir() do path
        fout = joinpath(path, "f.vcf")
        
        ioout = IOBuffer()
        ioin = IOBuffer(make_script(tmpoutfile = fout; 
            TN,
            anc.genome_length,
            mu = anc.mutation_rate,
            rho = anc.recombination_rate,
            Nsample,
            seed,
            ))
        tcompute = @elapsed begin
            run(pipeline(`$slim_exec`; stdin = ioin, stdout = ioout))
    
            df = CSV.read(fout, comment = "##", DataFrame);

            indvs = names(df)
            indvs = indvs[findfirst(==("FORMAT"), indvs) + 1 : end]
            ibs_lengths = map(i -> get_rs(df, anc.genome_length, i), indvs)
        end
        
        # (; tcompute, nindvs = length(indvs), ibs_lengths)
        ibs_lengths[1]
    end
end


function make_script(;kwargs...)
    r = (; kwargs...)
    @assert length(r.TN) >= 2
    @assert length(r.TN) % 2 == 0
    @assert r.Nsample > 0

    e = 1
    T0 = r.TN[e]
    N0 = r.TN[e+1]

    s =  """
        initialize() {
            setSeed($(r.seed));
            defineConstant("MU", $(r.mu));
            defineConstant("R", $(r.rho));

            initializeMutationRate(MU);
            initializeMutationType("m1", 0.5, "f", 0.0);
            initializeGenomicElementType("g1", m1, 1.0);
            initializeGenomicElement(g1, 0, $(r.genome_length-1));
            initializeRecombinationRate(R);
        }
    
        1 first(){
            m1.convertToSubstitution = T;
            sim.addSubpop("p1", $(N0));
        }
        $(T0) """

        T = T0
    while length(r.TN) >= e + 3
        e += 2
        T += r.TN[e]
        N = r.TN[e+1]
        s *= "early() { p1.setSubpopulationSize($(N)); }\n$(T) "
    end
    
    s *= """late() { 
        allIndividuals = sim.subpopulations.individuals;
        sampledIndividuals = sample(allIndividuals, $(r.Nsample));
        sampledIndividuals.genomes.outputVCF("$(r.tmpoutfile)");
    }
    """
    # println(s)
    s
end


function get_rs(df, L, indv)
    keep = map(v -> (v .== "1|0") || (v .== "0|1"), df[!, indv])
    p = df[keep, :POS]
    if length(p) < 2
        return([ L ])
    end
    p = p[2:end] .- p[1:end-1]
    push!(p, L-sum(p))
    p
end



end