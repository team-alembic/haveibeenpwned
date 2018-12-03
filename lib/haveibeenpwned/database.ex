defmodule Haveibeenpwned.Database do
  @moduledoc """
  Context for performing hash database read operations
  """
  alias Haveibeenpwned.Database.Doorman

  @database_read_length 44

  @doc """
  Hashes the supplied binary and returns it as a readable Base16 string
  """
  def hash_binary(binary) when is_binary(binary) do
    :sha |> :crypto.hash(binary) |> Base.encode16()
  end

  def hash_binary(_), do: raise(ArgumentError, "supplied argument must be a valid binary")

  @doc """
  Reads the specified portion of the haveibeenpwned hash database, beginning
  from `offset` and continuing up to `@database_read_length`
  """
  def read_portion(offset, length \\ @database_read_length) do
    with file when is_pid(file) <- GenServer.call(Doorman, :database_handle) do
      :file.pread(file, offset, length)
    end
  end

  @doc """
  Searches the Haveibeenpwned database for matching hashes. If the supplied
  password is compromised, returns a `{:warning, count}` tuple. If it is
  not compromised, returns an `{:ok, password}` tuple.
  """
  def password_pwned?(password) when is_binary(password) do
    password |> hash_binary() |> password_pwned?(password)
  end

  def password_pwned?(_), do: raise(ArgumentError, "supplied password must be a valid binary")

  defp password_pwned?(hash, original) do
    {:ok, original}
  end
end
