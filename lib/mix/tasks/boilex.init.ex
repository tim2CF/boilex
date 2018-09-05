defmodule Mix.Tasks.Boilex.Init do
  use Mix.Task
  import Mix.Generator
  import Boilex.Utils

  @shortdoc "Creates new configuration files for Elixir project dev tools"

  @moduledoc """
  Creates new (or updates old) configuration files for Elixir dev tools and scripts.

  # Usage
  ```
  cd ./myproject
  mix boilex.init
  ```
  """

  @spec run(OptionParser.argv) :: :ok
  def run(_) do

    include_postgres = Mix.shell.yes?("Are you using Postgres database?")
    include_hex_auth = Mix.shell.yes?("Are you using private hex.pm?")
    hex_organization = fetch_hex_organization_name(include_hex_auth)
    include_coveralls_push = Mix.shell.yes?("Do you want to push test coverage results to https://coveralls.io/ web service?")

    assigns = [
                # from user
                include_postgres:       include_postgres,
                include_hex_auth:       include_hex_auth,
                hex_organization:       hex_organization,
                include_coveralls_push: include_coveralls_push,
                # automated
                otp_application:        fetch_otp_application_name(),
                erlang_cookie:          (32 |> :crypto.strong_rand_bytes |> Base.encode64),
                elixir_version:         fetch_elixir_version(),
              ]

    # priv dir for usage in Elixir code
    create_directory  "priv"
    # generate dev tools configs
    :ok = Boilex.Generator.DevTools.run(assigns)
    # generate docker-related files
    :ok = Boilex.Generator.Docker.run(assigns)
    # generate local dev scripts
    :ok = Boilex.Generator.Scripts.run(assigns)
    # generate circleci configs
    :ok = Boilex.Generator.Circleci.run(assigns)
    # print instructions in STDOUT
    :ok = todo_instructions_template(assigns) |> Mix.shell.info
  end

  #
  # priv
  #

  defp fetch_hex_organization_name(true) do
    "Please type hex.pm organization name>"
    |> Mix.shell.prompt
    |> String.trim
    |> case do
      "" ->
        fetch_hex_organization_name(true)
      name when is_binary(name) ->
        name
    end
  end
  defp fetch_hex_organization_name(false) do
    "$HEX_ORGANIZATION"
  end

  defp fetch_otp_application_name do

    config =
      Mix.Project.config

    config
    |> Keyword.keyword?
    |> case do
      true ->
        config
        |> Keyword.get(:app)
        |> case do
          name when is_atom(name) and (name != nil) ->
            name
          name ->
            raise("wrong OTP application name #{inspect name}")
        end
      false ->
        raise("wrong Mix.Project.config value #{inspect config}")
    end
  end

  embed_template :todo_instructions, """
  #{IO.ANSI.magenta}
  *****************
  !!! IMPORTANT !!!
  *****************

  ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

  #{IO.ANSI.cyan}
  REPLACE `version` LINE OF `project` FUNCTION IN `mix.exs` FILE WITH
  #{IO.ANSI.green}


    version: ("VERSION" |> File.read! |> String.trim),


  #{IO.ANSI.cyan}
  ADD THE FOLLOWING PARAMETERS TO `project` FUNCTION IN `mix.exs` FILE
  #{IO.ANSI.green}


    # excoveralls
    test_coverage:      [tool: ExCoveralls],
    preferred_cli_env:  [
      coveralls:              :test,
      "coveralls.travis":     :test,
      "coveralls.circle":     :test,
      "coveralls.semaphore":  :test,
      "coveralls.post":       :test,
      "coveralls.detail":     :test,
      "coveralls.html":       :test,
    ],
    # dialyxir
    dialyzer: [
      ignore_warnings: ".dialyzer_ignore",
      plt_add_apps: [
        :mix,
        :ex_unit,
      ]
    ],
    # ex_doc
    name:         "<%= @otp_application |> Atom.to_string |> Macro.camelize %>",
    source_url:   "TODO_PUT_HERE_GITHUB_URL",
    homepage_url: "TODO_PUT_HERE_GITHUB_URL",
    docs:         [main: "readme", extras: ["README.md"]],
    # hex.pm stuff
    description:  "TODO_ADD_DESCRIPTION",
    package: [
      licenses: ["Apache 2.0"],
      files: ["lib", "priv", "mix.exs", "README*", "VERSION*"],
      maintainers: ["TODO_ADD_MAINTAINER"],
      links: %{
        "GitHub" => "TODO_PUT_HERE_GITHUB_URL",
        "Author's home page" => "TODO_PUT_HERE_HOMEPAGE_URL",
      }
    ],


  #{IO.ANSI.cyan}
  ADD THE FOLLOWING PARAMETERS TO `deps` FUNCTION IN `mix.exs` FILE
  #{IO.ANSI.green}


    # development tools
    {:excoveralls, "~> 0.8", runtime: false},
    {:dialyxir, "~> 0.5",    runtime: false},
    {:ex_doc, "~> 0.19",     runtime: false},
    {:credo, "~> 0.9",       runtime: false},
    {:boilex, "~> 0.2",      runtime: false},


  #{IO.ANSI.cyan}
  If your project is OTP application (not just library),
  probably you would like to add `stop` function to your
  `application.ex` file to prevent situations when
  erlang node continue to run while your
  application has been stopped (because of some reason). Example:
  #{IO.ANSI.green}


    def stop(reason) do
      "\#{__MODULE__} application is stopped, trying to shutdown erlang node ..."
      |> Logger.error([reason: reason])
      :init.stop()
    end


  #{IO.ANSI.cyan}
  ADD THE FOLLOWING LINES TO `.gitignore` FILE
  #{IO.ANSI.green}


    /doc
    /cover
    /.elixir_ls


  #{IO.ANSI.cyan}
  Please configure `scripts/.env` file if you want to use distributed erlang features in development process.

  #{IO.ANSI.magenta}

  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

  *****************
  !!! IMPORTANT !!!
  *****************
  #{IO.ANSI.reset}
  """

end
