using Plots
using Statistics
using CSV, Tables, LaTeXStrings,ColorSchemes
include("ComEn-Definitions.jl")
include("ColorDefinitions.jl")
ranges = [
    ["f",.2:.1:.6,"fixed cost of punishment",true,:bottomleft,"(a)"],
    ["v",.05:.05:.25,"variable cost of punishment",true,:bottom,"(b)"],
    ["l",2.:.5:4,"loss from fight",true,:bottomleft,"(c)"],
["b",3.:.5:5.,"benefit from cooperation",true,:bottomleft,"(d)"],
["c",.5:.5:2.5,"cost of cooperation",true,:bottom,"(e)"],
["w",1.:.5:3.,"background payoff",true,:bottomleft,"(f)"],
["p",.5:.5:2.5,"loss from being punished",true,:bottom,"(g)"],
["τ",.1:.2:.9,"tax rate",true,:bottom,"(h)"],
["ψ",.1:.2:.9,"capture from win",true,:bottomleft,"(i)"],
["δ",.1:.2:.9,"continuation probability",true,:bottomright,"(a)"],
["κ",1:5,"number of punishment periods",true,:bottomright,"(b)"],
["μ",.01:.01:.05,"probability of action mistakes",true,:bottomright,"(c)"],
["η",[.01,.1,.15,.2,.25],"logit noise",true,:bottomright,"(d)"],
["ε",0.05:0.05:.25,"probability of revision mistake",true,:bottomright,"(e)"],
["revisionVector",[
    [[Agent,.1],
    [Enforcer,0.3],
    [Producer,.6]],
    [[Agent,.33],
    [Enforcer,0.33],
    [Producer,.34]],
    [[Agent,1.],
    [Enforcer,0.],
    [Producer,0.]]
],"probability of global revision",true,:bottomright,"(f)"]
]



for ran in ranges
    parameter = ran[1]
    rang = ran[2]
    title = ran[3]
    show_baseline = ran[4]
    legend_place = ran[5]
    subfig_label = ran[6]

# parameter = "f"
# range = .2:.1:.6
# title = ranges[1][3]
        xCP = []
        xCE = []
        xP = []
        sCP = []
        sCE = []
        sP = []
        dir = "line-plots/$(parameter)"
        y = []
    for val in rang
        df = CSV.File("$(dir)/$(parameter)=$(val).csv")|> Tables.matrix
        len =length(df[:,1])
        append!(xCP, mean(map(i->df[i,1]/(df[i,1]+df[i,3]),1:len)))
        append!(xCE, mean(map(i->df[i,2]/(df[i,2]+df[i,4]),1:len)))
        append!(xP, mean(map(i->(df[i,1]+df[i,3])/(sum(df[i,:])),1:len)))
        
        # For standard deviations
        append!(sCP, Statistics.std(map(i->df[i,1]/(df[i,1]+df[i,3])/sqrt(len),1:len)))
        append!(sCE, Statistics.std(map(i->df[i,2]/(df[i,2]+df[i,4])/sqrt(len),1:len)))
        append!(sP, Statistics.std(map(i->(df[i,1]+df[i,3])/(sum(df[i,:]))/sqrt(len),1:len)))
        # println("xCP=$(xCP)")
        # println("sCP=$(sCP)")
        # for i in 1:length(df[:,1])
        #     xCP[i] = df[i,1]/(df[i,1]+df[i,3])
        #     xCE[i] = df[i,2]/(df[i,2]+df[i,4])
        #     xP[i] = (df[i,1]+df[i,3])/(sum(df[i,:]))
        # end
        append!(y,[xCP,xCE,xP,sCP,sCE,sP])
    end
   
    pgfplotsx()
    # gr()
    # pyplot(markershape = :auto)
    # pyplot()
    # names = [L"\frac{n_{CP}}{n_P}", L"\frac{n_{CE}}{n_E}", L"\frac{n_P}{n}"]
    names = [L"n_{CP}/n_P"  L"n_{CE}/n_E"  L"n_P/N"]
    # pointnames = [L"n_{CP}/n_P", L"n_{CE}/n_E", L"n_P/n", ""]
    # linenames = ["","","", "baseline"]
    # styles = [:solid, :dash, :dashdot]
    styles = [:solid, :solid, :solid]
    plot(layout=(1,1),tickfontfamily="Helvetica",clip_on=true)
    if parameter == "revisionVector"
        rang = map(i->rang[i][1][2],1:length(rang))
    end

    # for i in 1:length(names)
        # c = ColorSchemes.Paired_10[((2*i)./10)]
        # c = ColorSchemes.Paired_10[((2*i-1)./10)]
        # c = get(ColorSchemes.hawaii,i./length(names))
        # c = get(ColorSchemes.rainbow,i./length(names))
        sh = [:circle  :rect  :utriangle  :nothing]
        ms = [4 4 6]
        # plot!(rang,y[i],label=names[i],yerror=y[i+3],markershape = sh,markersize=ms,legend = legend_place,linestyle = styles[i],color = c,lw = 1.5, ylims = (0, 1),fontfamily = "Helvetica",linealpha=1,seriestype=:line)
        plot!(rang,y[1:3],label=names,markershape = sh,markersize=ms,
        legend = legend_place,linestyle = styles,color = mycompstatcolors,
        lw = 1.5, ylims = (0, 1),linealpha=1,seriestype=:line,
        tickfontfamily="Helvetica",guidefontsize=15,tickfontsize=12,titlefont="Courier",legendfontsize=12)
    # end
    include("ComEn-ParametersBaseline.jl")
    
    s = Symbol(parameter)
    theval = eval(s)
    if parameter == "revisionVector"
        theval =.1
    end
    if show_baseline
        plot!([theval],label=L"\textrm{\sffamily baseline}",seriestype=:vline,markersize=0,lw=1,style = :dash,color = "black")
    end
    # plot(range,[xCP,xCE,xP],linestyle=[:solid :dash :dashdot],linecolor = ["black" "blue" "red"],lw = 2, ylims = (0, 1))
    parametertx = parameter # LaTeX-friendly text to use for the parameter name
    greeknames = Dict("ψ" => "\\psi", "τ"=>"\\tau","δ" => "\\delta","κ" => "\\kappa","μ" => "\\mu","η" => "\\eta","ε" => "\\varepsilon","revisionVector" => "\\gamma_{P,E}")
    if parameter in keys(greeknames)
        parametertx = greeknames[parameter]
    end
    plot!(title=subfig_label,titlelocation=:left,titlefont=font("Helvetica"))
    plot!(xlabel=L"\textrm{\sffamily %$title}~%$parametertx",fontfamily = "Helvetica")
    plot!(size=(440,330))
# plot!(ylabel=L"\textrm{\sffamily Probability of~}n\leq n_{XL\cap DCA}", fontfamily="Computer Modern") 
    savefig("comp-stat/comp-stat-$(parameter).pdf")


end