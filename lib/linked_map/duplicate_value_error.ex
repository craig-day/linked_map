defmodule LinkedMap.DuplicateValueError do
  defexception [:value, :message]

  @impl true
  def message(%{value: value, message: nil}), do: "value #{inspect(value)} is already present"
  def message(%{message: message}), do: message
end
