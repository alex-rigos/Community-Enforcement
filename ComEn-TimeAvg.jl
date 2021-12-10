using Distributed
@everywhere using Plots
num_procs = 9
if nworkers() < min(length(Sys.cpu_info()),num_procs)
    addprocs(min(length(Sys.cpu_info()),num_procs) - nworkers())
end
@everywhere include("ComEn-Definitions.jl") # Definitions of our types and methods

# for model in ["Analytical","Baseline","StressTest"]
for model in ["Baseline"]
    @everywhere model = $model
# model = "Analytical"
# model = "Baseline"
    if model == "StressTest"
        modelString = "Baseline"
        stressParams = [
            ["δ",.7],
            ["κ",3],
            ["μ",.04],
            ["ρ",.02],
            ["η",.2],
            ["ε",.2],
            ["revisionVector",[[Agent,.33],[Enforcer,0.33],[Producer,.34]]]
        ]
    else
        modelString = model
        stressParams = [[]]
    end

    @everywhere include($(string("ComEn-Parameters",modelString,".jl"))) # Parameters for the simulation
    
    for par in stressParams
        # if !isempty(par)
        #     @everywhere string_as_varname($(par[1]),$(par[2])) 
        # end
   
        # println("$model")
        # println("v=$v")

        params = []
        # for l in [2.,3.,4.]
        #     for f in [.25,.5,.75]
        #         push!(params,[["l",l],["f",f],par])
        #     end
        # end

        for b in [3.,4.,5.]
            for c in [.5,1.,1.5]
                push!(params,[["b",b],["c",c],par])
            end
        end

        
        # for v in [.05,.1,.15]
        #     push!(params,[["v",v],par])
        # end

        @everywhere revisionVector = [  # Adjustment process: with what probability do we allow revisions of each type
            [Agent,.1],
            [Enforcer,0.3],
            [Producer,.6]
        ]

        @everywhere pop=[
            ["CP",5],
            ["CE",20],
            ["DP",5],
            ["DE",20],
            # ["clairvoyant",50],
            # ["aggressor",10],
            # ["clubby",10]
        ]

        @everywhere agentStrategyNames = map(x->x[1],pop)
        @everywhere agentStrategies = map(x->stratByName(x[1],allStrategies),pop)

        @everywhere population = makePopulation(pop)  # Initialize population
        @everywhere notIncluded = findall(i->stats(population)[i]==0,1:length(stratVector))
        @everywhere generations = 100000  # 100000
        @everywhere gensToIgnore = 0  # How many generations should we ignore for the time averages?

        pmap(ourPlot,params)
    end
end