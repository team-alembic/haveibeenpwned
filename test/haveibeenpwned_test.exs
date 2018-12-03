defmodule Haveibeenpwned.Database.Test do
  use ExUnit.Case

  alias Haveibeenpwned.Database

  describe "Haveibeenpwned.read_database_portion/2" do
    test "reads the specified portion of the hash database" do
      assert "0005AD76BD" == Database.read_portion(5, 10)
      assert ":004" == Database.read_portion(40, 4)
    end

    test "returns offset up to EOF if offset extends beyond EOF" do
      assert "54D43:040\n" == Database.read_portion(440, 100)
    end

    test "returns an error tuple when offset is at or beyond EOF" do
      assert {:error, :eof} = Database.read_portion(600, 1)
    end
  end
end
