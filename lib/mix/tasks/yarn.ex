defmodule Mix.Tasks.Yarn do
  @moduledoc """
    A task that will run the yarn command in the assets directory.
    All args passed to the command will also be passed down to yarn command.

    # Example
    `mix yarn add -D sass` will run `cd assets && yarn add -D sass`
  """
  use Mix.Task

  @doc """
    Runs the `mix yarn` task
  """
  @impl Mix.Task
  def run(args) do
    command = "cd assets && yarn " <> Enum.join(args, " ")

    Mix.shell().cmd(command)
  end
end
