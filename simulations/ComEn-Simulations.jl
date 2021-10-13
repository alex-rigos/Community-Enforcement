include("ComEn-Definitions.jl") # Definitions of our types and methods
include("ComEn-Parameters.jl") # Parameters for the simulation

#  Check that parameters do not give negative payoffs
warning()
#==================SIMULATION CODE=========================#
population = makePopulation(pop)  # Initialize population
gen=0  # Start counting generations
# for z in pop
#     map(x->x[2]>0?x[1]:)
dataToPlot = zeros(generations,length(stratVector))  # This is where the data is stored

while gen<generations
    gen += 1
    if gen%100==0
        println("Generation $(gen)")
    end
    cleanSlate!(population)  # Set fitness to zero
    #=============SUPERGAME=====================#
    oneMoreRound = true
    while oneMoreRound
        # mistakes!(population)
        matchStep12!(population)
        matchStep3!(population)
        redemption!(population)
        fitnessConsolidation!(population)
        oneMoreRound = mistake(δ)
    end
    #===========================================#
    selection!(population,agentsToRevise,revisionVector)
    if gen%100==0
        println(stats(population))
    end
    dataToPlot[gen,:]=stats(population)
end