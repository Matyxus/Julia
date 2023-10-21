"""
1) - Loading data -> transform them into JSON format using python
2) - Create project structure
2.1) - Algorithms (General structure, then sub-structure) for GA, perturbation etc.
2.2) - Statistics structure to handle all Statistics + file export
2.3) - GUI (with buttons etc)
2.4) - TSP -> Representation of TSP (distance matrix etc)
2.5) - Function main(file::string) -> Main loop of simulation
"""


# println(test(temp))
# println(test(temp2))

# Structure for TSP problems
mutable struct TSP
    name::String
    num_cities::Int
    distances::Matrix{Float64}
    initial_solution::Vector{Int}
    optiomal_solution::Vector{Int}
end

TSP() = TSP("test", 0, zeros(0, 0), [], [])

# Structure for recording progress of simulation
mutable struct Log
    cache::Dict{Any, Float64}
    best::Vector
end
Log()::Log = Log(Dict(), [])
# Get average, deviation

# Super type of all algorithms
abstract type Alg end
# Getters, defined for all Algorithms
get_params(alg::Alg)::Dict = alg.params
get_log(alg::Alg)::Log = alg.log
get_tsp(alg::Alg)::TSP = alg.tsp
# Functions, defined for all Algorithms
is_running(::Alg)::Bool = throw(ArgumentError("All subtypes of 'Alg' must define method 'is_running' !"))
step(::Alg)::Representation = throw(ArgumentError("All subtypes of 'Alg' must define method 'step' !"))
# Utils, checks for basic parameters in algorithm
missing_field(alg::Alg, member::Symbol) = throw(ArgumentError("'$(typeof(alg))' is subtype of 'Alg', therefore must define member '$(member)' !"))
check_field(alg::Alg, member::Symbol)::Bool = hasfield(typeof(alg), member) ? true : missing_field(alg, member)
check_alg(alg::Alg)::Bool = all([check_field(alg, member) for member in [:params, :log, :tsp]])

abstract type LocalSearch <: Alg end
# Getters, defined for all LocalSearch Algorithms
get_fitness(alg::LocalSearch)::Function = alg.fitness
get_perturbation(alg::LocalSearch)::Function = alg.perturbation

abstract type GeneticAlgorithm <: Alg end
# Getters, defined for all GeneticAlgorithm's
get_mutation(alg::GeneticAlgorithm)::Function = alg.mutation
get_crossover(alg::GeneticAlgorithm)::Function = alg.crossover

abstract type HeuresticAlgorithm <: Alg end

abstract type MemeticAlgorithm <: Alg end
get_local_search(alg::MemeticAlgorithm)::LocalSearch = alg.local_search


mutable struct GUI

end


mutable struct Interface
    solver::Alg
    gui::GUI
    termination::Function
end







