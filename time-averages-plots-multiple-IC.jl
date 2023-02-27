using CSV, Tables
include("ComEn-Definitions.jl")
include("ColorDefinitions.jl")

rootdir= "time-series-and-averages/"

indivplots = 1 # Set to 1 to generate plots for individual runs

params = Dict(
    "baseline"=> [["b",4.0],["c",1.0],["f1",0.3],["l",5.0],["v",0.10]],
    "worse" => [["b",3.0],["c",2.0],["f1",0.4],["l",4.0],["v",0.30]],
)

paramsToAdd = []
# paramsToAdd = [["ε",0.01]]

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
    par = vcat(params[parname],paramsToAdd)
    parString = theFile(par, " ")
    for karma = 1:3
        for nstrat in keys(enfindexlist[karma])
            enfindices = enfindexlist[karma][nstrat]
            subdirread = "$(rootdir)time-series-data/$(parString)/karma $(karma)/$(nstrat)-strategies/"
            subdirwrite = "$(rootdir)time-averages-plots/$(parString)/karma $(karma)/$(nstrat)-strategies/"
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
            plotAndSaveTimeAverages(mean(eachrow(shares)),"$(subdirwrite)AVG.pdf",prodindices,enfindices,mycolors[karma])
        end
    end
end