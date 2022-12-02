using Random  # For sample(), etc.
using StatsBase  # For mean()
using Plots

#=====AGENT TYPES, STRATEGIES AND CONSTRUCTORS==========#
abstract type Agent end
# convert(::Type{T}, x::Agent) where {T<:Agent} = T(x)
# convert(::Type{T}, x::T) where {T<:Agent} = x
    
Base.@kwdef mutable struct Enforcer <: Agent
    # Payoff tracking
    payoff::Real = 0.
    fitness::Real = 0.

    # Strategy specification
    strategy::String
    # punishesDefectors::Bool
    punishesif::Function
    attacksif::Function

    # Status tracking
    karmaI::Integer = 0
    karmaII::Integer = 0
    okWithRuleI::Bool = true
    okWithRuleII::Bool = true
end


Base.@kwdef mutable struct Producer <: Agent
    # Payoff tracking
    payoff::Real = 0.
    fitness::Real = 0.

    # Strategy specification
    strategy::String
    cooperate::Bool

    # Status tracking
    cooperated::Bool = true
end

Base.@kwdef struct Strategy
    strategyName::String
    agentType::Type
    # punishesDefectors::Any = "Producer"  # The default is of a type that gives an error if assigned to the wrong type
    punishesif::Any = "Producer"  # The default is of a type that gives an error if assigned to the wrong type
    attacksif::Any = "Producer"  # The default is of a type that gives an error if assigned to the wrong type
    cooperate::Any = "Enforcer"  # The default is of a type that gives an error if assigned to the wrong type
end

function punishAll(coop::Bool)
    true
end

function punishCoop(coop::Bool)
    coop
end

function punishDef(coop::Bool)
    !coop
end

function punishNone(coop::Bool)
    false
end

function attackAll(karma::Int)
    true
end

function attackGood(karma::Int)
    karma==0
end

function attackBad(karma::Int)
    karma>0
end

function attackNone(karma::Int)
    false
end

allStrategies = [
    Strategy(strategyName = "CP", agentType = Producer, cooperate = true),  # Cooperative Producer
    # Strategy(strategyName = "CE", agentType = Enforcer, punishesDefectors = true, attacksif = enf2::Enforcer->enf2.karmaI>0),  # Cooperation Enforcer
    Strategy(strategyName = "DP", agentType = Producer, cooperate = false),  # Defecting Producer
    # Strategy(strategyName = "DE", agentType = Enforcer, punishesDefectors = false, attacksif = enf2::Enforcer->true),  # Defecting Enforcer
    # Strategy(strategyName = "PE", agentType = Enforcer, punishesDefectors = false, attacksif = enf2::Enforcer->enf2.karmaII>0),  # Parochial Enforcer
    # Strategy(strategyName = "AE", agentType = Enforcer, punishesDefectors = true, attacksif = enf2::Enforcer->true),  # Aggressive Enforcer
    # Strategy(strategyName = "clairvoyant", agentType = Enforcer, punishesDefectors = true, attacksif = enf2::Enforcer->!(enf2.strategy=="clairvoyant"||enf2.strategy=="CE")),

    # Never punish
    Strategy(strategyName = "0000", agentType = Enforcer, punishesif = punishNone, attacksif = attackNone),  # Live and let live
    Strategy(strategyName = "0001", agentType = Enforcer, punishesif = punishNone, attacksif = attackBad),  # Attack bad
    Strategy(strategyName = "0010", agentType = Enforcer, punishesif = punishNone, attacksif = attackGood),  # Attack good
    Strategy(strategyName = "0011", agentType = Enforcer, punishesif = punishNone, attacksif = attackAll),  # Attack all
    # Punish Defectors
    Strategy(strategyName = "0100", agentType = Enforcer, punishesif = punishDef, attacksif = attackNone),  # Live and let live
    Strategy(strategyName = "0101", agentType = Enforcer, punishesif = punishDef, attacksif = attackBad),  # Attack bad
    Strategy(strategyName = "0110", agentType = Enforcer, punishesif = punishDef, attacksif = attackGood),  # Attack good
    Strategy(strategyName = "0111", agentType = Enforcer, punishesif = punishDef, attacksif = attackAll),  # Attack all
    # Punish Cooperators
    Strategy(strategyName = "1000", agentType = Enforcer, punishesif = punishCoop, attacksif = attackNone),  # Live and let live
    Strategy(strategyName = "1001", agentType = Enforcer, punishesif = punishCoop, attacksif = attackBad),  # Attack bad
    Strategy(strategyName = "1010", agentType = Enforcer, punishesif = punishCoop, attacksif = attackGood),  # Attack good
    Strategy(strategyName = "1011", agentType = Enforcer, punishesif = punishCoop, attacksif = attackAll),  # Attack all
    # Always punish
    Strategy(strategyName = "1100", agentType = Enforcer, punishesif = punishAll, attacksif = attackNone),  # Live and let live
    Strategy(strategyName = "1101", agentType = Enforcer, punishesif = punishAll, attacksif = attackBad),  # Attack bad
    Strategy(strategyName = "1110", agentType = Enforcer, punishesif = punishAll, attacksif = attackGood),  # Attack good
    Strategy(strategyName = "1111", agentType = Enforcer, punishesif = punishAll, attacksif = attackAll),  # Attack all
    # Parochial enforcer
    Strategy(strategyName = "PE", agentType = Enforcer, punishesif = punishNone, attacksif = attackBad),  # Parochial Enforcer
    # Cooperation enforcer
    Strategy(strategyName = "CE", agentType = Enforcer, punishesif = punishDef, attacksif = attackBad),  # Attack bad
    # Defection enforcer
    Strategy(strategyName = "DE", agentType = Enforcer, punishesif = punishNone, attacksif = attackAll),  # Attack all
]
stratVector = map(x->x.strategyName,allStrategies)

