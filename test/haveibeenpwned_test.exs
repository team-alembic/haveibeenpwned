defmodule Haveibeenpwned.Database.Test do
  use ExUnit.Case

  alias Haveibeenpwned.Database

  describe "Haveibeenpwned.read_database_portion/2" do
    test "reads the specified portion of the hash database" do
      assert "1234" == Database.read_database_portion(5, 10)
    end
  end
end
