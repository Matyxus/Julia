<div id="top"></div>


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h3 align="center">Traveling Sales Man</h3>
  <p align="center">
    Project showcasing algorithms capable of solving TSP.
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#Libraries">Libraries</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li>
      <a href="#usafe">Usage</a>
      <ul>
        <li><a href="#description">Description</a></li>
        <li><a href="#Algorithms">Algorithms</a></li>
      </ul>
    </li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

Project solving the [TSP](https://en.wikipedia.org/wiki/Travelling_salesman_problem) problem 
using iterative algorithms \
to achieve good solution (non-optimal) in reasonable amount of time.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

### Libraries

* [Random](https://docs.julialang.org/en/v1/stdlib/Random/)
* [Revise](https://timholy.github.io/Revise.jl/stable/)
* [Dates](https://docs.julialang.org/en/v1/stdlib/Dates/)
* [JSON](https://github.com/JuliaIO/JSON.jl)

### Installation

Use [Pkg](https://docs.julialang.org/en/v1/stdlib/Pkg/) to install project from GitHub.
```julia
(env) pkg> add https://github.com/Matyxus/julia
```

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage
To use the project, there is file Main.jl in [main](./src/Main.jl) folder.
This file provides the function *main*, and is used as follows:
```julia
using TravelingSalesman
file_name::String = "ga"
main(file_name)
```
Where *file_name* is the name of file located inside [data](./data) folder, which
provides all input related variables.


### Description
Files containing input of program are of type ".json", each algorithm has its own parameters  
e.g. GeneticAlgorithm has elitism, population, etc. 
In file there is also "seed" provided to keep the results \
always the same (for given seed), which are (if allowed) saved in
[logs](./src/logs) folder as ".json" files.

### Algorithms

There are 2 algorithms provided to solve the TSP:
1. [GeneticAlgorithm](./src/GeneticAlgorithm.jl)\
inspired by: https://en.wikipedia.org/wiki/Genetic_algorithm \
https://www.youtube.com/watch?v=hnxn6DtLYcY, \
https://www.youtube.com/watch?v=XP8R0yzAbdo \
crossover implemented by: https://user.ceng.metu.edu.tr/~ucoluk/research/publications/tspnew.pdf

3. [SimulatedAnnealing](./src/SimulatedAnnealing.jl) - https://en.wikipedia.org/wiki/Simulated_annealing


<p align="right">(<a href="#top">back to top</a>)</p>
