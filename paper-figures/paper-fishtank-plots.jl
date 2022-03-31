using Plots
using Statistics
using CSV, Tables, Latexify, LaTeXStrings,ColorSchemes

include("../ComEn-Definitions.jl")
include("../ColorDefinitions.jl")

subdirread = "paper-figures/fishtanks/fishtank-data/"
subdirwrite = "paper-figures/fishtanks/fishtank-plots/"

plot_font = "DejaVu Sans"
default(
  fontfamily=plot_font,
  linewidth=2, 
  framestyle=:box, 
  label=nothing, 
  grid=false
)
params = [
    [["f",.5],["l",2.5]],  # Most favorable to defection
    [["f",.4],["l",3.]],  # Baseline
    [["f",.3],["l",3.5]],  # Most favorable to cooperation
]
for i in 1:3
    parameters = params[i]
    # parameters = [["f",.3],["l",3.5]] 
    readfileString = theFile(parameters," ")
    writefileString = theFile(parameters,"-")
    results = CSV.File("$(subdirread)$(readfileString).csv")|> Tables.matrix
    subfig_label = ["(a)","(b)","(c)"][i]
    xx = results[:,1]
    yy = results[:,2]
    uu = results[:,3]
    zz = results[:,4]

    # Scale down the arrows (adjust so that they don't overlap)
    scale = 10
    # paramString = string("l=$(l) f=$(f)")
    
    # plotly()
    pgfplotsx()
    # pyplot()
    # gr()
    # GLMakie()
    # inspectdr()
    # fig = Figure(resolution(800,500))
    Plots.plot(layout=(1,1))
    # Plots.plot!(fontfamily="Computer Modern")
    plot!(xlims=[0,1],ylims=[0,1])
    Plots.plot!(size=(480,480))
    Plots.plot!(xlabel=L"\textrm{\sffamily proportion of cooperating producers}~\left(\frac{n_{CP}}{n_P}\right)",fontfamily = "Helvetica")
    Plots.plot!(ylabel=L"\textrm{\sffamily proportion of cooperation enforcers}~\left(\frac{n_{CE}}{n_E}\right)",fontfamily = "Helvetica")
    plot!(guidefontsize=15,tickfontsize=12)
    #==== Slow Alternative ===#
    for (x,y,u,v) in zip(xx,yy,uu/scale,zz/scale)
      arrow0!(x, y, u, v; as=0.02, lc=arrowcol, la=1,lw=1.,rounding=.0017)
    end
    plot!()
    #=========================#

    #==== Fast Alternative ===#
    Plots.plot!(xx, yy, quiver=(uu/scale,zz/scale),xlims=[0,1],ylims=[0,1],
    arrow=:big, thickness_scaling=1,
    legend=false,color=arrowcol, seriestype = :quiver,aspect_ratio=:equal,linewidth=1.3,tickfontfamily="Computer Modern")
    plot!(title=subfig_label,titlelocation=:left,titlefont=font("Helvetica"))
    #=========================#
    plot!(size=(440,440))
    # Plots.plot!(xlabel=L"{n_{CP}}/{n_P}")
    # Plots.plot!(ylabel=L"{n_{CE}}/{n_E}")
    
    mkpath(subdirwrite)
    println("$(subdirwrite)$(writefileString)")
    savefig("$(subdirwrite)$(writefileString).pdf")
end