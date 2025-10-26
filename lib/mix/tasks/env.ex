defmodule Mix.Tasks.Env do
  @moduledoc """
    A task for generating all required `.env` files for the project
  """
  use Mix.Task

  @doc """
    Runs the `mix env` task
  """
  @impl Mix.Task
  def run(_args) do
    case verify_exists() do
      :ok ->
        Mix.shell().info("All required files exist!")
        validate_and_fix()
        Mix.shell().info("All required environment variables are set!")

      {:error, missing} ->
        generate_missing(missing)
    end
  end

  # Checks if all required files exist
  defp verify_exists() do
    Mix.shell().info("Verifying all required `.env` files exist ...")

    cond do
      !File.dir?("docker/env") -> {:error, :docker_env_dir}
      !File.exists?("docker/env/postgres.env") -> {:error, :postgres}
      !File.exists?("docker/env/pgadmin.env") -> {:error, :pgadmin}
      true -> :ok
    end
  end

  # Generates missing files and directories
  defp generate_missing(:docker_env_dir) do
    directory = "docker/env"

    log_missing_directory(directory)
    create_directory(directory)
  end

  defp generate_missing(:postgres) do
    file_path = "docker/env/postgres.env"

    log_missing_file(file_path)

    content = """
    POSTGRES_USER="postgres"
    POSTGRES_PASSWORD="postgres"
    POSTGRES_DB="app_dev"
    """

    generate_env_file(file_path, content)
  end

  defp generate_missing(:pgadmin) do
    file_path = "docker/env/pgadmin.env"

    log_missing_file(file_path)

    email =
      Mix.shell().prompt("Enter your email for pgadmin:")
      |> String.trim()

    password =
      Mix.shell().prompt("Enter your password for pgadmin:")
      |> String.trim()

    content = """
    PGADMIN_DEFAULT_EMAIL="#{email}"
    PGADMIN_DEFAULT_PASSWORD="#{password}"
    PGADMIN_CONFIG_SERVER_MODE="False" 
    """

    generate_env_file(file_path, content)
  end

  # Logs that a file is missing
  defp log_missing_file(file_path) do
    Mix.shell().info("`#{file_path}` missing!")
    Mix.shell().info("Generating `#{file_path}` ...")
  end

  # Logs that a directory is missing
  defp log_missing_directory(directory) do
    Mix.shell().info("`#{directory}` directory missing!")
    Mix.shell().info("Creating `#{directory}` ...")
  end

  # Logs that an environment variable is missing
  defp log_missing_variable(file_path, key) do
    Mix.shell().info("`#{key}` variable is missing!")
    Mix.shell().info("Appending to `#{key}` to `#{file_path}` ...")
  end

  # Creates `.env` file and writes content to it then reruns task.
  defp generate_env_file(file_path, content) do
    case File.write(file_path, content) do
      :ok ->
        Mix.shell().info("`#{file_path}` successfully created!")
        run([])

      {:error, _} ->
        Mix.shell().error("Error: failed to generate `#{file_path}`")
    end
  end

  # Creates a directory then reruns task
  defp create_directory(directory) do
    case File.mkdir(directory) do
      :ok ->
        Mix.shell().info("`#{directory}` successfully created!")
        run([])

      {:error, _} ->
        Mix.shell().error("Error: failed to create `#{directory}` directory")
    end
  end

  # Validates all required variables are set and adds any missing variables
  defp validate_and_fix() do
    Mix.shell().info("Verifying all required environment varaibales are set ...")

    validate_and_fix(:postgres)
    validate_and_fix(:pgadmin)
  end

  defp validate_and_fix(:postgres) do
    file_path = "docker/env/postgres.env"
    required = ["POSTGRES_USER", "POSTGRES_PASSWORD", "POSTGRES_DB"]

    case validate_env(file_path, required) do
      :ok ->
        nil

      {:error, "POSTGRES_USER"} ->
        key = "POSTGRES_USER"

        log_missing_variable(file_path, key)
        append_variable(file_path, key, "postgres")

      {:error, "POSTGRES_PASSWORD"} ->
        key = "POSTGRES_PASSWORD"

        log_missing_variable(file_path, key)
        append_variable(file_path, key, "postgres")

      {:error, "POSTGRES_DB"} ->
        key = "POSTGRES_DB"

        log_missing_variable(file_path, key)
        append_variable(file_path, key, "app_dev")
    end
  end

  defp validate_and_fix(:pgadmin) do
    file_path = "docker/env/pgadmin.env"
    required = ["PGADMIN_DEFAULT_EMAIL", "PGADMIN_DEFAULT_PASSWORD", "PGADMIN_CONFIG_SERVER_MODE"]

    case validate_env(file_path, required) do
      :ok ->
        nil

      {:error, "PGADMIN_DEFAULT_EMAIL"} ->
        key = "PGADMIN_DEFAULT_EMAIL"

        log_missing_variable(file_path, key)

        email =
          Mix.shell().prompt("Enter your email for pgadmin:")
          |> String.trim()

        append_variable(file_path, "PGADMIN_DEFAULT_EMAIL", email)

      {:error, "PGADMIN_DEFAULT_PASSWORD"} ->
        key = "PGADMIN_DEFAULT_PASSWORD"

        log_missing_variable(file_path, key)

        password =
          Mix.shell().prompt("Enter your password for pgadmin:")
          |> String.trim()

        append_variable(file_path, "PGADMIN_DEFAULT_PASSWORD", password)

      {:error, "PGADMIN_CONFIG_SERVER_MODE"} ->
        key = "PGADMIN_CONFIG_SERVER_MODE"

        log_missing_variable(file_path, key)
        append_variable(file_path, "PGADMIN_CONFIG_SERVER_MODE", "False")
    end
  end

  # Validate that all required variables are set in given `.env` file
  defp validate_env(file_path, required_variables) do
    case File.read(file_path) do
      {:ok, file} ->
        missing =
          Enum.filter(required_variables, fn var ->
            !String.contains?(file, var)
          end)

        case missing do
          [] ->
            :ok

          vars ->
            {:error, Enum.at(vars, 0)}
        end

      {:error, _} ->
        Mix.shell().error("Error: failed to read `#{file_path}`")
    end
  end

  # Append a environment variable to `.env` file and rerun task
  defp append_variable(file_path, key, value) do
    case File.write(file_path, "#{key}=\"#{value}\"\n", [:append]) do
      :ok ->
        Mix.shell().info("`#{key}` variable successfully appended to `#{file_path}`!")
        validate_and_fix()

      {:error, _} ->
        Mix.shell().error("Error: failed to append `#{key}` variable to `#{file_path}`")
    end
  end
end
