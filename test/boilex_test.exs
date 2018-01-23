defmodule BoilexTest do
  use ExUnit.Case
  doctest Boilex

  test "greets the world" do
    assert Boilex.hello() == :world
  end
end
