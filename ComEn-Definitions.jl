using Random  # For sample(), etc.
using StatsBase  # For mean()

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
    punishesDefectors::Bool
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
    punishesDefectors::Any = "Producer"  # The default is of a type that gives an error if assigned to the wrong type
    attacksif::Any = "Producer"  # The default is of a type that gives an error if assigned to the wrong type
    cooperate::Any = "Enforcer"  # The default is of a type that gives an error if assigned to the wrong type
end

const allStrategies = [
    Strategy(strategyName = "cooperator", agentType = Producer, cooperate = true),
    Strategy(strategyName = "defector", agentType = Producer, cooperate = false),
    Strategy(strategyName = "peacekeeper", agentType = Enforcer, punishesDefectors = true, attacksif = enf2::Enforcer->enf2.karmaI>0),
    Strategy(strategyName = "clubby", agentType = Enforcer, punishesDefectors = false, attacksif = enf2::Enforcer->enf2.karmaII>0),
    Strategy(strategyName = "shortsighted", agentType = Enforcer, punishesDefectors = false, attacksif = enf2::Enforcer->true),
    Strategy(strategyName = "aggressor", agentType = Enforcer, punishesDefectors = true, attacksif = enf2::Enforcer->true),
    Strategy(strategyName = "clairvoyant", agentType = Enforcer, punishesDefectors = true, attacksif = enf2::Enforcer->!(enf2.strategy=="clairvoyant"||enf2.strategy=="peacekeeper")),
]
const stratVector = map(x->x.strategyName,allStrategies)

function agent(strat::Strategy)
    if strat.agentType == Enforcer
        Enforcer(strategy = strat.strategyName, punishesDefectors = strat.punishesDefectors, attacksif = strat.attacksif)
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
    oneMoreRound = true
    while oneMoreRound
        matchStep12!(population)
        matchStep3!(population)
        redemption!(population)
        monitoringCosts!(population)
        fitnessConsolidation!(population)
        oneMoreRound = mistake(δ)
    end
    #===========================================#
end

#===========GAME STUFF===========================#
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

    if list[prod1].cooperated
        if list[prod2].cooperated
            list[prod1].payoff = b - c + w
            list[prod2].payoff = b - c + w
        else
            list[prod1].payoff = w - c
            list[prod2].payoff = w + b
        end
    else
        if list[prod2].cooperated
            list[prod1].payoff = w + b
            list[prod2].payoff = w - c
        else
            list[prod1].payoff = w
            list[prod2].payoff = w
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
        producerPerceivedToDefect = list[prod].cooperated == mistake(probDetectionMistake)
        enforcerWillingToPunish = list[enf].punishesDefectors == !mistake(probPunishMistake)
        enforcerPunishesThisProducer = producerPerceivedToDefect && enforcerWillingToPunish
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

# Two enforcers who meet each other play the meta-enforcement game
function interactEnf!(enf1::Int, enf2::Int,list::Vector{<:Agent})
    checkType.([enf1,enf2],Ref(Enforcer),Ref(list))
    # Attack unless enforcer cooperates and opponent needs not be punished
    attacks1 = list[enf1].attacksif(list[enf2]) == !mistake(probAttackMistake)
    attacks2 = list[enf2].attacksif(list[enf1]) == !mistake(probAttackMistake)
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

#Check for transgressions of enf1 who meets enf2 and takes action attacks1.
function checkRulesStep3!(enf1::Int,attacks1::Bool,enf2::Int,list::Vector{<:Agent})
    if !(attacks1 && list[enf2].karmaI>0 || !attacks1 && list[enf2].karmaI==0)
        list[enf1].okWithRuleI = false
    end
    if !(attacks1 && list[enf2].karmaII>0 || !attacks1 && list[enf2].karmaII==0)
        list[enf1].okWithRuleII = false
    end
end

function updateKarma!(enfList::Vector{Int},list::Vector{<:Agent})
    checkType.(enfList,Ref(Enforcer),Ref(list))
    for enf in enfList
        if !list[enf].okWithRuleI
            list[enf].karmaI = maxKarmaI
            # if list[enf].strategy == "peacekeeper"
            #     println("Why am I being punished?!")
            # end
        end
        if !list[enf].okWithRuleII
            list[enf].karmaII = maxKarmaII
        end
    end
