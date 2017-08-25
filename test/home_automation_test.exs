defmodule HomeAutomationTest do
  use ExUnit.Case
  doctest HomeAutomation

  test "greets the world" do
    assert HomeAutomation.hello() == :world
  end
end
