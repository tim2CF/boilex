defmodule Boilex.Generator.Scripts do

  import Mix.Generator
  import Boilex.Utils

  def run(assigns) do
    create_directory  "scripts"
    create_file       "scripts/.env",           env_template(assigns)
    create_script     "scripts/pre-commit.sh",  pre_commit_text()
    create_script     "scripts/remote-iex.sh",  remote_iex_text()
    create_script     "scripts/cluster-iex.sh", cluster_iex_text()
    create_script     "scripts/check-vars.sh",  check_vars_text()
    create_script     "scripts/show-vars.sh",   show_vars_text()
    create_script     "scripts/docs.sh",        docs_text()
    create_script     "scripts/coverage.sh",    coverage_text()
    create_script     "scripts/start.sh",       start_text()
    create_script     "scripts/docker-iex.sh",  docker_iex_template(assigns)

    :ok
  end

  embed_template :env, """
  ERLANG_HOST=127.0.0.1
  ERLANG_OTP_APPLICATION="<%= @otp_application %>"
  ERLANG_COOKIE="<%= @erlang_cookie %>"
  ENABLE_DIALYZER=false
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
    --name "remote-$(date +%s)@$ERLANG_HOST" \\
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
    --name "local-$(date +%s)@$ERLANG_HOST" \\
    --cookie "$ERLANG_COOKIE" \\
    --erl "+K true +A 32" \\
    --erl "-kernel inet_dist_listen_min 9100" \\
    --erl "-kernel inet_dist_listen_max 9199" \\
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

  embed_text :show_vars, """
  #!/bin/bash

  set -e

  variables=( "$@" )

  echo ""
  for varname in "${variables[@]}"
  do
    echo "$varname=${!varname}"
  done
  echo ""
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

  embed_template :docker_iex, """
  #!/bin/bash

  set -e

  docker exec -it $(docker ps | grep "<%= @otp_application %>_main" | awk '{print $1;}') /app/scripts/remote-iex.sh
  """

end
