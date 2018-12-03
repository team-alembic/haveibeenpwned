defmodule Haveibeenpwned.Database.Doorman do
  @moduledoc """
  A GenServer which keeps the SHA database open for access. State is the file
  handle
  """
  use GenServer

  @database_relative_path Application.get_env(:haveibeenpwned, :database_relative_path)
  @database_path Application.app_dir(:haveibeenpwned, @database_relative_path)

  @doc """
  Start the GenServer with a registered name
  """
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  @doc """
  Start the GenServer, saving state as the file handle
  """
  def init(_) do
    :file.open(@database_path, [:binary, :read])
  end

  @impl true
  @doc """
  Allow outside processes to fetch the file handle
  """
  def handle_call(:file_handle, _from, state), do: {:reply, state, state}

  @impl true
  @doc """
  Close the file handle when server is shutting down
  """
  def terminate(_reason, state) do
    :file.close(state)
  end
end