function agent(strat::Strategy)
    if strat.agentType == Enforcer
        # Enforcer(strategy = strat.strategyName, punishesDefectors = strat.punishesDefectors, attacksif = strat.attacksif)
        Enforcer(strategy = strat.strategyName, punishesif = strat.punishesif, attacksif = strat.attacksif)
    elseif strat.agentType == Producer
        Producer(strategy = strat.strategyName, cooperate = strat.cooperate)
    end
end

function stratByName(s::String,strats::Vector{Strategy})
    strats[findfirst(x->x.strategyName == s,strats)]
end

function makePopulation(pop::Vector{Vector{Any}})
    reduce(vcat,reduce(vcat,map(y->map(x->agent(stratByName(y[1],allStrategies)),1:y[2]),pop)))
end

#===========MAIN SIMULATION CODE=================#
function simulate!(population::Vector{<:Agent})
    cleanSlate!(population)  # Set fitness to zero
    #=============SUPERGAME=====================#
    rounds = 0
    oneMoreRound = true
    while oneMoreRound
        rounds += 1
        awardBackgroundFitness!(population)
        matchStep12!(population)
        matchStep3!(population)
        redemption!(population)
        monitoringCosts!(population)
        fitnessConsolidation!(population)
        oneMoreRound = mistake(δ)
    end
    fitnessNormalization!(population,rounds)
    #===========================================#
end

function fitnessNormalization!(list::Vector{<:Agent},rounds::Int)
    for agent in 1:length(list)
        list[agent].fitness = list[agent].fitness/rounds
    end
end


#===========GAME STUFF===========================#
# Give producers background fitness
function awardBackgroundFitness!(list::Vector{<:Agent})
    producers = getAgentIndices(list,Producer)
    for prod in producers
        list[prod].payoff += w
    end
end

