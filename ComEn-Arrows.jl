@everywhere include("ComEn-Definitions.jl") # Definitions of our types and methods
@everywhere include("ComEn-Parameters.jl") # Parameters for the simulation

using Plots

# For parallel computing
# How many processes we should use for parallel computing?
num_procs = 8
if nprocs() <= min(length(Sys.cpu_info()),num_procs) - nprocs()
    addprocs(min(length(Sys.cpu_info()),num_procs) - nprocs())
end

# How many times to sample for each point?
@everywhere N = 500

#  Check that parameters do not give negative payoffs
# warning()

np = 100
prodstep = 10
ne = 100
enfstep = 10

pops = []
for CP = prodstep:prodstep:np-prodstep
    for CE = enfstep:enfstep:ne-enfstep
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

xx,yy,uu,vv = map(x->getindex.(results,x),1:4);

##
# Scale down the arrows (adjust so that they don't overlap)
scale = 10

quiver(xx, yy, quiver=(uu/scale,vv/scale),xlims=[0,1],ylims=[0,1])