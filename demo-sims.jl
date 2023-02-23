using CSV, Tables
include("demo-params.jl") # Parameters for the simulation
include("ColorDefinitions.jl")
rootdir = "demo/"
mkpath(rootdir)

generations = 10000

plotwindow = 1:10000

stratlist = Dict(
    1 => ["CP","DP","0000","0001","0010","0011","0100","0101","0110","0111","1000","1001","1010","1011","1100","1101","1110","1111"],
    2 => ["CP","DP","0000","0001","0010","0011","0100","0101","0110","0111","1000","1001","1010","1011","1100","1101","1110","1111"],
    3 => ["CP","CE","DP","DE","PE"]
)
strats = stratlist[karma]

# Specify strategy indices for each reputation system selection. THE INDICES ARE DEPENDENT ON THE allStrategies VECTOR!!!
prodindices = 1:2
enfindexlist = Dict(
    1 => 3:18,
    2 => 3:18,
    3 => 19:21
)
indices = vcat(1:2,enfindexlist[karma])

datafilename = "$(rootdir)demo-data.csv"
createAndSaveTimeSeries(strats,datafilename)


# Time series plots
gr()

filewrite = "$(rootdir)demo-time-series-$(plotwindow).pdf"
data = CSV.File(datafilename)|> Tables.matrix

plotAndSaveTimeSeries(data,plotwindow,filewrite,indices,mycolors[karma],"")

# Time averages
shares = Matrix{Float64}(undef,1,length(stratVector))
shares[1,:] = mean(map(x->x/sum(x),eachrow(data)))                
plotAndSaveTimeAverages(shares[1,:],"$(rootdir)demo-time-avg.pdf",prodindices,enfindexlist[karma],mycolors[karma])