using Distributed
using Plots

# How many threads should be used for parallel computing?
num_procs = 8
if nworkers() < min(length(Sys.cpu_info()),num_procs)
    addprocs(min(length(Sys.cpu_info()),num_procs) - nworkers())
end

# Distribute definitions to worker threads
@everywhere include("ComEn-Definitions.jl") # Definitions of our types and methods
@everywhere include("ComEn-Parameters.jl") # Parameters for the simulation

# How many times to sample for each point?
@everywhere N = 500

#  Check that parameters do not give negative payoffs
warning()

np = 160  # number of producers
prodstep = np/20  # step increment (grid) for producers
ne = 40  # number of enforcers
enfstep = ne/20  # step increment (grid) for enforcers

pops = []  # Vector to hold populations
for CP = prodstep:prodstep:np-prodstep
    for CE = enfstep:enfstep:ne-enfstep
# for CP = 4:4:16
#          for CE = 1:1:4
        pop=[
            ["cooperator", CP],
            ["defector", np - CP],
            ["peacekeeper", CE],
            ["shortsighted", ne - CE],
            ]
            push!(pops,pop)
    end
end
@everywhere agentStrategyNames = map(x->x[1],$pops[1])
@everywhere agentStrategies = map(x->stratByName(x[1],allStrategies),$pops[1])

results = pmap(calcArrow,pops)

xx,yy,uu,zz = map(x->getindex.(results,x),1:4);

##
# Scale down the arrows (adjust so that they don't overlap)
scale = 20

quiver(xx, yy, quiver=(uu/scale,zz/scale),xlims=[0,1],ylims=[0,1], 
xlabel="$(agentStrategyNames[1]) vs. $(agentStrategyNames[2])",
ylabel="$(agentStrategyNames[3]) vs. $(agentStrategyNames[4])")