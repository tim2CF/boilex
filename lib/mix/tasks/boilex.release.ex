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
    :ok = check_branch()
    [major, minor, patch] = "VERSION" |> File.read! |> String.trim |> String.split(".") |> Enum.map(&String.to_integer/1)
    new_version = case release_kind do
                    "major" -> [major + 1, 0, 0]
                    "minor" -> [major, minor + 1, 0]
                    "patch" -> [major, minor, patch + 1]
                  end
                  |> Enum.join(".")
    new_version_comment = "\"release v#{new_version}\""
    Mix.shell.info("bump version to #{new_version}")
    :ok = File.write!("VERSION", new_version)
    Mix.shell.info("commit changes to git repo")
    {_, 0} = System.cmd("git", ["commit", "-am", new_version_comment, "-n"])
    Mix.shell.info("create new tag")
    {_, 0} = System.cmd("git", ["tag", "-a", "v#{new_version}", "-m", new_version_comment, "-n"])
    Mix.shell.info("push changes to git")
    {_, 0} = System.cmd("git", ["push", "origin", "master"])
    Mix.shell.info("push tag to git")
    {_, 0} = System.cmd("git", ["push", "origin", "master", "--tags"])
    Mix.shell.info("release #{new_version} has been created!")
    #
    # TODO
    #
    :ok
  end

  defp check_branch do
    with {raw_branch, 0}  <- System.cmd("git", ["rev-parse", "--abbrev-ref", "HEAD"]),
         "master"         <- String.trim(raw_branch)
    do
      :ok
    else
      some ->
        """
        Release command is available only for `master` git branch.
        Got wrong branch #{inspect some}
        """
        |> raise
    end
  end

end
