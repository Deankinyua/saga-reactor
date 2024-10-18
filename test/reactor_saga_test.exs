defmodule ReactorSagaTest do
  use ExUnit.Case
  doctest ReactorSaga

  test "greets the world" do
    assert ReactorSaga.hello() == :world
  end
end
