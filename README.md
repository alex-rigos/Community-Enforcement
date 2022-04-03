# Emergence of Specialised Third-Party Enforcement
## Overview
This software is meant to support the research paper "Emergence of Specialised Third-Party Enforcement" by Erik Mohlin, Alexandros Rigos, and Simon Weidenholzer. It contains the tools that were used to produce the simulations and figures for the paper, as well as a demo script.
## 1. System requirements
### Hardware requirements
The software only requires a standard computer.

### Software requirements
The code is written in the [Julia](https://julialang.org/) language (v1.7).
### OS Requirements
The software should be able to run on all major operating systems. It has been tested on the following systems:

* macOS: Catalina (10.15.7)
* Windows 11 (version 21H2)

### Julia dependencies

* CSV (v0.10.4)
* ColorSchemes (v3.17.1)
* LaTeXStrings (v1.3.0)
* Measures (v0.3.1)
* PGFPlotsX (v1.4.1)
* Plots (v1.27.4)
* StatsBase (v0.33.16)
* Tables (v1.7.0)
* Distributed
* Random

## 2. Installation Guide:
### 2.1. Instructions
1. Download and install the Julia language from <https://julialang.org/>
2. Download the software from github and move to the installation directory. If you use `git` and have access to a terminal, you can use the following commands to do that.
```shell
$ git clone https://github.com/alex-rigos/Community-Enforcement
$ cd Community-Enforcement
```
If you do not have access to a terminal, navigate to  <https://github.com/alex-rigos/Community-Enforcement>, click on the Code button, and select `Download ZIP` to download the ZIP file. Then, unzip the file and navigate to the `Community-Enforcement` folder.

3. Install Julia dependencies:
    1. From the terminal
    ```shell
    $ julia install.js
    ```
    2. or from the Julia REPL
    ```shell
    $ julia> install.js
    ```

### 2.2. Typical installation time
After installing Julia, the installation of the required dependencies takets about 80 seconds.
## 3. Demo
### 3.1. Instructions
#### 3.1.1. Set model and simulation parameters
Select the parameters to be used in the simulation by editing the file `demo-params.jl` (and saving it). A short description of each parameter is included in this file. For more details, please see the paper. 

The version of the `demo-params.jl` file provided includes the parameter values for the baseline model and for a population of 50 agents with initial state $`(n_{CP},n_{CE},n_{DP},n_{DE})=(20,20,5,5)`$. The default number of periods for which simulations are run is 1,000. This can be changed by setting the value of the `generations` variable. Increasing this number will considerably affect execution times.

#### 3.1.2. Generate simulation data and plots
After setting the parameter values, you can run a simulation:
1. From the terminal
```shell
$ julia demo-sims.jl
```
2. or from the Julia REPL
```shell
julia> include("demo-sims.jl")
```


### 3.2. Output
The script generates three output files, which are placed under the `demo/` folder:
* `demo-data.csv`: simulation data
* `demo-evo.pdf`: population evolution period by period
* `demo-avg.pdf`: strategy averages across all periods

### 3.3. Expected run time 
The demo script takes approximately 30 seconds to execute the first time, as Julia needs to compile the source. After that, the script takes approximately 4 seconds to execute. These numbers are for 1000 period-long simulations. Increasing the number of periods will significantly increase execution time.

## 4. Instructions for use
To generate new data and figures like those in the paper, please follow the procedures laid out below. The scripts below use parallel processing to reduce execution time. To set the default parameter values for any of the data generation scripts below, edit the file `ComEn-Parameters.jl` accordingly (and Save). All data-generation scripts below take considerable amounts of time to execute for the default parameter values (up to 30 minutes).
### 4.1. Time series and time averages plots
#### 4.1.1. Data generation
Run the script `time-series-data-generation.jl`. This creates a directory tree with root `time-series/time-series-data/` where the data are stored in files under the appropriate folders:
* Subfolder `4-strategies` contains the data for simulations with the four main strategies of the paper
* subfolder `5-strategies` contains the data for simulations that also include the Parochial Enforcer strategy

#### 4.1.2. Generation of time-series plots (e.g. fig. 4d-f and 7a-c)
Run the script `time-series-plots.jl`. This will create the folder `time-series/time-series-plots/`, where the figures are stored under appropriately-named directories
#### 4.1.3. Generation of time-averages plots (e.g. fig. 4g-i and 7d-f)
Run the script `time-averages-plots.jl`. This will create the folder `time-averages-plots/`, where the figures are stored under appropriately-named directories

### 4.2. Phase diagrams (aka fishtank plots)
#### 4.2.1. Data generation
To generate the data, run the script `fishtank-data-generation.jl`. This will create data files in the directory `fishtanks/fishtank-data/`.

Parameter values are read from the `ComEn-ParametersBaseline.jl` file. The population states for which the calculations are run can be edited in the `fishtank-data-generation.jl` file.

#### 4.2.2. Generation of phase diagram plots (e.g. fig. 4a-c)
Run the script `fishtank-plots.jl`. This will create the folder `fishtanks/fishtank-plots/`, where the figures are stored for the data found in the `fishtanks/fishtank-data/` folder.

### 4.3. Comparative statics plots
#### 4.3.1. Data generation
To generate the data, run the script `comp-stat-data-generation.jl`. This will create data files in subfolders under the directory `comp-stat/comp-stat-data/`. The subfolders are named with the variables for which the comparative statics computation is being conducted.

Parameter values are read from the `ComEn-ParametersBaseline.jl` file. The parameters and parameter values for which the simulations are carried out can be edited in the `comp-stat-data-generation.jl` file.
#### 4.3.2. Generation of comparative statics plots (e.g. fig. 4a-i)
Run the script `comp-stat-plots.jl`. This will create the folder `comp-stat/comp-stat-plots/`, where the figures are stored for the data found in the `comp-stat/comp-stat-data/` folder.

## 5. Replication code for the paper's figures
Replicate the paper's figures:
1. From the terminal
```shell
$ julia paper-figures-replication.jl
```
2. or from the Julia REPL 
```shell
julia> include("paper-figures-replication.jl")
```

The scipt runs code that generates plots for the data that are found in subfolders under the `paper-figures/` folder (and were used for the paper's figures). These subfolders are
* `time-series/time-series-data/`
* `fishtanks/fishtank-data/`
* `comp-stat/comp-stat-data/`

The script creates the following subfolders (under the `paper-figures/` folder) where the generated figures are placed:
* `time-series/time-series-plots/`
* `time-averages/time-averages-plots/`
* `fishtanks/fish-tank-plots/`
* `comp-stat/comp-stat-plots/`