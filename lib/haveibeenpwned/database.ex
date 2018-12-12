defmodule Haveibeenpwned.Database do
  @moduledoc """
  Context for performing hash database read operations
  """
  alias Haveibeenpwned.Database.IO

  @doc """
  Reads the specified portion of the haveibeenpwned hash database, beginning
  from `offset` and continuing up to the length of an entry
  """
  def read_entry(number) when is_integer(number) do
    GenServer.call(IO, {:read_entry, number})
  end

  @doc """
  Return the entry count
  """
  def entry_count do
    GenServer.call(IO, :entry_count)
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
    password_pwned?({0, entry_count()}, subject, original)
  end

  defp password_pwned?({first, last}, subject, original) when last - first == 0 do
    {:ok, <<sha::binary-size(20), count::32>>} = read_entry(first)

    if subject == sha do
      {:warning, count}
    else
      {:ok, original}
    end
  end

  defp password_pwned?({first, last}, subject, original) when last - first == 1 do
    {:ok, <<sha::binary-size(20), count::32>>} = read_entry(last)

    if subject == sha do
      {:warning, count}
    else
      password_pwned?({first, first}, subject, original)
    end
  end

  defp password_pwned?({first, last}, subject, original) do
    middle = first + round((last - first) / 2)
    {:ok, <<sha::binary-size(20), count::32>>} = read_entry(middle)

    cond do
      subject == sha -> {:warning, count}
      subject > sha -> password_pwned?({middle, last}, subject, original)
      subject < sha -> password_pwned?({first, middle}, subject, original)
    end
  end

  @doc """
  Hashes the supplied binary and returns it as a readable Base16 string
  """
  def hash_binary(binary) when is_binary(binary) do
    :crypto.hash(:sha, binary)
  end

  def hash_binary(_), do: raise(ArgumentError, "supplied argument must be a valid binary")

  @doc """
  Ingest txt file into binary format
  """
  def ingest_file(input_txt_path, output_binary_path) do
    dest_stream = File.stream!(output_binary_path, [{:delayed_write, 10_000_000, 60}])

    input_txt_path
    |> File.stream!
    |> Stream.map(&format_line(&1))
    |> Stream.into(dest_stream)
    |> Stream.run()
  end

  defp format_line(line) do
    pattern = :binary.compile_pattern(["\n", ":"])
    [sha_str, count_str] = String.split(line, pattern, trim: true)
    {:ok, bin_sha} = Base.decode16(sha_str)
    {count_num, _} = Integer.parse(count_str)
    bin_count = <<count_num::32>>
    bin_sha <> bin_count
  end
end
