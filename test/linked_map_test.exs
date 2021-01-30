defmodule LinkedMapTest do
  use ExUnit.Case
  alias LinkedMap.Node
  doctest LinkedMap

  test "new/0" do
    assert LinkedMap.new() == %LinkedMap{head: nil, tail: nil, items: %{}}
  end

  test "add/2 with an empty map" do
    result = LinkedMap.new() |> LinkedMap.add("a")

    assert result.head == "a"
    assert result.tail == "a"
    assert Map.keys(result.items) == ["a"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == nil
  end

  test "add/2 with a single item map" do
    map = LinkedMap.new() |> LinkedMap.add("a")
    result = map |> LinkedMap.add("b")

    assert result.head == "a"
    assert result.tail == "b"
    assert Map.keys(result.items) == ["a", "b"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == "b"
    assert result.items["b"].previous == "a"
    assert result.items["b"].next == nil
  end

  test "add/2 with a N item map" do
    map = LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.add("b")
    result = map |> LinkedMap.add("c")

    assert result.head == "a"
    assert result.tail == "c"
    assert Map.keys(result.items) == ["a", "b", "c"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == "b"
    assert result.items["b"].previous == "a"
    assert result.items["b"].next == "c"
    assert result.items["c"].previous == "b"
    assert result.items["c"].next == nil
  end

  test "add_new/2 with a new item" do
    map = LinkedMap.new() |> LinkedMap.add("a")
    result = map |> LinkedMap.add_new("b")

    assert Map.keys(result.items) == ["a", "b"]
  end

  test "add_new/2 with an existing item" do
    map = LinkedMap.new() |> LinkedMap.add("a")
    result = map |> LinkedMap.add_new("a")

    assert Map.keys(result.items) == ["a"]
  end

  test "add_new!/2 with a new item" do
    map = LinkedMap.new() |> LinkedMap.add("a")
    result = map |> LinkedMap.add_new!("b")

    assert Map.keys(result.items) == ["a", "b"]
  end

  test "add_new!/2 with an existing item" do
    map = LinkedMap.new() |> LinkedMap.add("a")
    message = ~s(value "a" is already present)

    assert_raise LinkedMap.DuplicateValueError, message, fn ->
      LinkedMap.add_new!(map, "a")
    end
  end

  test "remove/2 with an empty map" do
    map = LinkedMap.new()
    result = map |> LinkedMap.remove("foo")

    assert result == map
  end

  test "remove/2 with a non-existent item" do
    map = LinkedMap.new() |> LinkedMap.add("a")
    result = map |> LinkedMap.remove("foo")

    assert result == map
  end

  test "remove/2 with the only item" do
    map = LinkedMap.new() |> LinkedMap.add("a")
    result = map |> LinkedMap.remove("a")

    assert result == LinkedMap.new()
  end

  test "remove/2 with the first of two items" do
    map = LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.add("b")
    result = map |> LinkedMap.remove("a")

    assert result.head == "b"
    assert result.tail == "b"
    assert Map.keys(result.items) == ["b"]
    assert result.items["b"].previous == nil
    assert result.items["b"].next == nil
  end

  test "remove/2 with the last of two items" do
    map = LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.add("b")
    result = map |> LinkedMap.remove("b")

    assert result.head == "a"
    assert result.tail == "a"
    assert Map.keys(result.items) == ["a"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == nil
  end

  test "remove/2 with the first of N items" do
    map = LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.add("b") |> LinkedMap.add("c")
    result = map |> LinkedMap.remove("a")

    assert result.head == "b"
    assert result.tail == "c"
    assert Map.keys(result.items) == ["b", "c"]
    assert result.items["b"].previous == nil
    assert result.items["b"].next == "c"
    assert result.items["c"].previous == "b"
    assert result.items["c"].next == nil
  end

  test "remove/2 with the last of N items" do
    map = LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.add("b") |> LinkedMap.add("c")
    result = map |> LinkedMap.remove("c")

    assert result.head == "a"
    assert result.tail == "b"
    assert Map.keys(result.items) == ["a", "b"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == "b"
    assert result.items["b"].previous == "a"
    assert result.items["b"].next == nil
  end

  test "remove/2 from the middle of N items" do
    map = LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.add("b") |> LinkedMap.add("c")
    result = map |> LinkedMap.remove("b")

    assert result.head == "a"
    assert result.tail == "c"
    assert Map.keys(result.items) == ["a", "c"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == "c"
    assert result.items["c"].previous == "a"
    assert result.items["c"].next == nil
  end

  test "remove!/2 with an existing item" do
    map = LinkedMap.new() |> LinkedMap.add("a")
    result = map |> LinkedMap.remove!("a")

    assert Map.keys(result.items) == []
  end

  test "remove!/2 with a non-existant item" do
    map = LinkedMap.new() |> LinkedMap.add("a")
    message = ~s(value "b" is not present)

    assert_raise LinkedMap.MissingValueError, message, fn ->
      LinkedMap.remove!(map, "b")
    end
  end
end
