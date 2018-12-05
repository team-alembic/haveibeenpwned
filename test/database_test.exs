defmodule Haveibeenpwned.Database.Test do
  use ExUnit.Case

  alias Haveibeenpwned.Database

  describe "Haveibeenpwned.Database.read_entry/2" do
    test "reads an entry from the database" do
      {:ok, bytes} = Database.read_entry(1)
      assert "04053A7B8A6957822A1A10641C094AF04ADC071E:187" == bytes
      {:ok, bytes} = Database.read_entry(8)
      assert "DD5D5862925F1F953CAB0DBA448B6B14E371BF53:823" == bytes
    end
  end

  describe "Haveibeenpwned.Database.password_pwned?/1" do
    test "returns a warning tuple when the password has been pwned" do
      assert {:warning, 342} == Database.password_pwned?("fourth")
    end

    test "returns an ok tuple when the password has not been pwned" do
      assert {:ok, "eleventh"} == Database.password_pwned?("eleventh")
    end
  end

  describe "Haveibeenpwned.Database.hash_binary/1" do
    test "hashes the supplied binary" do
      expected = :crypto.hash(:sha, "1234") |> Base.encode16()
      assert ^expected = Database.hash_binary("1234")
    end

    test "raises an ArgumentError when the argument supplied is not a binary" do
      assert_raise ArgumentError, "supplied argument must be a valid binary", fn ->
        Database.hash_binary(:foo)
      end
    end
  end
end
