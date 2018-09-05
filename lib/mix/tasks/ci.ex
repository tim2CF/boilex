[
  %{
    module: Mix.Tasks.Boilex.Ci.Docker.Build,
    description: "Builds application docker image",
    script: "docker-build.sh",
  },
  %{
    module: Mix.Tasks.Boilex.Ci.Docker.Push,
    description: "Pushes application docker image to dockerhub",
    script: "docker-push.sh",
  },
  %{
    module: Mix.Tasks.Boilex.Ci.Docker.Client.Install,
    description: "Installs docker client",
    script: "install-docker-client.sh",
  },
]
|> Enum.each(fn(%{module: module, description: description, script: script}) ->

  <<"elixir.", mix_command::binary>> = module |> Atom.to_string |> String.downcase

  defmodule module do
    use Mix.Task

    @shortdoc description
    @moduledoc """
    #{description}

    # Usage
    ```
    cd ./myproject
    mix #{mix_command} $args
    ```
    """

    @spec run(OptionParser.argv) :: :ok
    def run(args) do
      "#{:code.priv_dir :boilex}/#{unquote(script)}"
      |> System.cmd(args)
      |> case do
        {_, 0} ->
          Mix.shell.info("mix task #{unquote(mix_command)} finished successfully")
        {msg, code} ->
          """
          mix task #{unquote(mix_command)} finished with status #{code}, console output:

          #{msg}
          """
          |> raise
      end
    end
  end

end)
