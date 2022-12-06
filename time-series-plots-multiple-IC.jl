using CSV, Tables
using Measures, LaTeXStrings
include("ComEn-Definitions.jl")
include("ColorDefinitions.jl")

# plotwindow = 1:1000001
plotwindow = 1:200000

# rootdir = "trial/time-series-and-averages/"
rootdir= "trial/time-series-and-averages/new-thing/"

params = Dict(
    "baseline"=> [["b",4.0],["c",1.0],["f1",0.3],["l",5.0],["v",0.10]],
    "worse" => [["b",3.0],["c",2.0],["f1",0.4],["l",4.0],["v",0.20]]
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
            indices = vcat(1:2,enfindexlist[karma][nstrat])
            subdirread = "$(rootdir)time-series-data/$(parString)/karma $(karma)/$(nstrat)-strategies/"
            subdirwrite = "$(rootdir)time-series-plots/$(parString)/karma $(karma)/$(nstrat)-strategies/"
            mkpath(subdirwrite)
            for number in 1:7
                fileread = "$(subdirread)run-$(number).csv"
                filewrite = "$(subdirwrite)run-$(number)-$(plotwindow).pdf"
                data = CSV.File(fileread)|> Tables.matrix
                
                plotAndSaveTimeSeries(data,plotwindow,filewrite,indices,diagramcol)
            end
        end
    end
end