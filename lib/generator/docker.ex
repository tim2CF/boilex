defmodule Boilex.Generator.Docker do

  import Mix.Generator

  def run(assigns) do
    create_file       "Dockerfile",             dockerfile_template(assigns)
    create_file       "docker-compose.yml",     docker_compose_template(assigns)

    :ok
  end

  embed_template :dockerfile, """
  FROM elixir:<%= @elixir_version %>

  WORKDIR /app

  COPY . .

  RUN cd / && \\
      mix do local.hex --force, local.rebar --force && \\
      mix archive.install github heathmont/ex_env tag v0.2.2 --force && \\
      cd /app # && \\
      # rm -rf ./_build/ && \\
      # echo "Compressing static files..." && \\
      # mix phx.digest && \\
      # MIX_ENV=prelive mix compile.protocols && \\
      # MIX_ENV=prod    mix compile.protocols && \\
      # MIX_ENV=qa      mix compile.protocols && \\
      # MIX_ENV=staging mix compile.protocols

  CMD echo "Checking system variables..." && \\
      scripts/show-vars.sh \\
        "MIX_ENV" \\
        "ERLANG_OTP_APPLICATION" \\
        "ERLANG_HOST" \\
        "ERLANG_MIN_PORT" \\
        "ERLANG_MAX_PORT" \\
        "ERLANG_MAX_PROCESSES" \\
        "ERLANG_COOKIE" && \\
      scripts/check-vars.sh "in system" \\
        "MIX_ENV" \\
        "ERLANG_OTP_APPLICATION" \\
        "ERLANG_HOST" \\
        "ERLANG_MIN_PORT" \\
        "ERLANG_MAX_PORT" \\
        "ERLANG_MAX_PROCESSES" \\
        "ERLANG_COOKIE" && \\
      # echo "Running ecto create..." && \\
      # mix ecto.create && \\
      # echo "Running ecto migrate..." && \\
      # mix ecto.migrate && \\
      # echo "Running ecto seeds..." && \\
      # mix run priv/repo/seeds.exs && \\
      echo "Running app..." && \\
      elixir \\
        --name "$ERLANG_OTP_APPLICATION@$ERLANG_HOST" \\
        --cookie "$ERLANG_COOKIE" \\
        --erl "+K true +A 32 +P $ERLANG_MAX_PROCESSES" \\
        --erl "-kernel inet_dist_listen_min $ERLANG_MIN_PORT" \\
        --erl "-kernel inet_dist_listen_max $ERLANG_MAX_PORT" \\
        -pa "_build/$MIX_ENV/lib/<%= @otp_application %>/consolidated/" \\
        -S mix run \\
        --no-halt
  """

  embed_template :docker_compose, """
  version: "3"

  services:
    main:
      image: "<%= @otp_application %>:master"
      ports:
        # - "4369:4369"         # EPMD
        - "9100-9105:9100-9105" # Distributed Erlang
      environment:
        MIX_ENV: staging
        ERLANG_OTP_APPLICATION: "<%= @otp_application %>"
        ERLANG_HOST: "127.0.0.1"
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

end
