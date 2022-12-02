using CSV, Tables
include("ComEn-Definitions.jl")
include("ColorDefinitions.jl")

rootdir = "trial/time-series-and-averages/"

indivplots = 1 # Set to 1 to generate plots for individual runs

# gr()
for num_strat in [18]
    subdirread = "$(rootdir)time-series-data/" * "$(num_strat)-strategies/"
    subdirwrite = "$(rootdir)time-averages-plots/" * "$(num_strat)-strategies/separate/"
    for karma = 1:3

        params = [
            # [["b",4.5],["c",0.5],["f1",0.2],["l",6.0],["v",0.05],["karma",karma]],  # Most favorable to cooperation
            [["b",4.0],["c",1.0],["f1",0.3],["l",5.0],["v",0.10],["karma",karma]],  # Baseline
            # [["b",4.0],["c",1.0],["f1",0.3],["l",5.0],["v",0.10],["karma",karma],["ε",0.01]],  # Baseline with small noise
            # [["b",3.5],["c",1.5],["f1",0.4],["l",3.0],["v",0.15],["karma",karma]],  # Most favorable to defection
            # [["b",3.0],["c",2.0],["f1",0.6],["l",3.0],["v",0.20],["karma",karma]],  # Even More favorable to defection
            # [["b",3.0],["c",2.0],["f1",0.5],["l",4.0],["v",0.20],["karma",karma],["ε",0.01]],  # Even More favorable to defection
            # [["b",3.0],["c",2.0],["f1",0.4],["l",4.0],["v",0.20],["karma",karma],["ε",0.01]],  # Even More favorable to defection
        ]
        
        #= Initial condition (code needs to be run separately for each initial condition)=#
        for parameters in params
            writefileString = theFile(parameters,"-")
            prodindices = 1:2
            if num_strat == 18
                allindices = 1:18
                enfindices = 3:18
            elseif num_strat == 5
                allindices = [1,2,19,20,21]
                enfindices = 19:21
            elseif num_strat == 4
                allindices = [1,2,20,21]
                enfindices = 20:21
            else
                error("Please choose either 5 or 18 strategies.")
            end
            
            for stratindices in [prodindices,enfindices]
                if stratindices == allindices
                    stratstring = "ALL"
                elseif stratindices == prodindices 
                    stratstring = "PROD"
                elseif stratindices == enfindices
                    stratstring = "ENF"
                end
                err = 0
                stratVector1 = stratVector[stratindices]
                n_strat = length(stratindices)
                shares = Matrix{Number}(undef,7,n_strat)

                if stratindices == prodindices
                    ylim = [0,.75]
                elseif stratindices == enfindices
                    ylim = [0,.35]
                end

                for number = 1:7
                    readfile = subdirread * theFile(parameters," ") * "-$(number).csv"
                    if !isfile(readfile)
                        println("WARNING! Data file $(readfile) does not exist.")
                        err = 1
                    else
                        data = CSV.File(readfile)|> Tables.matrix
                        # data = data[:,stratindices]
                        shares[number,:] = mean(map(x->x/sum(x),eachrow(data[:,stratindices])))

                        # avg = mean(eachrow(data))
                        # shares[number,:] = avg/sum(data[1,:])
                        # println(shares)             
                        if indivplots == 1
                            bar(reshape(stratVector1,1,n_strat),reshape(shares[number,:],1,n_strat),
                                labels = stratVector1,legend = false,ylims=ylim,seriescolor=reshape(mycolors[stratindices],1,n_strat),
                                ytickfontfamily="Computer Modern",guidefontsize=15,tickfontsize=6,xticks = :all)
                            # plot!(size=(440,220)) # Alternatively: plot!(size=(440,330))
                            mkpath(subdirwrite)
                            file = subdirwrite * writefileString * "$(stratstring)-$(number).pdf"
                            savefig(file)
                            println(file)
                        end
                    end
                end
                if err == 0
                    bar(reshape(stratVector1,1,n_strat),reshape(mean(eachrow(shares)),1,n_strat),
                        labels = stratVector1,legend = false,ylims=ylim,seriescolor=reshape(mycolors[stratindices],1,n_strat),
                        ytickfontfamily="Computer Modern",guidefontsize=15,tickfontsize=6,xticks = :all)
                        # plot!(size=(440,220)) # Alternatively: plot!(size=(440,330))
                    mkpath(subdirwrite)
                    file = subdirwrite * writefileString * "$(stratstring)-AVG.pdf"
                    savefig(file)
                    println(file)
                end
            end
        end
    end
end