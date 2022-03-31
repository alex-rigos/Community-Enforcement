include("ComEn-Definitions.jl")
#--------------------------GAME PARAMETERS------------------------------------
#--Continuation probability--
δ = 0.9  # With what probability the stage game repeats
#--Reputation (bad karma)--
κ = 3  # For how many rounds does an enforcer who violated the CE standard stay in bad CE standing?
κ2 = 3  # For how many rounds does an enforcer who violated the PE standard stay in bad PE standing?
 
#---------PAYOFFS------
#--Production (Prisoner's Dilemma between producers)--
b = 4.  # benefit of cooperation to the opponent
c = 1.  # cost of cooperation to oneself
w = 2.  # baseline payoff
# Taxation rate
τ = .3
# Punishment
v = 0.1  # (Variable) Cost of punishment to enforcer (per producer she punishes)
f = .4  # Fixed cost of punishment
ϕ = .5  # Fraction of f that Parochial Enforcers bear (f2 = f * ϕ)
p = 2.  # Producer's loss from being punished

# Attack
ψ = .7  # Proportion of surplus plundered
l = 3.  # Loss for being attacked

#--------------------MISTAKE PROBABILITIES-------------------------------------
μ = 0.02  # mistakes for action implementation
probProduceMistake = μ  # mistakes for producers' decisions
probPunishMistake = μ   # mistakes for enforcers' decision to punish or not
probAttackMistake = μ   # mistakes for enforcers' decision to attack or not
ρ = 0.0  # enforcers' mistakes for monitoring producers' actions (in the paper it is set to 0)

#---------------------------EVOLUTION------------------------------------------
η = .1  # Logit parameter (weight of fitness f is exp(f/η)). For exact best response, set η = 0.
ε = 0.1  # Mutation probability (probability to choose a strategy uniformly randomly)

generations = 1000  # Number of periods for the simulation

agentsToRevise = 1  # Number of agents who update their strategy at the end of each generation
revisionVector = [  # Adjustment process: with what probability do we allow revisions of each type
    [Agent,.1],
    [Enforcer,0.3],
    [Producer,.6]
    ]

#-------------------------INITIALIZATION---------------------------------------
# Values for population initialization (how many of each type?). Use each type only once.
pop=[
    ["CP",20],  # Cooperating Producers
    ["DP",20],  # Defecting Producers
    ["CE",5],   # Cooperation Enforcers
    ["DE",5],   # Defection Enforcers
    # ["PE",5], # Parochial Enforcers
    ]
#-----------------------------------------------------------------------------
# DO NOT DELETE THE NEXT LINE
changef2(f) # sets the fixed cost for Parochial Enforcers equal to f * ϕ