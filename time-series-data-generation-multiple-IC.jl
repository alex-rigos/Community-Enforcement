# For parallel computing
using Distributed
startProcesses(8)

# @everywhere rootdir= "time-series-and-averages/"
# @everywhere rootdir= "trial/time-series-and-averages/"
rootdir= "trial/time-series-and-averages/new-thing/"

@everywhere using CSV, Tables
@everywhere include("ComEn-Definitions.jl") # Definitions of our types and methods
@everywhere model = "Baseline"

@everywhere generations = 1000000

# Specify parameter combinations
params = Dict(
    "baseline"=> [["b",4.0],["c",1.0],["f1",0.3],["l",5.0],["v",0.10]],
    "worse" => [["b",3.0],["c",2.0],["f1",0.4],["l",4.0],["v",0.20]]
)

# paramsToAdd = [["ε",0.01]]
paramsToAdd = []

# List strategy sets for each of the three reputation (karma) systems
stratlist = Vector{Dict}(undef,3)
stratlist[1] = Dict(
    4=>["CP","DP","CE","DE"],     
    18 => ["CP","DP","0000","0001","0010","0011","0100","0101","0110","0111","1000","1001","1010","1011","1100","1101","1110","1111"]
)
stratlist[2] = Dict(
    4=>["CP","DP","PE","DE"],     
    18 => ["CP","DP","0000","0001","0010","0011","0100","0101","0110","0111","1000","1001","1010","1011","1100","1101","1110","1111"]
)
stratlist[3] = Dict(
    5=>["CP","CE","DP","DE","PE"]
)

# for parname in keys(params)
for parname in keys(params)
    par = vcat(params[parname],paramsToAdd)
    @everywhere setParameters($par)
    parString = theFile(par, " ")
    # for karma = 1:3
    for karma in [1]
        @everywhere karma = $karma
        # for nstrat in keys(stratlist[karma])
        for nstrat in [4]
            strats = stratlist[karma][nstrat]
            subdir = "$(rootdir)time-series-data/$(parString)/karma $(karma)/$(length(strats))-strategies/"
            mkpath(subdir)
            filenames = ["$(subdir)run-$(number).csv" for number in 1:7]
            pmap(x->createAndSaveTimeSeries(strats,x),filenames)
        end
    end
end