import Random: seed!
import Distributions: Normal

seed!(42)

mutable struct Statistics
    solutions::Array{Pair{Union{BitArray, Vector{<:Real}}, Real}}
    Statistics(x::Pair{BitArray, Real}) = new([x])
    Statistics(x::Pair{Vector{<:Real}, Real}) = new([x])
end
# compute_mean(stats::Statistics)::Float64 = sum(stats.solutions)
# compute_std(stats::Statistics)::Float64 = 

"""
@return number of ones
"""
OneMax(vals::BitArray)::Int = sum(vals)

"""
    LABS(vals::BitArray)::Int

    Low-Autocorrelation binary sequence is very hard binary problem.
    We assume a sequence S = (s_1, ....., s_D), where s_i = +- 1.
    Autocorrelations of sequence S are defined as 
    C_k = ∑ s_i * s_(i+k), from 1 to D-k.
    Then, the “energy” of sequence S (to be minimized) is defined as
    ∑ (C_k ^ 2)(S), from 1 to D-1.

# Arguments
- `vals::BitArray`: Vector containing binary representation of problem.

`Returns` Int, energy of solution
"""
LABS(vals::BitArray)::Int = sum([_LABS_C(vals, k) for k in 1:(length(vals)-1)].^ 2)
"""
    _LABS_C(vals::BitArray, k::Int)::Int

    Helper function for LABS function.

# Arguments
- `vals::BitArray`: Vector containing binary representation of problem.
- `k::Int`: Current iteration.

`Returns` Int, C_k
"""
_LABS_C(vals::BitArray, k::Int)::Int = 2 * sum([vals[i] == vals[i+k] for i in 1:(length(vals)-k)]) - (length(vals)-k)
# _LABS_C(vals::BitArray, k::Int)::Int =  2 * sum(vals[1:(length(vals)-k)] .== vals[k+1:end]) - (length(vals)-k)
# array length = X (length(vals)-k)
# num of ones = Y
# num of zeros = ? -> X - Y
# -> (ones - zeros) -> Y - (X - Y) -> 2Y - X


Sphere(vals::Array{Real})::Float64 = sum((vals - ones(eltype(vals), size(vals))).^ 2)
# println(Sphere([-0.1 -1.2 -2.3 -3.4 -4.5 -5.6 -6.7 -7.8 -8.9 -9.1]))

Rosenbrock(vals::Array{<:Real})::Float64 = sum(
    # SUM([100 * (x_(i+1) - (x_i)^2)^2 + (1 - x_i)^2])
    100 .* ((vals[2:end] - (vals[begin:(end-1)] .^ 2)) .^ 2)  .+ 
    ((ones(eltype(vals), size(vals, 2)-1) - vals[begin:(end-1)]) .^ 2)
)
Rosenbrock(val::Real)::Float64 = 0.0    

Linear(vals::Vector{<:Real}, a::Vector{<:Real}, b::Real) = b + sum(a .* vals)
Linear(vals::Vector{<:Real}) = Linear(vals, ones(eltype(vals), size(vals)), 1)

Step(vals::Vector{<:Real}, a::Vector{<:Real}, b::Real) = b + sum(floor.(a .* vals))
Step(vals::Vector{<:Real}) = Step(vals, ones(eltype(vals), size(vals)), 1)

Rastrigin(vals::Vector{<:Real}) = 10*length(vals) + sum((vals .^ 2) - 10 .* cos.((2*π) .* vals))

GrieWank(vals::Vector{<:Real}) = 1 + (1/4000) * sum(vals .^ 2) - prod(cos.(vals / sqrt.(ones(eltype(vals), size(vals)))))

Schwefel(vals::Vector{<:Real}) = -sum(vals .* sin.(sqrt.(abs.(vals))))

# println(Schwefel([-0.1, -1.2, -2.3, -3.4, -4.5, -5.6, -6.7, -7.8, -8.9, -9.1]))



perturbation(vals::BitArray, prob::Float64)::BitArray = BitArray([val ⊻ (rand(Float64) < prob) for val in vals])
perturbation(vals::BitArray)::BitArray = perturbation(vals, 0.1)

perturbation_normal(vals::Vector{<:Real}, μ::Real, σ::Real; step::Real = 1)::Vector{<:Real} = vals += (step .* rand(Normal(μ, σ), length(vals)))
perturbation_normal(vals::Vector{<:Real})::Vector{<:Real} = perturbation_normal(vals, 0, 1)



bin_to_real(vals::BitArray, lower_bound::Array{<:Real}, upper_bound::Array{<:Real}) = (
    # Check if lengths of parameters are given correctly
    (length(lower_bound) == length(upper_bound) && isinteger(length(vals) / length(lower_bound))) ? 
    # Call bin to real for each interval and bounds
    [bin_to_real(val, lower_bound[i], upper_bound[i]) for (i, val) in enumerate(collect(BitArray, Iterators.partition(vals, (length(vals) ÷ length(lower_bound)))))] :
    # Error message
    "The binary vector length is not divisible by the dimensionality of the target vector space." 
)

bin_to_real(vals::BitArray, lower_bound::Real, upper_bound::Real)::Real = (
    (length(vals) == 1 || sum(vals) == length(vals) || sum(vals) == 0) ? 
    [lower_bound, upper_bound][vals[1]+1] : # Either lower_bound or upper_bound will be chosen
    # lower_bound + step * (integer representation of vals)
    lower_bound + ((abs(upper_bound) + abs(lower_bound)) / (2^length(vals) - 1)) * reduce((acc, b) -> acc << 1 + b, vals; init=0)
)


# println(bin_to_real(BitArray([0 1 0 0 0 0 0 0 0 0]), -5.12, 5.11))

function hill_climbing(fitness::Function, perturb::Function, termination::Function, x::Union{BitArray, Vector{<:Real}})::Statistics 
    println("Running hill_climbing with: fitness $(nameof(fitness)), perturbation: $(nameof(perturb)), termination: $(termination)")
    best::Real = fitness(x)
    current::Real = best
    stats::Statistics = Statistics(Pair{BitArray, Real}(x, current))
    println("Initial solution: $(stats.solutions[end])")
    while !termination(stats)
        x = perturb(x)
        current = fitness(x)
        if current < best
            best = current
        end
        push!(stats.solutions, x => current)
        println("Current solution: $(stats.solutions[end])")
    end
    println("Best solution: $(best)")
    return stats
end

function hill_climbing_rule(fitness::Function, termination::Function, x::Vector{<:Real}; low::Real = -Inf, high::Real = Inf)::Statistics
    println("Running hill_climbing with: fitness $(nameof(fitness)), perturbation Normal with 1/5 rule, termination: $(nameof(termination))")
    best::Real = fitness(x)
    current::Real = best
    stats::Statistics = Statistics(Pair{Vector{<:Real}, Real}(x, current))
    println("Initial solution: $(stats.solutions[end])")
    σ::Real = 0.5
    d::Float64 = sqrt(length(x)+1)
    while !termination(stats)
        y::Vector{<:Real} = clamp.(perturbation_normal(x, 0, 1; step=σ), low, high)
        current = fitness(y)
        σ *= exp((current < best) - 0.2)^d
        if current < best
            best = current
            x = y
        end
        push!(stats.solutions, y => current)
        # println("Current solution: $(stats.solutions[end]), σ=$(σ)")
    end
    println("Best solution: $(best)")
    return stats
end


terminator(stats::Statistics)::Bool = length(stats.solutions) > 100

hill_climbing_rule(Schwefel, terminator, [-420, 420]; low= -512.03, high=511.97)




