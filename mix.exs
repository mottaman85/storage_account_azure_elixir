defmodule StorageAccountAzure.MixProject do
  use Mix.Project

  def project do
    [
      app: :storage_account_azure,
      version: "0.1.0",
      elixir: "~> 1.9",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      name: :storage_account_azure,
      files: ["lib", "mix.exs", "LICENSE", "README.md"],
      mantainers: ["paulino"],
      license: ["MIT"],
      links: %{"GitHub" => ""}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, ">= 1.4.0"},
      {:elixir_xml_to_map, ">= 0.1.2"},
      {:mime, ">= 1.3.0"},
      {:jason, ">= 1.1.0"},
      {:joken, ">= 2.0.0"},
      {:ex_doc, ">= 0.19.1", only: :dev, runtime: false},
      {:timex, ">= 3.2.0"}
    ]
  end
end
