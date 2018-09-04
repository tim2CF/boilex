defmodule Mix.Tasks.Boilex.Hex.Publish do

  use Mix.Task

  @open_source_flag "--confirm-public"
  @shortdoc "mix hex.publish wrapper"

  @moduledoc """
  #{@shortdoc}
  Prevents accidental pushing of private code to open-source.

  # Usage
  ```
  # publish to private organization repo
  cd ./myproject
  mix boilex.hex.publish

  # publish to open-source
  cd ./myproject
  mix boilex.hex.publish #{@open_source_flag}
  ```
  """

  @spec run(OptionParser.argv) :: :ok
  def run(args) do

    is_open_source =
      args
      |> case do
        [] -> false
        [@open_source_flag] -> true
      end

    {:ok, {:defmodule, _, [project_module_ast, [do: _]]}} =
      "./mix.exs"
      |> File.read!
      |> Code.string_to_quoted

    {project_module, []} =
      project_module_ast
      |> Code.eval_quoted

    project_module.project[:package][:organization]
    |> case do
      nil when is_open_source ->
        :ok
      organization when is_binary(organization) and (organization != "") and not(is_open_source) ->
        :ok
      organization ->
        "\nOrganization from mix.exs file is #{inspect organization}. If you want to push to open-source, place explicit #{@open_source_flag} flag to cli and remove organization from mix.exs file. If you want to push to private hex.pm repo, provide proper organization name.\n"
        |> raise
    end

    System.cmd("mix", ["hex.publish", "--yes"])
    |> case do
      {debug_log, 0} ->
        Mix.shell.info(debug_log)
      {error_log, exit_code} ->
        "\nhex publish failed with exit code #{exit_code} and message #{error_log}\n"
        |> raise
    end

    :ok
  end

end
