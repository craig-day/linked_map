defmodule LinkedMap.Node do
  @moduledoc false

  @enforce_keys :value
  defstruct [:value, :previous, :next]

  @typedoc false
  @type t :: %__MODULE__{
          value: LinkedMap.value(),
          previous: LinkedMap.key(),
          next: LinkedMap.key()
        }
end
