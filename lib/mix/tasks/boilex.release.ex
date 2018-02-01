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
    Mix.shell.info("pull master")
    {_, 0} = System.cmd("git", ["pull", "origin", "master"])
    [major, minor, patch] = "VERSION" |> File.read! |> String.trim |> String.split(".") |> Enum.map(&String.to_integer/1)
    new_version = case release_kind do
                    "major" -> [major + 1, 0, 0]
                    "minor" -> [major, minor + 1, 0]
                    "patch" -> [major, minor, patch + 1]
                  end
                  |> Enum.join(".")
    new_version_git = "v#{new_version}"
    Mix.shell.info("bump VERSION #{new_version}")
    :ok = File.write!("VERSION", new_version)
    :ok = update_changelog(new_version_git)
    Mix.shell.info("commit changes to git repo")
    {_, 0} = System.cmd("git", ["commit", "-am", new_version_git, "-n"])
    Mix.shell.info("create new tag")
    {_, 0} = System.cmd("git", ["tag", "-a", new_version_git, "-m", new_version_git])
    Mix.shell.info("push changes to git")
    {_, 0} = System.cmd("git", ["push", "origin", "master"])
    Mix.shell.info("push tag to git")
    {_, 0} = System.cmd("git", ["push", "origin", "master", "--tags"])
    Mix.shell.info("release #{new_version_git} has been created!")
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

  defp update_changelog(new_version_git) do
    try do
      {_, 0} = System.cmd("github_changelog_generator", ["-v"])
    catch
      _,_ ->
        Mix.shell.info("it seems github_changelog_generator is not installed.. trying to install it")
        {_, 0} = System.cmd("gem", ["install", "github_changelog_generator"])
    end
    Mix.shell.info("update changelog")
    {_, 0} = System.cmd("github_changelog_generator", ["--future-release", new_version_git])
    :ok
  end

end
