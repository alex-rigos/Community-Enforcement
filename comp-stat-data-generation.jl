using Distributed
using CSV, Tables

include("ComEn-Definitions.jl") 

startProcesses(8)

@everywhere include("ComEn-Definitions.jl") # Definitions of our types and methods
@everywhere model = "Baseline" # Choose which file parameters are read from. They are read from "ComEn-Parameters$(model)"

@everywhere generations = 1000000

rootdir = "comp-stat/"  # Directory where data is stored

ranges = [  # Parameters and parameter value ranges for which comparative statics should be calculated. The third entry is the label of the x-axis
    ["f1",.6:.1:1.0,"fixed cost of punishment"],
    ["l",1.:1.:3.,"loss from fight"],
    ["v",0.25:.05:.5,"variable cost of punishment"],
    ["c",2.0:.25:3.0,"cost of cooperation"],
    ["w",3.5:.5:5.0,"autarky payoff"],
    
    ["f1",.1:.1:.5,"fixed cost of punishment"],
    ["v",0.0:.05:.2,"variable cost of punishment"],
    ["l",4.:1.:8.,"loss from fight"],
    ["b",2.:1.:6.,"benefit from cooperation"],
    ["c",0.25:.25:1.75,"cost of cooperation"],
    ["w",1.:.5:3.,"autarky payoff"],
    ["p",.5:.5:2.5,"loss from being punished"],
    ["τ",.2:.2:.8,"tax rate"],
    ["ψ",.1:.2:.9,"capture from win"],
    ["δ",[0.,0.3,0.6,0.9,0.95],"Continuation probability"],
    ["κ",[1,5,8,10,15],"Number of punishment periods"],
    ["μ",.0:.02:.1,"Probability of action mistakes"],
    ["η",[.01,.1,1.,5.,10.],"Logit noise"],
    ["ε",[0.01,.05,.1,.2,.5],"Probability of revision mistake"],
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

strats = Dict(
    1=>["CP","DP","CE","DE"],
    3=>["CP","DP","CE","PE","DE"]
)

data = []

for karma in [1,3]
    @everywhere agentStrategies = [stratByName(name,allStrategies) for name in $strats[$karma]]
    for ran in ranges  # Loop for the different parameters
        parameter = ran[1]
        values = ran[2]

        dir = "$(rootdir)comp-stat-data/karma $(karma)/$(parameter)/"
        mkpath(dir)

        for val in values
            @everywhere loadParameters(model)
            @everywhere setParameters($(parameter),$(val))
            @everywhere setParameters("karma",$(karma))
            pops = [createRandomPop(strats[karma]) for i in 1:7]
            dat = pmap(x->timeAverage(x,generations),pops)
            file = "$(dir)$(parameter)=$(val).csv"
            CSV.write(file,Tables.table(mapreduce(permutedims, vcat, dat)))
            println(file)
        end
    end
end