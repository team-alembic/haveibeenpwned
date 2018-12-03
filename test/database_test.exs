defmodule Haveibeenpwned.Database.Test do
  use ExUnit.Case

  alias Haveibeenpwned.Database

  describe "Haveibeenpwned.hash_binary/1" do
    test "hashes the given binary and returns the resultant SHA hash as a human readable Base 16 binary" do
      assert "7110EDA4D09E062AA5E4A390B0A572AC0D2C0220" == Database.hash_binary("1234")
    end

    test "raises an ArgumentError when supplied argument is not a binary" do
      assert_raise ArgumentError, "supplied argument must be a valid binary", fn ->
        Database.hash_binary(1234)
      end
    end
  end

  describe "Haveibeenpwned.read_database_portion/2" do
    test "reads the specified portion of the hash database" do
      assert {:ok, "A7B8A69578"} == Database.read_portion(5, 10)
      assert {:ok, ":187"} == Database.read_portion(40, 4)
    end

    test "returns offset up to EOF if offset extends beyond EOF" do
      assert {:ok, "AC03E:122\n"} == Database.read_portion(440, 100)
    end

    test "returns an error tuple when offset is at or beyond EOF" do
      assert :eof == Database.read_portion(600, 1)
    end
  end
end
