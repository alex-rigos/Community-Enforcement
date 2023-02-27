using CSV, Tables, Printf

include("../ComEn-Definitions.jl")
include("../ColorDefinitions.jl")

rootdir= "paper-figures/time-series-and-averages/"

indivplots = 0 # Set to 1 to generate plots for individual runs

params = Dict(
    "baseline"=> [["b",4.0],["c",1.0],["f1",0.3],["l",5.0],["v",0.10]],
    "worse" => [["b",3.0],["c",2.0],["f1",0.4],["l",4.0],["v",0.30]],
)
labels =Dict(
    [1,"baseline",18]=>["(a)",""],
    [1,"baseline",4]=>["(b)",""],
    [1,"worse",18]=>["(d)",""],
    [1,"worse",4]=>["(e)",""],
    [2,"baseline",18]=>["(a)",""],
    [2,"baseline",4]=>["(b)",""],
    [2,"worse",18]=>["(d)",""],
    [2,"worse",4]=>["(e)",""],
    [3,"baseline",5]=>["(c)",""],
    [3,"worse",5]=>["(f)",""],
)

paramsToAdd = []

# Specify strategy indices for each reputation system selection. THE INDICES ARE DEPENDENT ON THE allStrategies VECTOR!!!
prodindices = 1:2
enfindexlist = Vector{Dict}(undef,3)
enfindexlist[1] = Dict(
    4=>[20,21],
    18=>3:18
)
enfindexlist[2] = Dict(
    4=>[19,21],
    18=>3:18
)
enfindexlist[3] = Dict(
    5=>19:21
)

for parname in keys(params)
# for parname in ["baseline"]
    par = vcat(params[parname],paramsToAdd)
    parString = theFile(par, " ")
    # for karma = 1:3
    for karma in 1:3
        for nstrat in keys(enfindexlist[karma])
        # for nstrat in [4]
            enfindices = enfindexlist[karma][nstrat]
            subdirread = "$(rootdir)time-series-data/$(parString)/karma $(karma)/$(nstrat)-strategies/"
            subdirwrite = "$(rootdir)time-averages-plots/"
            mkpath(subdirwrite)
            shares = Matrix{Float64}(undef,7,length(stratVector))
            for number = 1:7
                fileread = "$(subdirread)run-$(number).csv"
                data = CSV.File(fileread)|> Tables.matrix
                shares[number,:] = mean(map(x->x/sum(x),eachrow(data)))                
                if indivplots == 1
                    plotAndSaveTimeAverages(shares[number,:],"$(subdirwrite)run-$(number).pdf",prodindices,enfindices,mycolors[karma])
                end
            end
            plotAndSaveTimeAverages(mean(eachrow(shares)),"$(subdirwrite)$(parname)-karma$(karma)-$(@sprintf("%02d",nstrat))-strategies.pdf",prodindices,enfindices,mycolors[karma],labels[[karma,parname,nstrat]])
            # plotAndSaveTimeAverages(mean(eachrow(shares)),"$(subdirwrite)$(parname)-karma$(karma)-$(@sprintf("%02d",nstrat))-strategies.pdf",prodindices,enfindices,mycolors[karma],labels)
        end
    end
end