# Match pairs of producers to random enforcers
function matchStep12!(list::Vector{<:Agent})
    producerList = shuffle(getAgentIndices(list,Producer))  # Shuffle producers 
    enforcerList = getAgentIndices(list,Enforcer)
    while length(producerList) ≥ 2
        if !isempty(enforcerList)
            interact3agents!(pop!(producerList), pop!(producerList) , rand(enforcerList), list)
        else
            interactProd!(pop!(producerList) , pop!(producerList),list)
        end
    end
end

# Match enforcers in pairs
function matchStep3!(list::Vector{<:Agent})
    enforcerList = shuffle(getAgentIndices(list,Enforcer))
    while length(enforcerList) ≥ 2
        interactEnf!(pop!(enforcerList) , pop!(enforcerList),list)
    end
end

# Interaction in Step 2 between a pair of producers and an enforcer
function interact3agents!(prod1::Int,prod2::Int,enf::Int, list::Vector{<:Agent})
    production!(prod1,prod2,list)  # The producers produce (PD)
    taxation!([prod1,prod2],enf,list)  # The enforcer taxes the producers (Can she not tell what they did from her tax income? Why is there a detection technology?)
    punishment!([prod1,prod2],enf,list)  # The enforcer may choose to punish the producers she perceives to have defected
end

# Two producers without an enforcer only produce
function interactProd!(prod1::Int,prod2::Int,list::Vector{<:Agent})
    production!(prod1,prod2,list)  # The producers produce (PD)
end

# Payoffs for the Prisoners' Dilemma between producers
function production!(prod1::Int,prod2::Int,list::Vector{<:Agent})
    checkType.([prod1,prod2],Ref(Producer),Ref(list))
    # Mistakes
    for prod in [prod1,prod2]
        list[prod].cooperated = list[prod].cooperate == !mistake(probProduceMistake)
    end

    if list[prod1].cooperated  # prod1 cooperates
        if list[prod2].cooperated  # prod2 cooperates
            list[prod1].payoff += b - c 
            list[prod2].payoff += b - c
        else  # prod2 defects
            list[prod1].payoff += - c
            list[prod2].payoff += b
        end
    else  # prod1 defects
        if list[prod2].cooperated  # prod2 cooperates
            list[prod1].payoff +=  b
            list[prod2].payoff += - c
        else  # prod2 defects
            list[prod1].payoff += 0
            list[prod2].payoff += 0
        end
    end
end

function taxation!(prodList::Vector{Int},enf::Int,list::Vector{<:Agent})
    # println("The $(enf.strategy) taxes $(length(prodList)) producers")
    for prod in prodList
        taxation!(prod,enf,list)
    end
end
# Additional method for only one input (mainly for testing purposes)
function taxation!(prod::Int,enf::Int,list::Vector{<:Agent})
    checkType([prod,enf],[Producer,Enforcer],list)
    # println("tax me! I have $(prod.payoff) dollars.")
    tax = τ * list[prod].payoff
    list[enf].payoff += tax
    list[prod].payoff -= tax
end

function punishment!(prodList::Vector{Int},enf::Int,list::Vector{<:Agent})
    checkType.(prodList,Ref(Producer),Ref(list))
    checkType(enf,Enforcer,list)
    for prod in prodList
        enforcerPunishesThisProducer = list[enf].punishesif(list[prod].cooperated == !mistake(ρ)) == !mistake(probPunishMistake)  # ρ is perception mistakes
        # producerPerceivedToDefect = list[prod].cooperated == mistake(ρ)
        # enforcerWillingToPunish = list[enf].punishesDefectors == !mistake(probPunishMistake)
        # enforcerPunishesThisProducer = producerPerceivedToDefect && enforcerWillingToPunish
        if enforcerPunishesThisProducer
            list[prod].payoff -= p
            list[enf].payoff -= v
        end
        if enforcerPunishesThisProducer == list[prod].cooperated
            list[enf].okWithRuleI = false
            # if list[enf].strategy =="peacekeeper"
            #     println("Why am I being punished 1?!")
            # end
        end
    end
    updateKarma!([enf],list)
end

