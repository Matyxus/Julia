using TSP
using Test

@testset "TSP.jl" begin
    # Write your tests here.
    @testset "File Loading" begin
        @test !isnothing(load_data("ga"))
        @test !isnothing(load_data("sa"))
        @test isnothing(load_data("?"))
    end

    @testset "Cities" begin
        cities = Dict{String, Any}(
            "start" => "a",
            "position" => Dict{String, Any}(
                "a" => [1, 2],
                "b" => [4, 1],
                "c" => [1, 8],
                "d" => [14, 1],
                "e" => [4, 10],
                "f" => [6, 7],
                "g" => [8, 2],
                "h" => [9, 10]
            )
        )
        @testset "CityManager" begin
            # Non existing starting city
            cities["start"] = "p"
            @test_throws KeyError CityManager(cities)
            # Missing key
            pop!(cities, "start")
            @test_throws KeyError CityManager(cities)
            cities["start"] = "a"
            # Wrong value in vector of positions
            cities["position"]["a"] = [1, "a"]
            @test_throws ErrorException CityManager(cities)
            # Check that matrix is symmetric
            cities["position"]["a"] = [1, 2]
            manager = CityManager(cities)
            @test all(isapprox.(manager.dist_matrix - manager.dist_matrix', 0; rtol=1e-10))
        end
        @testset "Route" begin
            manager = CityManager(cities)
            route = get_random_route(manager)
            @test !(manager.starting_city in route.path)
            @test unique(route.path) == route.path
        end
    end


    @testset "GeneticAlgorithm" begin
        @testset "crossover" begin
            parentA = [5, 7, 1, 3, 6, 4, 2]
            parentB = [4, 6, 2, 7, 3, 1, 5]
            inverseA = TravelingSalesman.get_inverse(parentA)
            inverseB = TravelingSalesman.get_inverse(parentB)
            # Test if inverse of sequence gets transformed back to original
            @test TravelingSalesman.get_permutation(inverseA) == parentA
            @test TravelingSalesman.get_permutation(inverseB) == parentB
            children = TravelingSalesman.crossover(Route(parentA), Route(parentB), 1.0)
            # Test children created by crossover
            @test unique(children.first.path) == children.first.path && length(children.first.path) == length(parentA)
            @test unique(children.second.path) == children.second.path && length(children.second.path) == length(parentA)
        end
    end
    
end

