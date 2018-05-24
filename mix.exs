defmodule HomeAutomation.Mixfile do
  use Mix.Project

  def project do
    [
      app: :home_automation,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpotion],
      mod: {HomeAutomation, []},
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:sweet_xml, "~> 0.6.5"},
      {:wakeonlan, "~> 0.1.0"},
      {:cowboy, "~> 2.4"},
      {:plug, "~> 1.5"},
      {:timex, "~> 3.3"},
      {:quantum, "~> 2.2"},
      {:httpotion, "~> 3.1"},
      {:poison, "~> 3.1"},
      {:lifx, github: "rosetta-home/lifx", ref: "083a2951556560dca96b629a1d0a8bd826a49bf2"},
    ]
  end
end
