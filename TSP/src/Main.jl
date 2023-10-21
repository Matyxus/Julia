import Random: seed!

export main

# Main function running project
function main(file_name::String)::Int
    println("Loading file: '$(file_name)'")
    json_file = load_data(file_name)
    if isa(json_file, Nothing)
        return 1
    end
    # 2) Load appropritate file + check it
    for key in ["problem_name", "logging", "algorithm", "cities", "gui"]
        if !haskey(json_file, key)
            println("Input file: '$(key)' is missing 'algorithms' key!")
            return 1
        end
    end
    println("Succesfully loaded: '$(file_name)'")
    # 3) Initialize GUI
    println("Initializing GUI")
    gui::GUI = GUI(json_file)
    println("Finished initializing GUI")
    # 4) Initialize algorithm
    seed!(json_file["algorithm"]["seed"])
    println("Initializing algorithm: $(json_file["algorithm"]["name"])")
    algorithm = ALGORITHMS[json_file["algorithm"]["name"]](json_file["algorithm"]["params"], json_file["cities"])
    println("Running algorithm: $(json_file["algorithm"]["name"]), iterations: $(json_file["algorithm"]["iterations"])")
    # ------------- Main loop -------------
    running::Bool = true
    max_iters::Int = json_file["algorithm"]["iterations"]
    pause::Bool = false
    run_time::Number = 0
    while running
        button_values::Dict{String, Bool} = get_buttons(gui)
        # Clear and reset values
        if button_values["Clear & Reset"]
            max_iters = json_file["algorithm"]["iterations"]
            run_time = 0
            # Reset algorithm progress
            algorithm.iteration = 0
            algorithm.log.entries = []
            set_button_value(gui, "Clear & Reset")
        end

        # Decide if we are playing or paused
        if pause != button_values["Pause"] # Changed "Pause" state from previous
            pause = !pause
            # Set "Play" to false
            button_values["Play"] = false
            set_button_value(gui, "Play")
        elseif button_values["Play"] # Play was clicked on true, set Pause to false
            button_values["Pause"] = pause = false
            set_button_value(gui, "Pause")
        end
        # Set slider values to algorithm
        slider_values::Dict{String, Union{Int, Float64}} = get_sliders(gui)
        for (parameter, value) in slider_values
            if haskey(algorithm.params, parameter)
                algorithm.params[parameter] = value
            end
        end
        # Either the game is running or its paused and user pressed "step" button
        if button_values["Play"] || (!button_values["Play"] && button_values["Step"])
            time_now = now()
            best::Route = alg_step(algorithm)
            run_time += (now() - time_now).value
            if !isnothing(best)
                update_gui(gui, algorithm.log.entries[end])
            end
            max_iters -= 1
        end
        # Check if we should continue running
        running = max_iters > 0
        if running
            running = gui.screen.window_open[] == true
        end
        # Reset "step" button
        set_button_value(gui, "Step")
        # Sleep
        sleep(slider_values["Step interval"] / 1000)
    end
    println("Finished running algorithm, run time: $(run_time / 1000)-seconds")
    # 4) exit program (save logg file if logging is enabled -> [Info, {params}, ...])
    if json_file["logging"]["save_log"]
        data::Dict{String, Any} = Dict{String, Any}(
            "info" => Dict{String, Any}(
                "input_file" => file_name,
                "algorithm" => json_file["algorithm"]["name"],
                "run_time" => (run_time / 1000) # In seconds
            ),
            "total" => get_total_result(algorithm.log),
            "log_entries" => (json_file["logging"]["detailed"] ? algorithm.log.entries : nothing)
        )
        println("Successfully saved log file: '$(save_log(json_file["problem_name"], data))'")
    end
    println("Exiting ...")
    exit()
    return 0
end

# 


