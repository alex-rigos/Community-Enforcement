using Distributed

num_procs = 8
if nworkers() < min(length(Sys.cpu_info()),num_procs)
    addprocs(min(length(Sys.cpu_info()),num_procs) - nworkers())
end

@everywhere using Plots, CSV, Tables

@everywhere include("ComEn-Definitions.jl") # Definitions of our types and methods

@everywhere model = "Baseline"

@everywhere generations = 100000

params = [
    [["f",.3],["l",3.5]],  # Most favorable to cooperation
    [["f",.4],["l",3.]],  # Baseline
    [["f",.5],["l",2.5]],  # Most favorable to defection
]

#= Initial condition =#

@everywhere pop=[
    # ["CP",20],
    # ["CE",20],
    # ["DP",5],
    # ["DE",5],

    # ["CP",5],
    # ["CE",20],
    # ["DP",5],
    # ["DE",20],

    # # For Figure 7
    ["CP",10],
    ["CE",10],
    ["DP",10],
    ["DE",10],
    ["PE",10],
]

@everywhere agentStrategyNames = map(x->x[1],pop)
@everywhere agentStrategies = map(x->stratByName(x[1],allStrategies),pop)

@everywhere population = makePopulation(pop)  # Initialize population
@everywhere notIncluded = findall(i->stats(population)[i]==0,1:length(stratVector))
@everywhere gensToIgnore = 0  # How many generations should we ignore for the time averages?

@everywhere function saveTimeSeries(par::Vector{Vector{Any}})
    setParameters(par)
    fileString = theFile(par)
    gen=0  # Start counting generations
    data = zeros(generations,length(stratVector))  # This is where the data is stored

    while gen<generations
        gen += 1
        simulate!(population)
        selection!(population,agentsToRevise,revisionVector)
        data[gen,:]=stats(population)
    end
    # println(data)
    subdir = "time-series/time-series-data/"
    subdir = subdir * "$(length(agentStrategyNames))-strategies/"
    mkpath(subdir)
    CSV.write("$(subdir)$(fileString).csv",Tables.table(data))
    # return data,fileString
end

pmap(saveTimeSeries,params)