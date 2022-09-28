using CSV, Tables
include("demo-params.jl") # Parameters for the simulation

dir = "demo/"
mkpath(dir)

#  Check that parameters do not give negative payoffs
warning()
#==================SIMULATION CODE=========================#
population = makePopulation(pop)  # Initialize population
agentStrategyNames = map(x->x[1],pop)
agentStrategies = map(x->stratByName(x[1],allStrategies),pop)

data = zeros(generations,length(stratVector))  # This is where the data is stored

gen=0  # Start counting generations
for gen = 1:generations
    if gen%1000==0
        println("Generation $(gen)")
    end
    simulate!(population)
    selection!(population,agentsToRevise,revisionVector)
    # if gen%1000==0
    #     println(stats(population))
    # end
    data[gen,:]=stats(population)
end

CSV.write("$(dir)demo-data.csv",Tables.table(data))

#=== Time series plot ===#
include("ColorDefinitions.jl")

t = 1:generations
notIncluded = findall(i->data[1,i]==0,1:length(stratVector))
data1 = data[1:end, setdiff(1:end,notIncluded)]
stratVector1 = stratVector[setdiff(1:end,notIncluded)]
stratVectorProd=stratVector1[1:2] # Producers
stratVectorEnf=stratVector1[3:end] # Enforcers

#areaplot(t,dataToPlot1,label=reshape(stratVector1,1,length(stratVector1)),stacked=true,normalized=false,legend=:bottomright)
areaplot(t,data1,label=reshape(stratVector1,1,length(stratVector1)),normalized=false,legend=:outerbottomright,seriescolor=mycolors,tickfontsize=10)
savefig("$(dir)demo-evo.pdf")
dataProd=data1[1:end,1:2]
dataEnf=data1[1:end,3:end]
for i=1:generations
    sProd = sum(dataProd,dims=2)[i]
    sEnf = sum(dataEnf,dims=2)[i]
    for j=1:length(stratVectorProd)
        dataProd[i,j]=dataProd[i,j]/sProd
    end
    for j=1:length(stratVectorEnf)
        dataEnf[i,j]=dataEnf[i,j]/sEnf
    end
end
areaplot(t,dataProd,label=reshape(stratVectorProd,1,length(stratVectorProd)),normalized=false,legend=:outerbottomright,seriescolor=mycolors[1:2]',tickfontsize=10)
savefig("$(dir)demo-evo-prod.pdf")

areaplot(t,dataEnf,label=reshape(stratVectorEnf,1,length(stratVectorEnf)),normalized=false,legend=:outerbottomright,seriescolor=mycolors[3:end]',tickfontsize=10)
savefig("$(dir)demo-evo-enf.pdf")


#=== Average population plots ===#
avg = mean(eachrow(data1))
avgProd = mean(eachrow(dataProd))
avgEnf = mean(eachrow(dataEnf))
num_strat = size(data1,2)
bar(reshape(stratVector1,1,num_strat),reshape(avg/sum(data[1,:]),1,num_strat),
        labels = stratVector1,legend = false,ylims=[0,1],seriescolor=mycolors,
        ytickfontfamily="Computer Modern",guidefontsize=15,tickfontsize=6,xticks = :all
    )
savefig("$(dir)demo-avg.pdf")

bar(reshape(stratVectorProd,1,2),reshape(avgProd/sum(dataProd[1,:]),1,2),
        labels = stratVectorProd,legend = false,ylims=[0,1],seriescolor=mycolors[1:2]',
        ytickfontfamily="Computer Modern",guidefontsize=15,tickfontsize=6,xticks = :all
    )
savefig("$(dir)demo-avg-prod.pdf")

bar(reshape(stratVectorEnf,1,num_strat-2),reshape(avgEnf/sum(dataEnf[1,:]),1,num_strat-2),
        labels = stratVectorEnf,legend = false,ylims=[0,1],seriescolor=mycolors[3:end]',
        ytickfontfamily="Computer Modern",guidefontsize=15,tickfontsize=6,xticks = :all
    )
savefig("$(dir)demo-avg-enf.pdf")

run(`cp demo-params.jl $(dir)demo-params.jl`)