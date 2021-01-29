defmodule LinkedMapTest do
  use ExUnit.Case
  alias LinkedMap.Node
  doctest LinkedMap

  test "creating a new map" do
    assert LinkedMap.new() == %LinkedMap{head: nil, tail: nil, items: %{}}
  end

  test "adding to an empty map" do
    result = LinkedMap.new() |> LinkedMap.add("a")

    assert result.head == "a"
    assert result.tail == "a"
    assert Map.keys(result.items) == ["a"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == nil
  end

  test "adding to a single item map" do
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

  test "adding to a N item map" do
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

  test "removing from an empty map" do
    map = LinkedMap.new()
    result = map |> LinkedMap.remove("foo")

    assert result == map
  end

  test "removing a non-existent item" do
    map = LinkedMap.new() |> LinkedMap.add("a")
    result = map |> LinkedMap.remove("foo")

    assert result == map
  end

  test "removing the only item" do
    map = LinkedMap.new() |> LinkedMap.add("a")
    result = map |> LinkedMap.remove("a")

    assert result == LinkedMap.new()
  end

  test "removing the first of two items" do
    map = LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.add("b")
    result = map |> LinkedMap.remove("a")

    assert result.head == "b"
    assert result.tail == "b"
    assert Map.keys(result.items) == ["b"]
    assert result.items["b"].previous == nil
    assert result.items["b"].next == nil
  end

  test "removing the last of two items" do
    map = LinkedMap.new() |> LinkedMap.add("a") |> LinkedMap.add("b")
    result = map |> LinkedMap.remove("b")

    assert result.head == "a"
    assert result.tail == "a"
    assert Map.keys(result.items) == ["a"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == nil
  end

  test "removing the first of N items" do
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

  test "removing the last of N items" do
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

  test "removing a random of N items" do
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
end
