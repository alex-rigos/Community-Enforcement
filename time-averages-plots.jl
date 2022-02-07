using CSV, Tables
using Vega, ColorSchemes, ColorBrewer,LaTeXStrings
include("ComEn-Definitions.jl")
include("ColorDefinitions.jl")

gr()

for num_strat in [4,5]
# num_strat = 4
    subdirread = "time-series/time-series-data/" * "$(num_strat)-strategies/"
    subdirwrite = "time-series/time-averages-plots/" * "$(num_strat)-strategies/"
    if num_strat == 4
        thelabels =["(g)","(h)","(i)"]
    else
        thelabels =["(d)","(e)","(f)"]
    end

    params = [
        [["f",.5],["l",2.5]],  # Most favorable to defection
        [["f",.4],["l",3.]],  # Baseline
        [["f",.3],["l",3.5]],  # Most favorable to cooperation
    ]
    for i in 1:3
        # i=1
        parameters = params[i]
        subfig_label = thelabels[i]
        # parameters = [["f",.3],["l",3.5]]
        readfileString = theFile(parameters," ")
        writefileString = theFile(parameters,"-")
        data = CSV.File("$(subdirread)$(readfileString).csv")|> Tables.matrix
        data = data[:,1:num_strat]
        
        c = mycolors
        stratVector1 = stratVector[1:num_strat]
        avg = mean(eachrow(data))
        # println("ψ=$(ψ), κ=$(κ)\n$(stratVector1)\n$(avg)")
    
        bar(reshape(stratVector1,1,num_strat),reshape(avg/sum(data[1,:]),1,num_strat),
        labels = stratVector1,legend = false,ylims=[0,1],seriescolor=c,
        ytickfontfamily="Computer Modern",guidefontsize=15,tickfontsize=12)
        plot!(title=subfig_label,titlelocation=:left,titlefont=font("Computer Modern",13))
        plot!(size=(440,220))
        # plot!(size=(440,330))
        mkpath(subdirwrite)
        println(writefileString)
        savefig("$(subdirwrite)/$(writefileString).pdf")
    end
end