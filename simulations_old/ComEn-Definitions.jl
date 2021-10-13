using Random
using StatsBase

abstract type Agent end
convert(::Type{T}, x::Agent) where {T<:Agent} = T(x)
convert(::Type{T}, x::T) where {T<:Agent} = x
    
mutable struct Enforcer <: Agent
    payoff::Real
    fitness::Real
    cooperate::Bool
    karma::Integer
    transgressed::Bool
    cooperatedS3::Bool  # Checks whether the enforcer cooperated in step 3 (accounting for mistakes)
    attacked::Bool

    Enforcer() = (coop = rand() ≤ probCooperateEnforcer; new(0. , 0. , coop , 0 , false, coop, false))
    Enforcer(coop) = new(0.,0.,coop,0,false,coop,false)
end

mutable struct Producer <: Agent
    payoff::Real
    fitness::Real
    cooperate::Bool
    cooperated::Bool

    Producer() = (coop= rand() ≤ probCooperateProducer; new(0. , 0. , coop , coop))
    Producer(coop) = (coop; new(0. , 0. , coop , coop))
end

# Match pairs of producers to random enforcers
function matchStep12!(list::Vector{Agent})
    producerList = shuffle(getAgentIndices(list,Producer))  # Shuffle producers 
    enforcerList = getAgentIndices(list,Enforcer)
    while length(producerList) ≥ 2 
        # println("Group $(i): producer1 = $(pop!(producerList)), producer2 = $(pop!(producerList)), enforcer = $(getRandomEnforcer(list))")
        if !isempty(enforcerList)
            interact!(list[pop!(producerList)] , list[pop!(producerList)] , list[rand(enforcerList)])
        else
            interact!(list[pop!(producerList)] , list[pop!(producerList)])
        end
    end
end

function getAgentIndices(list::Vector{Agent},t::Type)
    findall(x -> typeof(x)==t,list)
end
function getAgents(list::Vector{Agent},t::Type)
    map(x->list[x],getAgentIndices(list,t))
end

function interact!(prod1::Producer,prod2::Producer)
    production!(prod1,prod2)  # The producers produce (PD)
end

# Interaction in Step 2 between a pair of producers and an enforcer
function interact!(prod1::Producer,prod2::Producer,enforcer::Enforcer)
    production!(prod1,prod2)  # The producers produce (PD)
    taxation!([prod1,prod2],enforcer)  # The enforcer taxes the producers (Can she not tell what they did from her tax income? Why is there a detection technology?)
    punishment!([prod1,prod2],enforcer)  # The enforcer may choose to punish the producers she perceives to have defected
end

# Payoffs for the Prisoners' Dilemma between producers
function production!(prod1::Producer,prod2::Producer)
    if prod1.cooperated
        if prod2.cooperated
            prod1.payoff = prod2.payoff = b - c + w
        else
            prod1.payoff = w - c
            prod2.payoff = b + w
        end
    else
        if prod2.cooperated
            prod1.payoff = b + w
            prod2.payoff = w - c
        else
            prod1.payoff = w - c
            prod2.payoff = b + w
        end
    end
end

function taxation!(producers::Vector{Producer},enforcer::Enforcer)
    for prod in producers
        tax = τ * prod.payoff
        enforcer.payoff += tax
        prod.payoff -= tax    
    end
end
# Additional method for only one input (mainly for testing purposes)
function taxation!(producer::Producer,enforcer::Enforcer)
    taxation!([producer],enforcer)
end

function punishment!(producers::Vector{Producer},enforcer::Enforcer)
    for prod in producers
        producerPerceivedToDefect = prod.cooperated == mistake(probDetectionMistake)
        enforcerWillingToPunish = enforcer.cooperate == !mistake(probPunishMistake)
        enforcerPunishes = producerPerceivedToDefect && enforcerWillingToPunish
        if enforcerPunishes
            prod.payoff -= p
            enforcer.payoff -= v
        end
        enforcer.transgressed = enforcerPunishes == prod.cooperated
        if enforcer.transgressed
            # println("someone's been a bad boy!: $(enforcer)")
            enforcer.karma = maxKarma
        end
    end
