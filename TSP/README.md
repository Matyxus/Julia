# TravelingSalesMan

Project solving the [TSP](https://en.wikipedia.org/wiki/Travelling_salesman_problem) problem 
using iterative algorithms \
to achieve good solution (non-optimal) in reasonable amount of time. \
Individual documentation of algorithsm: https://github.com/Matyxus/julia, GUI: https://github.com/Urlikp/TravelingSalesmanGUI,
this project combines algorithm with GUI.

## Usage
To use the project, there is file Main.jl in [main](./src/Main.jl) folder.
This file provides the function *main*, and is used as follows:
```julia
using TSP
file_name::String = "ga"
main(file_name)
```
Where *file_name* is the name of file located inside [data](./data) folder, which
provides all input related variables, julia must be run in project root!.


