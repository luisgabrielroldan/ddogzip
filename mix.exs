defmodule DDogZip.MixProject do
  use Mix.Project

  def project do
    [
      app: :ddogzip,
      version: version(),
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      dialyzer: [flags: ["-Wunmatched_returns", :error_handling, :underspecs]],
      deps: deps(),
      releases: releases()
    ]
  end

  def version do
    File.read!("version.txt") |> String.trim()
  end

  def releases do
    [
      ddogzip: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DDogZip.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:bandit, "~> 1.0"},
      {:plug, "~> 1.15"},
      {:msgpax, "~> 2.2.1 or ~> 2.3"},
      {:httpoison, "~> 0.13 or ~> 1.0 or ~> 2.0"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