# Does enf1 attack enf2?
function attacks(enf1::Int,enf2::Int,list::Vector{<:Agent})
    checkType.([enf1,enf2],Ref(Enforcer),Ref(list))
    if karma == 2 || list[enf1].strategy =="PE"
        list[enf1].attacksif(list[enf2].karmaII) == !mistake(probAttackMistake)
    elseif karma == 1 || list[enf1].strategy =="CE"
        list[enf1].attacksif(list[enf2].karmaI) == !mistake(probAttackMistake)
    elseif list[enf1].attacksif(0)==list[enf1].attacksif(1) # if reputation system not crucial
        list[enf1].attacksif(list[enf2].karmaI) == !mistake(probAttackMistake)
    else # if reputation system is crucial but none is defined, give error
        error("No valid reputation system to use?")
    end
end

# Two enforcers who meet each other play the meta-enforcement game
function interactEnf!(enf1::Int, enf2::Int,list::Vector{<:Agent})
    checkType.([enf1,enf2],Ref(Enforcer),Ref(list))
    # Attack unless enforcer cooperates and opponent needs not be punished
    attacks1 = attacks(enf1,enf2,list)
    attacks2 = attacks(enf2,enf1,list)
    # attacks1 = list[enf1].attacksif(list[enf2]) == !mistake(probAttackMistake)
    # attacks2 = list[enf2].attacksif(list[enf1]) == !mistake(probAttackMistake)
    # Check for rule compliance based on actions
    checkRulesStep3!(enf1,attacks1,enf2,list)
    checkRulesStep3!(enf2,attacks2,enf1,list)
    updateKarma!([enf1], list)
    updateKarma!([enf2], list)

    # Payoffs from attack game
    if attacks1 && attacks2
        # println("both attacked")
        list[enf1].payoff -=  l
        list[enf2].payoff -=  l
    elseif attacks1 && !attacks2
        # println("1 attacked")
        list[enf1].payoff += ψ * list[enf2].payoff
        list[enf2].payoff -= ψ * list[enf2].payoff + l
    elseif attacks2 && !attacks1
        # println("2 attacked")
        list[enf2].payoff += ψ * list[enf1].payoff
        list[enf1].payoff -= ψ * list[enf1].payoff + l
    end 
    
end

# Check for transgressions of enf1 who meets enf2 and takes action attacks1.
function checkRulesStep3!(enf1::Int,attacks1::Bool,enf2::Int,list::Vector{<:Agent})
    if !(attacks1 && list[enf2].karmaI>0 || !attacks1 && list[enf2].karmaI==0)
        list[enf1].okWithRuleI = false
    end
    if !(attacks1 && list[enf2].karmaII>0 || !attacks1 && list[enf2].karmaII==0)
        list[enf1].okWithRuleII = false
    end
end

# Enforcers who do not comply with standards get bad reputation (karma)
function updateKarma!(enfList::Vector{Int},list::Vector{<:Agent})
    checkType.(enfList,Ref(Enforcer),Ref(list))
    for enf in enfList
        if !list[enf].okWithRuleI
            list[enf].karmaI = κ
        end
        if !list[enf].okWithRuleII
            list[enf].karmaII = κ
        end
    end
end

# Enforcers who comply with standards get better reputation (less bad karma)
function redemption!(list::Vector{<:Agent})
    enfInd = getAgentIndices(list,Enforcer)
    if !isempty(enfInd)
        for enf in enfInd
            if list[enf].karmaI>0 && list[enf].okWithRuleI
                list[enf].karmaI -= 1
            end
            if list[enf].karmaII>0 && list[enf].okWithRuleII
                list[enf].karmaII -= 1
            end
            list[enf].okWithRuleI = list[enf].okWithRuleII = true
        end
    end 
end
# Additional method for only one input (mainly for testing purposes)
function redemption!(enf::Int, list::Vector{<:Agent})
    redemption!([enf],list)
end

