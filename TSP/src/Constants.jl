import JSON: parsefile, print as j_print
import Dates: format, now

export pick_two, load_data, save_log, now

const SEP = Base.Filesystem.pathsep()
const DATA_PATH = "data" * SEP # ".." * SEP * 
const LOG_PATH  = "logs" * SEP # ".." * SEP * 
const JSON_EXTENSION = ".json"

pick_two(from::Int, to::Int)::Vector{Int} = rand(from:to, 2)

"""
    load_data(file_name::String)::Union{Nothing, Dict}

    Loads '.json' files containing program parameters.

# Arguments
- `file_name::String`: name of file located in TravelingSalesman/data (without extension)

If `file_name` is is not located in TravelingSalesman/data returns `nothing`.

# Examples
```julia-repl
julia> load_data("ga")

Dict{String, Any} with 4 entries:
"problem_name" => "problem01"
"logging"      => Dict{String, Any}("save_log" => false, ....)
"cities"       => Dict{String, Any}("f"=>Any[6, 7], "g"=>Any[8, 2], ...)
"params"       => Dict{String, Any}("population"=>30, "mutation"=>0.1, ...)
```
"""
function load_data(file_name::String)::Union{Nothing, Dict}
    # Move to "data" folder and add extension
    file_name = (DATA_PATH * file_name * JSON_EXTENSION)
    # Check file existence
    if !isfile(file_name)
        println("File: '$(file_name)' does not exist!")
        return nothing
    end
    return parsefile(file_name)
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
function save_log(name::String, data::Dict{String, Any})::Bool
    # Move to "logs" folder and add prefix + extension
    prefix::String = replace(format(now(), "HH:MM:SS"), ":" => "_") * "_"
    file_name = (LOG_PATH * prefix * name * JSON_EXTENSION)
    # Checks
    if isempty(data)
        println("Cannot save empty log!")
        return false
    elseif isfile(file_name)
        println("File: '$(file_name)' already exists!")
        return false
    end
    println("Saving log to file: '$(file_name)'")
    # Save data to file
    open(file_name,"w") do f
        j_print(f, data, 2)
    end
    return true
end


# ---------------------- GUI ----------------------

const BUTTON_LABELS = [
    "Play", 
    "Pause", 
    "Clear & Reset", 
    "Step", 
    "Default"
]

const LABEL_LABELS = [
    "Current iteration: ", 
    "Current shortest distance: ", 
    "Current best: ", 
    "Best distance: ",
    "Best: "
]

const LABEL_STARTING_VALUES = [
    0,
    0.0,
    "---",
    0.0,
    "---"
]

const AXIS_OFFSET = 2
const TEXT_OFFSET = 0.1


