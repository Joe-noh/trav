defmodule Trav.Mixfile do
  use Mix.Project

  def project do
    [app: :trav,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Trav, []},
      applications: [
        :phoenix, :cowboy, :logger, :gettext,
        :phoenix_ecto, :postgrex, :extwitter
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(:dev),  do: ["lib", "web", "mocks"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.1.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_ecto, "~> 3.0.0-beta.2"},
      {:gettext, "~> 0.9"},
      {:cowboy, "~> 1.0"},

      {:extwitter, "~> 0.7"},
      {:oauth, github: "tim/erlang-oauth"},
      {:joken, "~> 1.1"},
      {:cors_plug, "~> 1.1"},

      {:ex_machina, "~> 0.6.1", only: :test},
      {:mock, "~> 0.1", only: :test}
    ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
