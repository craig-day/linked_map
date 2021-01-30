defmodule LinkedMap.MissingValueError do
  defexception [:value, :message]

  @impl true
  def message(%{value: value, message: nil}), do: "value #{inspect(value)} is not present"
  def message(%{message: message}), do: message
end
