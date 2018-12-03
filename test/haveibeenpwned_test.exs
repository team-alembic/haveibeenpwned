defmodule Haveibeenpwned.Database.Test do
  use ExUnit.Case

  alias Haveibeenpwned.Database

  describe "Haveibeenpwned.read_database_portion/2" do
    test "reads the specified portion of the hash database" do
      assert "0005AD76BD" == Database.read_portion(5, 10)
      assert ":004" == Database.read_portion(40, 4)
    end
  end
end
