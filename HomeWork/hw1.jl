abstract type BracketingMethod end
 
struct Bisection <: BracketingMethod end
struct RegulaFalsi <: BracketingMethod end

midpoint(method::Bisection, f::Function, a, b) = ((a+b) / 2)
midpoint(method::RegulaFalsi, f::Function, a, b) = ((a * f(b) - b * f(a)) / (f(b) - f(a)))

function findroot(
    method::BracketingMethod, f::Function, a::Real, b::Real; 
    atol::Real = 1e-8, maxiter::Int = 1000
        )
    # Check a < b
    if !(a < b)
        a, b = b, a
    end
    # Check if root is given
    if abs(f(a)) < atol
        return a
    elseif abs(f(b)) < atol
        return b
    end
    # Check sign of a & B
    if sign(f(a)) == sign(f(b))
        throw(DomainError("Error, sign of function($a) is the same as function($b), cannot proceed!"))
    end
    for _ in 1:(maxiter-1)
        c::Real = midpoint(method, f, a, b)
        # Ending condition (near or at root)
        if abs(f(c)) < atol
            return c
        # Swap values
        elseif sign(f(a)) == sign(f(c))
            a = c
        else
            b = c
        end
    end
    return midpoint(method, f, a, b)
end

# f(x) = x^3-x-2
# println(findroot(Bisection(), f, 1, 2))


