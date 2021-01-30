defmodule LinkedMap do
  @moduledoc """
  A LinkedMap is a order-aware colelction with the following properties:

    - A `head` pointer
    - A `tail` pointer
    - An `items` map where the key is the content itself, and the value is a `LinkedMap.Node`
      which has `previous` and `next` pointers
  """
  alias LinkedMap.{DuplicateValueError, MissingValueError}
  alias LinkedMap.Node

  @enforce_keys [:items]
  defstruct head: nil, tail: nil, items: %{}

  @type t :: %__MODULE__{head: any(), tail: any(), items: map()}

  @doc """
  Create a new `LinkedMap`

  Returns a new empty `LinkedMap`.

  ## Examples

      iex> LinkedMap.new()
      %LinkedMap{head: nil, items: %{}, tail: nil}
  """
  @spec new :: LinkedMap.t()
  def new(), do: %__MODULE__{items: %{}}

  @doc """
  Adds an item to the linked map, or moves an existing one to tail.

  Returns the updated `LinkedMap`.

  ## Examples

      iex> LinkedMap.new() |> LinkedMap.add("foo")
      iex(6)> LinkedMap.new |> LinkedMap.add("foo") |> LinkedMap.add("bar")
      %LinkedMap{
        head: "foo",
        items: %{
          "bar" => %Node{next: nil, previous: "foo", value: "bar"},
          "foo" => %Node{next: "bar", previous: nil, value: "foo"}
        },
        tail: "bar"
      }
  """
  @spec add(__MODULE__.t(), any) :: __MODULE__.t()
  def add(linked_map, value)

  def add(%__MODULE__{head: nil, tail: nil, items: %{}}, value) do
    new_node = %Node{value: value}

    %__MODULE__{head: value, tail: value, items: %{value => new_node}}
  end

  def add(%__MODULE__{head: head, tail: tail} = lm, value) do
    if head == tail do
      add_second_item(lm, value)
    else
      add_nth_item(lm, value)
    end
  end

  defp add_second_item(%__MODULE__{head: head}, value) do
    second_node = %Node{value: value, previous: head}
    first_node = %Node{value: head, next: second_node.value}

    items = %{
      first_node.value => first_node,
      second_node.value => second_node
    }

    %__MODULE__{head: first_node.value, tail: second_node.value, items: items}
  end

  defp add_nth_item(%__MODULE__{tail: tail, items: items} = lm, value) do
    new_node = %Node{value: value, previous: tail}
    replacement_tail = %{items[tail] | next: new_node.value}

    updated_items =
      items
      |> Map.put(tail, replacement_tail)
      |> Map.put(new_node.value, new_node)

    %{lm | tail: new_node.value, items: updated_items}
  end

  @doc """
  Adds a new item to the linked map, unless it already exists.

  Returns the updated `LinkedMap`.

  ## Examples

      iex> LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.add_new("a")
      %LinkedMap{
        head: "a",
        items: %{
          "a" => %Node{next: nil, previous: nil, value: "a"}
        },
        tail: "a"
      }
  """
  @spec add_new(__MODULE__.t(), any) :: __MODULE__.t()
  def add_new(%__MODULE__{items: items} = lm, value) do
    if Map.has_key?(items, value) do
      lm
    else
      add(lm, value)
    end
  end

  @doc """
  Adds a new item to the linked map, or raises if `value` already exists.

  Returns the updated `LinkedMap` or raises if `value` already exists.

  Behaves the same as `add_new/2` but raises if `value` already exists.

  ## Examples

      iex> LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.add_new!("a")
      ** (LinkedMap.DuplicateValueError) value "a" is already present
  """
  @spec add_new!(__MODULE__.t(), any) :: __MODULE__.t()
  def add_new!(%__MODULE__{items: items} = lm, value) do
    if Map.has_key?(items, value) do
      raise DuplicateValueError, value: value
    else
      add(lm, value)
    end
  end

  @doc """
  Remove an item from the linked map if it exists.

  Returns the updated `LinkedMap`.

  ## Examples

      iex> linked_map = LinkedMap.new |> LinkedMap.add("a") |> LinkedMap.add("b") |> LinkedMap.add("c")
      %LinkedMap{
        head: "a",
        items: %{
          "a" => %Node{next: "b", previous: nil, value: "a"},
          "b" => %Node{next: "c", previous: "a", value: "b"},
          "c" => %Node{next: nil, previous: "b", value: "c"}
        },
        tail: "c"
      }
      iex> LinkedMap.remove(linked_map, "b")
      %LinkedMap{
        head: "a",
        items: %{
          "a" => %Node{next: "c", previous: nil, value: "a"},
          "c" => %Node{next: nil, previous: "a", value: "c"}
        },
        tail: "c"
      }
  """
  @spec remove(__MODULE__.t(), any) :: __MODULE__.t()
  def remove(linked_map, value)

  def remove(%__MODULE__{head: head, tail: tail, items: items} = lm, value) do
    cond do
      !Map.has_key?(items, value) ->
        lm

      head == value && tail == value ->
        new()

      head == value ->
        remove_first_item(lm, value)

      tail == value ->
        remove_last_item(lm, value)

      true ->
        remove_nth_item(lm, value)
    end
  end

  defp remove_first_item(%__MODULE__{items: items} = lm, value) do
    next_head_node = items[items[value].next]
    replacement_head_node = %{next_head_node | previous: nil}

    updated_items =
      items
      |> Map.delete(value)
      |> Map.put(replacement_head_node.value, replacement_head_node)

    %{lm | head: replacement_head_node.value, items: updated_items}
  end

  defp remove_last_item(%__MODULE__{items: items} = lm, value) do
    next_tail_node = items[items[value].previous]
    replacement_tail_node = %{next_tail_node | next: nil}

    updated_items =
      items
      |> Map.delete(value)
      |> Map.put(replacement_tail_node.value, replacement_tail_node)

    %{lm | tail: replacement_tail_node.value, items: updated_items}
  end

  defp remove_nth_item(%__MODULE__{items: items} = lm, value) do
    node_to_remove = items[value]
    previous_node = items[node_to_remove.previous]
    next_node = items[node_to_remove.next]
    replacement_previous_node = %{previous_node | next: next_node.value}
    replacement_next_node = %{next_node | previous: previous_node.value}

    updated_items =
      items
      |> Map.delete(node_to_remove.value)
      |> Map.put(previous_node.value, replacement_previous_node)
      |> Map.put(next_node.value, replacement_next_node)

    %{lm | items: updated_items}
  end

  @doc """
  Removes an item from the linked map, or raises if it doesn't exist.

  Returns the updated `LinkedMap`, or raises if `value` doesn't exist.

  Behavies the same as `remove/2`, but raises if `value` doesn't exist.

  ## Examples

      iex> LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.remove!("b")
      ** (LinkedMap.MissingValueError) value "b" is not present
  """
  @spec remove!(LinkedMap.t(), any) :: LinkedMap.t()
  def remove!(%__MODULE__{items: items} = lm, value) do
    if Map.has_key?(items, value) do
      remove(lm, value)
    else
      raise MissingValueError, value: value
    end
  end
end
