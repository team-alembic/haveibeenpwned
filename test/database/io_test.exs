defmodule Haveibeenpwned.Database.IOTest do
  use ExUnit.Case, async: true

  alias Haveibeenpwned.Database.IO

  describe "Haveibeenpwned.Database.IO.start_link/0" do
    test "starts a named GenServer" do
      server = Process.whereis(IO)
      assert Process.alive?(server)
    end
  end

  describe "Haveibeenpwned.Database.IO.init/1" do
    test "sets initial state to the open file handle" do
      {:ok, {pid, entry_count}} = IO.init(:foo)
      assert Process.alive?(pid)
      assert entry_count == 10
    end
  end

  describe "Haveibeenpwned.Database.IO.handle_call/3" do
    test "reads and entry of a specific offset and length" do
      {:ok, bytes} = GenServer.call(IO, {:read_entry, 1})

      assert <<4, 5, 58, 123, 138, 105, 87, 130, 42, 26, 16, 100, 28, 9, 74, 240, 74, 220, 7, 30,
               0, 0, 0, 187>> == bytes

      {:ok, bytes} = GenServer.call(IO, {:read_entry, 2})

      assert <<17, 174, 226, 73, 23, 62, 136, 125, 51, 27, 24, 120, 8, 12, 43, 248, 213, 156, 196,
               48, 0, 0, 0, 2>> == bytes
    end

    test "allows retrieval of the database file process" do
      {pid, entry_count} = GenServer.call(IO, :database_handle)
      assert Process.alive?(pid)
      assert entry_count == 10
    end

    test "get entry count" do
      entry_count = GenServer.call(IO, :entry_count)
      assert entry_count == 10
    end
  end
end
