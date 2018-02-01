defmodule Mix.Tasks.Boilex.Release do
  use Mix.Task

  @shortdoc "Bumps version, updates changelog and pushes new release"

  @moduledoc """
  #{@shortdoc}
  Argument is release kind: patch | minor | major

  # Usage
  ```
  cd ./myproject
  mix boilex.release patch
  ```
  """

  @spec run(OptionParser.argv) :: :ok
  def run([release_kind]) do
    [major, minor, patch] = "VERSION" |> File.read! |> String.trim |> String.split(".") |> Enum.map(&String.to_integer/1)
    case release_kind do
      "major" -> [major + 1, 0, 0]
      "minor" -> [major, minor + 1, 0]
      "patch" -> [major, minor, patch + 1]
    end
    |> Enum.join(".")
    |> IO.puts
    #
    # TODO
    #
    :ok
  end

end
