defmodule Haveibeenpwned.Database.IO do
  @moduledoc false

  use GenServer

  @database_relative_path Application.get_env(:haveibeenpwned, :database_relative_path)
  @database_path Application.app_dir(:haveibeenpwned, @database_relative_path)

  @database_entry_length 14

  ### Client API

  @doc """
  Start the GenServer with a registered name
  """
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Reads the specified portion of the haveibeenpwned hash database, beginning
  from `offset` and continuing up to the length of an entry
  """
  def read_entry(entry_number), do: GenServer.call(__MODULE__, {:read_entry, entry_number})

  @doc """
  Return the entry count
  """
  def entry_count, do: GenServer.call(__MODULE__, :entry_count)

  ### GenServer API

  @doc """
  Start the GenServer, saving state as the file handle
  """
  def init(_) do
    {:ok, file} = :file.open(@database_path, [:binary, :read])
    {:ok, file_info} = :file.read_file_info(@database_path)
    entry_count = Kernel.trunc(elem(file_info, 1) / @database_entry_length)
    {:ok, {file, entry_count}}
  end

  @doc """
  Reads a portion from the database
  """
  def handle_call({:read_entry, entry_number}, _from, {file, entry_count})
      when is_integer(entry_number) do
    offset = entry_number_offset(entry_number)
    entry = read_bytes(file, offset, @database_entry_length)
    {:reply, entry, {file, entry_count}}
  end

  @doc """
  Return entry_count
  """
  def handle_call(:entry_count, _from, {file, entry_count}),
    do: {:reply, entry_count, {file, entry_count}}

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
