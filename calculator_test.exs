# Run `elixir -r task_calculator.ex calculator_test.exs`
ExUnit.start()

defmodule CalculatorTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias Calculator, as: C

  describe "Calculator basic operation" do
    test "add" do
      assert capture_io(fn -> assert C.add(1, 2) == 3 end) =~ "1 + 2 = 3"
      assert capture_io(fn -> assert C.add(5, 0) == 5 end) =~ "5 + 0 = 5"
      assert capture_io(fn -> assert C.add(-1, -22) == -23 end) =~ "-1 + -22 = -23"
      assert capture_io(fn -> assert C.add(10, -10) == 0 end) =~ "10 + -10 = 0"
    end

    test "sub" do
      assert capture_io(fn -> assert C.sub(1, 2) == -1 end) =~ "1 - 2 = -1"
      assert capture_io(fn -> assert C.sub(5, 0) == 5 end) =~ "5 - 0 = 5"
      assert capture_io(fn -> assert C.sub(-1, -22) == 21 end) =~ "-1 - -22 = 21"
      assert capture_io(fn -> assert C.sub(10, -10) == 20 end) =~ "10 - -10 = 20"
    end

    test "mult" do
      assert capture_io(fn -> assert C.mult(1, 2) == 2 end) =~ "1 * 2 = 2"
      assert capture_io(fn -> assert C.mult(5, 0) == 0 end) =~ "5 * 0 = 0"
      assert capture_io(fn -> assert C.mult(-1, -22) == 22 end) =~ "-1 * -22 = 22"
      assert capture_io(fn -> assert C.mult(10, -10) == -100 end) =~ "10 * -10 = -100"
    end

    test "div" do
      assert C.div(5, 0) == {:error, :division_by_zero}
      assert capture_io(fn -> assert C.div(1, 2) == 0 end) =~ "1 / 2 = 0"
      assert capture_io(fn -> assert C.div(-1, -2) == 0 end) =~ "-1 / -2 = 0"
      assert capture_io(fn -> assert C.div(0, 2) == 0.0 end) =~ "0 / 2 = 0"
      assert capture_io(fn -> assert C.div(10, -10) == -1 end) =~ "10 / -10 = -1"
      assert capture_io(fn -> assert C.div(25, 5) == 5 end) =~ "25 / 5 = 5"
      assert capture_io(fn -> assert C.div(25, 4) == 6 end) =~ "25 / 4 = 6"
      assert capture_io(fn -> assert C.div(25, 3) == 8 end) =~ "25 / 3 = 8"
    end

    test "custom" do
      custom_fn = fn l, r ->
        l
        |> C.add(5)
        |> C.mult(10)
        |> C.sub(r)
        |> C.div(2)
        |> C.add(5)
      end

      io = capture_io(fn -> assert C.custom(2, 10, custom_fn) == 35 end)
      assert io =~ "2 + 5 = 7"
      assert io =~ "7 * 10 = 70"
      assert io =~ "70 - 10 = 60"
      assert io =~ "60 / 2 = 30"
      assert io =~ "30 + 5 = 35"
    end

    test "custom with zero division" do
      custom_fn = fn l, r ->
        l
        |> C.add(5)
        |> C.mult(10)
        |> C.sub(r)
        |> C.div(2)
        |> C.add(5)
      end

      io = capture_io(fn -> assert C.custom(2, 10, custom_fn) == 35 end)
      assert io =~ "2 + 5 = 7"
      assert io =~ "7 * 10 = 70"
      assert io =~ "70 - 10 = 60"
      assert io =~ "60 / 2 = 30"
      assert io =~ "30 + 5 = 35"
    end
  end

  describe "Reverse Polish Notation" do
    test "eval_rpn ok cases" do
      assert C.eval_rpn("1") == 1
      assert C.eval_rpn("1 0 /") == {:error, :division_by_zero}
      assert C.eval_rpn("1 2 +") == 1 + 2
      assert C.eval_rpn("1 2 3 + +") == 1 + 2 + 3
      assert C.eval_rpn("1 2 3 + -") == 1 - (2 + 3)
      assert C.eval_rpn("1 2 3 4 + + -") == 1 - (2 + (3 + 4))
      assert C.eval_rpn("4 2 / 3 4 + -") == div(4, 2) - (3 + 4)
      assert C.eval_rpn("2 2 2 2 * * *") == 2 * 2 * 2 * 2
    end

    test "eval_rpn error cases" do
      assert C.eval_rpn("1 2") == {:error, :invalid_expression}
      assert C.eval_rpn("1 0 /") == {:error, :division_by_zero}
      assert C.eval_rpn("1 2 + -") == {:error, :invalid_expression}
      assert C.eval_rpn("*") == {:error, :invalid_expression}
    end
  end
end
