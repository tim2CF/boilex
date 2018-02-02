defmodule Mix.Tasks.Boilex.Init do
  use Mix.Task
  import Mix.Generator

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

    otp_application = fetch_otp_application_name()
    erlang_cookie   = :crypto.strong_rand_bytes(32) |> Base.encode64
    assigns         = [otp_application: otp_application, erlang_cookie: erlang_cookie]

    # priv dir for usage in Elixir code
    create_directory  "priv"
    # dev tools configs
    create_file       "VERSION",                version_text()
    create_file       "CHANGELOG.md",           changelog_text()
    create_file       "coveralls.json",         coveralls_simple_text()
    create_file       ".credo.exs",             credo_text()
    create_file       ".dialyzer_ignore",       dialyzer_ignore_text()
    create_file       ".editorconfig",          editorconfig_text()
    # docker stuff
    create_file       "Dockerfile",             dockerfile_text()
    create_file       "docker-compose.yml",     docker_compose_template(assigns)
    # local dev scripts
    create_directory  "scripts"
    create_file       "scripts/.env",           env_template(assigns)
    create_script     "scripts/pre-commit.sh",  pre_commit_text()
    create_script     "scripts/remote-iex.sh",  remote_iex_text()
    create_script     "scripts/cluster-iex.sh", cluster_iex_text()
    create_script     "scripts/check-vars.sh",  check_vars_text()
    create_script     "scripts/docs.sh",        docs_text()
    create_script     "scripts/coverage.sh",    coverage_text()
    create_script     "scripts/start.sh",       start_text()
    # circleci
    create_directory  ".circleci"
    create_file       ".circleci/config.yml",   circleci_config_text()
    # instructions
    :ok = todo_instructions() |> Mix.shell.info
  end

  #
  # dev tools configs
  #

  embed_text :version, """
  0.1.0
  """

  embed_text :changelog, ""

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

  embed_text :editorconfig, """
  # Editor configuration file
  # For Emacs install package `editorconfig`
  # For Atom install package `editorconfig`
  # For Sublime Text install package `EditorConfig`
  root = true

  [*]
  indent_style = space
  indent_size = 2
  end_of_line = lf
  charset = utf-8
  trim_trailing_whitespace = true
  insert_final_newline = true
  max_line_length = 100

  [*.md]
  indent_style = space
  indent_size = 2

  [*.yml]
  indent_style = space
  indent_size = 2

  [*.json]
  indent_style = space
  indent_size = 2
  """

  #
  # docker stuff
  #

  embed_text :dockerfile, """
  FROM elixir:1.6
  MAINTAINER DEFINE_ME

  # inotify-tools is dep for hot code-reloading, useful for development
  RUN apt-get update && apt-get install -y libssl1.0.0 inotify-tools

  WORKDIR /app

  COPY . .

  RUN rm -rf ./_build/ && \\
      mix do local.hex --force, local.rebar --force && \\
      MIX_ENV=staging mix compile.protocols && \\
      MIX_ENV=prod  mix compile.protocols

  CMD echo "Checking system variables..." && \\
      scripts/check-vars.sh "in system" "MIX_ENV" "ERLANG_OTP_APPLICATION" "ERLANG_HOST" "ERLANG_MIN_PORT" "ERLANG_MAX_PORT" "ERLANG_MAX_PROCESSES" "ERLANG_COOKIE" && \\
      echo "Running app..." && \\
      elixir \\
        --name "$ERLANG_OTP_APPLICATION@$ERLANG_HOST" \\
        --cookie "$ERLANG_COOKIE" \\
        --erl "+K true +A 32 +P $ERLANG_MAX_PROCESSES" \\
        --erl "-kernel inet_dist_listen_min $ERLANG_MIN_PORT" \\
        --erl "-kernel inet_dist_listen_max $ERLANG_MAX_PORT" \\
        -pa "_build/$MIX_ENV/consolidated/" \\
        -S mix run \\
        --no-halt
  """

  embed_template :docker_compose, """
  version: "3"

  services:
    main:
      image: "<%= @otp_application %>:latest"
      ports:
        - "6666:4369"
        - "9100-9105:9100-9105"
      environment:
        MIX_ENV: staging
        ERLANG_OTP_APPLICATION: "<%= @otp_application %>"
        ERLANG_HOST: "${DOCKER_HOST}"
        ERLANG_MIN_PORT: 9100
        ERLANG_MAX_PORT: 9105
        ERLANG_MAX_PROCESSES: 1000000
        ERLANG_COOKIE: "<%= @erlang_cookie %>"
      networks:
        - default
      deploy:
        resources:
          limits:
            memory: 4096M
          reservations:
            memory: 2048M
        restart_policy:
          condition: on-failure
          delay: 5s
  """

  #
  # local dev scripts
  #

  embed_template :env, """
  ERLANG_HOST=
  ERLANG_OTP_APPLICATION="<%= @otp_application %>"
  ERLANG_COOKIE="<%= @erlang_cookie %>"
  ENABLE_DIALYZER=false
  CONFLUENCE_SUBDOMAIN=
  CONFLUENCE_PAGE_ID=
  """

  embed_text :pre_commit, """
  #!/bin/bash

  set -e
  export MIX_ENV=test

  if [[ -L "$0" ]] && [[ -e "$0" ]] ; then
    script_file="$(readlink "$0")"
  else
    script_file="$0"
  fi

  scripts_dir="$(dirname -- "$script_file")"
  export $(cat "$scripts_dir/.env" | xargs)
  "$scripts_dir/check-vars.sh" "in scripts/.env file" "ENABLE_DIALYZER"

  mix deps.get
  mix deps.compile
  mix compile --warnings-as-errors
  mix credo --strict
  mix coveralls.html
  mix docs

  if [ "$ENABLE_DIALYZER" = true ] ; then
    mix dialyzer --halt-exit-status
  fi

  echo "Congratulations! Pre-commit hook checks passed!"
  """

  embed_text :remote_iex, """
  #!/bin/bash

  set -e

  script_file="$0"
  scripts_dir="$(dirname -- "$script_file")"
  export $(cat "$scripts_dir/.env" | xargs)
  "$scripts_dir/check-vars.sh" "in scripts/.env file" "ERLANG_HOST" "ERLANG_OTP_APPLICATION" "ERLANG_COOKIE"

  iex \\
    --remsh "$ERLANG_OTP_APPLICATION@$ERLANG_HOST" \\
    --name "$USER-remote-$(date +%s)@$ERLANG_HOST" \\
    --cookie "$ERLANG_COOKIE" \\
    --erl "+K true +A 32" \\
    --erl "-kernel inet_dist_listen_min 9100" \\
    --erl "-kernel inet_dist_listen_max 9199"
  """

  embed_text :cluster_iex, """
  #!/bin/bash

  set -e

  script_file="$0"
  scripts_dir="$(dirname -- "$script_file")"
  export $(cat "$scripts_dir/.env" | xargs)
  "$scripts_dir/check-vars.sh" "in scripts/.env file" "ERLANG_HOST" "ERLANG_OTP_APPLICATION" "ERLANG_COOKIE"

  iex \\
    --name "$USER-local-$(date +%s)@$ERLANG_HOST" \\
    --cookie "$ERLANG_COOKIE" \\
    --erl "+K true +A 32" \\
    --erl "-kernel inet_dist_listen_min 9100" \\
    --erl "-kernel inet_dist_listen_max 9199" \\
    -pa "_build/dev/consolidated/" \\
    -e ":timer.sleep(5000); Node.connect(:\\"$ERLANG_OTP_APPLICATION@$ERLANG_HOST\\")" \\
    -S mix

  # To push local App.Module module bytecode to remote erlang node run
  #
  # nl(App.Module)
  #
  """

  embed_text :check_vars, """
  #!/bin/bash

  set -e

  arguments=( "$@" )
  variables=( "${arguments[@]:1}" )
  message="${arguments[0]}"

  for varname in "${variables[@]}"
  do
    if [[ -z "${!varname}" ]]; then
        echo "\\nplease set variable $varname $message\\n"
        exit 1
    fi
  done
  """

  embed_text :docs, """
  #!/bin/bash

  set -e

  mix compile
  mix docs
  echo "Documentation has been generated!"
  open ./doc/index.html
  """

  embed_text :coverage, """
  #!/bin/bash

  set -e

  mix compile
  mix coveralls.html
  echo "Coverage report has been generated!"
  open ./cover/excoveralls.html
  """

  embed_text :start, """
  #!/bin/bash

  set -e

  iex \\
    --erl "+K true +A 32" \\
    --erl "-kernel inet_dist_listen_min 9100" \\
    --erl "-kernel inet_dist_listen_max 9199" \\
    --erl "-kernel shell_history enabled" \\
    -S mix
  """

  #
  # circleci
  #

  embed_text :circleci_config, """
  defaults: &defaults
    docker:
      - image: elixir:1.6

  version: 2
  jobs:
    test:
      <<: *defaults
      steps:
        - checkout
        - run:
            name:       Check variables
            command:    ./scripts/check-vars.sh "in system" "ROBOT_SSH_KEY" "COVERALLS_REPO_TOKEN"
        - run:
            name:       Install env stuff
            command:    echo 'export TAR_OPTIONS="-o"' >> ~/.bashrc && mix local.hex --force && mix local.rebar --force
        - run:
            name:       Setup robot SSH key
            command:    echo "$ROBOT_SSH_KEY" | base64 --decode > $HOME/.ssh/id_rsa.robot && chmod 600 $HOME/.ssh/id_rsa.robot && ssh-add $HOME/.ssh/id_rsa.robot
        - run:
           name:        Setup SSH config
           command:     echo -e "Host *\\n IdentityFile $HOME/.ssh/id_rsa.robot\\n IdentitiesOnly yes" > $HOME/.ssh/config
        - run:
            name:       Fetch submodules
            command:    git submodule update --init --recursive
        - restore_cache:
            keys:
              - v1-deps-cache-{{ checksum "mix.lock" }}
              - v1-deps-cache
        - run:
            name:       Fetch dependencies
            command:    mix deps.get
        - run:
            name:       Compile dependencies
            command:    mix deps.compile
        - run:
            name:       Compile protocols
            command:    mix compile.protocols --warnings-as-errors
        - save_cache:
            key: v1-deps-cache-{{ checksum "mix.lock" }}
            paths:
              - _build
              - deps
              - ~/.mix
        - run:
            name:       Run tests
            command:    mix coveralls.circle
        - run:
            name:       Run style checks
            command:    mix credo --strict
        - restore_cache:
            keys:
              - v1-dialyzer-plt-cache-{{ checksum "mix.lock" }}
              - v1-plt-cache
        - run:
            name:       Run Dialyzer type checks
            command:    mix dialyzer --halt-exit-status
            no_output_timeout: 15m
        - save_cache:
            key: v1-dialyzer-plt-cache-{{ checksum "mix.lock" }}
            paths:
              - _build
              - ~/.mix
        - persist_to_workspace:
            root: ./
            paths:
              - .
    build:
      <<: *defaults
      steps:
        - checkout
        - run:
            name:       Check variables
            command:    ./scripts/check-vars.sh "in system" "ROBOT_SSH_KEY" "DOCKER_EMAIL" "DOCKER_ORG" "DOCKER_PASS" "DOCKER_USER"
        - run:
            name:       Install env stuff
            command:    echo 'export TAR_OPTIONS="-o"' >> ~/.bashrc && mix local.hex --force && mix local.rebar --force
        - run:
            name:       Setup robot SSH key
            command:    echo "$ROBOT_SSH_KEY" | base64 --decode > $HOME/.ssh/id_rsa.robot && chmod 600 $HOME/.ssh/id_rsa.robot && ssh-add $HOME/.ssh/id_rsa.robot
        - run:
           name:        Setup SSH config
           command:     echo -e "Host *\\n IdentityFile $HOME/.ssh/id_rsa.robot\\n IdentitiesOnly yes" > $HOME/.ssh/config
        - run:
            name:       Fetch submodules
            command:    git submodule update --init --recursive
        - setup_remote_docker
        - run:
            name:       Fetching dependencies
            command:    mix deps.get && MIX_ENV=staging mix deps.get && MIX_ENV=prod mix deps.get
        - run:
            name:       Compile protocols
            command:    mix compile.protocols --warnings-as-errors
        - run:
            name:       Install Docker client
            command:    mix boilex.ci.docker.client.install
        - run:
            name:       Login to docker
            command:    docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASS
        - run:
            name:       Building docker image
            command:    export $(cat "./scripts/.env" | xargs) && mix boilex.ci.docker.build "$CIRCLE_TAG"
        - run:
            name:       Push image to docker hub
            command:    export $(cat "./scripts/.env" | xargs) && mix boilex.ci.docker.push "$CIRCLE_TAG"
    doc:
      <<: *defaults
      steps:
        - checkout
        - run:
            name:       Check variables
            command:    ./scripts/check-vars.sh "in system" "ROBOT_SSH_KEY" "CONFLUENCE_SECRET"
        - run:
            name:       Install env stuff
            command:    echo 'export TAR_OPTIONS="-o"' >> ~/.bashrc && mix local.hex --force && mix local.rebar --force
        - run:
            name:       Update apt-get
            command:    apt-get update -y
        - run:
            name:       Install zip
            command:    apt-get install zip unzip -y
        - run:
            name:       Setup robot SSH key
            command:    echo "$ROBOT_SSH_KEY" | base64 --decode > $HOME/.ssh/id_rsa.robot && chmod 600 $HOME/.ssh/id_rsa.robot && ssh-add $HOME/.ssh/id_rsa.robot
        - run:
           name:        Setup SSH config
           command:     echo -e "Host *\\n IdentityFile $HOME/.ssh/id_rsa.robot\\n IdentitiesOnly yes" > $HOME/.ssh/config
        - run:
            name:       Fetch submodules
            command:    git submodule update --init --recursive
        - run:
            name:       Fetching dependencies
            command:    mix deps.get
        - run:
            name:       Compile protocols
            command:    mix compile.protocols --warnings-as-errors
        - run:
            name:       Compile documentation
            command:    mix docs
        - run:
            name:       Push documentation to confluence
            command:    export $(cat "./scripts/.env" | xargs) && mix boilex.ci.confluence.push "$CIRCLE_TAG"

  workflows:
    version: 2
    test:
      jobs:
        - test:
            filters:
              branches:
                only: /^([A-Z]{2,}-[0-9]+|hotfix-.+)$/
    test-build:
      jobs:
        - test:
            filters:
              branches:
                only: /^(build-*)$/
        - build:
            filters:
              branches:
                only: /^(build-*)$/
    test-build-doc:
      jobs:
        - test:
            filters:
              tags:
                only: /.*/
              branches:
                only: /^master$/
        - build:
            filters:
              tags:
                only: /.*/
              branches:
                only: /^master$/
        - doc:
            filters:
              tags:
                only: /.*/
              branches:
                only: /^master$/
  """

  #
  # priv
  #

  defp fetch_otp_application_name do
    Mix.shell.prompt("Please type OTP application name>")
    |> String.trim
    |> Macro.underscore
    |> String.downcase
    |> case do
      "" ->
        Mix.shell.error("Empty OTP application name!")
        fetch_otp_application_name()
      name ->
        case Regex.match?(~r/^[a-z][0-9a-z_]+[a-z]$/, name)  do
          true -> name
          false ->
            Mix.shell.error("Invalid OTP application name!")
            fetch_otp_application_name()
        end
    end
  end

  defp todo_instructions do
    """
    #{IO.ANSI.magenta}
    *****************
    !!! IMPORTANT !!!
    *****************

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

    #{IO.ANSI.cyan}
    ADD THE FOLLOWING PARAMETERS TO `deps` FUNCTION IN `mix.exs` FILE
    #{IO.ANSI.green}


      # development tools
      {:excoveralls, "~> 0.8",            only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5",               only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.18",                only: [:dev, :test], runtime: false},
      {:credo, "~> 0.8",                  only: [:dev, :test], runtime: false},
      {:boilex, github: "tim2CF/boilex",  only: [:dev, :test], runtime: false},


    #{IO.ANSI.reset}
    Please configure `scripts/.env` file if you want to use distributed erlang features in development process.

    #{IO.ANSI.magenta}
    *****************
    !!! IMPORTANT !!!
    *****************
    #{IO.ANSI.reset}
    """
  end

  defp create_script(name, value) do
    create_file       name, value
    :ok = File.chmod  name, 0o755
  end

end
