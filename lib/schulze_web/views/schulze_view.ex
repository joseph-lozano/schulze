defmodule SchulzeWeb.SchulzeView do
  use SchulzeWeb, :view

  def ordinalize(number) when is_integer(number) and number >= 0 do
    "#{number}#{suffix(number)}"
  end

  def ordinalize(number) do
    number
  end

  @spec suffix(integer()) :: String.t()
  defp suffix(num) do
    cond do
      Enum.any?([11, 12, 13], &(&1 == Integer.mod(num, 100))) ->
        "th"

      Integer.mod(num, 10) == 1 ->
        "st"

      Integer.mod(num, 10) == 2 ->
        "nd"

      Integer.mod(num, 10) == 3 ->
        "rd"

      true ->
        "th"
    end
  end

  def class(1), do: "h5"
  def class(_), do: ""
end
