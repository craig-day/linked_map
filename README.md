# LinkedMap

A LinkedMap is a order-aware collection with the following properties:

  - A `head` pointer
  - A `tail` pointer
  - A collection of `items` that can be added to, removed from, and traversed
    in either direction

I built this to have a collection I can traverse in either direction, but also
be able to remove items in less-than-linear time. I also didn't want something
that needed to be sorted or rebalanced after each addition or removal.

This uses Elixir's [`Map`](https://hexdocs.pm/elixir/Map.html) underneath, so
removing arbitrary items can happen in logarithmic time, rather than linear
time that most sorted collections incur.

## Installation

Add `linked_map` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:linked_map, "~> 0.1.0"}
  ]
end
```
