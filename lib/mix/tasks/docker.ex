defmodule Mix.Tasks.Docker do
  @moduledoc """
    A task to run docker compose if not already running
  """
  use Mix.Task

  @doc """
    Runs the `mix docker` task
  """
  @impl Mix.Task
  def run(_args) do
    if !docker_running?() do
      Mix.shell().info("Starting Docker ...")

      case System.cmd("docker", ["compose", "up", "-d"]) do
        {_, 0} -> Mix.shell().info("\nSuccessfully started Docker!")
        {_, 1} -> Mix.shell().error("\nError: failed to start Docker")
      end

      Process.sleep(3000)
    end
  end

  defp docker_running?() do
    {output, _} = System.cmd("docker", ["ps"])

    String.contains?(output, "postgres")
  end
end
