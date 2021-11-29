using Plots

t = 1:generations

notIncluded = findall(i->dataToPlot[1,i]==0,1:length(stratVector))
dataToPlot1 = dataToPlot[1:end, setdiff(1:end,notIncluded)]
stratVector1 = stratVector[setdiff(1:end,notIncluded)]

areaplot(t,dataToPlot1,label=reshape(stratVector1,1,length(stratVector1)),stacked=true,normalized=false,legend=:bottomright)
##
x1 = map(time->dataToPlot1[time,1]/(dataToPlot1[time,1]+dataToPlot1[time,2]),t)
y1 = map(time->dataToPlot1[time,3]/(dataToPlot1[time,3]+dataToPlot1[time,4]),t)
plot([x1],[y1],lw=2,xlims=[0,1],ylims=[0,1],legend = false)
xlabel!("CP")
ylabel!("CE")