# Apply monitoring costs to enforcers who use punishing strategies
function monitoringCosts!(list::Vector{<:Agent})
    for agent in 1:length(list)
        if typeof(list[agent])==Enforcer
            if uniformFixedCost
                # Cost for monitoring
                if (list[agent].punishesif(true)!=list[agent].punishesif(false)) || (list[agent].attacksif(0)!=list[agent].attacksif(1))
                    list[agent].payoff -= f1 + f2
                end
            else
                # Cost for monitoring producers
                if (list[agent].punishesif(true)!=list[agent].punishesif(false))
                    list[agent].payoff -= f1
                end
                # Cost for monitoring enforcers
                if (list[agent].attacksif(0)!=list[agent].attacksif(1))
                    list[agent].payoff -= f2
                end
            end
        end
    end
end

# Payoff acquired in this period is added to each agent's fitness
function fitnessConsolidation!(list::Vector{<:Agent})
    for agent in 1:length(list)
        list[agent].fitness += list[agent].payoff
        list[agent].payoff = 0.
    end
end

#-------------------------MISTAKE STUFF---------------------------------
# Make mistake with probability p
function mistake(p::Real)
    return rand() ≤ p
end

#-------------------------FITNESS STUFF---------------------------------

# A function that gives the average fitness of a strategy in a population (at the end of the generation)
function strategyFitness(list::Vector{<:Agent},strat::Strategy)
    fitnesses = map(x->list[x].fitness,findall(x -> x.strategy == strat.strategyName,list))
    if isempty(fitnesses)
        fit = -Inf
    else
        fit = mean(fitnesses)
    end
    return fit
end

# Return fitnesses for a list of strategies
function fitnessVector(list::Vector{<:Agent},strat::Vector{Strategy})
    fitVector=[]
    for s in strat
        push!(fitVector,[s.strategyName,strategyFitness(list,s)])
    end
    return fitVector
end

#  The natural selection process. The number of agents that consider changing is k. revVec is the revision Vector
function selection!(list::Vector{<:Agent},k::Int,revVec::Vector{Vector{Any}})
    typesToRevise = sample(map(x->x[1],revVec), Weights(map(x->x[2],revVec)), k)  # Randomly draw k agent types with appropriate weights
    fvec = fitnessVector(list,agentStrategies)  # Vector of ["strategyname", fitness] pairs for all strategies
    while !isempty(typesToRevise)
        type = pop!(typesToRevise)  # Type of agent that revises
        # Get fitness vector for strategies of that type
        stratSet = agentStrategies[findall(x->x.agentType <:type,agentStrategies)]  # Vector of strategies of the drawn type
        fitvec = map(s->fvec[findfirst(x->x[1]==s.strategyName,fvec)][2],stratSet)  # Vector of fitnesses to these strategies
        if mistake(ε)  # Mutation
            newAgent = agent(sample(stratSet))  # Sample a strategy with equal probability across all available strategies
        else  # (Noisy?) best response
            if η == 0. # exact best response
                fitvec = map(x-> x == maximum(fitvec),fitvec)  # If using best response, return a vector of 0s and a 1
            else
                fitvec = map(x-> exp(x/η),fitvec)
            end
            newAgent = agent(sample(stratSet, Weights(fitvec)))
        end

        # Replace an agent of the correct type with a best-performing agent of that type
        killIndex = sample(getAgentIndices(list,type))
        
        # println("$(fvec) Killed a $(list[killIndex].strategy). Gave birth to a $(newAgent.strategy).")
        list[killIndex] = newAgent
        # println("Indeed, the new agent is a $(list[killIndex].strategy).")
    end
end

# Reset fitness and reputation
function cleanSlate!(list::Vector{<:Agent})
    for agent in 1:length(list)
        list[agent].fitness = 0
        if typeof(list[agent]) == Enforcer
            list[agent].karmaI = 0
            list[agent].karmaII = 0
        end
    end
end

# Return number of agents in each strategy
function stats(list::Vector{<:Agent})
    map(strat-> count(y ->  y.strategy == strat,list),stratVector)
