defmodule Boilex.Utils do

  require Logger

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

end
