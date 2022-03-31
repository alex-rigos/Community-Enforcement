using Distributed
using Plots, Statistics
using CSV, Tables, Latexify, LaTeXStrings

num_procs = 8
if nworkers() < min(length(Sys.cpu_info()),num_procs)
    addprocs(min(length(Sys.cpu_info()),num_procs) - nworkers())
end

@everywhere include("ComEn-Definitions.jl") # Definitions of our types and methods
@everywhere model = "Baseline" # Choose which file parameters are read from. They are read from "ComEn-Parameters$(model)"

# @everywhere generations = 100000
@everywhere generations = 10

rootdir = "comp-stat/"  # Directory where data is stored

ranges = [  # Parameters and parameter value ranges for which comparative statics should be calculated. The third entry is the label of the x-axis
    ["f",.2:.1:.6,"fixed cost of punishment"],
    ["v",.05:.05:.25,"variable cost of punishment"],
    ["l",2.:.5:4,"loss from fight"],
    ["b",3.:.5:5.,"benefit from cooperation"],
    ["c",.5:.5:2.5,"cost of cooperation"],
    ["w",1.:.5:3.,"background payoff"],
    ["p",.5:.5:2.5,"loss from being punished"],
    ["τ",.1:.2:.9,"tax rate"],
    ["ψ",.1:.2:.9,"capture from win"],
    ["δ",.1:.2:.9,"Continuation probability"],
    ["κ",1:5,"Number of punishment periods"],
    ["μ",.01:.01:.05,"Probability of action mistakes"],
    ["η",[.01,.1,.15,.2,.25],"Logit noise"],
    ["ε",0.05:0.05:.25,"Probability of revision mistake"],
    ["revisionVector",
        [
            [
                [Agent,.1],
                [Enforcer,0.3],
                [Producer,.6]
            ],
            [
                [Agent,.33],
                [Enforcer,0.33],
                [Producer,.34]
            ],
            [
                [Agent,1.],
                [Enforcer,0.],
                [Producer,0.]
            ]
        ],
        "Probability of global revision"]
]

data = []

for ran in ranges  # Loop for the different parameters
    parameter = ran[1]
    values = ran[2]
    pops = [       # Vector of initial conditions
        [["CP",10],
        ["CE",2],
        ["DP",30],
        ["DE",8]],

        [["CP",10],
        ["CE",8],
        ["DP",30],
        ["DE",2]],

        [["CP",30],
        ["CE",8],
        ["DP",10],
        ["DE",2]],

        [["CP",30],
        ["CE",2],
        ["DP",10],
        ["DE",8]]
    ]
    @everywhere agentStrategies = map(x->stratByName(x[1],allStrategies),$pops[1])

    pops = append!(pops,pops) # Simulate 2 times for each initial condition

    for val in values
        @everywhere setParameters($(parameter),$(val))
        dir = "$(rootdir)comp-stat-data/$(parameter)/"
        mkpath(dir)
        dat = pmap(x->timeAverage(x,generations),pops)
        file = "$(dir)$(parameter)=$(val).csv"
        CSV.write(file,Tables.table(mapreduce(permutedims, vcat, dat)))
        println(file)
    end
end
