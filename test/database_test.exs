defmodule Haveibeenpwned.Database.Test do
  use ExUnit.Case

  alias Haveibeenpwned.Database

  def decode_binary_record(bytes) do
    <<sha::binary-size(20), count::32>> = bytes
    sha_str = Base.encode16(sha, case: :upper)
    {sha_str, count}
  end

  describe "Haveibeenpwned.Database.read_entry/2" do
    test "reads an entry from the database" do
      {:ok, bytes} = Database.read_entry(1)
      {sha_str, count} = decode_binary_record(bytes)
      assert "04053A7B8A6957822A1A10641C094AF04ADC071E" == sha_str
      assert 187 = count

      {:ok, bytes} = Database.read_entry(2)
      {sha_str, count} = decode_binary_record(bytes)
      assert "11AEE249173E887D331B1878080C2BF8D59CC430" == sha_str
      assert 2 == count

      {:ok, bytes} = Database.read_entry(3)
      {sha_str, count} = decode_binary_record(bytes)
      assert "2DB18E1D98E7AB7F49DEA56027312C2D97B1A2E0" == sha_str
      assert 342 == count
    end
  end

  describe "Haveibeenpwned.Database.password_pwned?/1" do
    test "returns a warning tuple when the password has been pwned" do
      assert {:warning, 127} == Database.password_pwned?("first")
      assert {:warning, 9} == Database.password_pwned?("second")
      assert {:warning, 522} == Database.password_pwned?("third")
      assert {:warning, 342} == Database.password_pwned?("fourth")
      assert {:warning, 1} == Database.password_pwned?("fifth")
      assert {:warning, 187} == Database.password_pwned?("sixth")
      assert {:warning, 2} == Database.password_pwned?("seventh")
      assert {:warning, 823} == Database.password_pwned?("eighth")
      assert {:warning, 248} == Database.password_pwned?("ninth")
      assert {:warning, 122} == Database.password_pwned?("tenth")
    end

    test "returns an ok tuple when the password has not been pwned" do
      assert {:ok, "eleventh"} == Database.password_pwned?("eleventh")
      assert {:ok, "90309jkfkk@#F2ko23fk"} = Database.password_pwned?("90309jkfkk@#F2ko23fk")
    end
  end

  describe "Haveibeenpwned.Database.hash_binary/1" do
    test "hashes the supplied binary" do
      expected = :crypto.hash(:sha, "1234")
      assert ^expected = Database.hash_binary("1234")
    end

    test "raises an ArgumentError when the argument supplied is not a binary" do
      assert_raise ArgumentError, "supplied argument must be a valid binary", fn ->
        Database.hash_binary(:foo)
      end
    end
  end
end
