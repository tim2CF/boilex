# Boilex

Boilex is tool to generate Elixir project configuration boilerplate.

## Installation

Add the following parameters to `deps` function in `mix.exs` file

```
{:boilex, github: "tim2CF/boilex", only: [:dev, :test], runtime: false},
```

## Usage

```
cd ./myproject
mix boilex.new
```
