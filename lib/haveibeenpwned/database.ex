defmodule Haveibeenpwned.Database do
  @moduledoc """
  Context for performing hash database read operations
  """
  alias Haveibeenpwned.Database.IO
  require Logger

  @database_entry_count 10
  @database_entry_length 44

  @doc """
  Reads the specified portion of the haveibeenpwned hash database, beginning
  from `offset` and continuing up to the length of an entry
  """
  def read_entry(number) when is_integer(number) do
    GenServer.call(IO, {:read_entry, number})
  end

  @doc """
  Searches the Haveibeenpwned database for matching hashes via a binary search.
  If the supplied password is compromised, returns a `{:warning, count}` tuple.
  If it is not compromised, returns an `{:ok, password}` tuple.
  """
  def password_pwned?(password) when is_binary(password) do
    password |> hash_binary() |> password_pwned?(password)
  end

  def password_pwned?(_) do
    raise(ArgumentError, "supplied password must be a valid binary")
  end

  defp password_pwned?(subject, original) do
    Logger.info(subject)
    password_pwned?({0, @database_entry_count}, subject, original)
  end

  defp password_pwned?({st, ed}, _subject, original) when ed - st == 0 do
    {:ok, original}
  end

  defp password_pwned?({st, ed}, _subject, original) when ed - st == 1 do
    {:ok, original}
  end

  defp password_pwned?({st, ed}, subject, original) do
    middle_index = st + round((ed - st) / 2)
    Logger.info("#{st} #{middle_index} #{ed}")
    {:ok, <<hash::bytes-size(40)>> <> ":" <> count} = read_entry(middle_index)

    cond do
      subject > hash -> password_pwned?({middle_index, ed}, subject, original)
      subject < hash -> password_pwned?({st, middle_index}, subject, original)
      subject == hash -> {:warning, String.to_integer(count)}
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
