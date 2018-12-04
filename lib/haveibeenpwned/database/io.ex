defmodule Haveibeenpwned.Database.IO do
  @moduledoc """
  A GenServer which keeps the SHA database open for access. State is the file
  handle
  """
  use GenServer

  @database_relative_path Application.get_env(:haveibeenpwned, :database_relative_path)
  @database_path Application.app_dir(:haveibeenpwned, @database_relative_path)

  @database_entry_length 44

  @doc """
  Start the GenServer with a registered name
  """
  def start_link do
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
  Reads a portion from the database
  """
  def handle_call({:read_entry, entry_number}, _from, state) when is_integer(entry_number) do
    offset = entry_number_offset(entry_number)
    entry = read_bytes(state, offset, @database_entry_length)
    {:reply, entry, state}
  end

  @impl true
  @doc """
  Allow outside processes to fetch the file handle
  """
  def handle_call(:database_handle, _from, state), do: {:reply, state, state}

  @impl true
  @doc """
  Close the file handle when server is shutting down
  """
  def terminate(_reason, state) do
    :file.close(state)
  end

  defp entry_number_offset(entry_number) when is_integer(entry_number) do
    entry_number = entry_number - 1
    @database_entry_length * entry_number + entry_number
  end

  defp read_bytes(file, offset, length) when is_pid(file) do
    :file.pread(file, offset, length)
  end
end
