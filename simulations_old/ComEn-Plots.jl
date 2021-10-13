using Plots
# using Vega
t = 1:generations
# # pyplot()
# # plot(rand(4,5))
# t = zeros(length(stratVector)*generations);
# g = zeros(length(stratVector)*generations);
# d = zeros(length(stratVector)*generations);
# # data = map(x->dataToPlot[x][2],1:length(dataToPlot))
# for i = 1:length(stratVector)
#     t[(i-1)*generations+1:i*generations] = 1:generations
#     g[(i-1)*generations+1:i*generations] = (i-1)*ones(generations)
#     d[(i-1)*generations+1:i*generations] = dataToPlot[:,i]
# end
# x = [0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9]
# y = [28, 43, 81, 19, 52, 24, 87, 17, 68, 49, 55, 91, 53, 87, 48, 49, 66, 27, 16, 15]
# g = [0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1]
# a = areaplot()
# t = [1,2,3,1,2,3]
# d = [2,3,4,3,4,5]
# g = [1,1,1,2,2,2]
# a = areaplot(t = t, d = d, group = g, stacked = true)
areaplot(t,dataToPlot,label=["Producer C" "Producer D" "Enforcer C" "Enforcer D"],stacked=true,normalized=true)