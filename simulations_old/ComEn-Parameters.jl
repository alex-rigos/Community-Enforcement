
#--------------------------STRATEGY VECTOR------------------------------------
# For birth of agents
const stratVector = [(Producer,true),(Producer,false),(Enforcer,true),(Enforcer,false)]

#--------------------------GAME PARAMETERS------------------------------------
#--Continuation probability--
const δ = 0.  # With what probability the stage game repeats
#--Karma--
const maxKarma = 1  # For how many rounds should a transgressor be attacked?

#---------PAYOFFS------
#--Production (PD between producers)--
const b = 3.  # benefit of cooperation to the opponent
const c = 1.  # cost of cooperation to oneself
const w = 1.  # baseline payoff ***( w > v / τ )***
# Taxation
const τ = .3 
# Punishment
const v = .1  # Cost of punishment to enforcer
const p = 1.5  # Producer's loss from being punished
# Attack
const ψ = .5  # Proportion of surplus plundered
const l = .5  # Loss for being attacked ***( l < 2(τ w -v) )***

#--------------------MISTAKE PROBABILITIES-------------------------------------
const probProduceMistake = 0.
const probDetectionMistake = 0.2
const probPunishMistake = 0.
const probAttackMistake = 0.

#---------------------------EVOLUTION------------------------------------------
const generations = 20000
const bestresponse = true
const agentsToRevise = 1  # Number of agents who update their strategy at the end of each generation

#-------------------------INITIALIZATION---------------------------------------
# Values for strategy initialization: they determine with what probability
# each strategy is played
const probCooperateProducer = .1
const probCooperateEnforcer = .1
# Values for population initialization (how many of each type?)
const producers = 700
const enforcers = 300
# Initialization code
enforcerList = map(x->Enforcer(),1:enforcers)
producerList = map(x->Producer(),1:producers)
population = vcat(producerList,enforcerList)
#-----------------------------------------------------------------------------