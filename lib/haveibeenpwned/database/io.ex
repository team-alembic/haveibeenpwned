defmodule Haveibeenpwned.Database.IO do
  @moduledoc """
  A GenServer which keeps the SHA database open for access. State is the file
  handle
  """
  use GenServer

  @database_relative_path Application.get_env(:haveibeenpwned, :database_relative_path)
  @database_path Application.app_dir(:haveibeenpwned, @database_relative_path)

  @database_entry_length 24

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
    {:ok, file} = :file.open(@database_path, [:binary, :read])
    {:ok, file_info} = :file.read_file_info(@database_path)
    entry_count = Kernel.trunc(elem(file_info, 1) / @database_entry_length)
    {:ok, {file, entry_count}}
  end

  @impl true
  @doc """
  Reads a portion from the database
  """
  def handle_call({:read_entry, entry_number}, _from, {file, entry_count})
      when is_integer(entry_number) do
    offset = entry_number_offset(entry_number)
    entry = read_bytes(file, offset, @database_entry_length)
    {:reply, entry, {file, entry_count}}
  end

  @impl true
  @doc """
  Allow outside processes to fetch the file handle
  """
  def handle_call(:database_handle, _from, state), do: {:reply, state, state}

  @impl true
  @doc """
  Return entry_count
  """
  def handle_call(:entry_count, _from, {file, entry_count}),
    do: {:reply, entry_count, {file, entry_count}}

  @impl true
  @doc """
  Close the file handle when server is shutting down
  """
  def terminate(_reason, {file, _records_num}) do
    :file.close(file)
  end

  defp entry_number_offset(entry_number) when is_integer(entry_number) do
    @database_entry_length * (entry_number - 1)
  end

  defp read_bytes(file, offset, length) when is_pid(file) do
    :file.pread(file, offset, length)
  end
end
