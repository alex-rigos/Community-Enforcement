include("ComEn-Definitions.jl")
# Random.seed!(3);
#--------------------------GAME PARAMETERS------------------------------------
#--Continuation probability--
δ = 0.9  # With what probability the stage game repeats
#--Reputation (bad karma)--
karma = 3 # Which reputation system should be used? 1: CE standing, 2: PE standing, 3: mixed standing (CE+PE+non-standing conditioning strategies only)
κ = 8  # For how many rounds does an enforcer who violated the CE standard stay in bad CE standing?
 
#---------PAYOFFS------
#--Production (Prisoner's Dilemma between producers)--
b = 4.  # benefit of cooperation to the opponent 4.
c = 1.  # cost of cooperation to oneself
w = 2.  # baseline payoff
# Taxation rate
τ = .3
# Punishment
v = 0.1  # (Variable) Cost of punishment to enforcer (per producer she punishes)
# f = 0.4  # Fixed cost of punishment
uniformFixedCost = true  # If true, then any enforcer who monitors either producers or enforcers pays a fixed cost of f1 + f2
f1 = 0.3 # Fixed cost for monitoring producers
f2 = 0. # Fixed cost for monitoring enforcers
p = 2.  # Producer's loss from being punished

# Attack
ψ = .7  # Proportion of surplus plundered
l = 5.  # Loss for being attacked

#--------------------MISTAKE PROBABILITIES-------------------------------------
μ = 0.005  # mistakes for action implementation
probProduceMistake = μ  # mistakes for producers' decisions
probPunishMistake = μ   # mistakes for enforcers' decision to punish or not
probAttackMistake = μ   # mistakes for enforcers' decision to attack or not
ρ = 0.0  # enforcers' mistakes for monitoring producers' actions (in the paper it is set to 0)

#---------------------------EVOLUTION------------------------------------------
# η = .1  # Logit parameter (weight of fitness f is exp(f/η)). For exact best response, set η = 0.
η = 0.01  # Logit parameter (weight of fitness f is exp(f/η)). For exact best response, set η = 0.
ε = 0.05  # Mutation probability (probability to choose a strategy uniformly randomly)

# generations = 100000  # Number of periods for the simulation

agentsToRevise = 1  # Number of agents who update their strategy at the end of each generation
revisionVector = [  # Adjustment process: with what probability do we allow revisions of each type
    [Agent,.1],
    [Enforcer,0.3],
    [Producer,.6]
    ]