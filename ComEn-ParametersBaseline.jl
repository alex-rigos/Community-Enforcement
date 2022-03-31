include("ComEn-Definitions.jl")
#--------------------------GAME PARAMETERS------------------------------------
#--Continuation probability--
δ = 0.9  # With what probability the stage game repeats
#--Karma--
κ = 3  # For how many rounds should a typeI transgressor be attacked?
κ2 = 3  # For how many rounds should a typeII transgressor be attacked?
 
#---------PAYOFFS------
#--Production (PD between producers)--
b = 4.  # benefit of cooperation to the opponent
c = 1.  # cost of cooperation to oneself
w = 2.  # baseline payoff
# Taxation
τ = .3
# Punishment
v = 0.1  # (Variable) Cost of punishment to enforcer (per producer she punishes)
f = .4  # Fixed cost of punishment
ϕ = .5  # Fraction of f that Parochial Enforcers bear (f2 = f * ϕ)
changef2(f)
p = 2.  # Producer's loss from being punished

# Attack
ψ = .7  # Proportion of surplus plundered
l = 3.  # Loss for being attacked

#--------------------MISTAKE PROBABILITIES-------------------------------------
μ = 0.02  # mistakes for action implementation
probProduceMistake = μ
probPunishMistake = μ
probAttackMistake = μ
ρ = 0.0  # enforcers' mistakes for monitoring producers' actions



#---------------------------EVOLUTION------------------------------------------
η = .1  # Logit parameter (weight of fitness f is exp(f/η)). For exact best response, set η = 0.
ε = 0.1  # Mutation probability (probability to choose uniformly randomly)


#------------------ These things don't matter for arrow plots -------------------

# generations = 100000

agentsToRevise = 1  # Number of agents who update their strategy at the end of each generation
revisionVector = [  # Adjustment process: with what probability do we allow revisions of each type
    [Agent,.1],
    [Enforcer,0.3],
    [Producer,.6]
    ]

#-------------------------INITIALIZATION---------------------------------------
# Values for population initialization (how many of each type?). Use each type only once.
pop=[
    ["CP",20],
    ["DP",20],
    ["CE",5],
    ["DE",5],
    ]
#-----------------------------------------------------------------------------