export CityManager, Route, Log, add_entry, get_total_result, GeneticAlgorithm, SimulatedAnnealing, ALGORITHMS, GUI


# ------------------------------ Cities ------------------------------ 
mutable struct CityManager
    # Maps names of cities to their id's and back
    name_to_id::Dict{String, Int}
    id_to_name::Dict{Int, String}
    # Matrix mapping distances between cities (id's)
    dist_matrix::Matrix{Float32}
    # Starting city as its id
    starting_city::Int 
    # Total number of cities
    num_cities::Int
end


mutable struct Route
    path::Vector{Int}
    distance::Float32
    Route(path::Vector{Int}, dist::Float32) = new(path, dist)
    Route(path::Vector{Int}) = new(path, floatmax(Float32))
    Route() = new([], floatmax(Float32))
end

# ------------------------------ Logging ------------------------------ 
mutable struct Log
    entries::Vector{Dict{String, Any}}
    Log() = new([])
end

add_entry(log::Log, entry::Dict{String, Any}) = push!(log.entries, entry)

function get_total_result(log::Log)::Dict{String, Any}
    result::Dict{String, Any} = Dict{String, Any}(
        "iterations" => 0,
        "best" => "",
        "distance" => floatmax(Float32)
    )
    # Empty values
    if isempty(log.entries)
        return result
    end
    # Find best value
    for entry in log.entries
        if entry["distance"] < result["distance"]
            result["distance"] = entry["distance"]
            result["best"] = entry["best"]
        end
    end
    result["iterations"] = length(log.entries)
    return result
end

# ------------------------------ Algorithms ------------------------------ 

abstract type Algorithm end

get_iteration(algorithm::Algorithm)::Int64 = algorithm.iteration
get_params(algorithm::Algorithm)::Dict{String, Any} = algorithm.params
get_city_manager(algorithm::Algorithm)::CityManager = algorithm.city_manager
get_log(algorithm::Algorithm)::Log = algorithm.log

mutable struct GeneticAlgorithm <: Algorithm
    params::Dict
    iteration::Int64
    city_manager::CityManager
    children::Vector{Route}
    log::Log
    GeneticAlgorithm(alg_params::Dict, city_params::Dict) = new(alg_params, 0, CityManager(city_params), [], Log())
end

mutable struct SimulatedAnnealing <: Algorithm
    params::Dict
    iteration::Int64
    city_manager::CityManager
    route::Route
    log::Log
    SimulatedAnnealing(alg_params::Dict, city_params::Dict) = new(alg_params, 0, CityManager(city_params), Route(), Log())
end

const ALGORITHMS = Dict{String, Any}(
    "GeneticAlgorithm" => GeneticAlgorithm,
    "SimulatedAnnealing" => SimulatedAnnealing
)

# ------------------------------ GUI ------------------------------ 

mutable struct MyGraphics
    sliders::Dict{String, Union{Int, Float64}} # Slider buttons (mapping label to value)
    buttons::Dict{String, Bool} # Buttons (mapping label to on/off bool)
    axis::Any  # Axis containing current best found cities sequence
    lines::Union{Any, Nothing}  # Lines containing current best found cities sequence
    best_axis::Any # Axis containing overall best found cities sequence
    best_lines::Union{Any, Nothing} # Lines containing overall best found cities sequence
    info_label_values::Dict{String, Any}    # Info labels containing information about current & overall best found cities sequence
end

mutable struct MyData
    cities::Dict{String, Any}   # City coordinates
    best_entry::Union{Dict{String, Any}, Nothing}   # Information about overall best iteration
end

mutable struct GUI
    data::MyData
    graphics::MyGraphics
    screen::Any
end


