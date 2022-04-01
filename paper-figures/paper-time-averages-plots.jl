using CSV, Tables

include("../ComEn-Definitions.jl")
include("../ColorDefinitions.jl")

gr()

for num_strat in [4,5]
    subdirread = "paper-figures/time-series/time-series-data/" * "$(num_strat)-strategies/"
    subdirwrite = "paper-figures/time-averages/time-averages-plots/" * "$(num_strat)-strategies/"
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
        parameters = params[i]
        subfig_label = thelabels[i]
        readfileString = theFile(parameters," ")
        writefileString = theFile(parameters,"-")
        data = CSV.File("$(subdirread)$(readfileString).csv")|> Tables.matrix
        data = data[:,1:num_strat]
        
        c = mycolors
        stratVector1 = stratVector[1:num_strat]
        avg = mean(eachrow(data))
    
        bar(reshape(stratVector1,1,num_strat),reshape(avg/sum(data[1,:]),1,num_strat),
        labels = stratVector1,legend = false,ylims=[0,1],seriescolor=c,
        ytickfontfamily="Computer Modern",guidefontsize=15,tickfontsize=12)
        plot!(title=subfig_label,titlelocation=:left,titlefont=font("Computer Modern",13))
        plot!(size=(440,220)) # Alternatively: plot!(size=(440,330))
        mkpath(subdirwrite)
        file = subdirwrite * writefileString * ".pdf"
        savefig(file)
        println(file)
    end
end