defmodule Mix.Tasks.Boilex.New do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Creates new configuration files for Elixir project dev tools"

  @moduledoc """
  Creates new configuration files for Elixir project dev tools.
  Usage
  ```
  cd ./myproject
  mix boilex.new
  ```
  """

  @spec run(OptionParser.argv) :: :ok
  def run(_) do
    create_directory  "priv"
    create_directory  "scripts"
    create_file       "coveralls.json", coveralls_simple_text()
    create_file       ".credo.exs", credo_text()
    create_file       ".dialyzer_ignore", dialyzer_ignore_text()
    create_file       "scripts/.env", env_text()
    create_script     "scripts/pre-commit.sh", pre_commit_text()
    create_script     "scripts/remote-iex.sh", remote_iex_text()
    create_script     "scripts/cluster-iex.sh", cluster_iex_text()
    :ok = todo_instructions() |> Mix.shell.info
  end

  embed_text :coveralls_simple, """
  {
    "coverage_options": {
      "treat_no_relevant_lines_as_covered": false,
      "minimum_coverage": 100
    },
    "skip_files": [

    ]
  }
  """

  embed_text :credo, """
  %{
    #
    # You can have as many configs as you like in the `configs:` field.
    configs: [
      %{
        #
        # Run any exec using `mix credo -C <name>`. If no exec name is given
        # "default" is used.
        #
        name: "default",
        #
        # These are the files included in the analysis:
        files: %{
          #
          # You can give explicit globs or simply directories.
          # In the latter case `**/*.{ex,exs}` will be used.
        #
          included: ["lib/", "src/", "web/", "apps/"],
          excluded: [~r"/_build/", ~r"/deps/"]
        },
        #
        # If you create your own checks, you must specify the source files for
        # them here, so they can be loaded by Credo before running the analysis.
        #
        requires: [],
        #
        # Credo automatically checks for updates, like e.g. Hex does.
        # You can disable this behaviour below:
        #
        check_for_updates: true,
        #
        # If you want to enforce a style guide and need a more traditional linting
        # experience, you can change `strict` to `true` below:
        #
        strict: true,
        #
        # If you want to use uncolored output by default, you can change `color`
        # to `false` below:
        #
        color: true,
        #
        # You can customize the parameters of any check by adding a second element
        # to the tuple.
        #
        # To disable a check put `false` as second element:
        #
        #     {Credo.Check.Design.DuplicatedCode, false}
        #
        checks: [
          {Credo.Check.Consistency.ExceptionNames},
          {Credo.Check.Consistency.LineEndings},
          {Credo.Check.Consistency.ParameterPatternMatching},
          {Credo.Check.Consistency.SpaceAroundOperators},
          {Credo.Check.Consistency.SpaceInParentheses},
          {Credo.Check.Consistency.TabsOrSpaces},

          # For some checks, like AliasUsage, you can only customize the priority
          # Priority values are: `low, normal, high, higher`
          #
          {Credo.Check.Design.AliasUsage, priority: :low, exit_status: 0},

          # For others you can set parameters

          # If you don't want the `setup` and `test` macro calls in ExUnit tests
          # or the `schema` macro in Ecto schemas to trigger DuplicatedCode, just
          # set the `excluded_macros` parameter to `[:schema, :setup, :test]`.
          #
          {Credo.Check.Design.DuplicatedCode, excluded_macros: []},

          # You can also customize the exit_status of each check.
          # If you don't want TODO comments to cause `mix credo` to fail, just
          # set this value to 0 (zero).
          #
          {Credo.Check.Design.TagTODO, priority: :low, exit_status: 0},
          {Credo.Check.Design.TagFIXME, priority: :low, exit_status: 0},

          {Credo.Check.Readability.FunctionNames},
          {Credo.Check.Readability.LargeNumbers},
          {Credo.Check.Readability.MaxLineLength, priority: :normal, max_length: 120, exit_status: 0},
          {Credo.Check.Readability.ModuleAttributeNames},
          {Credo.Check.Readability.ModuleDoc, false},
          {Credo.Check.Readability.ModuleNames, priority: :high},
          {Credo.Check.Readability.ParenthesesOnZeroArityDefs, priority: :high},
          {Credo.Check.Readability.ParenthesesInCondition, priority: :high},
          {Credo.Check.Readability.PredicateFunctionNames, priority: :high},
          {Credo.Check.Readability.PreferImplicitTry, false},
          {Credo.Check.Readability.RedundantBlankLines, priority: :low},
          {Credo.Check.Readability.StringSigils},
          {Credo.Check.Readability.TrailingBlankLine},
          {Credo.Check.Readability.TrailingWhiteSpace},
          {Credo.Check.Readability.VariableNames},
          {Credo.Check.Readability.Semicolons},
          {Credo.Check.Readability.SpaceAfterCommas, priority: :low},

          {Credo.Check.Refactor.DoubleBooleanNegation, priority: :high},
          {Credo.Check.Refactor.CondStatements},
          {Credo.Check.Refactor.CyclomaticComplexity, priority: :high, exit_status: 2, max_complexity: 12},
          {Credo.Check.Refactor.FunctionArity},
          {Credo.Check.Refactor.LongQuoteBlocks},
          {Credo.Check.Refactor.MatchInCondition},
          {Credo.Check.Refactor.NegatedConditionsInUnless, priority: :high, exit_status: 2},
          {Credo.Check.Refactor.NegatedConditionsWithElse, priority: :normal},
          {Credo.Check.Refactor.Nesting, max_nesting: 3, priority: :high, exit_status: 2},
          {Credo.Check.Refactor.PipeChainStart, false},
          {Credo.Check.Refactor.UnlessWithElse, priority: :higher, exit_status: 2},

          {Credo.Check.Warning.BoolOperationOnSameValues, priority: :high, exit_status: 2},
          {Credo.Check.Warning.IExPry, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.IoInspect, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.LazyLogging, false},
          {Credo.Check.Warning.OperationOnSameValues, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.OperationWithConstantResult, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedEnumOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedFileOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedKeywordOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedListOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedPathOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedRegexOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedStringOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedTupleOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.RaiseInsideRescue, priority: :higher, exit_status: 2},

          # Controversial and experimental checks (opt-in, just remove `, false`)
          #
          {Credo.Check.Refactor.ABCSize, false},
          {Credo.Check.Refactor.AppendSingleItem, priority: :normal},
          {Credo.Check.Refactor.VariableRebinding, priority: :normal},
          {Credo.Check.Warning.MapGetUnsafePass, priority: :high, exit_status: 0},
          {Credo.Check.Consistency.MultiAliasImportRequireUse, priority: :normal, exit_status: 0},

          # Deprecated checks (these will be deleted after a grace period)
          #
          {Credo.Check.Readability.Specs, false},
          {Credo.Check.Warning.NameRedeclarationByAssignment, false},
          {Credo.Check.Warning.NameRedeclarationByCase, priority: :normal},
          {Credo.Check.Warning.NameRedeclarationByDef, priority: :normal},
          {Credo.Check.Warning.NameRedeclarationByFn, priority: :normal},

          # Custom checks can be created using `mix credo.gen.check`.
          #
        ]
      }
    ]
  }
  """

  embed_text :dialyzer_ignore, """
  Any dialyzer's error output lines putted to this text file will be completely ignored by dialyzer's type checks.
  Please not abuse this file, type checks are VERY important.
  Use this file just in case of bad 3rd party auto-generated code.
  """

  embed_text :env, """
  ERLANG_HOST=
  ERLANG_APPLICATION=
  ERLANG_COOKIE =
  """

  embed_text :pre_commit, """
  #!/bin/sh

  set -e
  export MIX_ENV=test

  mix deps.get
  mix deps.compile
  mix compile --warnings-as-errors
  mix credo --strict
  mix coveralls.html
  mix docs

  if [ -v $ENABLE_DIALYZER ]
  then
    mix dialyzer --halt-exit-status
  fi

  echo "Congratulations! Pre-commit hook checks passed!"
  """

  embed_text :remote_iex, """
  #!/bin/sh

  set -e
  export $(cat .env.dev | xargs)

  iex \
    --remsh "$ERLANG_APPLICATION@$ERLANG_HOST" \
    --name "$USER-remote-$(date +%s)@$ERLANG_HOST" \
    --cookie "$ERLANG_COOKIE" \
    --erl "+K true +A 32" \
    --erl "-kernel inet_dist_listen_min 9100" \
    --erl "-kernel inet_dist_listen_max 9199"
  """

  embed_text :cluster_iex, """
  #!/bin/sh

  set -e
  export $(cat .env.dev | xargs)

  iex \
    --name "$USER-local-$(date +%s)@$ERLANG_HOST" \
    --cookie "$ERLANG_COOKIE" \
    --erl "+K true +A 32" \
    --erl "-kernel inet_dist_listen_min 9100" \
    --erl "-kernel inet_dist_listen_max 9199" \
    -pa "_build/dev/consolidated/" \
    -e ":timer.sleep(5000); Node.connect(:\"$ERLANG_APPLICATION@$ERLANG_HOST\")" \
    -S mix

  # To push local App.Module module bytecode to remote erlang node run
  #
  # nl(App.Module)
  #
  """

  defp todo_instructions do
    """

    *****************
    !!! IMPORTANT !!!
    *****************

    Add the following parameters to `project` function in `mix.exs` file

      # excoveralls
      test_coverage:      [tool: ExCoveralls],
      preferred_cli_env:  [
        "coveralls":            :test,
        "coveralls.travis":     :test,
        "coveralls.circle":     :test,
        "coveralls.semaphore":  :test,
        "coveralls.post":       :test,
        "coveralls.detail":     :test,
        "coveralls.html":       :test,
      ],
      # dialyxir
      dialyzer:     [ignore_warnings: ".dialyzer_ignore"],
      # ex_doc
      name:         "ELIXIR_APPLICATION_NAME",
      source_url:   "GITHUB_URL",
      homepage_url: "GITHUB_URL",
      docs:         [main: "ELIXIR_APPLICATION_NAME", extras: ["README.md"]],

    Add the following parameters to `deps` function in `mix.exs` file

      # development tools
      {:excoveralls, "~> 0.8",            only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5",               only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.18",                only: [:dev, :test], runtime: false},
      {:credo, "~> 0.8",                  only: [:dev, :test], runtime: false},
      {:boilex, github: "tim2CF/boilex",  only: [:dev, :test], runtime: false},

    Please configure `scripts/.env` file if you want to use distributed erlang features in development process.

    *****************
    !!! IMPORTANT !!!
    *****************
    """
  end

  defp create_script(name, value) do
    create_file       name, value
    :ok = File.chmod  name, 0o755
  end

end
