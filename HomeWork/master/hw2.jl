abstract type Agent end
abstract type Animal <: Agent end
abstract type Plant <: Agent end

mutable struct Grass <: Plant
    const id::Int
    size::Int
    const max_size::Int
end

mutable struct Sheep <: Animal
    const id::Int
    energy::Float64
    const Δenergy::Float64
    const reprprob::Float64
    const foodprob::Float64
end

mutable struct Wolf <: Animal
    const id::Int
    energy::Float64
    const Δenergy::Float64
    const reprprob::Float64
    const foodprob::Float64
end

mutable struct World{A<:Agent}
    agents::Dict{Int,A}
    max_id::Int
end

function Base.show(io::IO, g::Grass)
    x = g.size/g.max_size * 100
    # hint: to type the leaf in the julia REPL you can do:
    # \:herb:<tab>
    print(io,"🌿 #$(g.id) $(round(Int,x))% grown")
end

function Base.show(io::IO, s::Sheep)
    e = s.energy
    d = s.Δenergy
    pr = s.reprprob
    pf = s.foodprob
    print(io,"🐑 #$(s.id) E=$e ΔE=$d pr=$pr pf=$pf")
end

function Base.show(io::IO, w::Wolf)
    e = w.energy
    d = w.Δenergy
    pr = w.reprprob
    pf = w.foodprob
    print(io,"🐺 #$(w.id) E=$e ΔE=$d pr=$pr pf=$pf")
end

# optional: overload Base.show
function Base.show(io::IO, w::World)
    println(io, typeof(w))
    for (_,a) in w.agents
        println(io,"  $a")
    end
end


Grass(id,m=10) = Grass(id, rand(1:m), m)
Sheep(id, e=4.0, Δe=0.2, pr=0.8, pf=0.6) = Sheep(id,e,Δe,pr,pf)
Wolf(id, e=10.0, Δe=8.0, pr=0.1, pf=0.2) = Wolf(id,e,Δe,pr,pf)

function World(agents::Vector{<:Agent})
    max_id = maximum(a.id for a in agents)
    World(Dict(a.id=>a for a in agents), max_id)
end

function eat!(sheep::Sheep, grass::Grass, w::World)
    sheep.energy += grass.size * sheep.Δenergy
    grass.size = 0
end

function eat!(wolf::Wolf, sheep::Sheep, w::World)
    wolf.energy += sheep.energy * wolf.Δenergy
    kill_agent!(sheep,w)
end

kill_agent!(a::Agent, w::World) = delete!(w.agents, a.id)

function reproduce!(a::A, w::World) where A<:Animal
    a.energy = a.energy/2
    a_vals = [getproperty(a,n) for n in fieldnames(A) if n!=:id]
    new_id = w.max_id + 1
    â = A(new_id, a_vals...)
    w.agents[â.id] = â
    w.max_id = new_id
end

agent_count(A::Agent)::Float64 = (typeof(A) <: Animal) ? 1.0 : (A.size / A.max_size)
agent_count(agents::Vector{<:Agent}) = sum(agent_count.(agents))

function agent_count(w::World)::Dict{Symbol, Float64}
    ret_val::Dict{Symbol, Float64} = Dict{Symbol, Float64}()
    for agent in values(w.agents)
        symbol::Symbol = nameof(typeof(agent))
        if haskey(ret_val, symbol)
            ret_val[symbol] += agent_count(agent)
        else
            ret_val[symbol] = agent_count(agent)
        end
    end
    return ret_val
end

"""
grass1 = Grass(1,5,5);
grass2 = Grass(2,1,5);
sheep = Sheep(3,10.0,5.0,1.0,1.0);
wolf  = Wolf(4,20.0,10.0,1.0,1.0);
world = World([grass1, grass2, sheep, wolf]);

println(agent_count(grass1))
println(agent_count(grass2))
println(agent_count([grass1, grass2]))
println(agent_count(wolf))
println(agent_count(world))
"""

