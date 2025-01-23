using TestItems


using TestItemRunner
@run_package_tests  verbose=true



@testitem "SLiM" begin

    slim_exec = "slim"

    slim_found = try
        SLiM.check_slim(slim_exec)
    catch
        println("SLiM executable not found - skipping test")
        false
    end

    if slim_found
        anc = StationaryPopulation(
            ploidy = 2, 
            population_size = 100, 
            genome_length = 1_000_000, 
            recombination_rate = 1e-6, 
            mutation_rate = 1e-6)
        ibs = SLiM.IBS_segment_lengths(anc, seed = 123)
       

        @test length(ibs) >= 1
        @test sum(ibs) == 1_000_000
    end
end

@testitem "msprime" begin

    anc = StationaryPopulation(
            ploidy = 2, 
            population_size = 100, 
            genome_length = 1_000_000, 
            recombination_rate = 1e-6, 
            mutation_rate = 1e-6)

    ibs = Msprime.IBS_segment_lengths(anc, seed = 123)
    @test length(ibs) >= 1
    @test sum(ibs) == 1_000_000

    ibs = Msprime.IBS_segment_lengths(anc, seed = 123, model = "SmcApproxCoalescent")
    @test length(ibs) >= 1
    @test sum(ibs) == 1_000_000

    ibs = Msprime.IBS_segment_lengths(anc, seed = 123, model = "SmcPrimeApproxCoalescent")
    @test length(ibs) >= 1
    @test sum(ibs) == 1_000_000


end