end

#===========UTILITIES===============#
# Returns the indices of all agents of the given type
function getAgentIndices(list::Vector{<:Agent},t::Type)
    return findall(x -> typeof(x)<:t,list)
end

#-ERROR STUFF-#

# Throw an error if enforcers can obtain negative surpluses
function warning()
    if  v > τ*w
        error("*******  NEGATIVE PAYOFFS ARE POSSIBLE *******")
    end
end

# Throw an error if the wrong type of agent is supplied to a function
function checkType(agent::Int,t::Type,list::Vector{<:Agent})
    if !(typeof(list[agent]) == t)
        error("Wrong agent type!!")
    end
end

# Additional method for vectors of agents
function checkType(agents::Vector{Int},t::Vector{<:Type},list::Vector{<:Agent})
    checkType.(agents,t,Ref(list))
end

#-STUFF FOR ARROW DIAGRAMS-#

# Function that takes a population definition and gives the arrow that should be plotted at the relevant point.
function calcArrow(pop::Vector{Vector{Any}})
    population = makePopulation(pop)  # Initialize population

    pr = map(strat-> count(y ->  y.strategy == strat,population),agentStrategyNames)  # Vector of individuals in each strategy
    pr = map(s-> s/sum(pr),pr)  # Vector of fractions of each strategy in the total population
    q = probVec(population,N)  # Vector of choice probabilities for each strategy
    
    x = pr[1]/(pr[1]+pr[2])  # x position
    y = pr[3]/(pr[3]+pr[4])  # y position
    u = (pr[2]*q[1]-pr[1]*q[2])/(pr[1]+pr[2])  # x direction
    z = (pr[4]*q[3]-pr[3]*q[4])/(pr[3]+pr[4])  # y direction
    return [x,y,u,z]
end

# Simulate populations N times and get average choice probabilities for each profession
function probVec(list::Vector{<:Agent}, N::Int)
    fitvec = zeros(4)
    i = 0
    while i < N
        i += 1
        simulate!(list)
        fitvec += getindex.(fitnessVector(list,agentStrategies),2)/N  # Vector fitnesses for all strategies
    end
    vec = choiceProb(fitvec)
    return vec
end

# Take a fitness vector and calculate choice probabilities for each profession
function choiceProb(fitvec::Vector{<:Real})
    pvec = [-Inf,-Inf,-Inf,-Inf]  # Vector to store choice probabilities for each profession
    if η == 0. # exact best response
        pvec[1:2] = map(x-> x == maximum(fitvec[1:2]),fitvec[1:2])  # If using best response, return a vector of 0s and a 1 for producers
        pvec[3:4] = map(x-> x == maximum(fitvec[3:4]),fitvec[3:4])  # The same for enforcers
    else  # Logit noise in choice
        S = sum(map(x-> exp(x/η),fitvec[1:2]))
        pvec[1:2] = map(x-> exp(x/η)/S,fitvec[1:2])
        S = sum(map(x-> exp(x/η),fitvec[3:4]))
        pvec[3:4] = map(x-> exp(x/η)/S,fitvec[3:4])
    end
    return pvec
end

# Function to change the values of parameters
function setParameters(parameter::String,value::Any)
    include("$(string("ComEn-Parameters",model,".jl"))") # Parameters for the simulation
    string_as_varname(parameter,value)
        if parameter == "μ"
            globalMistakeProbability(μ)
        end
        # changef2(f)
        warning()
end

function setParameters(params::Vector{Vector{Any}})
    include("$(string("ComEn-Parameters",model,".jl"))") # Parameters for the simulation
    for parPair in params
        parameter = parPair[1]
        value = parPair[2]
        string_as_varname(parameter,value)
        if parameter == "μ"
            globalMistakeProbability(μ)
        end
    end
    # changef2(f)
    warning()
end

function setParameters(params::Vector{Any})
    setParameters([params])
end
# For time averages

