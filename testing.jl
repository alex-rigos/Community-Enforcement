include("ComEn-Definitions.jl") # Definitions of our types and methods
include("ComEn-Parameters.jl") # Parameters for the simulation

function agg() 
    agent(stratByName("aggressor",strategies))
end

function peace()
    agent(stratByName("peacekeeper",strategies))
end

function short()
    agent(stratByName("shortsighted",strategies))
end

function club()
    agent(stratByName("clubby",strategies))
end

function coop()
    agent(stratByName("cooperator",strategies))
end

function defect()
    agent(stratByName("defector",strategies))
end

testpop = [coop(),coop(),defect(),coop(),peace(),short()];

checkType(2,Producer,testpop)
checkType(5,Enforcer,testpop)
checkType.([2,3],Ref(Producer),Ref(testpop))
# checkType([2,5],[Producer,Enforcer],testpop)
# testpop = [coop,coop,peace]
##
println("Step 1: Production")
production!(1,2,testpop)  # The producers produce (PD)
production!(3,4,testpop)  # The producers produce (PD)
testpop
##
println("Step 1: Taxation")
taxation!([1,2],6,testpop)
taxation!([3,4],5,testpop)
testpop

##
testpop[2]
##
println("Step 1: Punishment")
punishment!([1,2],6,testpop)
punishment!([3,4],5,testpop)
testpop
##
# println("Steps 1 and 2")
# matchStep12!(testpop)
# testpop

##
println("Step 3")
matchStep3!(testpop)
testpop

##
println("Redemption")
redemption!(testpop)
testpop

##


while oneMoreRound
    mistakes!(population)
    matchStep12!(population)
    matchStep3!(population)
    redemption!(population)
    fitnessConsolidation!(population)
    oneMoreRound = mistake(δ)
end