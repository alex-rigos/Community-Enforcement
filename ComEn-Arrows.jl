using Distributed
using Plots

# How many threads should be used for parallel computing?
num_procs = 8
if nworkers() < min(length(Sys.cpu_info()),num_procs)
    addprocs(min(length(Sys.cpu_info()),num_procs) - nworkers())
end

# Distribute definitions to worker threads
@everywhere include("ComEn-Definitions.jl") # Definitions of our types and methods

for model in ["Analytical","Baseline"]
    @everywhere model = $model
# model = "Analytical"
# model = "Baseline"

    @everywhere include($(string("ComEn-Parameters",model,".jl"))) # Parameters for the simulation
    println("$model")
    println("v=$v")
    for l = 2.:1.:4
        for f = .25:.25:.75

            @everywhere global f = $(f)
            @everywhere global l = $(l)

            # How many times to sample for each point?
            @everywhere N = 5

            #  Check that parameters do not give negative payoffs
            warning()

            np = 160  # number of producers
            prodstep = np/20  # step increment (grid) for producers
            ne = 40  # number of enforcers
            enfstep = ne/20  # step increment (grid) for enforcers

            pops = []  # Vector to hold populations
            for CP = prodstep:prodstep:np-prodstep
                for CE = enfstep:enfstep:ne-enfstep
            # ATTENTION: Order matters here for where they are being plotted. Use exactly 4 srategies.
                    pop=[
                        ["CP", CP],  # x-axis x=1
                        ["DP", np - CP],  # x-axis x=0
                        ["CE", CE],  # y-axis y=1
                        ["DE", ne - CE],  # y-axis y=0
                        ]
                        push!(pops,pop)
                end
            end
            @everywhere agentStrategyNames = map(x->x[1],$pops[1])
            @everywhere agentStrategies = map(x->stratByName(x[1],allStrategies),$pops[1])

            results = pmap(calcArrow,pops)

            xx,yy,uu,zz = map(x->getindex.(results,x),1:4); 


            # Scale down the arrows (adjust so that they don't overlap)
            scale = 15
            paramString = "l=$(l) f=$(f)"
            titleString = string(model,": ",paramString)
            # plotly()
            gr()
            quiver(xx, yy, quiver=(uu/scale,zz/scale),xlims=[0,1],ylims=[0,1], 
            # xlabel="$(agentStrategyNames[1]) vs. $(agentStrategyNames[2])",
            # ylabel="$(agentStrategyNames[3]) vs. $(agentStrategyNames[4])",
            clip_on=true, thickness_scaling=1.5, aspect_ratio=:equal)
            annotate!(0,-0.12,text("$(agentStrategyNames[2])",:center,10))
            annotate!(1,-0.12,text("$(agentStrategyNames[1])",:center,10))
            annotate!(-.15,0,text("$(agentStrategyNames[4])",:right,10))
            annotate!(-.15,1,text("$(agentStrategyNames[3])",:right,10))
            title!(titleString)
            plot!(size=(600,600))
            savefig("./Figs/$(model)-model/arrow-plots/$(paramString).pdf")
        end
    end
end