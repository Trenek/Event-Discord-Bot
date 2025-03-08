defmodule MybotTest do
  use ExUnit.Case
  doctest Mybot

  test "greets the world" do
    assert Mybot.hello() == :world
  end
end
