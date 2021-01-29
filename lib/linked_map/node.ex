defmodule LinkedMap.Node do
  @moduledoc """
  A node in the linked map with `previous` and `next` pointers.
  """

  @enforce_keys [:value]
  defstruct [:value, :previous, :next]

  @type t :: %__MODULE__{value: any(), previous: any(), next: any()}
end
