defmodule Boilex.MixProject do
  use Mix.Project

  def project do
    [
      app: :boilex,
      version: ("VERSION" |> File.read! |> String.trim),
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      description: "Elixir project configurator (pre-commit hooks, scripts, coverage, documentation, dev tools)",
      source_url: "https://github.com/tim2CF/boilex",
      package: [
        licenses: ["Apache 2.0"],
        files: ["lib", "priv", "mix.exs", "README*", "LICENSE*", "VERSION*"],
        maintainers: ["Ilja Tkachuk aka timCF"],
        links: %{
          "GitHub" => "https://github.com/tim2CF/boilex",
          "Author's home page" => "https://timcf.github.io/"
        }
      ],
      # Docs
      name: "Boilex",
      docs: [main: "readme", extras: ["README.md"]],

    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
    ]
  end
end
