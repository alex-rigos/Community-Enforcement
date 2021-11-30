using Distributed
using Plots

# How many threads should be used for parallel computing?
num_procs = 8
if nworkers() < min(length(Sys.cpu_info()),num_procs)
    addprocs(min(length(Sys.cpu_info()),num_procs) - nworkers())
end

# Distribute definitions to worker threads
@everywhere include("ComEn-Definitions.jl") # Definitions of our types and methods

# for model in ["Analytical","Baseline","StressTest"]
for model in ["StressTest"]
    @everywhere model = $model
    # model = "Analytical"
    # model = "Baseline"
    if model == "StressTest"
        modelString = "Baseline"
        stressParams = [
            ["revisionVector",[[Agent,.33],[Enforcer,0.33],[Producer,.34]]],
            ["δ",.7],
            ["κ",3],
            ["μ",.04],
            ["ρ",.02],
            ["η",.2],
            ["ε",.2],
        ]
    else
        modelString = model 
        stressParams = [[]]
    end

    @everywhere include($(string("ComEn-Parameters",modelString,".jl"))) # Parameters for the simulation
    println("$model")
    println("v=$v")
    

    for par in stressParams
        addedString=""
        if !isempty(par)
            @everywhere string_as_varname($(par[1]),$(par[2]))
            println("$(par[1])=$(eval(Symbol(par[1])))")
            addedString=" $(par[1])=$(par[2])"
            if par[1] == "revisionVector"
                addedString=" revVec=$(getindex.(par[2],2))"
            end
        end
        for l = 2.:1.:4
            for f = .25:.25:.75
                @everywhere global f = $(f)
                @everywhere global l = $(l)

                # How many times to sample for each point?
                @everywhere N = 500  # 500

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

                xx,yy,uu,zz = map(x->getindex.(results,x),1:4); 


                # Scale down the arrows (adjust so that they don't overlap)
                scale = 15
                paramString = string("l=$(l) f=$(f)")
                titleString = string(model,": ",paramString,addedString)
                # plotly()
                gr()
                quiver(xx, yy, quiver=(uu/scale,zz/scale),xlims=[0,1],ylims=[0,1], 
                # xlabel="$(agentStrategyNames[1]) vs. $(agentStrategyNames[2])",
                # ylabel="$(agentStrategyNames[3]) vs. $(agentStrategyNames[4])",
                clip_on=true, thickness_scaling=1.5, aspect_ratio=:equal,titlefont=font(10))
                annotate!(0,-0.12,text("$(agentStrategyNames[2])",:center,10))
                annotate!(1,-0.12,text("$(agentStrategyNames[1])",:center,10))
                annotate!(-.15,0,text("$(agentStrategyNames[4])",:right,10))
                annotate!(-.15,1,text("$(agentStrategyNames[3])",:right,10))
                title!(titleString)
                plot!(size=(600,600))
                dir = "./Figs/$(model)-model/arrow-plots/"
                if model == "StressTest"
                    dir = "./Figs/$(model)-model/$(par[1])/arrow-plots/"
                end
                mkpath(dir)
                savefig("$(dir)/$(paramString).pdf")
            end
        end
    end
end