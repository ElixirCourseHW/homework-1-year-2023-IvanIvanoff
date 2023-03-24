# Run `elixir -r if_test.exs`
ExUnit.start()

defmodule IfElseTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  @external_resource Path.expand("task_if.exs", __DIR__)
  @task_if_source File.read!(@external_resource)

  test "if_else" do
    {_, functions} = Code.eval_string(@task_if_source)
    if_else = functions[:if_else]

    assert if_else.(1, 2, 3) == 2
    assert if_else.(nil, 2, 3) == 3
    assert if_else.(false, 2, 3) == 3
    assert if_else.({false}, 2, 3) == 2
    assert if_else.({nil}, 2, 3) == 2
    assert if_else.({nil, false, nil}, 2, 3) == 2
    assert if_else.(true, false, "bin") == false
    assert if_else.(true, true, "bin") == true
    assert if_else.("Kiro", "Pesho", "Ivan") == "Pesho"
    assert if_else.("", "Pesho", "Ivan") == "Pesho"
    assert if_else.("false", "Pesho", "Ivan") == "Pesho"
    assert if_else.("nil", "Pesho", "Ivan") == "Pesho"
    assert if_else.([], "Pesho", "Ivan") == "Pesho"
  end

  test "if_else_lazy" do
    {_, functions} = Code.eval_string(@task_if_source)
    if_else_lazy = functions[:if_else_lazy]

    # Връща функция на 0 аргумента, която принтира input
    puts = fn input -> fn -> IO.puts(input) end end

    log = capture_io(fn -> if_else_lazy.(true, puts.("truthy"), puts.("falsey")) end)
    assert log =~ "truthy"
    refute log =~ "falsey"

    ##
    log = capture_io(fn -> if_else_lazy.(5, puts.("truthy"), puts.("falsey")) end)
    assert log =~ "truthy"
    refute log =~ "falsey"
    ##
    log = capture_io(fn -> if_else_lazy.(%{a: 2}, puts.("truthy"), puts.("falsey")) end)
    assert log =~ "truthy"
    refute log =~ "falsey"

    ## a tuple of false is not falsey
    log = capture_io(fn -> if_else_lazy.({false}, puts.("truthy"), puts.("falsey")) end)
    assert log =~ "truthy"
    refute log =~ "falsey"

    ##
    log = capture_io(fn -> if_else_lazy.("", puts.("truthy"), puts.("falsey")) end)
    assert log =~ "truthy"
    refute log =~ "falsey"

    ##
    log = capture_io(fn -> if_else_lazy.(false, puts.("truthy"), puts.("falsey")) end)
    assert log =~ "falsey"
    refute log =~ "truthy"

    ##
    log = capture_io(fn -> if_else_lazy.(nil, puts.("truthy"), puts.("falsey")) end)
    assert log =~ "falsey"
    refute log =~ "truthy"
  end
end
