# IN SOME FUNCTIONS, IT MAY BE NECESSARY TO ADD KEYWORD ARGUMENTS

# using RDatasets
using LinearAlgebra
using RDatasets
using Statistics


computeQ(X, y) = reduce(hcat, [[y[i]*y[j] * sum(X[i, :] .* X[j, :]) for i in range(1, length=size(X)[1])] for j in range(1, length=size(X)[1])])
computeW(X, y, z) = sum([(y[i] * z[i]) .* X[i, :] for i in range(1, length=size(X)[1])])

function solve_SVM_dual(Q, C; max_epoch=100)
    n = size(Q)[1]
    z = zeros(n)
    for _ in range(1, length=max_epoch)
        for i in range(1, length=n)
            z[i] += ((-1 * sum(Q[i, :] .* z) + 1) / Q[i, i])
            z[i] = clamp(z[i], 0, C)
        end
    end
    println(z)
    return z
end

function solve_SVM(X, y, C; kwargs...)
    return computeW(X, y, solve_SVM_dual(computeQ(X, y), C; kwargs...))
end

function iris(C; kwargs...)
    data = dataset("datasets", "iris")
    data = data[data.Species .!= "setosa", :]
    # Prepare "y"
    y = ones(length(data.Species))
    for i in findall(x->x=="virginica", data.Species)
        y[i] = -1
    end
    # Prepare "X"
    X = hcat(data.PetalLength, data.PetalWidth)
    X = (X .- mean(X, dims=2)) ./ std(X, dims=2)
    X = hcat(X, y)
    return solve_SVM(X, y, C; kwargs...)
end

"""
data = dataset("datasets", "iris")
println(data[data.Species .!= "setosa", :])
data = data[data.Species .!= "setosa", :]
println(data)
println(length(data.Species))
println(findall(x->x=="virginica", data.Species))
println(findfirst(isequal("virginica"), data.Species))
X = hcat(data.PetalLength, data.PetalWidth)
X = (X .- mean(X, dims=2)) ./ std(X, dims=2)
X = hcat(X, ones(100))
println(size(X))
println(X)
println(size(computeQ(X, vcat(ones(100), -1 .* ones(100)))))
#y = iris.PetalWidth
#X = hcat(iris.PetalLength, ones(length(y)))



X = [1 2 1 -1 -1 -2; 1 1 2 -1 -2 -1]'
y = [1 1 1 -1 -1 -1]'
z = solve_SVM(X, y, Inf64, max_epoch=100)
println(z)
println(typeof(z))
"""
