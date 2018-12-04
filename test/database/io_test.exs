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
      {:ok, pid} = IO.init(:foo)
      assert Process.alive?(pid)
    end
  end

  describe "Haveibeenpwned.Database.IO.handle_call/3" do
    test "reads and entry of a specific offset and length" do
      {:ok, bytes} = GenServer.call(IO, {:read_entry, 4})
      assert "34FB3300B9A77BEBDC988EC3EDD0D4A6A42A26F9:522" == bytes
      {:ok, bytes} = GenServer.call(IO, {:read_entry, 9})
      assert "E0996A37C13D44C3B06074939D43FA3759BD32C1:127" == bytes
    end

    test "allows retrieval of the database file process" do
      pid = GenServer.call(IO, :database_handle)
      assert Process.alive?(pid)
    end
  end
end
