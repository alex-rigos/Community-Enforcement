using Distributed
using CSV, Tables, Plots

# How many threads should be used for parallel computing?
num_procs = 8
if nworkers() < min(length(Sys.cpu_info()),num_procs)
    addprocs(min(length(Sys.cpu_info()),num_procs) - nworkers())
end

rootdir= "fishtanks/"

# Distribute definitions to worker threads
# How many times to sample for each point?
@everywhere N = 1000

@everywhere include("ComEn-Definitions.jl") # Definitions of our types and methods
@everywhere model = "Baseline"

for parameters in [
    [["f",.3],["l",3.5]],  # Most favorable to cooperation
    [["f",.4],["l",3.]],  # Baseline
    [["f",.5],["l",2.5]],  # Most favorable to defection
]

    @everywhere setParameters($(parameters))

    np = 160  # number of producers
    prodstep = np/10  # step increment (grid) for producers
    ne = 40  # number of enforcers
    enfstep = ne/10  # step increment (grid) for enforcers

    pops = []  # Vector to hold populations
    for CP = prodstep:prodstep:np-prodstep
        for CE = enfstep:enfstep:ne-enfstep
    # ATTENTION: Order matters here for where they are being plotted. Use exactly 4 srategies.
            popu=[
                ["CP", CP],  # x-axis x=1
                ["DP", np - CP],  # x-axis x=0
                ["CE", CE],  # y-axis y=1
                ["DE", ne - CE],  # y-axis y=0
            ]
            push!(pops,popu)
        end
    end

    @everywhere agentStrategyNames = map(x->x[1],$pops[1])
    @everywhere agentStrategies = map(x->stratByName(x[1],allStrategies),$pops[1])

    results = pmap(calcArrow,pops)
    
    subdir = "$(rootdir)fishtank-data/"
    mkpath(subdir)
    file = subdir * theFile(parameters," ") * ".csv"
    CSV.write(file,Tables.table(mapreduce(permutedims, vcat, results)))
end