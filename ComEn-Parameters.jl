#--------------------------GAME PARAMETERS------------------------------------
#--Continuation probability--
δ = 0.9  # With what probability the stage game repeats
#--Karma--
κ = 10  # For how many rounds should a typeI transgressor be attacked?
κ2 = 1  # For how many rounds should a typeII transgressor be attacked?
 
#---------PAYOFFS------
#--Production (PD between producers)--
b = 4.  # benefit of cooperation to the opponent
c = 1.  # cost of cooperation to oneself
w = 2.  # baseline payoff
# Taxation
τ = .25
# Punishment
v = 0.  # (Variable) Cost of punishment to enforcer (per producer she punishes)
f = .75  # Fixed cost of punishment
p = 2.  # Producer's loss from being punished

# Attack
ψ = .25  # Proportion of surplus plundered
l = 2.  # Loss for being attacked

#--------------------MISTAKE PROBABILITIES-------------------------------------
μ = 0.  # mistakes for action implementation
ρ = 0.  # enforcers' mistakes for monitoring producers' actions
probProduceMistake = μ
probDetectionMistake = ρ
probPunishMistake = μ
probAttackMistake = μ

#---------------------------EVOLUTION------------------------------------------
η = 0.  # Logit parameter (weight of fitness f is exp(f/η)). For exact best response, set η = 0.
ε = 0.1  # Mutation probability (probability to choose uniformly randomly)


#------------------ These things don't matter for arrow plots -------------------

generations = 20000

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
    # ["clairvoyant",50],
    # ["aggressor",10],
    # ["clubby",10]
    ]
#-----------------------------------------------------------------------------