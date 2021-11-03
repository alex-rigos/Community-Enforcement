#--------------------------GAME PARAMETERS------------------------------------
#--Continuation probability--
const δ = 0.5  # With what probability the stage game repeats
#--Karma--
const maxKarmaI = 10  # For how many rounds should a typeI transgressor be attacked?
const maxKarmaII = 1  # For how many rounds should a typeII transgressor be attacked?
 
#---------PAYOFFS------
#--Production (PD between producers)--
const b = 3.  # benefit of cooperation to the opponent
const c = 1.  # cost of cooperation to oneself
const w = 1.  # baseline payoff
# Taxation
const τ = .3
# Punishment
const v = .1  # Cost of punishment to enforcer ***( v < τ w )***
const p = 1.5  # Producer's loss from being punished
const f = 0.1  # Fixed cost of being able to punish ``correctly''
# Attack
const ψ = .5  # Proportion of surplus plundered
const l = .5  # Loss for being attacked ***( l < 2(τ w -v) - f )***

#--------------------MISTAKE PROBABILITIES-------------------------------------
const μ = 0.  # mistakes for action implementation
const ρ = 0.  # enforcers' mistakes for monitoring producers' actions
const probProduceMistake = μ
const probDetectionMistake = ρ
const probPunishMistake = μ
const probAttackMistake = μ

#---------------------------EVOLUTION------------------------------------------
const generations = 1000
const ε = .1  # Mutation probability (probability to choose uniformly randomly)
const η = 0.  # Logit parameter (weight of fitness f is exp(f/η)). For exact best response, set η = 0.

const agentsToRevise = 1  # Number of agents who update their strategy at the end of each generation
const revisionVector = [  # Adjustment process: with what probability do we allow revisions of each type
    [Agent,.05],
    [Enforcer,0.30],
    [Producer,.65]
    ]

#-------------------------INITIALIZATION---------------------------------------
# Values for population initialization (how many of each type?). Use each type only once.
pop=[
    ["cooperator",150],
    ["defector",150],
    ["peacekeeper",50],
    ["shortsighted",50],
    # ["clairvoyant",50],
    # ["aggressor",10],
    # ["clubby",10]
    ]
#-----------------------------------------------------------------------------