end

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

# Enforcer costs for using a punishing strategy (which requires monitoring)
function monitoringCosts!(list::Vector{<:Agent})
    for agent in 1:length(list)
        if typeof(list[agent])==Enforcer && list[agent].punishesDefectors
            list[agent].payoff -= f
        end
    end
end

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

function fitnessVector(list::Vector{<:Agent},strat::Vector{Strategy})
    fitVector=[]
    for s in strat
        push!(fitVector,[s.strategyName,strategyFitness(list,s)])
    end
    return fitVector
end

# function fitnessVector(list::Vector{<:Agent})
#     fitVector=[]
#     for s in allStrategies
#         push!(fitVector,[s.strategyName,strategyFitness(list,s)])
#     end
#     return fitVector
# end

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

function cleanSlate!(list::Vector{<:Agent})
    for agent in 1:length(list)
        list[agent].fitness = 0
        if typeof(list[agent]) == Enforcer
            list[agent].karmaI = 0
            list[agent].karmaII = 0
            # if agent.strategy == "peacekeeper"
                # println("cleaned me!")
            # end
        end
    end
end

function stats(list::Vector{<:Agent})
    map(strat-> count(y ->  y.strategy == strat,list),stratVector)
    # count( x->x.cooperate==true&&typeof(x) ,list)
end



#===========UTILITIES===============#
function getAgentIndices(list::Vector{<:Agent},t::Type)
    return findall(x -> typeof(x)<:t,list)
end
# function getAgents(list::Vector{<:Agent},t::Type)
#     list[getAgentIndices(list,t)]
# end

function warning()
    if ! ( 0 ≤ l + f ≤ 2*(τ*w -v) )
        println("******* WARNING: NEGATIVE PAYOFFS ARE POSSIBLE *******")
    end
end

# ERROR STUFF

function checkType(agent::Int,t::Type,list::Vector{<:Agent})
    if !(typeof(list[agent]) == t)
        error("Wrong agent type!!")
    end
end

function checkType(agents::Vector{Int},t::Vector{<:Type},list::Vector{<:Agent})
    checkType.(agents,t,Ref(list))
end

# STUFF FOR ARROW DIAGRAMS

# Function that takes a population definition and gives the arrow that should be plotted at the relevant point.
function calcArrow(pop::Vector{Vector{Any}})
    population = makePopulation(pop)  # Initialize population
    agentStrategyNames = map(x->x[1],pop)
    agentStrategies = map(x->stratByName(x[1],allStrategies),pop)

    pr = arrowStats(population)  # Vector of individuals in each strategy
    pr = map(s-> s/sum(pr),pr)  # Vector of fractions of each strategy in the total population
    q = probVec(population,N)  # Vector of choice probabilities for each strategy
    
    x = pr[1]/(pr[1]+pr[2])
    y = pr[3]/(pr[3]+pr[4])
    u = (pr[2]*q[1]-pr[1]*q[2])/(pr[1]+pr[2])
    z = (pr[4]*q[3]-pr[3]*q[4])/(pr[3]+pr[4])
    # u = (q[1]-q[2])/(pr[1]+pr[2])
    # z = (q[3]-q[4])/(pr[3]+pr[4])
    return [x,y,u,z]
end

# Simulate populations N times and get average choice probabilities for each profession
function probVec(list::Vector{<:Agent}, N::Int)
    fitvec = zeros(4)
    i = 0
    while i < N
        i += 1
        dummypop = copy(list)
        simulate!(dummypop)
        fitvec += getindex.(fitnessVector(list,agentStrategies),2)/N  # Vector fitnesses for all strategies
        # vec += choiceProb(dummypop)/N  # Take averages
    end
    vec = choiceProb(fitvec)
    return vec
end

# Take a simulated population (i.e.that HAS fitnesses) and calculate choice probabilities for each profession
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

function arrowStats(list::Vector{<:Agent})
    map(strat-> count(y ->  y.strategy == strat,list),agentStrategyNames)
end