# Give an initial population and a number of generations. Get the time average of each strategy across generations
function timeAverage(pop::Vector{Vector{Any}},generations::Int)        
    gen=0  # Start counting generations
    data = zeros(generations,length(stratVector))  # This is where the data is stored
    population = makePopulation(pop)
    while gen<generations
        gen += 1
        simulate!(population)
        selection!(population,agentsToRevise,revisionVector)
        data[gen,:]=stats(population)
    end
    return mean(eachrow(data))
end

# Set a global variable equal to a value
function string_as_varname(s::AbstractString,v::Any)
    s = Symbol(s)
    @eval (global ($s)=($v))
end

# Set all mistake probabilities equal to the same number
function globalMistakeProbability(μ::Real)
    global probProduceMistake = μ
    global probPunishMistake = μ
    global probAttackMistake = μ
end

# Set the fixed cost for Parochial Enforcers to f * ϕ
# function changef2(f::Real)
#     global f2 = f * ϕ
# end

# Function to create filenames
function theFile(parameters::Vector{Vector{Any}},separator::String)
    toAdd = ""
    fString = ""
    for i in 1:length(parameters)
        par = parameters[i]
        toAdd="$(par[1])=$(par[2])"
        if i > 1
            fString = fString * separator
        end
        fString = fString * toAdd
    end
    return fString
end

# Create arrow plots from vectors x, y, u, v
function arrow0!(x, y, u, v; as=0.07, lc=:black, la=1, lw=1,rounding=.02)
    nuv = sqrt(u^2 + v^2)
    v1, v2 = [u;v] / nuv,  [-v;u] / nuv
    v4 = (3*v1 + v2)/3.1623  # sqrt(10) to get unit vector
    v5 = v4 - 2*(v4'*v2)*v2
    v4, v5 = as*v4, as*v5
    plot!(circleShape(x+u,y+v,rounding),seriestype = [:shape],lw=0,c=arrowcol,legend=false,fillalpha=1,aspect_ratio=1)
    plot!([x,x+u], [y,y+v], lc=lc,la=la,lw=lw)
    plot!([x+u,x+u-v5[1]], [y+v,y+v-v5[2]], lc=lc, la=la,lw=lw)
    plot!([x+u,x+u-v4[1]], [y+v,y+v-v4[2]], lc=lc, la=la,lw=lw)
    
end

# Draw a circle for arrow tips
function circleShape(h,k,r)
    θ = LinRange(0,2*π,100)
    h .+ r*sin.(θ), k .+ r*cos.(θ)
end

# For plots of averages
function plotaverages(shares::Vector{Float64}, stratindices::Vector{Int}, ylim::Vector{<:Real}, colors::Vector{RGB{Float64}})
    n_strat = length(stratindices)
    if n_strat == 2
        xlim = [-.5,2.6]
    else 
        xlim = :default
    end
    stratVector1 = stratVector[stratindices]
    shares = shares[stratindices]
    bar(reshape(stratVector1,1,n_strat),reshape(shares,1,n_strat), xlims = xlim,
        labels = stratVector1,legend = false,ylims=ylim,seriescolor=reshape(colors[stratindices],1,n_strat),
        ytickfontfamily="Computer Modern",guidefontsize=15,tickfontsize=6,xticks = :all,bar_width=0.8)
end

function plotaverages(shares::Vector{<:AbstractFloat}, stratindices::Vector{Vector{Int}}, ylim::Vector{Vector{Float64}}, colors::Vector{RGB{Float64}})
    if !(length(stratindices)==length(ylim)==2)
        error("Please use exactly two strategy sets and y-boundaries.")
    end
    l1 = length(stratindices[1])
    l2 = length(stratindices[2])
    plot1 = plotaverages(shares,stratindices[1],ylim[1],colors)
    plot2 = plotaverages(shares,stratindices[2],ylim[2],colors)
    plot(plot1,plot2, layout=grid(1,2, widths=(l1/(l1+l2),l2/(l1+l2))))
end

