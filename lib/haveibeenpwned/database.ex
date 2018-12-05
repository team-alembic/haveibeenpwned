defmodule Haveibeenpwned.Database do
  @moduledoc """
  Context for performing hash database read operations
  """
  alias Haveibeenpwned.Database.IO

  require Logger

  @database_entry_count 10

  @doc """
  Reads the specified portion of the haveibeenpwned hash database, beginning
  from `offset` and continuing up to the length of an entry
  """
  def read_entry(number) when is_integer(number)  do
    GenServer.call(IO, {:read_entry, number})
  end

  @doc """
  Searches the Haveibeenpwned database for matching hashes via a binary search.
  If the supplied password is compromised, returns a `{:warning, count}` tuple.
  If it is not compromised, returns an `{:ok, password}` tuple.
  """
  def password_pwned?(password) when is_binary(password) do
    password |> hash_binary() |> password_pwned?(password, round(@database_entry_count / 2))
  end

  def password_pwned?(_) do
    raise(ArgumentError, "supplied password must be a valid binary")
  end

  defp password_pwned?(subject, original, index) when is_integer(index) do
    {:ok, <<sha::bytes-size(40), _colon::bytes-size(1), count::binary>>} = read_entry(index)

    cond do
      sha == subject -> {:warning, String.to_integer(count)}
      index == 1 -> {:ok, original}
      index == @database_entry_count -> {:ok, original}
      subject < sha -> password_pwned?(subject, original, round(index / 2))
      subject > sha -> password_pwned?(subject, original, round((index + @database_entry_count) / 2))
    end
  end

  @doc """
  Hashes the supplied binary and returns it as a readable Base16 string
  """
  def hash_binary(binary) when is_binary(binary) do
    :sha |> :crypto.hash(binary) |> Base.encode16()
  end

  def hash_binary(_), do: raise(ArgumentError, "supplied argument must be a valid binary")
end
