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

  describe "Haveibeenpwned.Database.IO.read_entry/1" do
    test "reads and entry of a specific offset and length" do
      {:ok, bytes} = IO.read_entry(1)
      assert <<4, 5, 58, 123, 138, 105, 87, 130, 42, 26, 0, 0, 0, 187>> == bytes
      {sha_str, count} = decode_binary_record(bytes)
      assert "04053A7B8A6957822A1A" == sha_str
      assert 187 = count

      {:ok, bytes} = IO.read_entry(2)
      assert <<17, 174, 226, 73, 23, 62, 136, 125, 51, 27, 0, 0, 0, 2>> == bytes
      {sha_str, count} = decode_binary_record(bytes)
      assert "11AEE249173E887D331B" == sha_str
      assert 2 == count
    end
  end

  describe "Haveibeenpwned.Database.IO.entry_count/0" do
    test "get entry count" do
      assert IO.entry_count() == 10
    end
  end

  def decode_binary_record(bytes) do
    <<sha::binary-size(10), count::32>> = bytes
    sha_str = Base.encode16(sha, case: :upper)
    {sha_str, count}
  end
end
