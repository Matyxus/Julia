# IN SOME FUNCTIONS, IT MAY BE NECESSARY TO ADD KEYWORD ARGUMENTS

function generate_solutions(f, g, P, x_min, x_max)
    #x_generated = zeros(length(x_min), trunc(Int, (x_max - x_min) / 5) + 1)
    dim = length(x_min)
    step = x_min
    diff = (x_max - x_min) / 100
    result = round.(optim(f, g, x -> P(x, x_min, x_max), step); digits=4)
    step += diff
    while step < x_max
        result = hcat(result, round.(optim(f, g, x -> P(x, x_min, x_max), step); digits=4))
        step += diff
    end
    return unique(result, dims=2)
end

# If you need to write multiple methods based on input types, it is fine.
f_griewank(x) = 1 + 1/4000 * sum(x .^ 2) - prod(cos.(x ./ Array(1: length(x)) .^ 0.5))
g_griewank(x::AbstractVector) = ( (1/2000) * x .+ 
    sin.(x ./ (Array(1: length(x)) .^ 0.5)) ./ 
    ((Array(1: length(x)) .^ 0.5) .* (cos.(x ./ (Array(1: length(x)) .^ 0.5)))) .*
    prod(cos.(x ./ (Array(1: length(x)) .^ 0.5)))
)
g_griewank(x::Real) = 1/2000 * x + sin(x)

function optim(f, g, P, x; α=0.01, max_iter=10000)
    for _ in 1:max_iter
        y = x - α*g(x)
        x = P(y)
    end
    return x
end
 
P(x, x_min, x_max) = min.(max.(x, x_min), x_max)
