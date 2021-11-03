include("ComEn-Definitions.jl") # Definitions of our types and methods
include("ComEn-Parameters.jl") # Parameters for the simulation

#  Check that parameters do not give negative payoffs
warning()
#==================SIMULATION CODE=========================#
population = makePopulation(pop)  # Initialize population
agentStrategyNames = map(x->x[1],pop)
agentStrategies = map(x->stratByName(x[1],allStrategies),pop)
gen=0  # Start counting generations
dataToPlot = zeros(generations,length(stratVector))  # This is where the data is stored

while gen<generations
    gen += 1
    if gen%100==0
        println("Generation $(gen)")
    end
    simulate!(population)
    selection!(population,agentsToRevise,revisionVector)
    if gen%100==0
        println(stats(population))
    end
    dataToPlot[gen,:]=stats(population)
end