end



function matchStep3!(list::Vector{Agent})
    enforcerList = shuffle(getAgentIndices(list,Enforcer))
    while length(enforcerList) ≥ 2
        interact!(list[pop!(enforcerList)] , list[pop!(enforcerList)])
    end
end

function interact!(enf1::Enforcer, enf2::Enforcer)
    # Attack unless enforcer cooperates and opponent needs not be punished
    enf1.attacked = !(enf1.cooperatedS3 && enf2.karma == 0)
    enf2.attacked = !(enf2.cooperatedS3 && enf1.karma == 0)
    # Payoffs from attack game
    if enf1.attacked && enf2.attacked
        enf1.payoff -=  l
        enf2.payoff -=  l
    elseif enf1.attacked
        enf1.payoff += ψ * enf2.payoff
        enf2.payoff -= ψ * enf2.payoff + l         
    elseif enf2.attacked
        enf2.payoff += ψ * enf1.payoff
        enf1.payoff -= ψ * enf1.payoff + l
    end 
    checkTransgression!(enf1,enf2)
    checkTransgression!(enf2,enf1)
end

#Check for transgressions of enf1 who meets enf2. No detection errors here?
function checkTransgression!(enf1::Enforcer,enf2::Enforcer)     
     if enf1.attacked == (enf2.karma == 0)
        enf1.transgressed = true
        enf1.karma = maxKarma
    end
end

function redemption!(enforcers::Vector{Enforcer})
    for enf in enforcers
        if enf.karma>0 && !enf.transgressed
            enf.karma -= 1
        end
        enf.transgressed = false
    end
end
# Additional method for only one input (mainly for testing purposes)
function redemption!(enf::Enforcer)
    redemption!([enf])
end

function consolidation!(list::Vector{Agent})
    for agent in list
        agent.fitness += agent.payoff
        agent.payoff = 0.
    end
end

#-------------------------MISTAKE STUFF---------------------------------
# Make mistake with probability p
function mistake(p::Real)
    return rand() ≤ p
end

function mistakes!(list::Vector{Agent})
    for agent in list
        mistakes!(agent)
    end
end
function mistakes!(prod::Producer)
    prod.cooperated = prod.cooperate == !mistake(probProduceMistake) 
end
function mistakes!(enf::Enforcer)
    enf.cooperatedS3 = enf.cooperate == !mistake(probAttackMistake) 
end

#-------------------------FITNESS STUFF---------------------------------
function strategyFitness(list::Vector{Agent},T::Type,strat::Bool)
    fitnesses = map(x->list[x].fitness,findall(x -> typeof(x)==T && x.cooperate == strat,list))
    if isempty(fitnesses)
        fit = 0.
    else
        fit = mean(fitnesses)
    end
    return fit
end

function fitnessVector(list::Vector{Agent})
    fitVector::Vector{Real}=[]
    for x in stratVector
        push!(fitVector,strategyFitness(list,x[1],x[2]))
    end
    return fitVector
end

function selection!(list::Vector{Agent},k::Int)
    fvec = fitnessVector(list)
    if bestresponse
        # maxfit = maximum(fvec)
        fvec = map(x->x==maximum(fvec),fvec)
    end
    shuffle!(list)
    deleteat!(list,1:k)
    my_samps = sample(stratVector, Weights(fvec), k)
    # println(Weights(fvec))
    # println(my_samps)
    append!(list,map(x-> x[1](x[2]), my_samps))
end

function cleanSlate!(list::Vector{Agent})
    for agent in list
        agent.fitness = 0
    end
end

function stats(list::Vector{Agent})
    map(x-> count(y -> typeof(y)==x[1] && y.cooperate == x[2],list),stratVector)
    # count( x->x.cooperate==true&&typeof(x) ,list)
end