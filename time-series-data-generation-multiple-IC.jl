using Distributed

num_procs = 8
if nworkers() < min(length(Sys.cpu_info()),num_procs)
    addprocs(min(length(Sys.cpu_info()),num_procs) - nworkers())
end

# @everywhere rootdir= "time-series-and-averages/"
@everywhere rootdir= "trial/time-series-and-averages/"

@everywhere using CSV, Tables
@everywhere include("ComEn-Definitions.jl") # Definitions of our types and methods
@everywhere model = "Baseline"

@everywhere generations = 1000000

# for karma = 1:3
for karma = 1
    nstrat = 4

    params = [
        # [["b",4.5],["c",0.5],["f1",0.2],["l",6.0],["v",0.05],["karma",karma]],  # Most favorable to cooperation
        # [["b",4.0],["c",1.0],["f1",0.3],["l",5.0],["v",0.10],["karma",karma]],  # Baseline
        # [["b",4.0],["c",1.0],["f1",0.3],["l",5.0],["v",0.10],["karma",karma],["ε",0.01]],  # Baseline with small noise
        # [["b",3.5],["c",1.5],["f1",0.4],["l",3.0],["v",0.15],["karma",karma]],  # More favorable to defection
        # [["b",3.0],["c",2.0],["f1",0.5],["l",3.0],["v",0.20],["karma",karma]],  # Even More favorable to defection
        # [["b",3.0],["c",2.0],["f1",0.6],["l",3.0],["v",0.20],["karma",karma]],  # Even More favorable to defection
        # [["b",3.0],["c",2.0],["f1",0.5],["l",4.0],["v",0.20],["karma",karma],["ε",0.01]],  # Even More favorable to defection
        [["b",3.0],["c",2.0],["f1",0.4],["l",4.0],["v",0.20],["karma",karma],["ε",0.01]],  # Even More favorable to defection
    ]

    #= Initial condition (code needs to be run separately for each initial condition)=#
    for par in params

        @everywhere par = $par

        if karma == 1 || karma == 2
            if nstrat == 18
                @everywhere nstrat = 18
                @everywhere strats = ["CP","DP","0000","0001","0010","0011","0100","0101","0110","0111","1000","1001","1010","1011","1100","1101","1110","1111"]
            elseif nstrat == 4
                @everywhere nstrat = 4
                @everywhere strats = ["CP","DP","CE","DE"]
            end
        elseif karma == 3
            @everywhere nstrat = 5
            @everywhere strats = ["CP","CE","DP","DE","PE"]
        else
            error("Please choose a valid karma number")
        end

        # Create 7 random initial conditions and store them in pops
        # pops = Array{Any}(undef,7)
        # for i = 1:7
        #     A = rand(1:nstrat,50-nstrat)
        #     pv = ones(nstrat) + map(x->count(==(x),A),1:nstrat)
        #     pops[i] = [ [strats[j],pv[j]] for j in 1:nstrat]
        # end

        # Create random initial conditions in each process
        # @everywhere function createRandomPop()
        #     A = rand(1:nstrat,50-nstrat)
        #     pv = ones(nstrat) + map(x->count(==(x),A),1:nstrat)
        #     global population = makePopulation([ [strats[j],pv[j]] for j in 1:nstrat])
        # end

        # Create random initial conditions in each process
        @everywhere function createRandomPop()
            A = vcat(0,sort(rand(0:50-nstrat,nstrat-1)) + collect(1:nstrat-1),50)
            pv = map(i->A[i]-A[i-1],2:nstrat+1)
            global population = makePopulation([ [strats[j],pv[j]] for j in 1:nstrat])
        end

        @everywhere createRandomPop()

        @everywhere agentStrategyNames = strats
        @everywhere agentStrategies = [stratByName(x,allStrategies) for x in strats]


        # pmap(makePopulation,pops)

        # @everywhere population = makePopulation(pop)  # Initialize population
        @everywhere notIncluded = findall(i->stats(population)[i]==0,1:length(stratVector))
        @everywhere gensToIgnore = 0  # How many generations should we ignore for the time averages?

        # pmap(saveTimeSeries,params);
        # @everywhere println(gensToIgnore)

        @everywhere function saveTimeSeries(par::Vector{Vector{Any}},number::Number)
            setParameters(par)
            fileString = theFile(par, " ")
            gen=0  # Start counting generations
            data = zeros(generations+1,length(stratVector))  # This is where the data is stored
            data[1,:]=stats(population)
            while gen<generations
                gen += 1
                simulate!(population)
                selection!(population,agentsToRevise,revisionVector)
                data[gen+1,:]=stats(population)
            end
            subdir = "$(rootdir)time-series-data/" * "$(length(agentStrategyNames))-strategies/"
            mkpath(subdir)
            file = "$(subdir)$(fileString)-$(number).csv"
            CSV.write(file,Tables.table(data));
            println(file);
        end

        pmap(x->saveTimeSeries(par,x),1:7)
        # @everywhere saveTimeSeries(par)
    end
end