defmodule LinkedMap do
  @moduledoc """
  A `LinkedMap` is an extension to `Map` that keeps pointers to previous
  and next elements based on the order items were put into it.
  """
  alias LinkedMap.Node

  @enforce_keys [:map]
  defstruct head: nil, tail: nil, map: %{}

  @type key :: any()
  @type value :: any()
  @type t :: %__MODULE__{head: key, tail: key, map: map()}

  @doc """
  Returns a new empty `LinkedMap`.

  The map can be built using any existing `Enumerable` and the order will be
  whatever order is determined by passing the enumerable to `Enum.reduce/3`.

  In the case of a `List`, every two elements will be assumed to be a key-value
  pair. If there is an odd number of elements, the last key will get a `nil`
  value.

  ## Examples

      iex> LinkedMap.new()
      %LinkedMap{head: nil, map: %{}, tail: nil}

      iex> LinkedMap.new(key: "value")
      %LinkedMap{
        head: :key,
        map: %{key: %LinkedMap.Node{next: nil, previous: nil, value: "value"}},
        tail: :key
      }

      iex> LinkedMap.new(["key", "value"])
      %LinkedMap{
        head: "key",
        map: %{"key" => %LinkedMap.Node{next: nil, previous: nil, value: "value"}},
        tail: "key"
      }

      iex> LinkedMap.new(%{"key" => "value"})
      %LinkedMap{
        head: "key",
        map: %{"key" => %LinkedMap.Node{next: nil, previous: nil, value: "value"}},
        tail: "key"
      }

      iex> LinkedMap.new(["a", "b", "c"])
      %LinkedMap{
        head: "a",
        map: %{
          "a" => %LinkedMap.Node{next: "c", previous: nil, value: "b"},
          "c" => %LinkedMap.Node{next: nil, previous: "a", value: nil}
        },
        tail: "c"
      }
  """
  @spec new :: LinkedMap.t()
  def new(), do: %__MODULE__{map: %{}}

  @spec new(Enumerable.t()) :: __MODULE__.t()
  def new(enumerable)

  def new(list) when is_list(list), do: new_from_list(list)
  def new(%_{} = struct), do: new_from_struct(struct)
  def new(%{} = map), do: new_from_map(map)
  def new(enum), do: new_from_enum(enum)

  defp new_from_list([{_k, _v} | _tail] = list) do
    Enum.reduce(list, new(), fn {key, value}, map -> put(map, key, value) end)
  end

  defp new_from_list(list) do
    list
    |> Enum.chunk_every(2, 2, [nil])
    |> Enum.reduce(new(), fn [key, value], map ->
      put(map, key, value)
    end)
  end

  defp new_from_struct(struct) do
    struct
    |> Map.from_struct()
    |> new_from_map()
  end

  defp new_from_map(map) do
    Enum.reduce(map, new(), fn {key, value}, map -> put(map, key, value) end)
  end

  defp new_from_enum(enum) do
    enum
    |> Enum.to_list()
    |> new_from_list()
  end

  @doc """
  Gets the value for a specific `key` in `linked_map`.

  If `key` is present in `linked_map` then its `value` is returned. Otherwise,
  `default` is returned.

  If `default` is not provided, `nil` is used.

  See also `Map.get/3`

  ## Examples

    iex> LinkedMap.new(key: "value") |> LinkedMap.get(:key)
    "value"

    iex> LinkedMap.new("key", "value") |> LinkedMap.get("other")
    nil

    iex LinkedMap.new(key: "value") |> LinkedMap.get("other", "default")
    "default"
  """
  @spec get(__MODULE__.t(), key, value) :: value
  def get(linked_map, key, default \\ nil)

  def get(%__MODULE__{map: map}, key, default) do
    Map.get(map, key, %Node{value: default}).value
  end

  @doc """
  Gets the value for a specific `key` in `linked_map`.

  If `key` is present in `linked_map` then its value is returned. Otherwise,
  `fun` is evaluated and its result is returned.

  This is useful if the default value is very expensive to calculate or
  generally difficult to setup and teardown again.

  See also `Map.get_lazy/3`

  ## Examples

      iex>
  """
  @spec get_lazy(__MODULE__.t(), key, fun) :: value
  def get_lazy(linked_map, key, fun)

  def get_lazy(%__MODULE__{map: map}, key, fun) do
    default_fun = fn -> %Node{value: fun.()} end
    Map.get_lazy(map, key, default_fun).value
  end

  @doc """
  Puts the given `value` under `key` at the tail of `linked_map`.

  Returns the updated map. If `key` was already present, it is moved to the
  tail of `linked_map`.

  Also aliased as `LinkedMap.put_at_tail/3`

  See also `Map.put/3`

  ## Examples

      iex>
  """
  @spec put(__MODULE__.t(), key, value) :: __MODULE__.t()
  def put(linked_map, key, value)

  def put(%__MODULE__{map: map}, key, value) when map == %{}, do: new([{key, value}])
  def put(%__MODULE__{tail: tail} = lm, key, value), do: put_after(lm, tail, key, value)

  @doc """
  Puts the given `value` under `key` at the tail of `linked_map` only if `key`
  is not already present.

  Returns the updated map, or an unmodified map if `key` is already present.

  ## Examples

      iex>
  """
  @spec put_new(__MODULE__.t(), key, value) :: __MODULE__.t()
  def put_new(linked_map, key, value)

  def put_new(%__MODULE__{map: map} = lm, key, value) do
    if Map.has_key?(map, key), do: map, else: put(lm, key, value)
  end

  @doc """
  Puts the given `value` under `key` at the tail of `linked_map` only if `key`
  is not already present.

  Returns the updated map, or raises `ArgumentError` if `key` is already present.

  ## Examples

      iex>
  """
  @spec put_new!(__MODULE__.t(), key, value) :: __MODULE__.t()
  def put_new!(linked_map, key, value)

  def put_new!(%__MODULE__{map: map} = lm, key, value) do
    if Map.has_key?(map, key), do: raise(ArgumentError), else: put(lm, key, value)
  end

  @doc """
  Puts the given `value` under `key` at the head of `linked_map`.

  Performs the same function as `LinkedMap.put/3`, but updates the pointers
  to keep the new element at the head of `linked_map`, rather than tail.

  ## Examples

      iex>
  """
  @spec put_at_head(__MODULE__.t(), key, value) :: __MODULE__.t()
  def put_at_head(linked_map, key, value)

  def put_at_head(%__MODULE__{map: map}, key, value) when map == %{}, do: new([{key, value}])
  def put_at_head(%__MODULE__{head: head} = lm, key, value), do: put_before(lm, head, key, value)

  @doc """
  Puts the given `value` under `key` after `existing_key` in `linked_map`.

  Raises `ArgumentError` if `existing_key` does not exist in `linked_map`.

  ## Examples

      iex>
  """
  @spec put_after(__MODULE__.t(), key, key, value) :: __MODULE__.t()
  def put_after(linked_map, existing_key, key, value)

  def put_after(_lm, _e, k, _v) when is_integer(k), do: raise(ArgumentError)
  def put_after(_lm, e, _k, _v) when is_integer(e), do: raise(ArgumentError)
  def put_after(_lm, _e, k, _v) when is_boolean(k), do: raise(ArgumentError)
  def put_after(_lm, e, _k, _v) when is_boolean(e), do: raise(ArgumentError)

  def put_after(%__MODULE__{map: map} = lm, existing, key, value) do
    unless Map.has_key?(map, existing), do: raise(ArgumentError)

    existing_node = map[existing]
    existing_next_node = map[existing_node.next]
    node = %Node{value: value, previous: existing, next: existing_node.next}
    replacement_node = %{existing_node | next: key}
    clean_map = if Map.has_key?(map, key), do: Map.delete(map, key), else: map

    updated_map =
      clean_map
      |> Map.put(existing, replacement_node)
      |> Map.put(key, node)

    updated_map =
      if existing_next_node == nil do
        updated_map
      else
        replacement_next_node = %{existing_next_node | previous: key}
        Map.put(updated_map, existing_node.next, replacement_next_node)
      end

    %{lm | map: updated_map}
  end

  @doc """

  """
  @spec put_before(__MODULE__.t(), key, key, value) :: __MODULE__.t()
  def put_before(linked_map, existing, key, value)

  def put_before(_lm, _e, k, _v) when is_integer(k), do: raise(ArgumentError)
  def put_before(_lm, e, _k, _v) when is_integer(e), do: raise(ArgumentError)
  def put_before(_lm, _e, k, _v) when is_boolean(k), do: raise(ArgumentError)
  def put_before(_lm, e, _k, _v) when is_boolean(e), do: raise(ArgumentError)

  def put_before(%__MODULE__{map: map} = lm, existing, key, value) do
    unless Map.has_key?(map, existing), do: raise(ArgumentError)

    existing_node = map[existing]
    existing_previous_node = map[existing_node.previous]
    node = %Node{value: value, previous: existing_node.previous, next: existing}
    replacement_node = %{existing_node | previous: key}
    clean_map = if Map.has_key?(map, key), do: Map.delete(map, key), else: map

    updated_map =
      clean_map
      |> Map.put(existing, replacement_node)
      |> Map.put(key, node)

    updated_map =
      if existing_previous_node == nil do
        updated_map
      else
        replacement_previous_node = %{existing_previous_node | next: key}
        Map.put(updated_map, existing_node.previous, replacement_previous_node)
      end

    %{lm | map: updated_map}
  end

  #############################################################################
  #############################################################################
  #############################################################################

  # @doc """
  # Remove an item from the linked map if it exists.

  # Returns the updated `LinkedMap`.

  # ## Examples

  #     iex> linked_map = LinkedMap.new |> LinkedMap.add("a") |> LinkedMap.add("b") |> LinkedMap.add("c")
  #     %LinkedMap{
  #       head: "a",
  #       items: %{
  #         "a" => %Node{next: "b", previous: nil, value: "a"},
  #         "b" => %Node{next: "c", previous: "a", value: "b"},
  #         "c" => %Node{next: nil, previous: "b", value: "c"}
  #       },
  #       tail: "c"
  #     }
  #     iex> LinkedMap.remove(linked_map, "b")
  #     %LinkedMap{
  #       head: "a",
  #       items: %{
  #         "a" => %Node{next: "c", previous: nil, value: "a"},
  #         "c" => %Node{next: nil, previous: "a", value: "c"}
  #       },
  #       tail: "c"
  #     }
  # """
  # @spec remove(__MODULE__.t(), any) :: __MODULE__.t()
  # def remove(linked_map, value)

  # def remove(%__MODULE__{head: head, tail: tail, items: items} = lm, value) do
  #   cond do
  #     !Map.has_key?(items, value) ->
  #       lm

  #     head == value && tail == value ->
  #       new()

  #     head == value ->
  #       remove_first_item(lm, value)

  #     tail == value ->
  #       remove_last_item(lm, value)

  #     true ->
  #       remove_nth_item(lm, value)
  #   end
  # end

  # defp remove_first_item(%__MODULE__{items: items} = lm, value) do
  #   next_head_node = items[items[value].next]
  #   replacement_head_node = %{next_head_node | previous: nil}

  #   updated_items =
  #     items
  #     |> Map.delete(value)
  #     |> Map.put(replacement_head_node.value, replacement_head_node)

  #   %{lm | head: replacement_head_node.value, items: updated_items}
  # end

  # defp remove_last_item(%__MODULE__{items: items} = lm, value) do
  #   next_tail_node = items[items[value].previous]
  #   replacement_tail_node = %{next_tail_node | next: nil}

  #   updated_items =
  #     items
  #     |> Map.delete(value)
  #     |> Map.put(replacement_tail_node.value, replacement_tail_node)

  #   %{lm | tail: replacement_tail_node.value, items: updated_items}
  # end

  # defp remove_nth_item(%__MODULE__{items: items} = lm, value) do
  #   node_to_remove = items[value]
  #   previous_node = items[node_to_remove.previous]
  #   next_node = items[node_to_remove.next]
  #   replacement_previous_node = %{previous_node | next: next_node.value}
  #   replacement_next_node = %{next_node | previous: previous_node.value}

  #   updated_items =
  #     items
  #     |> Map.delete(node_to_remove.value)
  #     |> Map.put(previous_node.value, replacement_previous_node)
  #     |> Map.put(next_node.value, replacement_next_node)

  #   %{lm | items: updated_items}
  # end

  # @doc """
  # Removes an item from the linked map, or raises if it doesn't exist.

  # Returns the updated `LinkedMap`, or raises if `value` doesn't exist.

  # Behavies the same as `remove/2`, but raises if `value` doesn't exist.

  # ## Examples

  #     iex> LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.remove!("b")
  #     ** (LinkedMap.MissingValueError) value "b" is not present
  # """
  # @spec remove!(LinkedMap.t(), any) :: LinkedMap.t()
  # def remove!(linked_map, value)

  # def remove!(%__MODULE__{items: items} = lm, value) do
  #   if Map.has_key?(items, value) do
  #     remove(lm, value)
  #   else
  #     raise MissingValueError, value: value
  #   end
  # end

  # @doc """
  # Returns the number of items in the `linked_map`.

  # ## Examples

  #     iex> LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.size()
  #     1
  # """
  # @spec size(LinkedMap.t()) :: non_neg_integer
  # def size(%__MODULE__{items: items}), do: map_size(items)

  # @doc """
  # Returns whether the given `value` exists in the given `linked_map`.

  # ## Examples

  #     iex> LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.member?("a")
  #     true

  #     iex> LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.member?("b")
  #     false
  # """
  # @spec member?(LinkedMap.t(), any) :: boolean
  # def member?(%__MODULE__{items: items}, value), do: Map.has_key?(items, value)

  # @doc """
  # Returns the values as a `List` in order.

  # ## Examples

  #     iex> LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.add("b") |> LinkedMap.to_list()
  # """
  # @spec to_list(LinkedMap.t()) :: [any()]
  # def to_list(linked_map)

  # def to_list(%__MODULE__{head: head, items: items}) do
  #   case map_size(items) do
  #     0 -> []
  #     1 -> [head]
  #     _ -> [head] ++ remaining_items(head, items)
  #   end
  # end

  # defp remaining_items(nil, _items), do: []

  # defp remaining_items(current, items) do
  #   next = items[current].next

  #   if next == nil do
  #     []
  #   else
  #     [next] ++ remaining_items(next, items)
  #   end
  # end

  # defimpl Enumerable do
  #   def count(linked_map) do
  #     {:ok, LinkedMap.size(linked_map)}
  #   end

  #   def member?(linked_map, value) do
  #     {:ok, LinkedMap.member?(linked_map, value)}
  #   end

  #   # Let the default reduce-based implementation be used since we
  #   # require traversal of all items to maintain ordering.
  #   def slice(_linked_map), do: {:error, __MODULE__}

  #   def reduce(linked_map, acc, fun) do
  #     Enumerable.List.reduce(LinkedMap.to_list(linked_map), acc, fun)
  #   end
  # end
end
