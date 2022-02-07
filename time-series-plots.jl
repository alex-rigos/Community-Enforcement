using CSV, Tables
using ColorSchemes, LaTeXStrings,Measures
include("ComEn-Definitions.jl")
include("ColorDefinitions.jl")
gr()
# inspectdr()
# pgfplots()
for num_strat in [4,5]
# num_strat = 4
    subdirread = "time-series/time-series-data/" * "$(num_strat)-strategies/"
    subdirwrite = "time-series/time-series-plots/" * "$(num_strat)-strategies/"
    if num_strat == 4
        thelabels =["(d)","(e)","(f)"]
    else
        thelabels =["(a)","(b)","(c)"]
    end
    params = [
        [["f",.5],["l",2.5]],  # Most favorable to defection
        [["f",.4],["l",3.]],  # Baseline
        [["f",.3],["l",3.5]],  # Most favorable to cooperation
    ]
    for i in 1:3
    # i=3
        parameters = params[i]
        subfig_label = thelabels[i]
        # parameters = [["f",.3],["l",3.5]]
        readfileString = theFile(parameters," ")
        writefileString = theFile(parameters,"-")
        data = CSV.File("$(subdirread)$(readfileString).csv")|> Tables.matrix
        data = data[:,1:num_strat]
        areaplot((1:100000)/1000,data,stacked=true,normalized=false,legend=false,
        seriescolor=mycolors,clip_on=true,thickness_scaling=1.7,
        tickfontfamily="Computer Modern",guidefontsize=6)
        # plot!(ylabel=L"{\textrm{\sffamily \LARGE population}}",fontfamily = "Helvetica",font=10)
        theheight = -10
        hshift=5
        annotate!(-15,40,text("population",:right,11,"Helvetica",rotation=90))
        annotate!(49+hshift,theheight,text("period",:right,11,"Helvetica"))
        # annotate!(51,theheight,text(L"\left(\times~10^3\right)",:left,10))
        annotate!(51+hshift,theheight+.5,text(L"\left.~10^3\right.",:left,10))
        annotate!(51+hshift,theheight,text(L"\left(\right.",:left,13))
        annotate!(58+hshift,theheight,text(L"\left.\right)",:left,13))
        thescale=1.5
        # plot!(size=(440*thescale,220*thescale))
        plot!(size=(440*thescale,330*thescale))
        plot!(title=subfig_label,titlelocation=:left,titlefont=font("Computer Modern",11))
        plot!(guidefontsize=6,tickfontsize=10,bottom_margin=3mm)
        mkpath(subdirwrite)
        println("$(subdirwrite)/$(writefileString)")
        savefig("$(subdirwrite)/$(writefileString).pdf")
    end
end