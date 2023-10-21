export alg_step

function alg_step(algorithm::SimulatedAnnealing)::Union{Route, Nothing}
    # println("Performing step function on SimulatedAnnealing, iteration: $(algorithm.iteration)")
    # Algorithm cannot run anymore
    if algorithm.params["temperature"] <= 1
        println("Parameter temperature has to be greater than 1, got: $(algorithm.params["temperature"])")
        return nothing
    elseif algorithm.iteration != 0 && !isa(algorithm.route, Nothing)
        # Deep copy of previous
        new_route::Route = deepcopy(algorithm.route)
        # Get two indexes of cities to swap (subtract 1, since Routes do not have initial city)
        swap_city!(new_route, pick_two(1, algorithm.city_manager.num_cities-1)...)
        new_route.distance = get_route_distance(algorithm.city_manager, new_route)
        # Decide if new solution should be accepted
        if accept_probability(algorithm.route.distance, new_route.distance, algorithm.params["temperature"]) > rand()
            algorithm.route = new_route
        end
        # Change temperature
        algorithm.params["temperature"]  *= (1-algorithm.params["cooling_rate"])
    else # Iteration 0 (Initialization)
        algorithm.route = get_random_route(algorithm.city_manager)
    end
    # Add log entry
    entry::Dict{String, Any} = Dict{String, Any}(
        "iteration" => algorithm.iteration,
        "temperature" => algorithm.params["temperature"],
        "best" => get_route_name(algorithm.city_manager, algorithm.route),
        "distance" => algorithm.route.distance
    )
    add_entry(algorithm.log, entry)
    # Update algorithm
    algorithm.iteration += 1
    return algorithm.route
end


function accept_probability(current_energy::Float32, new_energy::Float32, temperature::Real)::Float32
    # Found better solution
    if (new_energy < current_energy)
        return 1.0
    end
    # Decide based on probability
    return exp((current_energy-new_energy) / temperature)
end

