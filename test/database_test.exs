defmodule Haveibeenpwned.Database.Test do
  use ExUnit.Case

  alias Haveibeenpwned.Database

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
end
