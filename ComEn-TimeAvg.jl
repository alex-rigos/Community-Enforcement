using Distributed
@everywhere using Plots
num_procs = 5
if nworkers() < min(length(Sys.cpu_info()),num_procs)
    addprocs(min(length(Sys.cpu_info()),num_procs) - nworkers())
end
@everywhere include("ComEn-Definitions.jl") # Definitions of our types and methods

@everywhere include("ComEn-Parameters.jl") # Parameters for the simulation
#  Check that parameters do not give negative taxable/contestable income

params = []
for l = 1.:1.:3.
    for f = .25:.25:.75
        push!(params,[l,f])
    end
end

@everywhere revisionVector = [  # Adjustment process: with what probability do we allow revisions of each type
    [Agent,.1],
    [Enforcer,0.3],
    [Producer,.6]
]

@everywhere pop=[
    ["cooperator",5],
    ["peacekeeper",20],
    ["defector",5],
    ["shortsighted",20],
    # ["clairvoyant",50],
    # ["aggressor",10],
    # ["clubby",10]
]

@everywhere agentStrategyNames = map(x->x[1],pop)
@everywhere agentStrategies = map(x->stratByName(x[1],allStrategies),pop)

@everywhere population = makePopulation(pop)  # Initialize population
@everywhere notIncluded = findall(i->stats(population)[i]==0,1:length(stratVector))
@everywhere generations = 20000
@everywhere gensToIgnore = 0  # How many generations should we ignore for the time averages?

plots = pmap(ourPlot,params)