# Emergence of Specialised Third-Party Enforcement
## Overview
## System requirements
### Hardware requirements
The software only requires an ordinary computer.
### Software requirements
The code is written in [Julia](https://julialang.org/) and uses the following dependencies
  ```
  Random 
  StatsBase (>=0.33.10)
  Plots (>=1.22.5)
  CSV (>=0.9.11)
  Tables (>=1.6.1)
  ColorSchemes (>=3.16.0)
  LaTeXStrings (>=1.3.0)
  Measures (>=0.3.1)
  Vega (>=2.3.0)
  ColorBrewer (>=0.4.0)
  Distributed
  ```

## Installation
### Instructions
1. Install Julia (<https://julialang.org/>)
2. Download software from github and move to the installation directory. From the Terminal
```
$ git clone https://github.com/alex-rigos/Community-Enforcement
$ cd Community-Enforcement
```
3. Open the Julia REPL
```
$ julia
```
4. Install Julia dependencies
    ```
    julia> ]
    (@v1.6) pkg> add Random StatsBase Plots CSV Tables ColorSchemes Measures Vega ColorBrewer LaTeXStrings Distributed
    (@v1.6) pkg> [backspace]
    julia>
    ```

### Typical install time

## Demo
### 1. Set model and simulation parameters
Select the parameters to be used in the simulation by editing the file `demo-params.jl` (and saving the file). A short description of each parameter is included in this file. For more details, please see the paper. The version of the file provided includes the parameter values for the baseline model and for a population of 50 agents with initial state $(n_{CP},n_{CE},n_{DP},n_{DE})=(20,20,5,5)$.

### 2. Data generation (simulations)
Run the simulation (default is 1,000 generations, this can be changed in the `demo-params.jl` file). This can be done in two ways:
* From the terminal
    ```
    $ julia demo-sims.jl
    ```
* From the Julia REPL
    ```
    julia> include("demo-sims.jl")
    ```
The generated data are stored in `demo-data.csv`.

### 3. Plot the data
Generate plots of the data. This can be done in two ways:
* From the terminal
```
$ julia demo-plots.jl
```
* From the Julia REPL
```
julia> include("demo-plots.jl")
```
The resulting plots are `demo-evo.pdf` (population evolution generation by generation) and `demo-avg.pdf` (population averages across all generations). These are plotted for the data that was generated in step 2.

## Generation of figures for the paper
The following procedures can be used to generate the paper's figures. They use parallel processing to save time.
### Data generation
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