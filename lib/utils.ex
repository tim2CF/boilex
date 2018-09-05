defmodule Boilex.Utils do

  require Logger
  import Mix.Generator

  def create_symlink(destination_path, symlink_path) do
    destination_path
    |> File.ln_s(symlink_path)
    |> case do
      :ok ->
        Logger.info("symbolic link from #{symlink_path} to #{destination_path} has been created")
      {:error, :eexist} ->
        symlink_path
        |> File.rm
        |> case do
          :ok ->
            Logger.info("symbolic link #{symlink_path} has been removed")
            create_symlink(destination_path, symlink_path)
          error ->
            """

            ************************************************
            Can not remove symlink link #{symlink_path}
            because of error #{inspect error}
            ************************************************

            """
            |> raise
        end
      error ->
        """

        ************************************************
        Can not create symbolic link from #{symlink_path}
        To #{destination_path}
        because of error #{inspect error}
        ************************************************

        """
        |> raise
    end
  end

  def create_script(name, value) do
    create_file       name, value
    :ok = File.chmod  name, 0o755
  end

  def fetch_elixir_version do
    [{:elixir, _, version}] =
      :application.which_applications
      |> Enum.filter(fn({app, _, _}) ->
        app == :elixir
      end)

    version
    |> :erlang.list_to_binary
  end

end
