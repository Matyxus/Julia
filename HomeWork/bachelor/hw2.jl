# IN SOME FUNCTIONS, IT MAY BE NECESSARY TO ADD KEYWORD ARGUMENTS

function generate_solutions(
    f, g, P, 
    x_min, x_max
        )
    result = round.(optim(f, g, x -> P(x, x_min, x_max), x_min); digits=4)
    # 100 points between each point
    step = (x_max - x_min) / 100
    current = x_min + step
    while current < x_max
        result = hcat(result, round.(optim(f, g, x -> P(x, x_min, x_max), current); digits=4))
        current += step
    end
    return unique(result, dims=2)
end


# If you need to write multiple methods based on input types, it is fine.
f_griewank(x) = (
    1 + (1/4000) * sum(x .^ 2) - prod(cos.(x ./ (Array(1: length(x)) .^ 0.5)))
)
# sum(v -> v^2, v) == sum(2 .^ x)


g_griewank(x::AbstractVector) = ( 
    (1/2000) * x .+ 
    sin.(x ./ (Array(1: length(x)) .^ 0.5)) ./ 
    ((Array(1: length(x)) .^ 0.5) .* (cos.(x ./ (Array(1: length(x)) .^ 0.5)))) .*
    prod(cos.(x ./ (Array(1: length(x)) .^ 0.5)))
)
g_griewank(x::Real) = 1/2000 * x + sin(x)

#println(f_griewank([1, 2, 3]))
#println(g_griewank(1))

function optim(f, g, P, x; α = 0.01, max_iter = 10000)
    for _ in 1:max_iter
        y = x - α*g(x)
        x = P(y)
    end
    return x
end


P(x, x_min, x_max) = min.(max.(x, x_min), x_max)
#x = [1; 2; 3]
#x_min = [0; 0; 0]
#x_max = [2; 2; 2]
#println(P(x, x_min, x_max))
# println(optim(f_griewank, g_griewank, P, 10))

#i = 2
#println(union(Array(1: i-1), Array(i+1: 5)))
#println(round.([56.7685, 56.7685, 58.21234]; digits = 3))


#for (i, j) in zip([1, 2], [4, 5])
#    println(i)
#    println(j)
#end

#println(Array(1:0.1:3))


#println(unique([1, 2, 3, 4, 5, 5, 4, 3, 8]))
