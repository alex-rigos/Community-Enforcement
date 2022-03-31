using CSV, Tables
using ColorSchemes, LaTeXStrings, Measures
include("ComEn-Definitions.jl")
include("ColorDefinitions.jl")

rootdir = "time-series/"

gr()
for num_strat in [4,5]
    subdirread = "$(rootdir)time-series-data/" * "$(num_strat)-strategies/"
    subdirwrite = "$(rootdir)time-series-plots/" * "$(num_strat)-strategies/"
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
            s = size(data,1)
            m = s/100000
            areaplot((1:s)/1000,data,stacked=true,normalized=false,legend=false,
                seriescolor=mycolors,clip_on=true,thickness_scaling=1.7,
                tickfontfamily="Computer Modern",guidefontsize=6)
            # Place axis labels
            theheight = -10
            hshift = 5*m
            annotate!(-(8-log(10,s)) * m * log(10,s),40,text("population",:right,11,"Helvetica",rotation=90))
            annotate!(49 * m + hshift,theheight,text("period",:right,11,"Helvetica"))
            annotate!(51 * m + hshift,theheight + .5,text(L"\left.~10^3\right.",:left,10))
            annotate!(51 * m + hshift,theheight,text(L"\left(\right.",:left,13))
            annotate!(58 * m + hshift,theheight,text(L"\left.\right)",:left,13))
            thescale = 1.5
            plot!(size=(440*thescale,330*thescale))
            plot!(guidefontsize=6,tickfontsize=10,bottom_margin=3mm)
            mkpath(subdirwrite)
            file = "$(subdirwrite)$(writefileString).pdf"
            savefig(file)
            println(file)
        end
    end
end