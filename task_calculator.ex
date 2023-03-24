defmodule Calculator do
  import Kernel, except: [div: 2]

  # Илюстрация за custom guard
  defguard are_numbers(a, b) when is_number(a) and is_number(b)

  def add(left, right) when are_numbers(left, right) do
    # За илюстрация на функцията `tap/2`, която приема аргумент и функция и
    # и връща аргумента, а не резултата от изпълнението на функцията.
    (left + right)
    |> tap(fn result -> IO.puts("#{left} + #{right} = #{result}") end)
  end

  def sub(left, right) when are_numbers(left, right) do
    result = left - right
    IO.puts("#{left} - #{right} = #{result}")
    result
  end

  def mult(left, right) when are_numbers(left, right) do
    result = left * right
    IO.puts("#{left} * #{right} = #{result}")
    result
  end

  # Ако div("pesho", 0), то по-конкретната грешка е, че опитваме да делим
  # низ на число, а не че делим на 0
  def div(left, 0) when is_number(left), do: {:error, :division_by_zero}

  def div(left, right) when are_numbers(left, right) do
    result = Kernel.div(left, right)
    IO.puts("#{left} / #{right} = #{result}")
    result
  end

  def custom(left, right, fun) when are_numbers(left, right) and is_function(fun, 2) do
    fun.(left, right)
  end

  def eval_rpn(expr) do
    # Токенизираме: "1 2 3 + +" -> [1, 2, 3, "+", "+"]
    result =
      tokenize(expr)
      |> Enum.reduce([], &rpn/2)

    # Тъй като работим чрез списък (стек), резултатът накрая ще бъде елемент в списък
    # Можем да използваме просто `Enum.reduce(...) |> hd()`, но тогава ще върнем резултат
    # за невалидни изрази като "2 3"
    case result do
      # Проверка дали е число, иначе просто изразът `*` ще се оцени като `*`
      [res] when is_number(res) ->
        res

      # Pattern matching за {:error, _} наредена двойка, за да не презапишем по-конкретната
      # грешка {:error, :division_by_zero} с по-общата {:error, :invalid_expression}
      {:error, _} = error ->
        error

      _ ->
        {:error, :invalid_expression}
    end
  end

  # Изпълняваме операциите. Всеки път когато срещнем операция (+ - * /),
  # изпълняваме операцията с последните две числа в стека. Когато не срещнем
  # операция, добавяме числото в началото на списък, симулирайки стек. Така
  # когато срещнем операция, на върха на стека (първите два елемента в списъка)
  # ще имаме числата, върху които трябва да извършим пресмятането
  defp rpn("+", [b, a | rest]), do: [a + b | rest]
  defp rpn("-", [b, a | rest]), do: [a - b | rest]
  defp rpn("*", [b, a | rest]), do: [a * b | rest]
  defp rpn("/", [0, _ | _rest]), do: {:error, :division_by_zero}
  defp rpn("/", [b, a | rest]), do: [Kernel.div(a, b) | rest]
  defp rpn(num, stack), do: [num | stack]

  # `trim: true` премахва празните низове, т.е. се справя с водещи и завършващи интервали
  # Пример:
  # String.split(" 1 2 3 + + ", " ") -> ["", "1", "2", "3", "+", "+", ""]
  # String.split(" 1 2 3 + + ", " ", trim: true) -> ["1", "2", "3", "+", "+"]
  defp tokenize(bin) do
    bin
    |> String.split(" ", trim: true)
    |> Enum.map(&maybe_to_integer/1)
  end

  defp maybe_to_integer(bin) do
    # За по-добър error handling можем да съпоставим и с {num, _} като втора клауза,
    # за да обработим токените, които не са числа, но започват с число, например: "1asd"
    case Integer.parse(bin) do
      {num, ""} -> num
      _ -> bin
    end
  end
end
