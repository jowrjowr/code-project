defmodule QuestionMachine.MixProject do
  use Mix.Project

  def project do
    [
      app: :question_machine,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {QuestionMachine.Application, []}
    ]
  end

  # Please only use the standard library
  defp deps do
    [
      {:uuid, "~> 1.1"}
    ]
  end
end
