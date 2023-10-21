function circlemat(n::Int)::AbstractMatrix{Int}
    ret_val::Matrix{Int} = zeros(Int64, n, n)
    # Fill diagonals around main diagonal with ones
    for i in 1:(n-1)
        ret_val[i, i+1] = 1
        ret_val[i+1, i] = 1
    end
    # Fill corners of matrix with one
    ret_val[1, n] = 1
    ret_val[n, 1] = 1
    return ret_val
end


function polynomial(a, x)
    accumulator = (typeof(x) <: AbstractMatrix) ? zeros(eltype(x), size(x)) : 0
    for i in length(a):-1:1
        accumulator += x^(i-1) * a[i]
    end
    return accumulator
end

# a = [-19, 7, -4, 6]

