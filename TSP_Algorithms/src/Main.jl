import Random: seed!

export main

# Main function running project
function main(file_name::String)::Int
    println("Loading file: '$(file_name)'")
    json_file = load_data(file_name)
    if isnothing(json_file)
        return 1
    end
    # 2) Load appropritate file + check it
    for key in ["problem_name", "logging", "algorithm", "cities"]
        if !haskey(json_file, key)
            println("Input file: '$(key)' is missing 'algorithms' key!")
            return 1
        end
    end
    println("Succesfully loaded: '$(file_name)'")
    # 3) Initialize algorithm
    seed!(json_file["algorithm"]["seed"])
    println("Initializing algorithm: $(json_file["algorithm"]["name"])")
    algorithm = ALGORITHMS[json_file["algorithm"]["name"]](pop!(json_file["algorithm"], "params"), pop!(json_file, "cities"))
    println("Running algorithm, iterations: $(json_file["algorithm"]["iterations"])")
    run_time = now()
    for _ in 1:json_file["algorithm"]["iterations"]
        if isnothing(alg_step(algorithm))
            println("Finished running algorithm!")
            break
        end 
    end
    run_time = (now() - run_time)
    println("Finished running algorithm, run time: $((run_time.value / 1000))-seconds")
    # 4) exit program (save logg file if logging is enabled -> [Info, {params}, ...])
    if json_file["logging"]["save_log"]
        data::Dict{String, Any} = Dict{String, Any}(
            "info" => Dict{String, Any}(
                "input_file" => file_name,
                "algorithm" => json_file["algorithm"]["name"],
                "run_time" => (run_time.value / 1000) # In seconds
            ),
            "total" => get_total_result(algorithm.log),
            "log_entries" => (json_file["logging"]["detailed"] ? algorithm.log.entries : nothing)
        )
        println("Successfully saved log file: '$(save_log(json_file["problem_name"], data))'")
    end
    println("Exiting ...")
    return 0
end
