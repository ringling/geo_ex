defmodule GeoEx.Mixfile do
  use Mix.Project

  def project do
    [app: :geo_ex,
     version: "0.0.1",
     elixir: "~> 0.15.1",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: []]
  end

  defp deps do
    [
      {:apex, "~>0.3.0"},
      {:exprintf, github: "parroty/exprintf"},
      {:poison, github: "devinus/poison"},
    ]

  end
end
