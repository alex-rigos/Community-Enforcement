# Community Enforcement

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