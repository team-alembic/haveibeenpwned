defmodule Haveibeenpwned.Database do
  @moduledoc """
  Context for performing hash database read operations
  """
  alias Haveibeenpwned.Database.IO

  @database_entry_count 10

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
    password_pwned?({0, @database_entry_count}, subject, original)
  end

  defp password_pwned?({start, ed}, subject, original) when ed - start == 0 do
    {:ok, <<sha::bytes-size(40), _colon::bytes-size(1), count::binary>>} = read_entry(start)

    if subject == sha do
      {:warning, String.to_integer(count)}
    else
      {:ok, original}
    end
  end

  defp password_pwned?({start, ed}, subject, original) when ed - start == 1 do
    {:ok, <<sha::bytes-size(40), _colon::bytes-size(1), count::binary>>} = read_entry(ed)

    if subject == sha do
      {:warning, String.to_integer(count)}
    else
      password_pwned?({start, start}, subject, original)
    end
  end

  defp password_pwned?({start, ed}, subject, original) do
    middle = start + round((ed - start) / 2)
    {:ok, <<sha::bytes-size(40), _colon::bytes-size(1), count::binary>>} = read_entry(middle)

    cond do
      subject == sha -> {:warning, String.to_integer(count)}
      subject > sha -> password_pwned?({middle, ed}, subject, original)
      subject < sha -> password_pwned?({start, middle}, subject, original)
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
