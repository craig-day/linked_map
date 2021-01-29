defmodule LinkedMap.MixProject do
  use Mix.Project

  def project do
    [
      name: "LinkedMap",
      app: :linked_map,
      version: "0.1.0",
      elixir: "~> 1.0",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      source_url: "https://github.com/craig-day/linked_map",
      homepage_url: "https://github.com/craig-day/linked_map",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    An ordered datastructure with head and tail pointers and logarithmic add/remove time.
    """
  end

  defp package do
    [
      name: "linked_map",
      licenses: ["MIT"],
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG*),
      links: %{"GitHub" => "https://github.com/craig-day/linked_map"}
    ]
  end

  defp docs do
    [
      main: "LinkedMap",
      extras: ["README.md"]
    ]
  end
end
