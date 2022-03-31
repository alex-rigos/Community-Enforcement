include("ComEn-Definitions.jl") # Definitions of our types and methods
include("demo-params.jl") # Parameters for the simulation

#  Check that parameters do not give negative payoffs
warning()
#==================SIMULATION CODE=========================#
population = makePopulation(pop)  # Initialize population
agentStrategyNames = map(x->x[1],pop)
agentStrategies = map(x->stratByName(x[1],allStrategies),pop)
gen=0  # Start counting generations
data = zeros(generations,length(stratVector))  # This is where the data is stored

while gen<generations
    gen += 1
    if gen%1000==0
        println("Generation $(gen)")
    end
    simulate!(population)
    selection!(population,agentsToRevise,revisionVector)
    if gen%1000==0
        println(stats(population))
    end
    data[gen,:]=stats(population)
end

CSV.write("demo-data.csv",Tables.table(data))

#=== Time series plot ===#
using Plots
include("ColorDefinitions.jl")

t = 1:generations
notIncluded = findall(i->data[1,i]==0,1:length(stratVector))
data1 = data[1:end, setdiff(1:end,notIncluded)]
stratVector1 = stratVector[setdiff(1:end,notIncluded)]

#areaplot(t,dataToPlot1,label=reshape(stratVector1,1,length(stratVector1)),stacked=true,normalized=false,legend=:bottomright)
areaplot(t,data1,label=reshape(stratVector1,1,length(stratVector1)),normalized=false,legend=:bottomright,seriescolor=mycolors)
savefig("demo-evo.pdf")

#=== Average population plots ===#
avg = mean(eachrow(data1))
num_strat = size(data1,2)
bar(reshape(stratVector1,1,num_strat),reshape(avg/sum(data[1,:]),1,num_strat),
        labels = stratVector1,legend = false,ylims=[0,1],seriescolor=mycolors,
        ytickfontfamily="Computer Modern",guidefontsize=15,tickfontsize=12
    )

savefig("demo-avg.pdf")