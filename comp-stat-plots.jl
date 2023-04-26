using CSV, Tables, LaTeXStrings, Statistics
include("ComEn-Definitions.jl")
include("ColorDefinitions.jl")

rootdir = "comp-stat/"

ranges = [
    ["f1",.1:.1:1.0,"fixed cost of punishment",true,:bottomleft],
    ["v",.0:.05:.5,"variable cost of punishment",true,:bottom],
    ["l",1.:1.:8.,"loss from fight",true,:bottomleft],
    ["b",2.:1.:6.,"benefit from cooperation",true,:bottomleft],
    ["c",.25:.25:3.0,"cost of cooperation",true,:bottom],
    ["w",1.:.5:5.,"autarky payoff",true,:bottomleft],
    ["p",.5:.5:2.5,"loss from being punished",true,:bottom],
    ["τ",.2:.1:.8,"tax rate",true,:bottom],
    ["ψ",.1:.2:.9,"capture from win",true,:bottomleft],
    ["δ",[0.,0.3,0.6,0.9,0.95],"continuation probability",true,:bottomleft],
    ["κ",[1,5,8,10,15],"number of punishment periods",true,:bottomright],
    ["μ",.0:.02:.1,"probability of action mistakes",true,:bottomright],
    ["η",[.01,.1,1.,5.,10.],"logit noise",true,:bottomright],
    ["ε",[0.01,.05,.1,.2,.5],"probability of revision mistake",true,:bottomright],
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
    ],"probability of global revision",true,:bottomright],
    ["startingKarma",0:8,"initial bad reputation of enforcers",true,:bottomleft],
    ["fullKarma",1:10,"full initial bad reputation of enforcers",false,:bottomleft],
]

errorbars = 1 # Choose whether to add error bars

for karma in [1,3]
    
    for ran in ranges
        parameter = ran[1]
        rang = ran[2]
        title = ran[3]
        show_baseline = ran[4]
        legend_place = ran[5]

        readdir = "$(rootdir)comp-stat-data/karma $(karma)/$(parameter)/"
        writedir = "$(rootdir)comp-stat-plots/karma $(karma)/$(parameter)/"

        xCP = []
        xCE = []
        xPE = []
        xP = []
        sCP = []
        sCE = []
        sPE = []
        sP = []
        y = [] # Where the data to be plotted is stored
        
        for val in rang
            df = CSV.File("$(readdir)$(parameter)=$(val).csv")|> Tables.matrix
            len =length(df[:,1])
            append!(xCP, mean(map(i->df[i,1]/(df[i,1]+df[i,2]),1:len))) # Proportion of CP among producers
            append!(xCE, mean(map(i->df[i,20]/(df[i,19]+df[i,20]+df[i,21]),1:len))) # Proportion of CE among enforcers
            append!(xPE, mean(map(i->df[i,19]/(df[i,19]+df[i,20]+df[i,21]),1:len))) # Proportion of PE among enforcers
            append!(xP, mean(map(i->(df[i,1]+df[i,2])/(sum(df[i,:])),1:len))) # Proportion of producers among agents

            # For standard deviations (requires Statistics)
            append!(sCP, Statistics.std(map(i->df[i,1]/(df[i,1]+df[i,2])/sqrt(len),1:len)))
            append!(sCE, Statistics.std(map(i->df[i,20]/(df[i,19]+df[i,20]+df[i,21])/sqrt(len),1:len)))
            append!(sPE, Statistics.std(map(i->df[i,19]/(df[i,19]+df[i,20]+df[i,21])/sqrt(len),1:len)))
            append!(sP, Statistics.std(map(i->(df[i,1]+df[i,2])/(sum(df[i,:]))/sqrt(len),1:len)))

            # append!(y,[xCP,xCE,xPE,xP,sCP,sCE,sPE,sP])
            append!(y,[xCP,xCE,xPE,xP])
        end
        
        theTicks = :auto
        plotscale = :identity
        mticks = 0
        if parameter == "η"
            plotscale = :log10
            theTicks = [.01,.1,1.,10.]
            mticks = 10
        end

        pgfplotsx()
        
        names = [L"n_{CP}/n_P"  L"n_{CE}/n_E" L"n_{PE}/n_E"  L"n_P/N"]
        styles = [:solid, :solid, :solid, :solid]
        plot(layout=(1,1),tickfontfamily="Helvetica",clip_on=true)
        if parameter == "revisionVector"
            rang = map(i->rang[i][1][2],1:length(rang))
        end

        sh = [:circle :rect :rect :utriangle :nothing]
        ms = [4 4 4 6 ]
        if karma == 1
            indices = [1,2,4]
        elseif karma == 3
            indices = 1:4
        else
            error("Please use a valid karma value")
        end
        
        # If using error bars, make series points a bit transparent
        if errorbars == 1
            alph = .5
        else
            alph = 1
        end

        plot!(rang,y[indices],label=format(names,indices), markershape = format(sh,indices),markersize=format(ms,indices),
        legend = legend_place,linestyle = format(styles,indices),color = format(mycompstatcolors,indices),
        lw = 1.5, ylims = (0, 1),linealpha=1,seriestype=:line, xscale = plotscale,
        tickfontfamily="Helvetica",guidefontsize=15,tickfontsize=12,titlefont="Courier",legendfontsize=9,seriesalpha=alph)
        
        # Plot error bars
        if errorbars == 1
            plot!(rang, xCP,yerror=sCP,label=:none,linewidth=0,linecolor=format(mycompstatcolors,indices)[1])
            plot!(rang, xCE,yerror=sCE,label=:none,linewidth=0,linecolor=format(mycompstatcolors,indices)[2])
            if karma == 1
                plot!(rang, xP,yerror=sP,label=:none,linewidth=0,linecolor=format(mycompstatcolors,indices)[3])
            elseif karma == 3
                plot!(rang, xPE,yerror=sPE,label=:none,linewidth=0,linecolor=format(mycompstatcolors,indices)[3])
                plot!(rang, xP,yerror=sP,label=:none,linewidth=0,linecolor=format(mycompstatcolors,indices)[4])
            end
        end
        
        
        include("ComEn-ParametersBaseline.jl")
        
        s = Symbol(parameter)
        if parameter == "revisionVector"
            theval =.1
        elseif parameter == "fullKarma"
            theval = κ
        else
            theval = eval(s)
        end

        if show_baseline
            plot!([theval],label=L"\textrm{\sffamily baseline}",seriestype=:vline,markersize=0,lw=1,style = :dash,color = "black", xticks = theTicks, minorticks = mticks)
        end
        parametertx = parameter # LaTeX-friendly text to use for the parameter name
        greeknames = Dict("fullKarma" => "\\kappa", "startingKarma" => "", "ψ" => "\\psi", "τ"=>"\\tau","δ" => "\\delta","κ" => "\\kappa","μ" => "\\mu","η" => "\\eta","ε" => "\\varepsilon","revisionVector" => "\\gamma_{P,E}","f1"=>"f")
        if parameter in keys(greeknames)
            parametertx = greeknames[parameter]
        end
        plot!(xlabel=L"\textrm{\sffamily %$title}~%$parametertx",fontfamily = "Helvetica")
        plot!(size=(440,330))
        mkpath(writedir)
        file = "$(writedir)comp-stat-$(parameter).pdf"
        println(file)
        savefig(file)
    end
end