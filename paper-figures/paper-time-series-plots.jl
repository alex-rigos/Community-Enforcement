using CSV, Tables
using Measures, LaTeXStrings
include("../ComEn-Definitions.jl")
include("../ColorDefinitions.jl")
# plotwindow = 1:1000001
plotwindow = 1:200000

# rootdir = "trial/time-series-and-averages/"
# rootdir= "trial/time-series-and-averages/new-thing/"
rootdir= "paper-figures/time-series-and-averages/"

params = Dict(
    "baseline"=> [["b",4.0],["c",1.0],["f1",0.3],["l",5.0],["v",0.10]],
    "worse" => [["b",3.0],["c",2.0],["f1",0.4],["l",4.0],["v",0.30]],
)

label = Dict(
    "baseline" => "(c)",
    "worse" => "(f)",
)

# label = "(a)"

# paramsToAdd = []
paramsToAdd = [["ε",0.01]]

stringToAdd = ""
if !isempty(paramsToAdd)
    stringToAdd = "-" * paramsToAdd[1][1] * "=$(paramsToAdd[1][2])"
end

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

gr()
# for parname in ["baseline"]
# for parname in ["worse"]
for parname in keys(params)
    par = vcat(params[parname],paramsToAdd)
    parString = theFile(par, " ")
    # for karma = 1:3
    # for karma in [1,3]
    for karma in [1]
        # for nstrat in keys(enfindexlist[karma])
        for nstrat in [4]
            indices = vcat(1:2,enfindexlist[karma][nstrat])
            subdirread = "$(rootdir)time-series-data/$(parString)/karma $(karma)/$(nstrat)-strategies/"
            subdirwrite = "$(rootdir)time-series-plots/"
            mkpath(subdirwrite)
            # for number in 1:7
            # for number in [4]
            for number in [5]
                if parname == "baseline"
                    number = 4
                elseif parname == "worse"
                    number = 5
                end
                fileread = "$(subdirread)run-$(number).csv"
                # filewrite = "$(subdirwrite)timeseries$(stringToAdd)-$(parname)-karma$(karma)-$(nstrat)-strategies-run$(number)-$(plotwindow).pdf"
                filewrite = "$(subdirwrite)timeseries-$(parname).pdf"
                data = CSV.File(fileread)|> Tables.matrix
                gr()
                plotAndSaveTimeSeries(data,plotwindow,filewrite,indices,mycolors[karma],label[parname])
            end
        end
    end
end