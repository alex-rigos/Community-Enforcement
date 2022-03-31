using CSV, Tables
using Vega, ColorSchemes, ColorBrewer,LaTeXStrings
include("ComEn-Definitions.jl")
include("ColorDefinitions.jl")

rootdir = "time-series/"

gr()
for num_strat in [4,5]
    subdirread = "$(rootdir)time-series-data/" * "$(num_strat)-strategies/"
    subdirwrite = "$(rootdir)time-aveages-plots/" * "$(num_strat)-strategies/"

    params = [
        [["f",.5],["l",2.5]],  # Most favorable to defection
        [["f",.4],["l",3.]],  # Baseline
        [["f",.3],["l",3.5]],  # Most favorable to cooperation
    ]
    for i in 1:3
        parameters = params[i]
        readfile = subdirread * theFile(parameters," ") * ".csv"
        writefileString = theFile(parameters,"-")
        if !isfile(readfile)
            println("WARNING! Data file $(readfile) does not exist.")
        else
            data = CSV.File(readfile)|> Tables.matrix
            data = data[:,1:num_strat]
            c = mycolors
            stratVector1 = stratVector[1:num_strat]
            avg = mean(eachrow(data))
        
            bar(reshape(stratVector1,1,num_strat),reshape(avg/sum(data[1,:]),1,num_strat),
            labels = stratVector1,legend = false,ylims=[0,1],seriescolor=c,
            ytickfontfamily="Computer Modern",guidefontsize=15,tickfontsize=12)
            plot!(size=(440,220)) # Alternatively: plot!(size=(440,330))
            mkpath(subdirwrite)
            file = "$(subdirwrite)$(writefileString).pdf"
            savefig(file)
            println(file)
        end
    end
end