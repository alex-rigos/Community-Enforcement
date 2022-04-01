using CSV, Tables, LaTeXStrings
include("ComEn-Definitions.jl")
include("ColorDefinitions.jl")
ranges = [
    ["f",.2:.1:.6,"fixed cost of punishment",true,:bottomleft],
    ["v",.05:.05:.25,"variable cost of punishment",true,:bottom],
    ["l",2.:.5:4,"loss from fight",true,:bottomleft],
    ["b",3.:.5:5.,"benefit from cooperation",true,:bottomleft],
    ["c",.5:.5:2.5,"cost of cooperation",true,:bottom],
    ["w",1.:.5:3.,"background payoff",true,:bottomleft],
    ["p",.5:.5:2.5,"loss from being punished",true,:bottom],
    ["τ",.1:.2:.9,"tax rate",true,:bottom],
    ["ψ",.1:.2:.9,"capture from win",true,:bottomleft],
    ["δ",.1:.2:.9,"continuation probability",true,:bottomright],
    ["κ",1:5,"number of punishment periods",true,:bottomright],
    ["μ",.01:.01:.05,"probability of action mistakes",true,:bottomright],
    ["η",[.01,.1,.15,.2,.25],"logit noise",true,:bottomright],
    ["ε",0.05:0.05:.25,"probability of revision mistake",true,:bottomright],
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
    ],"probability of global revision",true,:bottomright]
]

for ran in ranges
    parameter = ran[1]
    rang = ran[2]
    title = ran[3]
    show_baseline = ran[4]
    legend_place = ran[5]

    rootdir = "comp-stat/"
    readdir = "$(rootdir)comp-stat-data/$(parameter)/"
    writedir = "$(rootdir)comp-stat-figures/"

    xCP = []
    xCE = []
    xP = []
    sCP = []
    sCE = []
    sP = []
    y = [] # Where the data to be plotted is stored
    
    for val in rang
        df = CSV.File("$(readdir)$(parameter)=$(val).csv")|> Tables.matrix
        len =length(df[:,1])
        append!(xCP, mean(map(i->df[i,1]/(df[i,1]+df[i,3]),1:len))) # Proportion of CP among producers
        append!(xCE, mean(map(i->df[i,2]/(df[i,2]+df[i,4]),1:len))) # Proportion of CE among enforcers
        append!(xP, mean(map(i->(df[i,1]+df[i,3])/(sum(df[i,:])),1:len))) # Proportion of producers among agents

        append!(y,[xCP,xCE,xP,sCP,sCE,sP])
    end
   
    pgfplotsx()
    names = [L"n_{CP}/n_P"  L"n_{CE}/n_E"  L"n_P/N"]
    styles = [:solid, :solid, :solid]
    plot(layout=(1,1),tickfontfamily="Helvetica",clip_on=true)
    if parameter == "revisionVector"
        rang = map(i->rang[i][1][2],1:length(rang))
    end

    sh = [:circle  :rect  :utriangle  :nothing]
    ms = [4 4 6]
    plot!(rang,y[1:3],label=names,markershape = sh,markersize=ms,
    legend = legend_place,linestyle = styles,color = mycompstatcolors,
    lw = 1.5, ylims = (0, 1),linealpha=1,seriestype=:line,
    tickfontfamily="Helvetica",guidefontsize=15,tickfontsize=12,titlefont="Courier",legendfontsize=12)
    
    include("ComEn-ParametersBaseline.jl")
    
    s = Symbol(parameter)
    theval = eval(s)
    if parameter == "revisionVector"
        theval =.1
    end
    if show_baseline
        plot!([theval],label=L"\textrm{\sffamily baseline}",seriestype=:vline,markersize=0,lw=1,style = :dash,color = "black")
    end
    parametertx = parameter # LaTeX-friendly text to use for the parameter name
    greeknames = Dict("ψ" => "\\psi", "τ"=>"\\tau","δ" => "\\delta","κ" => "\\kappa","μ" => "\\mu","η" => "\\eta","ε" => "\\varepsilon","revisionVector" => "\\gamma_{P,E}")
    if parameter in keys(greeknames)
        parametertx = greeknames[parameter]
    end
    plot!(xlabel=L"\textrm{\sffamily %$title}~%$parametertx",fontfamily = "Helvetica")
    plot!(size=(440,330))
    mkpath(writedir)
    file = "$(writedir)comp-stat-$(parameter).pdf"
    savefig(file)
    println(file)   
end