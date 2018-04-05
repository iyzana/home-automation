defmodule HomeAutomation.Mixfile do
  use Mix.Project

  def project do
    [
      app: :home_automation,
      version: "0.1.0",
      elixir: "~> 1.6",
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
      {:cowboy, "~> 2.2.2"},
      {:plug, "~> 1.5.0"},
      {:timex, "~> 3.2.1"},
      {:httpotion, "~> 3.1.0"},
      {:poison, "~> 3.1"},
      {:lifx, "~> 0.1.8"},
    ]
  end
end
