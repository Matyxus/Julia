export alg_step

function alg_step(algorithm::GeneticAlgorithm)::Route
    # println("Performing step function on Genetic Algorithm")
    if algorithm.iteration != 0 && !isempty(algorithm.children)
        new_children::Vector{Route} = []
        num_children::Int64 = length(algorithm.children)
        # ---------- Elitism ----------
        # Elitism guarantees to save the best genes in next generation
        # Check if previous (population * elitism) is bigger then new population, if so
        # take elitism from current population number
        elite_index::Int = (
            (num_children * algorithm.params["elitism"] < algorithm.params["population"]) ?
            floor(Int64, num_children * algorithm.params["elitism"]) :
            floor(Int64, algorithm.params["population"]  * algorithm.params["elitism"])
        )
        # println("Calculating elitism index: $(elite_index)")
        if elite_index > 0
            append!(new_children, algorithm.children[1:elite_index])
        end
        # ---------- Cross over ----------
        while length(new_children) < algorithm.params["population"]
            append!(new_children, crossover(algorithm.children[pick_two(1, num_children)]..., algorithm.params["crossover"]))
        end
        # Check number of children (crossover could have added 1 more)
        new_children = new_children[1:algorithm.params["population"]]
        # ---------- Mutation ----------
        mutate.(new_children, algorithm.params["mutation"])
        # Assign distances
        for child in new_children
            child.distance = get_route_distance(algorithm.city_manager, child)
        end
        algorithm.children = new_children
    else # Iteration 0 (Initialization)
        algorithm.children = [get_random_route(algorithm.city_manager) for _ in 1:algorithm.params["population"]]
    end
    # Sort children based on distance
    sort!(algorithm.children, by = r -> r.distance)
    # Add log entry
    entry::Dict{String, Any} = Dict{String, Any}(
        "iteration" => algorithm.iteration,
        "best" => get_route_name(algorithm.city_manager, algorithm.children[1]),
        "distance" => algorithm.children[1].distance
    )
    add_entry(algorithm.log, entry)
    # Update algorithm
    algorithm.iteration += 1
    return algorithm.children[1]
end

"""
    save_log(name::String, data::Vector)::Bool

Saves information about algorithm run into 
'.json' file located in TravelingSalesman/logs.

# Arguments
- `name::String`: name of file, will be saved in (with current time as prefix)
- `data::Dict{String, Any}`: data to be saved in file (total result of algorithm runtime)

`Returns` true on success, false otherwise.

# Examples
```julia-repl
julia> save_log("test", Dict{String, Any}("test" => 1))
true
```
"""
function mutate(child::Route, chance::Float64)::Nothing
    # Failed to trigger mutation
    if rand() > chance
        return nothing
    end
    # Since TravelingSalesman problem has constraint of having each city appear only once,
    # we can just swap randomly two cities to perform mutation
    swap_city!(child, pick_two(1, length(child.path))...)
    return nothing
end

# -------------------------- Cross Over --------------------------
# Implementation of: https://user.ceng.metu.edu.tr/~ucoluk/research/publications/tspnew.pdf
# https://en.wikipedia.org/wiki/Crossover_(genetic_algorithm)

"""
    get_inverse(route::Vector{Int})::Vector{Int}

    Creates vector 'result' where each index 'i' corresponds
    to number in `route` argument, and 'result[i]' is equal to
    count of numbers which are preceding (index wise) 'i' and
    are lower in `route`.

# Arguments
- `route::Vector{Int}`: Vector containing sequence of numbers (starting from 1 up to N, must include all)

`Returns` Vector{Int64} of same lenght as input

# Examples
```julia-repl
julia> get_inverse([5, 7, 1, 3, 6, 4, 2])
7-element Vector{Int64}: [2, 5, 2, 0, 2, 0, 0]
```
"""
function get_inverse(route::Vector{Int})::Vector{Int}
    inverse::Vector{Int} = []
    for i in 1:length(route)
        inverse_i::Int = 0
        m::Int = 1
        while (route[m] != i)
            if route[m] > i
                inverse_i += 1
            end
            m += 1
        end
        append!(inverse, inverse_i)
    end
    return inverse
end

"""
    get_permutation(inverse::Vector{Int})::Vector{Int}

    Reverses the function get_inverse(route::Vector{Int}), from
    inverse sequence constructs original sequence.

# Arguments
- `inverse::Vector{Int}`: Vector containing sequence of numbers

`Returns` true on success, false otherwise.

# Examples
```julia-repl
julia> get_permutation([2, 5, 2, 0, 2, 0, 0])
7-element Vector{Int64}: [5, 7, 1, 3, 6, 4, 2]

julia> get_permutation(get_inverse([5, 7, 1, 3, 6, 4, 2]))
7-element Vector{Int64}: [5, 7, 1, 3, 6, 4, 2]
```
"""
function get_permutation(inverse::Vector{Int})::Vector{Int}
    len::Int = length(inverse)
    temp::Vector{Int} = zeros(Int, len)
    for i in len:-1:1
        for m in (i+1):len
            if temp[m] >= (inverse[i] + 1)
                temp[m] += 1
            end
        end
        temp[i] = (inverse[i] + 1)
    end
    permutation::Vector{Int} = zeros(Int, len)
    for i in 1:len
        permutation[temp[i]] = i
    end
    return permutation
end

"""
    crossover(parentA::Route, parentB::Route, chance::Float64)::Pair{Route, Route}

    Performs crossover operation, by using inverse sequence of city id's
    and randomly selected index, inverseA[1:index] is combined with 
    inverseB[index+1:end] to create new Route (another using inverseB
    first). Uses function get_permutation() and get_inverse().

# Arguments
- `parentA::Route`: Route class representing first parent 'gene'
- `parentB::Route`: Route class representing second parent 'gene'
- `chance::Float64`: chance of triggering crossover value between [0, 1]

`Returns` Pair, containing (parentA, parentB) if chance to crossover does not trigger, else two new Routes.

# Examples
```julia-repl
julia> crossover(Route([5, 7, 1, 3, 6, 4, 2]), Route([4, 6, 2, 7, 3, 1, 5]), 1.0)
Pair(Route([4, 6, 1, 7, 3, 5, 2]), Route([5, 7, 2, 3, 6, 1, 4]))

julia> crossover(Route([5, 7, 1, 3, 6, 4, 2]), Route([4, 6, 2, 7, 3, 1, 5]), 0.0)
Pair(Route([5, 7, 1, 3, 6, 4, 2]), Route([4, 6, 2, 7, 3, 1, 5]))
```
"""
function crossover(parentA::Route, parentB::Route, chance::Float64)::Pair{Route, Route}
    # Faild to trigger crossover
    if rand() > chance
        return Pair(parentA, parentB)
    end
    inverseA::Vector{Int} = get_inverse(parentA.path)
    inverseB::Vector{Int} = get_inverse(parentB.path)
    crossover_point::Int = rand(1:(length(parentA.path)-1))
    return Pair(
        Route(get_permutation(append!(inverseA[1:crossover_point],  inverseB[crossover_point+1:end]))),
        Route(get_permutation(append!(inverseB[1:crossover_point],  inverseA[crossover_point+1:end])))
    )
end

