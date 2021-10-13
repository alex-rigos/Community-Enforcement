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
const probProduceMistake = 0.
const probDetectionMistake = 0.
const probPunishMistake = 0.
const probAttackMistake = 0.

#---------------------------EVOLUTION------------------------------------------
const generations = 5000
const bestresponse = true  # If true, then we use best-response updating. If false, we use logit
const agentsToRevise = 1  # Number of agents who update their strategy at the end of each generation
const revisionVector = [
    [Agent,.05],
    [Enforcer,0.30],
    [Producer,.65]
    ]

#-------------------------INITIALIZATION---------------------------------------
# Values for population initialization (how many of each type?)
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

verbose = false