import Random: shuffle

export get_route_name, get_route_distance, get_random_route

function CityManager(city_params::Dict)::Union{CityManager, ErrorException, KeyError, TypeError}
    # Check cities
    for key in ["position", "start"]
        if !haskey(city_params, key)
            throw(KeyError("Missing key: '$(key)'!"))
        end
    end
    position = city_params["position"]
    if !isa(position, Dict)
        throw(TypeError("In key 'position' in 'cities'", Dict, typeof(position)))
    elseif isempty(position)
        throw(KeyError("Cities read from file are empty!"))
    elseif length(position) < 2
        throw(KeyError("There must be at least 2 cities, got: $(length(position)) !"))
    # Check values
    elseif !all(y->(y isa Vector) && (length(y) == 2) && all(isa.(y, Real)), values(position))
        throw(ErrorException("Expected cities to be mapped to vector containing two (real) numbers, got: $(values(position))!"))
    elseif !haskey(position, city_params["start"])
        throw(KeyError("Starting city '$(city_params["start"])' is not located in 'position'!"))
    end
    city_params["start"] = string(city_params["start"])
    # Mapping of names to proper ids
    value = pop!(position, city_params["start"]) # Pop starting city
    temp = Dict([string(city_name), id] for (id, city_name) in enumerate(keys(position)))
    # Guarantee that starting city is the highest id
    temp[city_params["start"]] = (length(position) + 1) 
    positions::Vector = push!(collect(values(position)), value)
    # Return original value
    position[city_params["start"]] = value
    return CityManager(temp, Dict(values(temp) .=> keys(temp)), distance_matrix(positions), temp[city_params["start"]], length(keys(temp)))
end


"""
    distance_matrix(cities::Vector)::Matrix{Float32}

    Compute the euclidean distances between each city into Matrix.

# Arguments
- `cities::Vector`: Vector of two-tuples (coordinates of cities)

`Returns` matrix of distances.

# Examples
```julia-repl
julia> distance_matrix([Any[1, 8], Any[4, 1], Any[1, 2]])

3x3 Matrix{Float32}:
 0.0    7.616  6.0
 7.616  0.0    3.162
 6.0    3.162  0.0
```
"""
function distance_matrix(cities::Vector)::Matrix{Float32}
    # Calculate (euclidean) distance between two points
    function get_distance(city_1::Vector, city_2::Vector)::Float32
        return round(sqrt((city_2[1] - city_1[1])^2 + (city_2[2] - city_1[2])^2); digits=3)
    end
    matrix::Matrix{Float32} = zeros(Float32, length(cities), length(cities))
    # Used the fact, that matrix is symmetric
    for i in 1:(length(cities)-1)
        for j in (i+1):length(cities)
            matrix[i,j] = get_distance(cities[i], cities[j])
        end
    end
    return matrix + matrix'
end

# ------ Getters ------ 

get_route_name(manager::CityManager, route::Route)::String = (
    manager.id_to_name[manager.starting_city] * "-" * # Add starting city
    join([manager.id_to_name[id] for id in route.path], "-") * "-" *
    manager.id_to_name[manager.starting_city]  # Add ending city
)
get_route_distance(manager::CityManager, route::Route)::Float32 = (
    manager.dist_matrix[manager.starting_city, route.path[1]] + # Add distance from starting city
    sum([manager.dist_matrix[route.path[index], route.path[index+1]] for index in 1:(manager.num_cities-2)]) +
    manager.dist_matrix[route.path[end], manager.starting_city] # Add distance to ending city
)
get_route_distance(manager::CityManager, path::Vector{Int})::Float32 = (
    manager.dist_matrix[manager.starting_city, path[1]] + # Add distance from starting city
    sum([manager.dist_matrix[path[index], path[index+1]] for index in 1:(manager.num_cities-2)]) +
    manager.dist_matrix[path[end], manager.starting_city] # Add distance to ending city
)
# Return randomly generated path (without starting & ending city)
function get_random_route(manager::CityManager)::Route
    path::Vector{Int} = shuffle([1:(manager.num_cities-1)...])
    return Route(path, get_route_distance(manager, path))
end

# -------------------- Routes  --------------------

function swap_city!(route::Route, index1::Int, index2::Int)::Nothing
    route.path[index1], route.path[index2] = route.path[index2], route.path[index1]
    return nothing
end

