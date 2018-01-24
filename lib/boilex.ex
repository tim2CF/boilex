defmodule Boilex do

  @moduledoc """
  Some compile-time executed code
  1) Fetching submodules.
  2) Generation of pre-commit hook link.
  """

  require Logger

  project_top_path = Mix.Project.deps_path() |> Path.join("..") |> Path.expand()
  git_hooks_path = Path.join(project_top_path, ".git/hooks") |> Path.expand()

  git_hooks_path
  |> File.exists?
  |> case do
    true ->
      {_, 0} = System.cmd("git", ["submodule", "update", "--init", "--recursive"], [cd: project_top_path])
      pre_commit_hook_path = Path.join(git_hooks_path, "pre-commit")
      project_top_path
      |> Path.join("scripts/pre-commit.sh")
      |> Boilex.Utils.create_symlink(pre_commit_hook_path)
    false ->
      """

      ************************************************
      It seems path #{git_hooks_path} is not exist.
      To meet the requirements, your Elixir project should be in git repository.
      If you want just experiment with code locally, you can init repo using command 'git init'
      ************************************************

      """
      |> raise
  end
end
