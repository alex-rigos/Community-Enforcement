include("ComEn-Definitions.jl") # Definitions of our types and methods
include("ComEn-Parameters.jl") # Parameters for the simulation

#==================SIMULATION CODE=========================#
gen=0  # Start counting generations
dataToPlot = zeros(generations,length(stratVector))  # This is where the data is stored

while gen<generations
    gen += 1
    if gen%100==0
        println("Generation $(gen)")
    end
    cleanSlate!(population)  # Set fitness to zero
    # println("\n$(population[[producers+enforcers-1,producers+enforcers]])")
    # println(population)
    #=============STAGE GAME LOOP==============#
    oneMoreRound = true
    while oneMoreRound
        mistakes!(population)
        matchStep12!(population)
        matchStep3!(population)
        if !isempty(getAgents(population,Enforcer))
            redemption!(getAgents(population,Enforcer))
        end
        consolidation!(population)
        # println("\n$(population[[producers+enforcers-1,producers+enforcers]])")
        oneMoreRound = mistake(δ)
        # oneMoreRound = false  # for testing purposes
    end
    #===========================================#
    # println("\n$(population[[producers+enforcers-1,producers+enforcers]])")
    # println("Before selection")
    # println(population)
    # fitnessVector(population)
    selection!(population,agentsToRevise)
    # println("\n$(population[[producers+enforcers-1,producers+enforcers]])")
    # println("After selection")
    # println(population)
    if gen%100==0
        println(stats(population))
        println(fitnessVector(population))
    end
    dataToPlot[gen,:]=stats(population)
end