# Community Enforcement

## System Requirements
1. [Julia v1.6](https://julialang.org/) with the following pacakges 
  * `Random` (??), 
  * `StatsBase v0.33.10` 
  * `Plots v1.22.5` 
  * `CSV v0.9.11` 
  * `Tables v1.6.1` 
  * `ColorSchemes v3.16.0`
  * `LaTeXStrings v1.3.0`
  * `Measures v0.3.1`
  * `Vega v2.3.0`
  * `ColorBrewer v0.4.0`
  * `Distributed`

# Installation
1. Download `Julia` from <https://julialang.org/>
2. Open the Julia REPL
3. At the prompt `julia>` type `]` to enter the package manager
4. At the prompt (e.g. `(@v1.6) pkg>`) run the following command 
```
    add Random StatsBase Plots CSV Tables ColorSchemes Measures Vega ColorBrewer LaTeXStrings Distributed
```
5. Type `[backspace]` to exit the package manager environment
6. 

## Usage
### Simulation
1. Open `ComEn-Parameters.jl` to set up the simulation parameters (and Save).
2. Execute `ComEn-Simulations.jl` to run the simulation with the given parameters.
3. Execute `ComEn-Plots.jl` to plot the result of the simulations.

### Arrow plots
1. Open `ComEn-Parameters.jl` to set up the simulation parameters (and Save).
2. Open `ComEn-Arrows.jl` to change the population parameters. (Since this is run for many different populations (for many different initial conditions), the population settings in `ComEn-Parameters.jl` are ignored. The same goes for the generations).
3. Execute `ComEn-Arrows.jl` to run the simulations with the given parameters and get the arrow plots.

### Time averages
1. Open `ComEn-Parameters.jl` to set up the simulation parameters (and Save).
2. Open `ComEn-TimeAvg.jl` to set initial population conditions, number of generations and the values of $l$ and $f$ for which the simulations should be run. Settings for `pop` (initial conditions), `l`, `f`, and `generations` override those in `ComEn-Parameters.jl`.
3. Execute `ComEn-TimeAvg.jl` to run the simulations with the given parameters and get the arrow plots.